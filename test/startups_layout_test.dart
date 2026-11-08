import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrimoine/controllers/portfolio_controller.dart';
import 'package:patrimoine/data/database.dart';
import 'package:patrimoine/models/startup.dart';
import 'package:patrimoine/theme/app_theme.dart';
import 'package:patrimoine/ui/screens/startups_screen.dart';
import 'package:provider/provider.dart';

/// Disposition de l'onglet Synthèse : « Répartition par catégorie » et
/// « Valorisation par année d'investissement » côte à côte sur écran large,
/// empilées sur écran étroit.
void main() {
  late AppDatabase db;
  late PortfolioController controller;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    controller = PortfolioController(db);
  });

  tearDown(() => db.close());

  Future<void> seed() async {
    Future<void> add(String name, StartupDraft draft) async {
      final id = await db.addAsset(
        AssetsCompanion.insert(name: name, type: 'startup'),
      );
      await db.saveStartupDetails(draft.toCompanion(id));
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
        categorie: 'Europe Multi-Stage',
        quantite: 100,
        prixEntree: 10,
        prixActuel: 10,
        frais: 8,
        dateInvestissement: DateTime(2022, 1, 1),
      ),
    );
  }

  Future<void> pumpScreen(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
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

  testWidgets('écran large : les deux cartes partagent la même ligne', (
    tester,
  ) async {
    await seed();
    await pumpScreen(tester, const Size(1000, 3000));

    expect(tester.takeException(), isNull);
    final donut = tester.getRect(find.text('Répartition par catégorie'));
    final bars = tester.getRect(
      find.text("Valorisation par année d'investissement"),
    );
    // Même ligne : les deux en-têtes sont alignés en haut.
    expect((donut.top - bars.top).abs(), lessThan(1));
    // Deux colonnes : la seconde commence après la première.
    expect(bars.left, greaterThan(donut.right));
  });

  testWidgets('écran étroit : les deux cartes sont empilées', (tester) async {
    await seed();
    await pumpScreen(tester, const Size(360, 3000));

    expect(tester.takeException(), isNull);
    final donut = tester.getRect(find.text('Répartition par catégorie'));
    final bars = tester.getRect(
      find.text("Valorisation par année d'investissement"),
    );
    // Empilement : même colonne, l'une sous l'autre.
    expect(bars.top, greaterThan(donut.bottom));
    expect((donut.left - bars.left).abs(), lessThan(1));
  });
}
