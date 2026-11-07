import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrimoine/controllers/portfolio_controller.dart';
import 'package:patrimoine/data/csv_import.dart';
import 'package:patrimoine/data/database.dart';
import 'package:patrimoine/domain/startup_portfolio.dart';
import 'package:patrimoine/models/asset_type.dart';
import 'package:patrimoine/models/startup.dart';
import 'package:patrimoine/theme/app_theme.dart';
import 'package:patrimoine/utils/format.dart';
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

/// Format enrichi : date|type|actions|prix|frais|commission_pv.
final String _marketDetail = [
  'nom,quantite,prix_entree,marche_secondaire',
  'Alpha,100,10,"2025-10-27|revente|500|3,29|0,00|229,00;'
      '2025-11-02|achat|120|4,5|12,50|0"',
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

    test('format enrichi : date|type|actions|prix|frais|commission_pv', () {
      final txs = parseSecondaryTransactions(
        '2025-10-27|revente|500|3,29|0,00|229,00;'
        '2025-11-02|achat|120|4,5|12,50|0',
      );
      expect(txs, hasLength(2));

      final vente = txs[0];
      expect(vente.type, 'revente');
      expect(vente.date, DateTime(2025, 10, 27));
      expect(vente.actions, 500);
      expect(vente.prix, closeTo(3.29, 1e-9));
      expect(vente.frais, closeTo(0, 1e-9));
      expect(vente.commissionPv, closeTo(229, 1e-9));
      expect(vente.hasDetail, isTrue);
      // Vente : montant reçu = actions × prix − commission PV.
      expect(vente.montant, closeTo(500 * 3.29 - 229, 1e-9));

      final achat = txs[1];
      expect(achat.type, 'achat');
      expect(achat.actions, 120);
      expect(achat.prix, closeTo(4.5, 1e-9));
      expect(achat.frais, closeTo(12.5, 1e-9));
      expect(achat.commissionPv, 0);
      // Achat : montant payé = actions × prix + frais.
      expect(achat.montant, closeTo(120 * 4.5 + 12.5, 1e-9));
    });

    test('format enrichi partiel : frais et commission absents valent 0', () {
      final txs = parseSecondaryTransactions('2025-10-27|achat|40|2,50');
      expect(txs, hasLength(1));
      expect(txs.single.actions, 40);
      expect(txs.single.prix, closeTo(2.5, 1e-9));
      expect(txs.single.frais, 0);
      expect(txs.single.commissionPv, 0);
      expect(txs.single.montant, closeTo(100, 1e-9));

      // Champs présents mais vides.
      final vides = parseSecondaryTransactions('2025-10-27|achat|40|2,50||');
      expect(vides.single.frais, 0);
      expect(vides.single.commissionPv, 0);
    });

    test('ancien format date|type|montant : montant conservé tel quel', () {
      final txs = parseSecondaryTransactions('2026-01-29|achat|600,00');
      expect(txs, hasLength(1));
      expect(txs.single.hasDetail, isFalse);
      expect(txs.single.actions, 0);
      expect(txs.single.prix, 0);
      expect(txs.single.montant, closeTo(600, 1e-9));
    });

    test('date invalide et type inconnu dans le format enrichi', () {
      final txs = parseSecondaryTransactions(
        'pas-une-date|ACHAT|10|12,00|1,00|0;2025-10-27|erreur|10|12|0|0',
      );
      expect(txs, hasLength(1));
      expect(txs.single.date, isNull);
      expect(txs.single.actions, 10);
      expect(txs.single.montant, closeTo(121, 1e-9));
    });
  });

  group('plus-value de cession', () {
    test('PV brute = actions × (prix − PRU)', () {
      expect(secondaryPvBrut(100, 20, 10), closeTo(1000, 1e-9));
      expect(secondaryPvBrut(500, 3.29, 10), closeTo(500 * (3.29 - 10), 1e-9));
      expect(secondaryPvBrut(0, 20, 10), 0);
    });

    test('PV nette : commission, frais puis flat tax de 30 %', () {
      // 100 × (20 − 10) = 1 000 ; base = 1 000 − 20 − 5 = 975 ;
      // flat tax = 292,50 ; net = 682,50.
      final net = secondaryPvNet(100, 20, 10, 20, 5);
      expect(net, closeTo(682.5, 1e-9));
      expect(
        net,
        closeTo(
          secondaryPvBrut(100, 20, 10) - 20 - 5 - 0.30 * (1000 - 20 - 5),
          1e-9,
        ),
      );
      expect(secondaryFlatTaxRate, 0.30);
    });

    test('PV nette sans flat tax quand la base est nulle ou négative', () {
      // Base exactement nulle : commission + frais absorbent la PV brute.
      expect(secondaryPvNet(100, 12, 10, 150, 50), 0);
      // Moins-value : aucune flat tax, pertes imputées en totalité.
      final perte = secondaryPvNet(50, 5, 10, 3, 2);
      expect(perte, closeTo(-255, 1e-9));
    });

    test('PRU inconnu (0) : détecté comme indisponible', () {
      expect(secondaryPruAvailable(0), isFalse);
      expect(secondaryPruAvailable(4.2), isTrue);
    });

    test('montant : achat = actions × prix + frais, vente = − commission', () {
      expect(secondaryMontant('achat', 10, 5, 2, 99), closeTo(52, 1e-9));
      expect(secondaryMontant('revente', 10, 5, 2, 3), closeTo(47, 1e-9));
    });
  });

  group('filtres du marché secondaire', () {
    test('filtre par type de transaction', () {
      expect(secondaryTypeMatches('achat', SecondaryTypeFilter.tous), isTrue);
      expect(secondaryTypeMatches('revente', SecondaryTypeFilter.tous), isTrue);
      expect(secondaryTypeMatches('achat', SecondaryTypeFilter.achat), isTrue);
      expect(
        secondaryTypeMatches('revente', SecondaryTypeFilter.achat),
        isFalse,
      );
      expect(
        secondaryTypeMatches('revente', SecondaryTypeFilter.revente),
        isTrue,
      );
      expect(secondaryTypeMatches('achat', SecondaryTypeFilter.revente), isFalse);
      expect(secondaryTypeFilterLabel(SecondaryTypeFilter.tous), 'Tous');
      expect(secondaryTypeFilterLabel(SecondaryTypeFilter.achat), 'Achats');
      expect(secondaryTypeFilterLabel(SecondaryTypeFilter.revente), 'Ventes');
    });

    test('recherche par nom : casse et accents ignorés', () {
      expect(startupNameMatches('Écosystème', 'ecosysteme'), isTrue);
      expect(startupNameMatches('Écosystème', 'ÉCO'), isTrue);
      expect(startupNameMatches('Alpha', '  alp '), isTrue);
      expect(startupNameMatches('Alpha', ''), isTrue);
      expect(startupNameMatches('Alpha', 'beta'), isFalse);
      expect(normalizeStartupSearch('  Société Générale '), 'societe generale');
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

    test('le détail chiffré est persisté et le montant recalculé', () async {
      final result = await controller.importCsv(
        csv: _marketDetail,
        type: AssetType.startup,
      );
      expect(result.imported, 1);

      final assetId = (await db.allAssets()).single.id;
      final rows = await db.secondaryTransactionsFor(assetId);
      expect(rows, hasLength(2));

      final vente = rows[0];
      expect(vente.type, 'revente');
      expect(vente.actions, 500);
      expect(vente.prix, closeTo(3.29, 1e-9));
      expect(vente.frais, 0);
      expect(vente.commissionPv, closeTo(229, 1e-9));
      expect(vente.montant, closeTo(500 * 3.29 - 229, 1e-9));

      final achat = rows[1];
      expect(achat.actions, 120);
      expect(achat.prix, closeTo(4.5, 1e-9));
      expect(achat.frais, closeTo(12.5, 1e-9));
      expect(achat.commissionPv, 0);
      expect(achat.montant, closeTo(120 * 4.5 + 12.5, 1e-9));

      expect(controller.secondaryTransactionsOf(assetId), hasLength(2));
    });

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

  group('migration v5 -> v7', () {
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
        expect(version.data.values.first, 7);
      },
    );
  });

  group('migration v6 -> v7', () {
    test('ajoute le détail chiffré sans perdre les transactions', () async {
      final dir = await Directory.systemTemp.createTemp('patrimoine_v6');
      final file = File('${dir.path}/v6.sqlite');
      addTearDown(() async {
        if (await dir.exists()) await dir.delete(recursive: true);
      });

      final seed = AppDatabase.forTesting(NativeDatabase(file));
      final assetId = await seed.addAsset(
        AssetsCompanion.insert(name: 'Alpha', type: 'startup'),
      );
      await seed.addSecondaryTransaction(
        SecondaryTransactionDraft(
          date: DateTime(2026, 1, 29),
          type: 'achat',
          montant: 600,
        ).toCompanion(assetId),
      );
      await seed.close();

      // Retour au schéma v6 : table sans les quatre colonnes de détail.
      final raw = sqlite.sqlite3.open(file.path);
      for (final column in ['actions', 'prix', 'frais', 'commission_pv']) {
        raw.execute('ALTER TABLE secondary_transactions DROP COLUMN $column');
      }
      raw.execute('PRAGMA user_version = 6');
      raw.close();

      final db = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(db.close);

      final rows = await db.secondaryTransactionsFor(assetId);
      expect(rows, hasLength(1));
      expect(rows.single.montant, 600);
      expect(rows.single.actions, 0);
      expect(rows.single.prix, 0);
      expect(rows.single.frais, 0);
      expect(rows.single.commissionPv, 0);

      final version = await db
          .customSelect('PRAGMA user_version')
          .getSingle();
      expect(version.data.values.first, 7);
    });
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

    testWidgets('détail chiffré, PV estimée, filtre de type et recherche', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(420, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final alpha = await db.addAsset(
        AssetsCompanion.insert(name: 'Alpha', type: 'startup'),
      );
      await db.saveStartupDetails(
        const StartupDraft(quantite: 100, prixEntree: 10).toCompanion(alpha),
      );
      // Achat : 100 × 8 + 5 = 805 €.
      await db.addSecondaryTransaction(
        SecondaryTransactionDraft(
          date: DateTime(2025, 10, 1),
          type: 'achat',
          actions: 100,
          prix: 8,
          frais: 5,
        ).toCompanion(alpha),
      );
      // Vente : 50 × 20 − 10 = 990 € ; PV brute 500 € ; PV nette 341,60 €.
      await db.addSecondaryTransaction(
        SecondaryTransactionDraft(
          date: DateTime(2025, 10, 27),
          type: 'revente',
          actions: 50,
          prix: 20,
          frais: 2,
          commissionPv: 10,
        ).toCompanion(alpha),
      );

      // PRU inconnu : la PV reste affichée « — ».
      final beta = await db.addAsset(
        AssetsCompanion.insert(name: 'Beta', type: 'startup'),
      );
      await db.saveStartupDetails(
        const StartupDraft(quantite: 10, prixEntree: 0).toCompanion(beta),
      );
      await db.addSecondaryTransaction(
        SecondaryTransactionDraft(
          date: DateTime(2025, 11, 5),
          type: 'revente',
          actions: 10,
          prix: 5,
        ).toCompanion(beta),
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

      expect(find.text('Marché secondaire (2)'), findsOneWidget);

      final achatDetail =
          '100 actions · PU ${formatEuro(8, cents: true)} · '
          'Frais ${formatEuro(5, cents: true)}';
      expect(find.text(achatDetail), findsOneWidget);
      expect(find.text(formatEuro(805, cents: true)), findsOneWidget);
      expect(find.text(formatEuro(990, cents: true)), findsOneWidget);
      expect(
        find.textContaining('PV brut ${formatSignedEuro(500, cents: true)}'),
        findsOneWidget,
      );
      expect(
        find.textContaining('PV net ${formatSignedEuro(341.6, cents: true)}'),
        findsOneWidget,
      );
      // Beta : PRU indisponible, aucun PV trompeur.
      expect(find.textContaining('PV brut —'), findsOneWidget);
      expect(find.textContaining('PV net —'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Filtre « Ventes » : l'achat d'Alpha disparaît.
      await tester.tap(find.text('Ventes'));
      await tester.pumpAndSettle();
      expect(find.text(achatDetail), findsNothing);
      expect(find.text('Alpha'), findsOneWidget);
      expect(find.text('Beta'), findsOneWidget);

      // Filtre « Achats » : Beta, qui n'a qu'une vente, disparaît.
      await tester.tap(find.text('Achats'));
      await tester.pumpAndSettle();
      expect(find.text('Beta'), findsNothing);
      expect(find.text(achatDetail), findsOneWidget);

      // Retour à « Tous » puis recherche par nom de startup.
      await tester.tap(find.text('Tous'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'BÊT');
      await tester.pumpAndSettle();
      expect(find.text('Alpha'), findsNothing);
      expect(find.text('Beta'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'zzz');
      await tester.pumpAndSettle();
      expect(find.textContaining('Aucune startup'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
    testWidgets('écran étroit (360 dp) : pas de débordement', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final id = await db.addAsset(
        AssetsCompanion.insert(name: 'Alpha', type: 'startup'),
      );
      await db.saveStartupDetails(
        const StartupDraft(quantite: 100, prixEntree: 10).toCompanion(id),
      );
      await db.addSecondaryTransaction(
        SecondaryTransactionDraft(
          date: DateTime(2025, 10, 27),
          type: 'revente',
          actions: 500,
          prix: 3.29,
          commissionPv: 229,
        ).toCompanion(id),
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

      expect(find.text('Ventes'), findsOneWidget);
      expect(find.textContaining('500 actions'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
