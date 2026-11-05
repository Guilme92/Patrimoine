import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrimoine/controllers/portfolio_controller.dart';
import 'package:patrimoine/data/database.dart';
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

  /// L'app cible Windows : les poignées de drag par défaut n'apparaissent
  /// que sur les plateformes desktop.
  Future<void> onWindows(Future<void> Function() body) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    try {
      await body();
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  }

  Future<void> pumpScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: MaterialApp(
          theme: buildDarkTheme(),
          home: const Scaffold(body: AssetsScreen()),
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

  testWidgets('le mode « Ordre manuel » suit sortOrder et le réordonnancement', (
    tester,
  ) async {
    await onWindows(() async {
      await seed(tester);
      await pumpScreen(tester);

      await tester.tap(find.text('Ordre manuel'));
      await tester.pumpAndSettle();

      expect(find.byType(ReorderableListView), findsOneWidget);
      // Poignées de drag par défaut (utilisables à la souris sur Windows).
      expect(find.byIcon(Icons.drag_handle), findsWidgets);

      final before = controller.assets.map((a) => a.name).toList();
      expect(before, ['Livret A', 'Bitcoin', 'PEA']);

      // Réordonne puis recharge : l'écran suit allAssets() (sortOrder).
      final ids = controller.assets.map((a) => a.id).toList();
      await tester.runAsync(
        () => controller.reorderAssets([ids[2], ids[0], ids[1]]),
      );
      await tester.pumpAndSettle();

      expect(controller.assets.map((a) => a.name).toList(), [
        'PEA',
        'Livret A',
        'Bitcoin',
      ]);
      expect(
        tester.getTopLeft(find.text('PEA')).dy,
        lessThan(tester.getTopLeft(find.text('Livret A')).dy),
      );

      // Retour au groupement par type : en-têtes de catégorie visibles.
      await tester.tap(find.text('Par type'));
      await tester.pumpAndSettle();
      expect(find.byType(ReorderableListView), findsNothing);
      expect(find.text('Investissements'), findsWidgets);
    });
  });

  testWidgets('un glisser-déposer réordonne réellement en base', (
    tester,
  ) async {
    await seed(tester);
    await pumpScreen(tester);
    await tester.tap(find.text('Ordre manuel'));
    await tester.pumpAndSettle();

    // Saisit la première ligne et la descend de deux rangs.
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Livret A')),
    );
    await tester.pump(const Duration(milliseconds: 600));
    for (var i = 0; i < 12; i++) {
      await gesture.moveBy(const Offset(0, 12));
      await tester.pump(const Duration(milliseconds: 20));
    }
    await gesture.up();
    await tester.pumpAndSettle();

    expect(controller.assets.map((a) => a.name).toList(), [
      'Bitcoin',
      'PEA',
      'Livret A',
    ]);
  });
}
