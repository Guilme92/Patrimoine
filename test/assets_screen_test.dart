import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrimoine/controllers/portfolio_controller.dart';
import 'package:patrimoine/data/database.dart';
import 'package:patrimoine/models/asset_type.dart';
import 'package:patrimoine/theme/app_theme.dart';
import 'package:patrimoine/ui/screens/assets_screen.dart';
import 'package:provider/provider.dart';

void main() {
  late AppDatabase db;
  late PortfolioController controller;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    controller = PortfolioController(db);
  });

  tearDown(() => db.close());

  Future<void> pumpScreen(
    WidgetTester tester, {
    Widget screen = const AssetsScreen(),
  }) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: MaterialApp(
          theme: buildDarkTheme(),
          home: Scaffold(body: screen),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> seed(WidgetTester tester) async {
    await db.addAsset(
      AssetsCompanion.insert(
        name: 'Livret A',
        type: 'cash',
        value: const Value(5000),
        sortOrder: Value(await db.nextAssetSortOrder()),
      ),
    );
    await db.addAsset(
      AssetsCompanion.insert(
        name: 'Bitcoin',
        type: 'crypto',
        value: const Value(3000),
        sortOrder: Value(await db.nextAssetSortOrder()),
      ),
    );
    await db.addAsset(
      AssetsCompanion.insert(
        name: 'PEA',
        type: 'investment',
        value: const Value(20000),
        sortOrder: Value(await db.nextAssetSortOrder()),
      ),
    );
    await tester.runAsync(() => controller.load());
  }

  testWidgets('le filtre par catégorie masque les autres actifs', (
    tester,
  ) async {
    await seed(tester);
    await pumpScreen(tester);

    expect(find.text('Livret A'), findsOneWidget);
    expect(find.text('Bitcoin'), findsOneWidget);
    expect(find.text('PEA'), findsOneWidget);

    // Coche la catégorie Crypto.
    await tester.tap(find.widgetWithText(FilterChip, 'Crypto'));
    await tester.pumpAndSettle();

    expect(find.text('Bitcoin'), findsOneWidget);
    expect(find.text('Livret A'), findsNothing);
    expect(find.text('PEA'), findsNothing);

    // Multi-sélection : ajoute les liquidités.
    await tester.tap(find.widgetWithText(FilterChip, 'Liquidités'));
    await tester.pumpAndSettle();
    expect(find.text('Livret A'), findsOneWidget);
    expect(find.text('Bitcoin'), findsOneWidget);
    expect(find.text('PEA'), findsNothing);

    // « Tous » réinitialise.
    await tester.tap(find.widgetWithText(FilterChip, 'Tous'));
    await tester.pumpAndSettle();
    expect(find.text('PEA'), findsOneWidget);
  });

  testWidgets('le paramètre types restreint les actifs et masque les chips', (
    tester,
  ) async {
    await seed(tester);

    // Onglet « Bourse et Crypto » : PEA + Bitcoin, pas les liquidités.
    await pumpScreen(
      tester,
      screen: const AssetsScreen(
        types: {AssetType.investment, AssetType.crypto},
      ),
    );
    expect(find.text('PEA'), findsOneWidget);
    expect(find.text('Bitcoin'), findsOneWidget);
    expect(find.text('Livret A'), findsNothing);
    // Aucun FilterChip de type dans un onglet restreint.
    expect(find.byType(FilterChip), findsNothing);

    // Onglet « Immobilier » : aucun actif de ce type.
    await pumpScreen(
      tester,
      screen: const AssetsScreen(types: {AssetType.realEstate}),
    );
    expect(find.text('Aucun actif dans cet onglet'), findsOneWidget);
    expect(find.text('Livret A'), findsNothing);
  });

  testWidgets(
    'supprimer une catégorie demande confirmation puis vide le type',
    (tester) async {
      await seed(tester);
      await pumpScreen(
        tester,
        screen: const AssetsScreen(
          types: {AssetType.cash, AssetType.other, AssetType.loan},
        ),
      );

      expect(find.text('Livret A'), findsOneWidget);

      await tester.tap(find.byTooltip('Supprimer une catégorie'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Supprimer Liquidités'));
      await tester.pumpAndSettle();

      // Confirmation explicite.
      expect(find.text('Supprimer « Liquidités » ?'), findsOneWidget);
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();
      expect(controller.assets.map((a) => a.name), contains('Livret A'));

      await tester.tap(find.byTooltip('Supprimer une catégorie'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Supprimer Liquidités'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Supprimer'));
      await tester.pumpAndSettle();

      expect(controller.assets.map((a) => a.name), isNot(contains('Livret A')));
      expect(controller.assets.where((a) => a.type == 'cash'), isEmpty);
      expect(find.text('Aucun actif dans cet onglet'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
