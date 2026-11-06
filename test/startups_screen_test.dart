import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrimoine/controllers/portfolio_controller.dart';
import 'package:patrimoine/data/database.dart';
import 'package:patrimoine/models/startup.dart';
import 'package:patrimoine/theme/app_theme.dart';
import 'package:patrimoine/ui/screens/home_screen.dart';
import 'package:patrimoine/ui/screens/startups_screen.dart';
import 'package:patrimoine/utils/format.dart';
import 'package:provider/provider.dart';

void main() {
  late AppDatabase db;
  late PortfolioController controller;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    controller = PortfolioController(db);
  });

  tearDown(() => db.close());

  Future<void> seed() async {
    Future<int> add(String name, StartupDraft draft) async {
      final id = await db.addAsset(
        AssetsCompanion.insert(name: name, type: 'startup'),
      );
      await db.saveStartupDetails(draft.toCompanion(id));
      return id;
    }

    await add(
      'Alpha',
      StartupDraft(
        categorie: 'Licornes pre-IPO',
        quantite: 100,
        prixEntree: 10,
        prixActuel: 30,
        frais: 12,
        dateInvestissement: DateTime(2020, 1, 1),
      ),
    );
    await add(
      'Beta',
      StartupDraft(
        categorie: 'Licornes pre-IPO',
        quantite: 100,
        prixEntree: 10,
        prixActuel: 10,
        frais: 8,
        dateInvestissement: DateTime(2022, 1, 1),
      ),
    );
    await add(
      'Gamma',
      StartupDraft(
        categorie: 'Europe Multi-Stage',
        quantite: 100,
        prixEntree: 10,
        frais: 5,
        statut: 'sorti',
        exitProduit: 2500,
        dateInvestissement: DateTime(2020, 1, 1),
        exitDate: DateTime(2023, 1, 1),
        exitMode: 'acquisition',
      ),
    );
    await add(
      'Delta',
      StartupDraft(
        categorie: '',
        quantite: 50,
        prixEntree: 10,
        statut: 'radie',
      ),
    );
  }

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.runAsync(() => controller.load());
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: MaterialApp(
          theme: buildDarkTheme(),
          home: const Scaffold(body: StartupsScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('synthèse, filtres et liste sans débordement en 360 dp', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await seed();

    await pumpScreen(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('Capital investi'), findsOneWidget);
    expect(find.text('Valorisation totale'), findsOneWidget);
    expect(find.text('Multiple MOIC'), findsOneWidget);
    expect(find.text('Répartition par catégorie'), findsOneWidget);
    expect(find.text('Par catégorie'), findsOneWidget);
    expect(find.text('Top 5 par valorisation'), findsOneWidget);
    // Compteurs : 2 actives (Alpha, Beta), 1 sortie (Gamma), 1 radiée (Delta).
    expect(find.text('2 actives · 1 sortie · 1 radiée'), findsOneWidget);

    // Sous-onglet Liste.
    await tester.tap(find.text('Liste'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Startups (4)'), findsOneWidget);
    expect(find.text('Nom'), findsOneWidget);

    // Filtre catégorie : il ne reste qu'Europe Multi-Stage.
    await tester.tap(
      find.widgetWithText(FilterChip, 'Europe Multi-Stage').first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Startups (1)'), findsOneWidget);

    // Réinitialisation.
    await tester.tap(find.text('Réinitialiser'));
    await tester.pumpAndSettle();
    expect(find.text('Startups (4)'), findsOneWidget);

    // Filtre année : seules les lignes datées 2022 restent.
    await tester.tap(find.text('Toutes les années'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2022').last);
    await tester.pumpAndSettle();
    expect(find.text('Startups (1)'), findsOneWidget);
    await tester.tap(find.text('Réinitialiser'));
    await tester.pumpAndSettle();

    // Tri sur l'en-tête « Nom » : ordre croissant puis décroissant.
    await tester.tap(find.text('Nom'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(
      tester.getTopLeft(find.text('Alpha')).dy <
          tester.getTopLeft(find.text('Beta')).dy,
      isTrue,
    );
    await tester.tap(find.text('Nom'));
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(find.text('Beta')).dy <
          tester.getTopLeft(find.text('Alpha')).dy,
      isTrue,
    );

    // Sous-onglet Sorties (le libellé du filtre de statut porte le même nom :
    // le dernier « Sorties » est celui du sélecteur de section).
    await tester.tap(find.text('Sorties').last);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Sorties (1)'), findsOneWidget);
    expect(find.text('Acquisition'), findsNothing);
    expect(find.textContaining('Acquisition'), findsOneWidget);
  });

  testWidgets('aucune startup : message d\'invitation', (tester) async {
    tester.view.physicalSize = const Size(360, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await pumpScreen(tester);

    expect(tester.takeException(), isNull);
    expect(
      find.text('Ajoutez une startup pour voir ce dashboard'),
      findsOneWidget,
    );
  });

  testWidgets('KPI « Frais total » et recherche par nom', (tester) async {
    tester.view.physicalSize = const Size(360, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await seed();
    await pumpScreen(tester);

    // Somme des frais du périmètre complet : 12 + 8 + 5 + 0.
    expect(find.text('Frais total'), findsOneWidget);
    expect(find.text(formatEuro(25)), findsOneWidget);

    // Le KPI suit le filtre de catégorie (12 + 8).
    await tester.tap(find.widgetWithText(FilterChip, 'Licornes pre-IPO').first);
    await tester.pumpAndSettle();
    expect(find.text(formatEuro(20)), findsOneWidget);

    await tester.tap(find.text('Réinitialiser'));
    await tester.pumpAndSettle();
    expect(find.text(formatEuro(25)), findsOneWidget);

    // Recherche sur le sous-onglet Liste : casse et accents ignorés.
    await tester.tap(find.text('Liste'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'GAM');
    await tester.pumpAndSettle();
    expect(find.text('Startups (1)'), findsOneWidget);
    expect(find.text('Gamma'), findsOneWidget);
    expect(find.text('Alpha'), findsNothing);

    await tester.enterText(find.byType(TextField), 'gämma');
    await tester.pumpAndSettle();
    expect(find.text('Gamma'), findsOneWidget);

    // Le KPI Frais total suit aussi la recherche (Gamma : 5 €).
    await tester.tap(find.text('Synthèse'));
    await tester.pumpAndSettle();
    expect(find.text(formatEuro(5)), findsOneWidget);

    // Effacement de la recherche via la croix.
    await tester.tap(find.byTooltip('Effacer la recherche'));
    await tester.pumpAndSettle();
    expect(find.text(formatEuro(25)), findsOneWidget);
    await tester.tap(find.text('Liste'));
    await tester.pumpAndSettle();
    expect(find.text('Startups (4)'), findsOneWidget);

    // Une recherche sans résultat affiche l'état vide.
    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pumpAndSettle();
    expect(
      find.text('Aucune startup ne correspond aux filtres ou à la recherche.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('« Startups » est la 3e destination de la barre de navigation', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await seed();
    await tester.runAsync(() => controller.load());

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: MaterialApp(theme: buildDarkTheme(), home: const HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NavigationDestination), findsNWidgets(4));
    final destinations = tester
        .widgetList<NavigationDestination>(find.byType(NavigationDestination))
        .map((d) => d.label)
        .toList();
    expect(destinations, ['Tableau de bord', 'Actifs', 'Startups', 'Analyses']);

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Startups'),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Capital investi'), findsOneWidget);
  });
}
