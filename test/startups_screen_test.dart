import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  /// Amène un contrôle de la barre de filtres dans la zone visible : sur un
  /// écran étroit, les sélecteurs défilent horizontalement.
  Future<void> revealFilter(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
  }

  /// Ouvre le menu des catégories et coche la catégorie demandée.
  Future<void> pickCategory(WidgetTester tester, String categorie) async {
    final bouton = find.byTooltip('Filtrer par catégorie');
    await revealFilter(tester, bouton);
    await tester.tap(bouton);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(CheckboxMenuButton, categorie));
    await tester.pumpAndSettle();
    // Le menu reste ouvert (multi-sélection) : Échap le referme.
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
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
    // Compteurs : 2 actives (Alpha, Beta), 1 sortie (Gamma) — Delta, sans
    // catégorie, appartient à l'onglet Blast et n'est pas comptée ici.
    expect(find.text('2 actives · 1 sortie · 0 radiée'), findsOneWidget);

    // Sous-onglet Liste.
    await tester.tap(find.text('Liste'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Startups (3)'), findsOneWidget);
    expect(find.text('Nom'), findsOneWidget);

    // Filtre catégorie (menu à cases à cocher) : il ne reste qu'Europe.
    await pickCategory(tester, 'Europe Multi-Stage');
    expect(find.text('Startups (1)'), findsOneWidget);
    // Le bouton résume la sélection courante.
    expect(find.text('Europe Multi-Stage'), findsWidgets);

    // Réinitialisation.
    await tester.tap(find.text('Réinitialiser'));
    await tester.pumpAndSettle();
    expect(find.text('Startups (3)'), findsOneWidget);

    // Filtre année : seules les lignes datées 2022 restent.
    final annee = find.text('Toutes les années');
    await revealFilter(tester, annee);
    await tester.tap(annee);
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
    // les onglets étant désormais en haut, c'est le premier « Sorties »).
    await tester.tap(find.text('Sorties').first);
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
    // Le montant apparaît dans le KPI et dans la ligne « Total » du tableau
    // par catégorie (sa colonne « Frais »).
    expect(find.text('Frais total'), findsOneWidget);
    expect(find.text(formatEuro(25)), findsWidgets);

    // Le KPI suit le filtre de catégorie (12 + 8).
    await pickCategory(tester, 'Licornes pre-IPO');
    expect(find.text(formatEuro(20)), findsWidgets);

    await tester.tap(find.text('Réinitialiser'));
    await tester.pumpAndSettle();
    expect(find.text(formatEuro(25)), findsWidgets);

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
    expect(find.text(formatEuro(5)), findsWidgets);

    // Effacement de la recherche via la croix. Le RenderBox de l'icône est un
    // proxy (non testé au hit-test) : on désactive l'avertissement du testeur,
    // le résultat est vérifié juste après.
    expect(find.byTooltip('Effacer la recherche'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.close), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.text(formatEuro(25)), findsWidgets);
    await tester.tap(find.text('Liste'));
    await tester.pumpAndSettle();
    expect(find.text('Startups (3)'), findsOneWidget);

    // Une recherche sans résultat affiche l'état vide.
    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pumpAndSettle();
    expect(
      find.text('Aucune startup ne correspond aux filtres ou à la recherche.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('onglets principaux en haut : ordre, Startup et Blast', (
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

    // Plus de barre de navigation basse : les onglets sont sous l'AppBar.
    expect(find.byType(NavigationBar), findsNothing);
    const labels = [
      'Tableau de bord',
      'Immobilier',
      'Bourse et Crypto',
      'Startup',
      'Blast',
      'Blast Market',
      'Analyse',
      'Autres',
    ];
    for (final label in labels) {
      expect(find.text(label), findsOneWidget, reason: 'onglet $label absent');
    }
    // Ordre horizontal des libellés.
    for (var i = 1; i < labels.length; i++) {
      expect(
        tester.getTopLeft(find.text(labels[i - 1])).dx,
        lessThan(tester.getTopLeft(find.text(labels[i])).dx),
      );
    }

    // La barre est défilable : on amène l'onglet dans la vue avant d'appuyer.
    Future<void> tapTab(String label) async {
      final finder = find.text(label);
      await tester.ensureVisible(finder);
      await tester.pumpAndSettle();
      await tester.tap(finder);
      await tester.pumpAndSettle();
    }

    // Onglet Startup : uniquement les startups catégorisées.
    await tapTab('Startup');
    expect(tester.takeException(), isNull);
    expect(find.text('Capital investi'), findsOneWidget);
    await tester.tap(find.text('Liste'));
    await tester.pumpAndSettle();
    expect(find.text('Startups (3)'), findsOneWidget);
    expect(find.text('Delta'), findsNothing);

    // Onglet Blast : la startup sans catégorie.
    await tapTab('Blast');
    expect(tester.takeException(), isNull);
    expect(find.text('Blast (1)'), findsOneWidget);
    expect(find.text('Delta'), findsOneWidget);
    expect(find.text('Alpha'), findsNothing);
  });

  testWidgets('les startups sans catégorie sont exclues de l\'onglet Startup', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    Future<void> add(String name, String? categorie) async {
      final id = await db.addAsset(
        AssetsCompanion.insert(name: name, type: 'startup'),
      );
      await db.saveStartupDetails(
        StartupDraft(
          categorie: categorie,
          quantite: 10,
          prixEntree: 5,
          prixActuel: 6,
        ).toCompanion(id),
      );
    }

    await add('Catégorisée', 'Licornes pre-IPO');
    await add('Blanche', '   ');
    await add('SansCategorie', null);

    await pumpScreen(tester);
    await tester.tap(find.text('Liste'));
    await tester.pumpAndSettle();

    expect(find.text('Startups (1)'), findsOneWidget);
    expect(find.text('Catégorisée'), findsOneWidget);
    expect(find.text('Blanche'), findsNothing);
    expect(find.text('SansCategorie'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('aucune startup catégorisée : renvoi vers l\'onglet Blast', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final id = await db.addAsset(
      AssetsCompanion.insert(name: 'BlastOnly', type: 'startup'),
    );
    await db.saveStartupDetails(
      const StartupDraft(quantite: 10, prixEntree: 5).toCompanion(id),
    );

    await pumpScreen(tester);

    expect(find.text('Aucune startup catégorisée'), findsOneWidget);
    expect(find.textContaining('onglet Blast'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('colonne « Frais » dans la synthèse par catégorie', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await seed();
    await pumpScreen(tester);

    // En-tête de colonne du tableau (le KPI s'appelle « Frais total »).
    expect(find.text('Frais'), findsOneWidget);
    final inTable = find.descendant(
      of: find.byType(DataTable),
      matching: find.text(formatEuro(20)),
    );
    // Frais de la catégorie Licornes : 12 + 8.
    expect(inTable, findsOneWidget);
    // Frais d'Europe Multi-Stage : 5 (une seule ligne du tableau).
    expect(
      find.descendant(
        of: find.byType(DataTable),
        matching: find.text(formatEuro(5)),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('blocs réordonnables : onglets en haut, ordre persisté', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await seed();
    await pumpScreen(tester);

    // Ordre par défaut : sélecteur d'onglets avant la carte des filtres.
    expect(
      tester.getTopLeft(find.text('Synthèse')).dy,
      lessThan(tester.getTopLeft(find.text('Filtres')).dy),
    );
    // Les deux blocs exposent une poignée de glisser-déposer.
    expect(find.byIcon(Icons.drag_indicator), findsNWidgets(2));

    // Réordonnancement (équivalent du glisser-déposer) : filtres puis onglets.
    await tester.runAsync(
      () => controller.reorderStartupBlocks(const ['filters', 'tabs']),
    );
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(find.text('Filtres')).dy,
      lessThan(tester.getTopLeft(find.text('Synthèse')).dy),
    );

    // L'ordre est écrit en base et rechargé par un nouveau contrôleur.
    expect(await db.preferenceValue(startupBlockOrderKey), 'filters,tabs');
    final reloaded = PortfolioController(db);
    await tester.runAsync(reloaded.load);
    expect(reloaded.startupBlockOrder, ['filters', 'tabs']);
    expect(tester.takeException(), isNull);
  });

  test('parseStartupBlockOrder : ordre robuste', () {
    expect(parseStartupBlockOrder(null), ['tabs', 'filters']);
    expect(parseStartupBlockOrder('  '), ['tabs', 'filters']);
    expect(parseStartupBlockOrder('tabs,filters'), ['tabs', 'filters']);
    expect(parseStartupBlockOrder('filters,tabs'), ['filters', 'tabs']);
    // Doublons et identifiants inconnus ignorés, blocs manquants ajoutés.
    expect(parseStartupBlockOrder('tabs,tabs,inconnu'), ['tabs', 'filters']);
    expect(parseStartupBlockOrder('filters'), ['filters', 'tabs']);
  });

  testWidgets('glisser-déposer : les onglets passent sous les filtres', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await seed();
    await pumpScreen(tester);

    // Poignée du bloc d'onglets (premier de l'écran) : en la faisant glisser
    // vers le bas, le bloc passe sous la carte des filtres. Le seuil de
    // permutation dépend de la hauteur du bloc survolé (≈ sa moitié).
    final handle = find.byIcon(Icons.drag_indicator).first;
    final gesture = await tester.startGesture(tester.getCenter(handle));
    await tester.pump(const Duration(milliseconds: 100));
    for (var i = 0; i < 30; i++) {
      await gesture.moveBy(const Offset(0, 20));
      await tester.pump(const Duration(milliseconds: 20));
    }
    await gesture.up();
    await tester.pumpAndSettle();

    expect(controller.startupBlockOrder, ['filters', 'tabs']);
    expect(
      tester.getTopLeft(find.text('Filtres')).dy,
      lessThan(tester.getTopLeft(find.text('Synthèse')).dy),
    );
    expect(tester.takeException(), isNull);
  });
}
