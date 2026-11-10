import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:patrimoine/app.dart';
import 'package:patrimoine/controllers/portfolio_controller.dart';
import 'package:patrimoine/data/database.dart';
import 'package:patrimoine/theme/app_theme.dart';
import 'package:patrimoine/ui/screens/home_screen.dart';
import 'package:patrimoine/ui/widgets/asset_tile.dart';
import 'package:patrimoine/ui/widgets/settings_sheet.dart';
import 'package:patrimoine/utils/format.dart';

Asset _asset(String type, {double value = 0, String name = 'Bien test'}) =>
    Asset(
      id: 1,
      name: name,
      type: type,
      value: value,
      currency: 'EUR',
      institution: null,
      note: null,
      sortOrder: 0,
      createdAt: DateTime(2026),
    );

Rental _rental() => Rental(
  id: 1,
  assetId: 1,
  statut: 'loue',
  typeBail: 'vide',
  locataire: 'M. Dupont',
  loyerHc: 900,
  chargesLocatives: 50,
  depotGarantie: 1800,
  dateDebutBail: DateTime(2025),
  dateFinBail: null,
  modeGestion: 'direct',
  fraisGestion: 60,
  taxeFonciere: 1200,
  assurancePno: 240,
  chargesCopropriete: 600,
  travauxEntretien: 300,
  vacanceLocative: 0,
  note: null,
  aUnCredit: true,
  montantCredit: 180000,
  tauxCreditPct: 2.5,
  mensualiteCredit: 700,
  dureeCreditMois: 180,
  capitalRestantDu: 120000,
  assuranceEmprunteur: 30,
  createdAt: DateTime(2026),
);

Position _position() => Position(
  id: 1,
  assetId: 1,
  symbol: 'AAPL',
  name: 'Apple',
  quantity: 10,
  unitCost: 100,
  assetClass: null,
  sector: null,
  region: null,
  fees: 0,
  createdAt: DateTime(2026),
);

Widget _rentedTile() => AssetTile(
  asset: _asset('realEstate', value: 200000),
  positions: const [],
  prices: const {},
  rental: _rental(),
);

Widget _positionTile() => AssetTile(
  asset: _asset('investment', name: 'Compte-titres'),
  positions: [_position()],
  prices: const {'AAPL': 150.0},
);

void main() {
  late AppDatabase db;
  late PortfolioController controller;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    controller = PortfolioController(db);
  });

  tearDown(() => db.close());

  Widget wrap(Widget child) =>
      ChangeNotifierProvider<PortfolioController>.value(
        value: controller,
        child: MaterialApp(
          theme: buildDarkTheme(),
          home: Scaffold(body: SingleChildScrollView(child: child)),
        ),
      );

  group('PortfolioController.fontScale', () {
    test('borne l’échelle entre 0,85 et 1,5 et la persiste', () async {
      expect(controller.fontScale, 1.0);

      await controller.setFontScale(2.0);
      expect(controller.fontScale, fontScaleMax);
      expect(await db.preferenceValue(fontScaleKey), '1.5');

      await controller.setFontScale(0.2);
      expect(controller.fontScale, fontScaleMin);
      expect(await db.preferenceValue(fontScaleKey), '0.85');
    });

    test('n’écrit rien quand l’échelle est inchangée', () async {
      // Témoin : si `setFontScale` réécrivait la préférence, il disparaîtrait.
      await db.setPreference(fontScaleKey, 'témoin');
      await controller.setFontScale(1.0);
      expect(await db.preferenceValue(fontScaleKey), 'témoin');
    });

    test('load restaure l’échelle persistée, bornée', () async {
      await db.setPreference(fontScaleKey, '1.3');
      await controller.load();
      expect(controller.fontScale, 1.3);

      await db.setPreference(fontScaleKey, '4.2');
      await controller.load();
      expect(controller.fontScale, fontScaleMax);
    });
  });

  testWidgets('la feuille Réglages affiche et applique la taille de police', (
    tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<PortfolioController>.value(
        value: controller,
        child: MaterialApp(
          theme: buildDarkTheme(),
          home: const Scaffold(body: SettingsSheet()),
        ),
      ),
    );

    expect(find.text('Réglages'), findsOneWidget);
    expect(find.text('Taille de police'), findsOneWidget);
    expect(find.text('100 %'), findsOneWidget);
    expect(tester.widget<Slider>(find.byType(Slider)).value, 1.0);

    await tester.runAsync(() => controller.setFontScale(1.25));
    await tester.pump();

    expect(find.text('125 %'), findsOneWidget);
    expect(tester.widget<Slider>(find.byType(Slider)).value, 1.25);
  });

  testWidgets('les cellules compactes suivent l’échelle de police', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(_rentedTile()));
    final base = tester
        .widget<Text>(find.text(formatEuro(900)))
        .style!
        .fontSize!;
    expect(base, greaterThan(0));

    await tester.runAsync(() => controller.setFontScale(1.4));
    await tester.pump();

    final grown = tester
        .widget<Text>(find.text(formatEuro(900)))
        .style!
        .fontSize!;
    expect(grown, closeTo(base * 1.4, 0.01));

    // Positions : les tailles codées en dur y sont aussi multipliées.
    await tester.pumpWidget(wrap(_positionTile()));
    final qtySize = tester
        .widget<Text>(find.text(formatQty(10)))
        .style!
        .fontSize!;
    expect(qtySize, closeTo(12 * 1.4, 0.01));
  });

  testWidgets('l’engrenage de l’AppBar ouvre la feuille de réglages', (
    tester,
  ) async {
    await tester.runAsync(() => controller.load());
    await tester.pumpWidget(
      ChangeNotifierProvider<PortfolioController>.value(
        value: controller,
        child: MaterialApp(
          theme: buildDarkTheme(),
          home: const HomeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Réglages'));
    await tester.pumpAndSettle();

    expect(find.text('Taille de police'), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);
  });

  testWidgets('PatrimoineApp applique l’échelle à tout le texte de l’app', (
    tester,
  ) async {
    final appDb = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(appDb.close);

    await tester.pumpWidget(PatrimoineApp(db: appDb));
    await tester.pump();

    final element = tester.element(find.text('Patrimoine'));
    final controller = Provider.of<PortfolioController>(element, listen: false);
    final before = MediaQuery.textScalerOf(element).scale(10);

    await tester.runAsync(() => controller.setFontScale(1.5));
    await tester.pump();

    final after = MediaQuery.textScalerOf(
      tester.element(find.text('Patrimoine')),
    ).scale(10);
    // La barre de titre de Material plafonne son échelle (1.34) : on vérifie
    // seulement que le `textScaler` global a bien suivi le réglage.
    expect(after, greaterThan(before));
  });

  testWidgets('à 360 dp et police agrandie : aucune exception de rendu', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrap(_rentedTile()));
    await tester.runAsync(() => controller.setFontScale(fontScaleMax));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Loyer'), findsOneWidget);
    expect(
      tester.getTopRight(find.byType(AssetTile)).dx,
      lessThanOrEqualTo(360),
    );

    await tester.pumpWidget(wrap(_positionTile()));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Cours'), findsOneWidget);
    expect(
      tester.getTopRight(find.byType(AssetTile)).dx,
      lessThanOrEqualTo(360),
    );
  });
}
