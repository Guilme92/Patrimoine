import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrimoine/controllers/portfolio_controller.dart';
import 'package:patrimoine/data/database.dart';
import 'package:patrimoine/models/rental.dart';
import 'package:patrimoine/theme/app_theme.dart';
import 'package:patrimoine/ui/screens/asset_detail_screen.dart';
import 'package:patrimoine/ui/screens/edit_asset_screen.dart';
import 'package:provider/provider.dart';

/// Écran haut : évite de scroller pour atteindre les sections basses.
void _useTallViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1800);
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

  testWidgets('détail d\'un bien loué : location, rendement et documents', (
    tester,
  ) async {
    _useTallViewport(tester);
    final id = await db.addAsset(
      AssetsCompanion.insert(
        name: 'Appartement Lyon',
        type: 'realEstate',
        value: const Value(200000),
      ),
    );
    await db.saveRental(
      RentalDraft(
        statut: 'loue',
        typeBail: 'vide',
        locataire: 'M. Dupont',
        loyerHc: 900,
        taxeFonciere: 1200,
        aUnCredit: true,
        mensualiteCredit: 700,
      ).toCompanion(id),
    );
    await db.addDocument(
      DocumentsCompanion.insert(
        assetId: id,
        label: 'Bail signé',
        fileName: 'bail.pdf',
        filePath: '/tmp/bail.pdf',
      ),
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

    expect(find.text('Location'), findsOneWidget);
    expect(find.text('Rendement brut'), findsOneWidget);
    expect(find.text('Cashflow / mois'), findsOneWidget);
    expect(find.text('M. Dupont'), findsOneWidget);
    expect(find.text('Bail signé'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Modifier'), findsOneWidget);

    // Détail replié : les champs de charges n'apparaissent qu'après expansion.
    expect(find.text('Taxe foncière (annuelle)'), findsNothing);
    await tester.tap(find.text('Détail des charges et du crédit'));
    await tester.pumpAndSettle();
    expect(find.text('Taxe foncière (annuelle)'), findsOneWidget);
    expect(find.text('Capital restant dû'), findsOneWidget);
  });

  testWidgets('un actif non immobilier n\'affiche pas la section Location', (
    tester,
  ) async {
    _useTallViewport(tester);
    final id = await db.addAsset(
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
          home: AssetDetailScreen(asset: controller.assetById(id)!),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Location'), findsNothing);
    expect(find.text('Documents'), findsOneWidget);
  });

  testWidgets('modifier un actif met à jour la base', (tester) async {
    _useTallViewport(tester);
    final id = await db.addAsset(
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
          home: EditAssetScreen(asset: controller.assetById(id)!),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Livret Boosté');
    await tester.enterText(fields.at(1), '7500');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Enregistrer les modifications'));
    await tester.pumpAndSettle();

    final updated = await tester.runAsync(() => db.allAssets());
    expect(updated, hasLength(1));
    expect(updated!.single.name, 'Livret Boosté');
    expect(updated.single.value, 7500);
  });
}
