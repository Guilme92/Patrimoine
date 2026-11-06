import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrimoine/controllers/portfolio_controller.dart';
import 'package:patrimoine/data/database.dart';
import 'package:patrimoine/models/startup.dart';
import 'package:patrimoine/theme/app_theme.dart';
import 'package:patrimoine/ui/screens/asset_detail_screen.dart';
import 'package:patrimoine/utils/format.dart';
import 'package:provider/provider.dart';

void _useTallViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(900, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void main() {
  late AppDatabase db;
  late PortfolioController controller;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    controller = PortfolioController(db);
  });

  tearDown(() => db.close());

  testWidgets('détail d\'une startup : KPIs, info-bulles et levées', (
    tester,
  ) async {
    _useTallViewport(tester);
    final id = await db.addAsset(
      AssetsCompanion.insert(
        name: 'Qonto',
        type: 'startup',
        value: const Value(0),
      ),
    );
    await db.saveStartupDetails(
      const StartupDraft(
        typeTitre: 'actions',
        categorie: 'Europe Multi-Stage',
        quantite: 100,
        prixEntree: 10,
        frais: 50,
        stade: 'serie_b',
        prixActuel: 25,
      ).toCompanion(id),
    );
    await db.addFundingRound(
      FundingRoundDraft(
        date: DateTime(2024, 6, 1),
        montantLeve: 3000000,
        valorisationPostMoney: 50000000,
        prixParAction: 12.5,
      ).toCompanion(id),
    );
    await tester.runAsync(() => controller.load());

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: MaterialApp(
          theme: buildDarkTheme(),
          home: AssetDetailScreen(asset: controller.assetById(id)!),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Startup'), findsOneWidget);
    expect(find.text('Capital investi'), findsOneWidget);
    expect(find.text('Valorisation'), findsWidgets);
    expect(find.text('PV latente'), findsOneWidget);
    expect(find.text('Multiple (MOIC)'), findsOneWidget);
    expect(find.text('TRI annualisé'), findsOneWidget);
    // La catégorie de la fiche startup est affichée.
    expect(find.text('Catégorie'), findsOneWidget);
    expect(find.text('Europe Multi-Stage'), findsOneWidget);
    // MOIC = 2500 / 1050 = 2.38×
    expect(find.text('2.38×'), findsOneWidget);
    // La valorisation calculée (100 × 25 €) remplace la valeur manuelle.
    expect(find.text(formatEuro(2500)), findsNWidgets(2));
    expect(find.text('Levées de fonds'), findsOneWidget);
    expect(find.text('Levée du 01/06/2024'), findsOneWidget);
    expect(find.text('Montant levé'), findsOneWidget);
    // Les KPI portent des info-bulles explicatives.
    expect(find.byIcon(Icons.info_outline), findsWidgets);

    // La section Location ne s'affiche pas pour une startup.
    expect(find.text('Location'), findsNothing);
  });

  testWidgets('une startup sans fiche affiche les formulaires vides', (
    tester,
  ) async {
    _useTallViewport(tester);
    final id = await db.addAsset(
      AssetsCompanion.insert(name: 'Mistral AI', type: 'startup'),
    );
    await tester.runAsync(() => controller.load());

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: MaterialApp(
          theme: buildDarkTheme(),
          home: AssetDetailScreen(asset: controller.assetById(id)!),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Startup'), findsOneWidget);
    expect(find.text('Renseigner'), findsOneWidget);
    expect(find.text('Capital investi'), findsNothing);
    expect(find.text('Renseignez d\'abord la fiche startup pour suivre ses '
        'levées de fonds.'), findsOneWidget);
  });
}
