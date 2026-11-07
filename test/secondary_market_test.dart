import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrimoine/controllers/portfolio_controller.dart';
import 'package:patrimoine/data/csv_import.dart';
import 'package:patrimoine/data/database.dart';
import 'package:patrimoine/models/asset_type.dart';
import 'package:patrimoine/models/startup.dart';
import 'package:patrimoine/theme/app_theme.dart';
import 'package:patrimoine/ui/screens/blast_market_screen.dart';
import 'package:provider/provider.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

/// CSV minimal : le parseur lit les colonnes par leur en-tête.
final String _marketV1 = [
  'nom,quantite,prix_entree,marche_secondaire',
  'Alpha,100,10,"2026-01-29|achat|600,00;2026-01-29|achat|700,00"',
].join('\n');

final String _marketV2 = [
  'nom,quantite,prix_entree,marche_secondaire',
  'Alpha,100,10,"2026-02-10|revente|900,00;2026-03-05|achat|250,50"',
].join('\n');

/// Même société, colonne présente mais vide : rien ne doit être supprimé.
final String _marketEmpty = [
  'nom,quantite,prix_entree,marche_secondaire',
  'Alpha,100,10,',
].join('\n');

void main() {
  group('parseSecondaryTransactions', () {
    test('sépare les transactions sur « ; » puis les champs sur « | »', () {
      final txs = parseSecondaryTransactions(
        '2026-01-29|achat|600,00;2026-01-29|achat|700,00',
      );
      expect(txs, hasLength(2));
      expect(txs[0].type, 'achat');
      expect(txs[0].date, DateTime(2026, 1, 29));
      expect(txs[0].montant, closeTo(600, 1e-9));
      expect(txs[1].montant, closeTo(700, 1e-9));
    });

    test('gère revente, espaces, fragments vides et types inconnus', () {
      final txs = parseSecondaryTransactions(
        ' 2026-02-10 | Revente | 900,00 ;; 2026-03-05|ACHAT|250.50;'
        '2026-04-01|erreur|100',
      );
      expect(txs, hasLength(2));
      expect(txs[0].type, 'revente');
      expect(txs[0].montant, closeTo(900, 1e-9));
      expect(txs[1].type, 'achat');
      expect(txs[1].montant, closeTo(250.5, 1e-9));
      expect(txs[1].date, DateTime(2026, 3, 5));
    });

    test('date invalide : transaction conservée mais non datée', () {
      final txs = parseSecondaryTransactions('pas-une-date|achat|100');
      expect(txs, hasLength(1));
      expect(txs.single.date, isNull);
      expect(txs.single.montant, closeTo(100, 1e-9));
    });

    test('colonne absente ou vide : aucune transaction', () {
      expect(parseSecondaryTransactions(null), isEmpty);
      expect(parseSecondaryTransactions(''), isEmpty);
      expect(parseSecondaryTransactions('   '), isEmpty);
      expect(parseSecondaryTransactions(';;'), isEmpty);
    });
  });

  group('import CSV', () {
    late AppDatabase db;
    late PortfolioController controller;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      controller = PortfolioController(db);
    });

    tearDown(() => db.close());

    test(
      'les transactions secondaires sont insérées puis remplacées',
      () async {
        final first = await controller.importCsv(
          csv: _marketV1,
          type: AssetType.startup,
        );
        expect(first.imported, 1);

        final assetId = (await db.allAssets()).single.id;
        var rows = await db.secondaryTransactionsFor(assetId);
        expect(rows, hasLength(2));
        expect(rows.map((r) => r.type).toList(), ['achat', 'achat']);
        expect(rows.map((r) => r.montant).toList(), [600, 700]);
        expect(rows.first.date, DateTime(2026, 1, 29));
        expect(controller.secondaryTransactionsOf(assetId), hasLength(2));

        // Ré-import : remplacement en bloc, aucune transaction orpheline.
        final second = await controller.importCsv(
          csv: _marketV2,
          type: AssetType.startup,
        );
        expect(second.updated, 1);

        rows = await db.secondaryTransactionsFor(assetId);
        expect(rows, hasLength(2));
        expect(rows.map((r) => r.type).toList(), ['revente', 'achat']);
        expect(rows.map((r) => r.montant).toList(), [900, 250.5]);
        expect((await db.allSecondaryTransactions()), hasLength(2));
        expect(await db.allAssets(), hasLength(1));
      },
    );

    test('une colonne vide laisse les transactions existantes', () async {
      await controller.importCsv(csv: _marketV1, type: AssetType.startup);
      final assetId = (await db.allAssets()).single.id;
      expect(await db.secondaryTransactionsFor(assetId), hasLength(2));

      final result = await controller.importCsv(
        csv: _marketEmpty,
        type: AssetType.startup,
      );
      expect(result.updated, 1);
      expect(await db.secondaryTransactionsFor(assetId), hasLength(2));
    });
  });

  group('migration v5 -> v6', () {
    test(
      'crée la table du marché secondaire sans toucher aux données',
      () async {
        final dir = await Directory.systemTemp.createTemp('patrimoine_v5');
        final file = File('${dir.path}/v5.sqlite');
        addTearDown(() async {
          if (await dir.exists()) await dir.delete(recursive: true);
        });

        // Base v5 réelle (schéma courant), dans laquelle on retire la table
        // ajoutée en v6 puis on force user_version = 5.
        final seed = AppDatabase.forTesting(NativeDatabase(file));
        final assetId = await seed.addAsset(
          AssetsCompanion.insert(name: 'Alpha', type: 'startup'),
        );
        await seed.saveStartupDetails(
          const StartupDraft(
            categorie: 'Licornes pre-IPO',
            quantite: 100,
            prixEntree: 10,
          ).toCompanion(assetId),
        );
        await seed.addFundingRound(
          FundingRoundDraft(
            date: DateTime(2024, 3, 1),
            montantLeve: 500,
          ).toCompanion(assetId),
        );
        await seed.close();

        final raw = sqlite.sqlite3.open(file.path);
        raw.execute('DROP TABLE secondary_transactions');
        raw.execute('PRAGMA user_version = 5');
        raw.close();

        final db = AppDatabase.forTesting(NativeDatabase(file));
        addTearDown(db.close);

        // Données v5 conservées.
        final assets = await db.allAssets();
        expect(assets, hasLength(1));
        expect(assets.single.name, 'Alpha');
        expect(
          (await db.startupDetailsFor(assetId))!.categorie,
          'Licornes pre-IPO',
        );
        expect(await db.allFundingRounds(), hasLength(1));

        // La table v6 existe et accepte des écritures.
        await db.addSecondaryTransaction(
          const SecondaryTransactionDraft(
            type: 'achat',
            montant: 1200,
          ).toCompanion(assetId),
        );
        final rows = await db.secondaryTransactionsFor(assetId);
        expect(rows, hasLength(1));
        expect(rows.single.montant, 1200);

        final version = await db
            .customSelect('PRAGMA user_version')
            .getSingle();
        expect(version.data.values.first, 6);
      },
    );
  });

  group('suppression', () {
    late AppDatabase db;
    late PortfolioController controller;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      controller = PortfolioController(db);
    });

    tearDown(() => db.close());

    test('supprimer une catégorie supprime les données rattachées', () async {
      final startupId = await db.addAsset(
        AssetsCompanion.insert(name: 'Alpha', type: 'startup'),
      );
      await db.addPosition(
        PositionsCompanion.insert(
          assetId: startupId,
          symbol: 'ALPHA',
          name: 'Alpha',
          quantity: 2,
          unitCost: 5,
        ),
      );
      await db.saveStartupDetails(
        const StartupDraft(quantite: 2, prixEntree: 5).toCompanion(startupId),
      );
      await db.addFundingRound(
        FundingRoundDraft(montantLeve: 10).toCompanion(startupId),
      );
      await db.addSecondaryTransaction(
        const SecondaryTransactionDraft(
          type: 'achat',
          montant: 50,
        ).toCompanion(startupId),
      );
      await db.addDocument(
        DocumentsCompanion.insert(
          assetId: startupId,
          label: 'Statuts',
          fileName: 'statuts.pdf',
          filePath: '/tmp/patrimoine-inexistant/statuts.pdf',
        ),
      );
      final cashId = await db.addAsset(
        AssetsCompanion.insert(
          name: 'Livret A',
          type: 'cash',
          value: const Value(500),
        ),
      );

      await controller.load();
      final deleted = await controller.deleteAssetsOfType(AssetType.startup);

      expect(deleted, 1);
      expect((await db.allAssets()).map((a) => a.id), [cashId]);
      expect(await db.allPositions(), isEmpty);
      expect(await db.allStartupDetails(), isEmpty);
      expect(await db.allFundingRounds(), isEmpty);
      expect(await db.allSecondaryTransactions(), isEmpty);
      expect(await db.allDocuments(), isEmpty);
    });

    test('supprimer un actif supprime ses enfants', () async {
      final id = await db.addAsset(
        AssetsCompanion.insert(name: 'Alpha', type: 'startup'),
      );
      await db.addSecondaryTransaction(
        const SecondaryTransactionDraft(
          type: 'revente',
          montant: 99,
        ).toCompanion(id),
      );

      await db.deleteAsset(id);

      expect(await db.allAssets(), isEmpty);
      expect(await db.allSecondaryTransactions(), isEmpty);
    });
  });

  group('écran Blast Market', () {
    late AppDatabase db;
    late PortfolioController controller;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      controller = PortfolioController(db);
    });

    tearDown(() => db.close());

    testWidgets('affiche totaux achetés/revendus et le détail daté', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final id = await db.addAsset(
        AssetsCompanion.insert(name: 'Alpha', type: 'startup'),
      );
      await db.saveStartupDetails(
        const StartupDraft(quantite: 10, prixEntree: 5).toCompanion(id),
      );
      await db.addSecondaryTransaction(
        SecondaryTransactionDraft(
          date: DateTime(2026, 1, 29),
          type: 'achat',
          montant: 600,
        ).toCompanion(id),
      );
      await db.addSecondaryTransaction(
        SecondaryTransactionDraft(
          date: DateTime(2026, 2, 10),
          type: 'revente',
          montant: 300,
        ).toCompanion(id),
      );
      // Startup sans transaction : hors écran.
      final other = await db.addAsset(
        AssetsCompanion.insert(name: 'Beta', type: 'startup'),
      );
      await db.saveStartupDetails(
        const StartupDraft(quantite: 1, prixEntree: 1).toCompanion(other),
      );
      await tester.runAsync(() => controller.load());

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: controller,
          child: MaterialApp(
            theme: buildDarkTheme(),
            home: const Scaffold(body: BlastMarketScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Marché secondaire (1)'), findsOneWidget);
      expect(find.text('Alpha'), findsOneWidget);
      expect(find.text('Beta'), findsNothing);
      expect(find.text('Total acheté'), findsOneWidget);
      expect(find.text('Total revendu'), findsOneWidget);
      expect(find.text('Achat'), findsOneWidget);
      expect(find.text('Revente'), findsOneWidget);
      expect(find.text('29/01/2026'), findsOneWidget);
      expect(find.text('10/02/2026'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
