import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrimoine/controllers/portfolio_controller.dart';
import 'package:patrimoine/data/database.dart';
import 'package:patrimoine/models/asset_type.dart';
import 'package:patrimoine/theme/app_theme.dart';
import 'package:patrimoine/ui/widgets/net_worth_chart.dart';
import 'package:patrimoine/utils/format.dart';

void main() {
  late AppDatabase db;
  late PortfolioController controller;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    controller = PortfolioController(db);
  });

  tearDown(() => db.close());

  Future<void> seedAsset({
    required String name,
    required double value,
    String type = 'cash',
    int order = 1,
  }) => db.addAsset(
    AssetsCompanion.insert(
      name: name,
      type: type,
      value: Value(value),
      sortOrder: Value(order),
    ),
  );

  Future<void> seedSnapshot(DateTime date, double netWorth) =>
      db.into(db.snapshots).insert(
        SnapshotsCompanion.insert(date: date, netWorth: netWorth),
      );

  group('snapshots quotidiens', () {
    test('load() enregistre un premier point avec le patrimoine net', () async {
      await seedAsset(name: 'Livret A', value: 5000, order: 1);
      await seedAsset(name: 'Crédit', value: 2000, type: 'loan', order: 2);

      await controller.load();

      expect(controller.snapshots, hasLength(1));
      expect(controller.snapshots.single.netWorth, 3000);
      expect(controller.summary.netWorth, 3000);
    });

    test('un second load() le même jour ne crée pas de doublon', () async {
      await seedAsset(name: 'Livret A', value: 5000);
      await controller.load();
      expect(controller.snapshots, hasLength(1));

      // La valeur change, mais le point du jour est déjà pris.
      await controller.updateAssetValue(controller.assets.single.id, 9000);
      expect(controller.snapshots, hasLength(1));
      expect(controller.snapshots.single.netWorth, 5000);

      await controller.load();
      expect(controller.snapshots, hasLength(1));
      expect(await db.allSnapshots(), hasLength(1));
    });

    test('chaque nouvelle journée ajoute un point', () async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      await seedSnapshot(yesterday, 4000);
      await seedAsset(name: 'Livret A', value: 5200);

      await controller.load();

      expect(controller.snapshots, hasLength(2));
      expect(controller.snapshots.first.netWorth, 4000);
      expect(controller.snapshots.last.netWorth, 5200);
      expect(
        controller.snapshots.first.date.isBefore(
          controller.snapshots.last.date,
        ),
        isTrue,
      );
    });

    test('un point du jour déjà en base bloque le nouveau', () async {
      await seedSnapshot(DateTime.now(), 1234);
      await seedAsset(name: 'Livret A', value: 9000);

      await controller.load();

      expect(controller.snapshots, hasLength(1));
      expect(controller.snapshots.single.netWorth, 1234);
    });

    test('les mutations du jour ne créent qu\'un seul point', () async {
      await seedAsset(name: 'Livret A', value: 5000);
      await controller.load();
      await controller.addAsset(name: 'PEA', type: AssetType.investment);
      await controller.addAsset(name: 'Or', type: AssetType.other);

      expect(controller.snapshots, hasLength(1));
      expect(await db.allSnapshots(), hasLength(1));
    });

    test('un portefeuille vide n\'enregistre aucun point', () async {
      await controller.load();
      expect(controller.snapshots, isEmpty);
      expect(await db.allSnapshots(), isEmpty);

      // Le premier actif crée le point du jour.
      await controller.addAsset(name: 'Livret A', type: AssetType.cash);
      expect(controller.snapshots, hasLength(1));
    });
  });

  group('courbe du patrimoine', () {
    NetWorthSnapshot snap(int id, DateTime date, double value) =>
        NetWorthSnapshot(id: id, date: date, netWorth: value);

    Future<void> pump(
      WidgetTester tester,
      List<NetWorthSnapshot> points,
    ) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: buildDarkTheme(),
          home: Scaffold(body: NetWorthChart(snapshots: points)),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('aucun point : rien ne s\'affiche', (tester) async {
      await pump(tester, const []);
      expect(find.text('Évolution du patrimoine'), findsNothing);
    });

    testWidgets('un seul point : valeur et message d\'attente', (tester) async {
      await pump(tester, [snap(1, DateTime(2026, 1, 1), 100000)]);
      expect(find.text('Évolution du patrimoine'), findsOneWidget);
      expect(
        find.text('La courbe se construit au fil des jours'),
        findsOneWidget,
      );
      expect(find.byType(LineChart), findsNothing);
    });

    testWidgets('deux points : variation affichée et courbe tracée', (
      tester,
    ) async {
      await pump(tester, [
        snap(1, DateTime(2026, 1, 1), 100000),
        snap(2, DateTime(2026, 1, 2), 105000),
      ]);
      final expected =
          '${formatSignedEuro(5000)} (${formatPct(5)})';
      expect(find.text(expected), findsOneWidget);
      expect(find.byType(LineChart), findsOneWidget);
      expect(
        find.text('La courbe se construit au fil des jours'),
        findsNothing,
      );
    });
  });
}
