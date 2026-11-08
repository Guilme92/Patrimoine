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
import 'package:patrimoine/ui/screens/blast_market_detail_screen.dart';
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
        raw.execute('ALTER TABLE startup_details DROP COLUMN montant_investi');
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
        expect(version.data.values.first, 8);
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
      raw.execute('ALTER TABLE startup_details DROP COLUMN montant_investi');
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
      expect(version.data.values.first, 8);
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

  group('agrégats du marché secondaire', () {
    SecondaryTransaction tx({
      String type = 'achat',
      int actions = 0,
      double prix = 0,
      double frais = 0,
      double commissionPv = 0,
      double? montant,
    }) => SecondaryTransaction(
      id: 0,
      assetId: 1,
      type: type,
      date: null,
      actions: actions,
      prix: prix,
      frais: frais,
      commissionPv: commissionPv,
      montant:
          montant ??
          (type == 'revente'
              ? actions * prix - commissionPv
              : actions * prix + frais),
    );

    test('totaux, P.U. moyen pondéré et PV par type', () {
      final summary = SecondaryMarketSummary.of(
        [
          tx(actions: 10, prix: 2),
          tx(actions: 30, prix: 4, frais: 5),
          tx(
            type: 'revente',
            actions: 50,
            prix: 20,
            frais: 2,
            commissionPv: 10,
          ),
        ],
        pru: 10,
      );

      expect(summary.totalAchat, closeTo(20 + 125, 1e-9));
      expect(summary.actionsAchat, 40);
      // (10×2 + 30×4) / 40 = 3,50 € — les frais ne polluent pas le P.U.
      expect(summary.puMoyenAchat, closeTo(3.5, 1e-9));
      expect(summary.totalRevente, closeTo(990, 1e-9));
      expect(summary.actionsVente, 50);
      expect(summary.puMoyenVente, closeTo(20, 1e-9));
      expect(summary.pvBrute, closeTo(500, 1e-9));
      expect(summary.pvNette, closeTo(341.6, 1e-9));
      expect(summary.ventesEvaluees, 1);
      expect(summary.pvPartielle, isFalse);
      expect(summary.pvIndisponible, isFalse);
    });

    test('PV ignorée quand le PRU est inconnu ; P.U. à 0 sans détail', () {
      final summary = SecondaryMarketSummary.of(
        [
          tx(type: 'revente', actions: 10, prix: 5),
          tx(type: 'revente', montant: 300),
        ],
        pru: 0,
      );
      expect(summary.totalRevente, closeTo(350, 1e-9));
      expect(summary.pvBrute, 0);
      expect(summary.pvNette, 0);
      expect(summary.ventesEvaluees, 0);
      expect(summary.ventesNonEvaluees, 2);
      expect(summary.pvPartielle, isTrue);
      expect(summary.pvIndisponible, isTrue);
      // P.U. moyen calculé sur la seule vente détaillée.
      expect(summary.puMoyenVente, closeTo(5, 1e-9));

      // Agrégat neutre.
      expect(SecondaryMarketSummary.empty.totalAchat, 0);
      expect(SecondaryMarketSummary.empty.pvIndisponible, isFalse);
    });

    test('somme de deux startups : totaux et PV cumulés', () {
      final alpha = SecondaryMarketSummary.of(
        [
          tx(type: 'revente', actions: 50, prix: 20, commissionPv: 10, frais: 2),
        ],
        pru: 10,
      );
      final beta = SecondaryMarketSummary.of(
        [tx(actions: 4, prix: 10)],
        pru: 10,
      );
      final total = SecondaryMarketSummary.empty + alpha + beta;
      expect(total.pvBrute, closeTo(500, 1e-9));
      expect(total.pvNette, closeTo(341.6, 1e-9));
      expect(total.totalAchat, closeTo(40, 1e-9));
      expect(total.puMoyenAchat, closeTo(10, 1e-9));
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

    /// Monte l'écran et attend le chargement du contrôleur.
    Future<void> pumpMarket(WidgetTester tester) async {
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
    }

    testWidgets('KPIs de PV, grille compacte et P.U. moyen par type', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(420, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final alpha = await db.addAsset(
        AssetsCompanion.insert(name: 'Alpha', type: 'startup'),
      );
      await db.saveStartupDetails(
        const StartupDraft(quantite: 100, prixEntree: 10).toCompanion(alpha),
      );
      // Achat : 100 × 8 + 5 = 805 € (P.U. 8 €).
      await db.addSecondaryTransaction(
        SecondaryTransactionDraft(
          date: DateTime(2025, 10, 1),
          type: 'achat',
          actions: 100,
          prix: 8,
          frais: 5,
        ).toCompanion(alpha),
      );
      // Vente : 50 × 20 − 10 = 990 € (P.U. 20 €) ; PV brute 500 € ;
      // PV nette 341,60 €.
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
      // Startup sans transaction : hors écran.
      final other = await db.addAsset(
        AssetsCompanion.insert(name: 'Beta', type: 'startup'),
      );
      await db.saveStartupDetails(
        const StartupDraft(quantite: 1, prixEntree: 1).toCompanion(other),
      );
      await tester.runAsync(() => controller.load());

      await pumpMarket(tester);

      expect(find.text('Marché secondaire (1)'), findsOneWidget);
      expect(find.text('Alpha'), findsOneWidget);
      expect(find.text('Beta'), findsNothing);
      // Totaux de flux.
      expect(find.text('Total acheté'), findsOneWidget);
      expect(find.text('Total revendu'), findsOneWidget);
      expect(find.text('Solde net'), findsOneWidget);
      // Nouveaux KPIs de plus-value (ventes du périmètre filtré).
      expect(find.text('Plus-value brute totale'), findsOneWidget);
      expect(find.text('Plus-value nette totale'), findsOneWidget);
      expect(find.text(formatSignedEuro(500, cents: true)), findsOneWidget);
      expect(find.text(formatSignedEuro(341.6, cents: true)), findsOneWidget);
      // Grille compacte : montant + actions + P.U. moyen, rien d'autre.
      expect(find.byKey(const Key('market-grid')), findsOneWidget);
      expect(find.byKey(ValueKey('market-card-$alpha')), findsOneWidget);
      expect(
        find.text('100 act. · PU ${formatEuro(8, cents: true)}'),
        findsOneWidget,
      );
      expect(
        find.text('50 act. · PU ${formatEuro(20, cents: true)}'),
        findsOneWidget,
      );
      // Le détail ligne par ligne n'est plus dans l'onglet.
      expect(find.text('Actions'), findsNothing);
      expect(find.text('Prix unitaire'), findsNothing);
      expect(find.text('01/10/2025'), findsNothing);
      expect(find.textContaining('PV brut'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('un clic sur la carte ouvre l\'écran de détail complet', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(420, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final alpha = await db.addAsset(
        AssetsCompanion.insert(name: 'Alpha', type: 'startup'),
      );
      await db.saveStartupDetails(
        const StartupDraft(quantite: 100, prixEntree: 10).toCompanion(alpha),
      );
      await db.addSecondaryTransaction(
        SecondaryTransactionDraft(
          date: DateTime(2025, 10, 1),
          type: 'achat',
          actions: 100,
          prix: 8,
          frais: 5,
        ).toCompanion(alpha),
      );
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
      await tester.runAsync(() => controller.load());

      await pumpMarket(tester);
      await tester.tap(find.byKey(ValueKey('market-card-$alpha')));
      await tester.pumpAndSettle();

      expect(find.byType(BlastMarketDetailScreen), findsOneWidget);
      expect(find.text('Transactions (2)'), findsOneWidget);
      expect(find.text('Actions'), findsNWidgets(2));
      expect(find.text('100 actions'), findsOneWidget);
      expect(find.text('50 actions'), findsOneWidget);
      expect(find.text('Prix unitaire'), findsNWidgets(2));
      expect(find.text(formatEuro(8, cents: true)), findsOneWidget);
      expect(find.text(formatEuro(20, cents: true)), findsOneWidget);
      expect(find.text('Frais'), findsNWidgets(2));
      expect(find.text(formatEuro(5, cents: true)), findsOneWidget);
      expect(find.text('Commission PV'), findsOneWidget);
      expect(find.text(formatEuro(10, cents: true)), findsOneWidget);
      expect(find.text('PV brute'), findsOneWidget);
      expect(find.text('PV nette'), findsOneWidget);
      expect(find.text(formatSignedEuro(500, cents: true)), findsOneWidget);
      expect(find.text(formatSignedEuro(341.6, cents: true)), findsOneWidget);
      expect(find.text('01/10/2025'), findsOneWidget);
      expect(find.text('27/10/2025'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Retour à la grille.
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('market-grid')), findsOneWidget);
      expect(find.text('Marché secondaire (1)'), findsOneWidget);
    });

    testWidgets('PRU inconnu : KPIs de PV et détail affichent « — »', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(420, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

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

      await pumpMarket(tester);

      expect(
        find.descendant(
          of: find.byKey(const Key('kpi-pv-brute')),
          matching: find.text('—'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('kpi-pv-nette')),
          matching: find.text('—'),
        ),
        findsOneWidget,
      );
      // Signalement d'une estimation partielle.
      expect(find.textContaining('sans PRU connu'), findsOneWidget);

      await tester.tap(find.byKey(ValueKey('market-card-$beta')));
      await tester.pumpAndSettle();
      expect(find.text('PV brute'), findsOneWidget);
      expect(find.text('PV nette'), findsOneWidget);
      expect(find.text('—'), findsNWidgets(3)); // PV nette KPI, PV brute, PV nette
      expect(tester.takeException(), isNull);
    });

    testWidgets('filtre de type et recherche par nom filtrent la grille', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(420, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final alpha = await db.addAsset(
        AssetsCompanion.insert(name: 'Alpha', type: 'startup'),
      );
      await db.saveStartupDetails(
        const StartupDraft(quantite: 100, prixEntree: 10).toCompanion(alpha),
      );
      await db.addSecondaryTransaction(
        SecondaryTransactionDraft(
          date: DateTime(2025, 10, 1),
          type: 'achat',
          actions: 100,
          prix: 8,
        ).toCompanion(alpha),
      );
      await db.addSecondaryTransaction(
        SecondaryTransactionDraft(
          date: DateTime(2025, 10, 27),
          type: 'revente',
          actions: 50,
          prix: 20,
        ).toCompanion(alpha),
      );
      final beta = await db.addAsset(
        AssetsCompanion.insert(name: 'Beta', type: 'startup'),
      );
      await db.saveStartupDetails(
        const StartupDraft(quantite: 10, prixEntree: 5).toCompanion(beta),
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

      await pumpMarket(tester);
      expect(
        find.text('100 act. · PU ${formatEuro(8, cents: true)}'),
        findsOneWidget,
      );

      // Filtre « Ventes » : le bloc achats d'Alpha passe à « — ».
      await tester.tap(find.text('Ventes'));
      await tester.pumpAndSettle();
      expect(
        find.text('100 act. · PU ${formatEuro(8, cents: true)}'),
        findsNothing,
      );
      expect(
        find.text('50 act. · PU ${formatEuro(20, cents: true)}'),
        findsOneWidget,
      );
      expect(
        find.text('10 act. · PU ${formatEuro(5, cents: true)}'),
        findsOneWidget,
      );
      // KPIs : plus aucun achat dans le périmètre.
      expect(find.text(formatEuro(0)), findsWidgets);

      // Filtre « Achats » : Beta, qui n'a qu'une vente, disparaît.
      await tester.tap(find.text('Achats'));
      await tester.pumpAndSettle();
      expect(find.text('Beta'), findsNothing);
      expect(
        find.text('100 act. · PU ${formatEuro(8, cents: true)}'),
        findsOneWidget,
      );

      // Retour à « Tous » puis recherche par nom (accents ignorés).
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

    testWidgets('grille responsive : 3 colonnes sur desktop, 2 sur mobile', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(800, 1200);
      addTearDown(tester.view.reset);

      // L'écran trie les startups par nom : l'ordre de la grille est connu.
      const names = ['Deux', 'Quatre', 'Trois', 'Un'];
      final idsByName = <String, int>{};
      for (final name in names) {
        final id = await db.addAsset(
          AssetsCompanion.insert(name: name, type: 'startup'),
        );
        await db.saveStartupDetails(
          const StartupDraft(quantite: 10, prixEntree: 5).toCompanion(id),
        );
        await db.addSecondaryTransaction(
          SecondaryTransactionDraft(
            date: DateTime(2025, 10, 1),
            type: 'achat',
            actions: 10,
            prix: 5,
          ).toCompanion(id),
        );
        idsByName[name] = id;
      }
      await tester.runAsync(() => controller.load());
      await pumpMarket(tester);

      // 800 dp → 3 colonnes : les trois premières cartes partagent la même
      // ordonnée, la quatrième passe à la ligne.
      List<Offset> topsFor() => [
        for (final name in names)
          tester.getTopLeft(
            find.byKey(ValueKey('market-card-${idsByName[name]}')),
          ),
      ];
      final tops = topsFor();
      expect(tops[0].dy, tops[1].dy);
      expect(tops[1].dy, tops[2].dy);
      expect(tops[3].dy, greaterThan(tops[0].dy));
      expect(tops[0].dx, lessThan(tops[1].dx));
      expect(tops[1].dx, lessThan(tops[2].dx));

      // 360 dp → 2 colonnes : la troisième carte passe à la ligne.
      tester.view.physicalSize = const Size(360, 1600);
      await tester.pumpAndSettle();
      final narrow = topsFor();
      expect(narrow[0].dy, narrow[1].dy);
      expect(narrow[2].dy, greaterThan(narrow[0].dy));

      // 1200 dp → 4 colonnes : toute la ligne tient sur une seule rangée.
      tester.view.physicalSize = const Size(1200, 900);
      await tester.pumpAndSettle();
      final wide = topsFor();
      expect(wide[1].dy, wide[0].dy);
      expect(wide[2].dy, wide[0].dy);
      expect(wide[3].dy, wide[0].dy);
      expect(wide[0].dx, lessThan(wide[1].dx));
      expect(wide[3].dx, greaterThan(wide[2].dx));
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
      await pumpMarket(tester);

      expect(find.text('Ventes'), findsOneWidget);
      expect(
        find.text('500 act. · PU ${formatEuro(3.29, cents: true)}'),
        findsOneWidget,
      );
      expect(find.text('Plus-value nette totale'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
