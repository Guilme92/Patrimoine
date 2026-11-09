import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrimoine/controllers/portfolio_controller.dart';
import 'package:patrimoine/data/database.dart';
import 'package:patrimoine/theme/app_theme.dart';
import 'package:patrimoine/ui/screens/assets_screen.dart';
import 'package:patrimoine/ui/screens/dashboard_screen.dart';
import 'package:provider/provider.dart';

void main() {
  late AppDatabase db;
  late PortfolioController controller;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    controller = PortfolioController(db);
  });

  tearDown(() => db.close());

  testWidgets('écran étroit (360 dp) : pas de débordement, menu CSV présent', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    // Un bien immobilier loué : c'est la carte la plus dense de l'app.
    final assetId = await db.addAsset(
      AssetsCompanion.insert(
        name: 'Appartement Lyon 3e',
        type: 'realEstate',
        value: const Value(200000),
      ),
    );
    await db.saveRental(
      RentalsCompanion.insert(
        assetId: assetId,
        statut: const Value('loue'),
        loyerHc: const Value(900),
        chargesLocatives: const Value(50),
        aUnCredit: const Value(true),
        mensualiteCredit: const Value(700),
      ),
    );
    await tester.runAsync(() => controller.load());
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

    expect(tester.takeException(), isNull);
    expect(find.byIcon(Icons.more_vert), findsOneWidget);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    expect(find.text('Importer CSV'), findsOneWidget);
    expect(find.text('Modèle CSV'), findsOneWidget);
  });

  testWidgets('tableau de bord : KPIs de performance, sans liste d\'actifs', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await db.addAsset(
      AssetsCompanion.insert(
        name: 'Livret A',
        type: 'cash',
        value: const Value(5000),
      ),
    );
    await tester.runAsync(() => controller.load());
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: MaterialApp(
          theme: buildDarkTheme(),
          home: const Scaffold(body: DashboardScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Évolution du patrimoine'), findsOneWidget);
    expect(
      find.text('La courbe se construit au fil des jours'),
      findsOneWidget,
    );
    expect(find.text('Capital investi'), findsOneWidget);
    expect(find.text('Plus-value latente'), findsOneWidget);
    // La liste redondante des actifs a disparu du tableau de bord.
    expect(find.text('Mes actifs'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tableau de bord 360 dp : pas de débordement au défilement', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final peaId = await db.addAsset(
      AssetsCompanion.insert(
        name: 'CTO',
        type: 'investment',
        value: const Value(0),
      ),
    );
    await db.addPosition(
      PositionsCompanion.insert(
        assetId: peaId,
        symbol: 'CW8',
        name: 'MSCI World',
        quantity: 10,
        unitCost: 400,
      ),
    );
    await db.upsertPrice('CW8', 470, 'EUR');
    final rentalId = await db.addAsset(
      AssetsCompanion.insert(
        name: 'Appartement Lyon',
        type: 'realEstate',
        value: const Value(250000),
      ),
    );
    await db.saveRental(
      RentalsCompanion.insert(
        assetId: rentalId,
        statut: const Value('loue'),
        loyerHc: const Value(1000),
        aUnCredit: const Value(true),
        mensualiteCredit: const Value(600),
      ),
    );

    await tester.runAsync(() => controller.load());
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: MaterialApp(
          theme: buildDarkTheme(),
          home: const Scaffold(body: DashboardScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Patrimoine net'), findsOneWidget);
    expect(find.text('Mes actifs'), findsNothing);

    final scrollable = find.byType(Scrollable).first;
    for (var i = 0; i < 10; i++) {
      await tester.drag(scrollable, const Offset(0, -350));
      await tester.pump();
      expect(
        tester.takeException(),
        isNull,
        reason: 'débordement pendant le défilement ($i)',
      );
    }
    expect(find.text('Revenus locatifs'), findsOneWidget);
  });
}
