import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrimoine/data/database.dart';
import 'package:patrimoine/domain/startup.dart';
import 'package:patrimoine/models/asset_type.dart';
import 'package:patrimoine/models/startup.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

StartupDetail _detail({
  String statut = 'en_portefeuille',
  double quantite = 100,
  double prixEntree = 10,
  double frais = 50,
  double prixActuel = 25,
  double exitProduit = 0,
  DateTime? dateInvestissement,
  DateTime? exitDate,
}) => StartupDetail(
  id: 1,
  assetId: 1,
  typeTitre: 'actions',
  quantite: quantite,
  prixEntree: prixEntree,
  frais: frais,
  dateInvestissement: dateInvestissement,
  stade: 'seed',
  prixActuel: prixActuel,
  dateValorisation: DateTime(2026, 1, 1),
  valorisationEntreprise: 5000000,
  statut: statut,
  exitDate: exitDate,
  exitProduit: exitProduit,
  exitMode: statut == 'sorti' ? 'acquisition' : null,
  note: null,
  createdAt: DateTime(2026),
);

void main() {
  group('indicateurs startup', () {
    test('capital investi = quantité × prix d\'entrée + frais', () {
      expect(investedCapital(_detail()), 1050);
    });

    test('valeur de ligne selon le statut', () {
      // En portefeuille : quantité × prix actuel manuel.
      expect(lineValue(_detail()), 2500);
      // Sortie : produit de sortie, quel que soit le prix actuel.
      expect(
        lineValue(
          _detail(statut: 'sorti', exitProduit: 3000, prixActuel: 999),
        ),
        3000,
      );
      // Radiation : perte totale.
      expect(lineValue(_detail(statut: 'radie', prixActuel: 999)), 0);
    });

    test('plus-value latente et pourcentage', () {
      final s = _detail();
      expect(unrealizedGain(s), 1450);
      expect(unrealizedGainPct(s), closeTo(138.095238, 1e-5));
    });

    test('multiple sur capital investi (MOIC)', () {
      expect(moic(_detail()), closeTo(2.380952, 1e-5));
      expect(moic(_detail(statut: 'radie')), 0);
      expect(moic(_detail(quantite: 0, prixEntree: 0, frais: 0)), 0);
    });

    test('plus-value réalisée uniquement à la sortie', () {
      expect(realizedGain(_detail()), 0);
      expect(
        realizedGain(_detail(statut: 'sorti', exitProduit: 3000)),
        1950,
      );
      expect(realizedGain(_detail(statut: 'radie')), 0);
    });

    test('TRI annualisé entre investissement et aujourd\'hui', () {
      final s = _detail(dateInvestissement: DateTime(2020, 1, 1));
      expect(
        triAnnualizedPct(s, today: DateTime(2025, 1, 1)),
        closeTo(18.9376, 0.001),
      );
    });

    test('TRI annualisé jusqu\'à la date de sortie', () {
      final s = _detail(
        statut: 'sorti',
        exitProduit: 3000,
        dateInvestissement: DateTime(2020, 1, 1),
        exitDate: DateTime(2023, 1, 1),
      );
      expect(
        triAnnualizedPct(s, today: DateTime(2030)),
        closeTo(41.887, 0.001),
      );
    });

    test('TRI nul si données insuffisantes', () {
      expect(triAnnualizedPct(_detail()), 0); // pas de date d'investissement
      expect(
        triAnnualizedPct(
          _detail(quantite: 0, prixEntree: 0, frais: 0),
          today: DateTime(2025),
        ),
        0,
      );
      final memeJour = _detail(dateInvestissement: DateTime(2025, 1, 1));
      expect(triAnnualizedPct(memeJour, today: DateTime(2025, 1, 1)), 0);
      // Sortie antérieure à l'investissement.
      expect(
        triAnnualizedPct(
          _detail(
            statut: 'sorti',
            exitProduit: 3000,
            dateInvestissement: DateTime(2022, 1, 1),
            exitDate: DateTime(2021, 1, 1),
          ),
        ),
        0,
      );
    });

    test('libellés français', () {
      expect(startupInstrumentLabel('bspce'), 'BSPCE');
      expect(startupStageLabel('serie_a'), 'Série A');
      expect(startupStatusLabel('sorti'), 'Sorti');
      expect(startupExitModeLabel('ipo'), 'Introduction en bourse (IPO)');
      expect(startupInstrumentLabel(null), 'Non renseigné');
    });

    test('le type startup est une classe d\'actif dédiée', () {
      expect(assetTypeLabel(AssetType.startup), 'Startups');
      expect(assetTypeFrom('startup'), AssetType.startup);
      expect(isLiabilityType(AssetType.startup), false);
      expect(supportsPositions(AssetType.startup), false);
    });
  });

  group('StartupDraft', () {
    test('convertit les champs vides en NULL', () {
      const draft = StartupDraft(typeTitre: '  ', stade: '', note: ' \n ');
      final c = draft.toCompanion(4);
      expect(c.assetId.value, 4);
      expect(c.typeTitre.value, isNull);
      expect(c.stade.value, isNull);
      expect(c.note.value, isNull);
      expect(c.statut.value, 'en_portefeuille');
    });

    test('aller-retour depuis une fiche existante', () {
      final s = _detail(statut: 'sorti', exitProduit: 3000);
      final c = StartupDraft.fromDetail(s).toCompanion(1);
      expect(c.quantite.value, 100);
      expect(c.frais.value, 50);
      expect(c.statut.value, 'sorti');
      expect(c.exitProduit.value, 3000);
      expect(c.exitMode.value, 'acquisition');
    });
  });

  group('persistance startup', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting(
        NativeDatabase.memory(
          setup: (raw) => raw.execute('PRAGMA foreign_keys = ON'),
        ),
      );
    });

    tearDown(() => db.close());

    test('crée puis met à jour une seule fiche par startup', () async {
      final assetId = await db.addAsset(
        AssetsCompanion.insert(name: 'Qonto', type: 'startup'),
      );

      await db.saveStartupDetails(
        const StartupDraft(
          typeTitre: 'actions',
          quantite: 100,
          prixEntree: 10,
          frais: 50,
          prixActuel: 25,
        ).toCompanion(assetId),
      );

      var s = await db.startupDetailsFor(assetId);
      expect(s, isNotNull);
      expect(s!.quantite, 100);
      expect(s.statut, 'en_portefeuille');
      expect(investedCapital(s), 1050);

      await db.saveStartupDetails(
        StartupDraft.fromDetail(s).toCompanion(assetId).copyWith(
          prixActuel: const Value(40),
        ),
      );

      s = await db.startupDetailsFor(assetId);
      expect(s!.prixActuel, 40);
      expect(await db.allStartupDetails(), hasLength(1));

      await db.deleteStartupDetails(assetId);
      expect(await db.startupDetailsFor(assetId), isNull);
    });

    test('levées de fonds : ajout, tri décroissant et suppression', () async {
      final assetId = await db.addAsset(
        AssetsCompanion.insert(name: 'Qonto', type: 'startup'),
      );
      await db.addFundingRound(
        const FundingRoundDraft(
          date: null,
          montantLeve: 1000000,
          valorisationPostMoney: 20000000,
        ).toCompanion(assetId),
      );
      await db.addFundingRound(
        FundingRoundDraft(
          date: DateTime(2024, 6, 1),
          montantLeve: 3000000,
          valorisationPostMoney: 50000000,
          prixParAction: 12.5,
        ).toCompanion(assetId),
      );
      await db.addFundingRound(
        FundingRoundDraft(
          date: DateTime(2022, 3, 1),
          montantLeve: 500000,
        ).toCompanion(assetId),
      );

      var rounds = await db.fundingRoundsFor(assetId);
      expect(rounds, hasLength(3));
      expect(rounds.first.montantLeve, 3000000); // la plus récente d'abord
      expect(rounds[1].montantLeve, 500000);
      expect(rounds.last.date, isNull); // les non datées en dernier

      await db.deleteFundingRound(rounds.first.id);
      rounds = await db.fundingRoundsFor(assetId);
      expect(rounds, hasLength(2));
    });

    test('supprimer l\'actif supprime la fiche et les levées', () async {
      final assetId = await db.addAsset(
        AssetsCompanion.insert(name: 'Qonto', type: 'startup'),
      );
      await db.saveStartupDetails(
        const StartupDraft(quantite: 10, prixEntree: 5).toCompanion(assetId),
      );
      await db.addFundingRound(
        const FundingRoundDraft(montantLeve: 1000000).toCompanion(assetId),
      );

      await db.deleteAsset(assetId);

      expect(await db.allStartupDetails(), isEmpty);
      expect(await db.allFundingRounds(), isEmpty);
    });
  });

  group('ordre manuel des actifs', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() => db.close());

    test('sortOrder croît à la création et suit reorderAssets', () async {
      final a = await db.addAsset(
        AssetsCompanion.insert(
          name: 'A',
          type: 'cash',
          sortOrder: Value(await db.nextAssetSortOrder()),
        ),
      );
      final b = await db.addAsset(
        AssetsCompanion.insert(
          name: 'B',
          type: 'cash',
          sortOrder: Value(await db.nextAssetSortOrder()),
        ),
      );
      final c = await db.addAsset(
        AssetsCompanion.insert(
          name: 'C',
          type: 'cash',
          sortOrder: Value(await db.nextAssetSortOrder()),
        ),
      );

      var assets = await db.allAssets();
      expect(assets.map((e) => e.name).toList(), ['A', 'B', 'C']);
      expect(assets.map((e) => e.sortOrder).toList(), [1, 2, 3]);

      await db.reorderAssets([c, a, b]);

      assets = await db.allAssets();
      expect(assets.map((e) => e.name).toList(), ['C', 'A', 'B']);
      expect(assets.map((e) => e.sortOrder).toList(), [0, 1, 2]);
    });
  });

  group('migration v2 -> v3', () {
    test(
      'conserve les actifs et ajoute sortOrder + les tables startup',
      () async {
        final dir = await Directory.systemTemp.createTemp('patrimoine_v2');
        final file = File('${dir.path}/v2.sqlite');

        final raw = sqlite.sqlite3.open(file.path);
        raw.execute('''
        CREATE TABLE assets (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          type TEXT NOT NULL,
          value REAL NOT NULL DEFAULT 0,
          currency TEXT NOT NULL DEFAULT 'EUR',
          institution TEXT,
          note TEXT,
          created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
        );
      ''');
        raw.execute('''
        CREATE TABLE positions (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          asset_id INTEGER NOT NULL REFERENCES assets(id) ON DELETE CASCADE,
          symbol TEXT NOT NULL,
          name TEXT NOT NULL,
          quantity REAL NOT NULL,
          unit_cost REAL NOT NULL,
          asset_class TEXT,
          sector TEXT,
          region TEXT,
          fees REAL NOT NULL DEFAULT 0,
          created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
        );
      ''');
        raw.execute('''
        CREATE TABLE price_cache (
          symbol TEXT NOT NULL PRIMARY KEY,
          price REAL NOT NULL,
          currency TEXT NOT NULL,
          updated_at INTEGER NOT NULL
        );
      ''');
        raw.execute('''
        CREATE TABLE snapshots (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          date INTEGER NOT NULL,
          net_worth REAL NOT NULL
        );
      ''');
        raw.execute('''
        CREATE TABLE rentals (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          asset_id INTEGER NOT NULL UNIQUE REFERENCES assets(id) ON DELETE CASCADE,
          statut TEXT NOT NULL DEFAULT 'vacant',
          type_bail TEXT,
          locataire TEXT,
          loyer_hc REAL NOT NULL DEFAULT 0,
          charges_locatives REAL NOT NULL DEFAULT 0,
          depot_garantie REAL NOT NULL DEFAULT 0,
          date_debut_bail INTEGER,
          date_fin_bail INTEGER,
          mode_gestion TEXT,
          frais_gestion REAL NOT NULL DEFAULT 0,
          taxe_fonciere REAL NOT NULL DEFAULT 0,
          assurance_pno REAL NOT NULL DEFAULT 0,
          charges_copropriete REAL NOT NULL DEFAULT 0,
          travaux_entretien REAL NOT NULL DEFAULT 0,
          vacance_locative REAL NOT NULL DEFAULT 0,
          note TEXT,
          a_un_credit INTEGER NOT NULL DEFAULT 0,
          montant_credit REAL NOT NULL DEFAULT 0,
          taux_credit_pct REAL NOT NULL DEFAULT 0,
          mensualite_credit REAL NOT NULL DEFAULT 0,
          duree_credit_mois INTEGER NOT NULL DEFAULT 0,
          capital_restant_du REAL NOT NULL DEFAULT 0,
          assurance_emprunteur REAL NOT NULL DEFAULT 0,
          created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
        );
      ''');
        raw.execute('''
        CREATE TABLE documents (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          asset_id INTEGER NOT NULL REFERENCES assets(id) ON DELETE CASCADE,
          label TEXT NOT NULL,
          file_name TEXT NOT NULL,
          file_path TEXT NOT NULL,
          note TEXT,
          created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
        );
      ''');
        raw.execute(
          "INSERT INTO assets (name, type, value) "
          "VALUES ('Qonto', 'startup', 12000)",
        );
        raw.execute('PRAGMA user_version = 2');
        raw.close();

        final db = AppDatabase.forTesting(NativeDatabase(file));

        // L'actif v2 est conservé, avec un sortOrder par défaut.
        final assets = await db.allAssets();
        expect(assets, hasLength(1));
        expect(assets.single.name, 'Qonto');
        expect(assets.single.value, 12000);
        expect(assets.single.sortOrder, 0);

        // Les tables startup sont utilisables.
        final assetId = assets.single.id;
        await db.saveStartupDetails(
          const StartupDraft(
            typeTitre: 'bsa',
            quantite: 200,
            prixEntree: 8,
            frais: 20,
            prixActuel: 12,
          ).toCompanion(assetId),
        );
        final detail = await db.startupDetailsFor(assetId);
        expect(detail, isNotNull);
        expect(investedCapital(detail!), 1620);
        expect(lineValue(detail), 2400);

        await db.addFundingRound(
          FundingRoundDraft(
            date: DateTime(2025, 2, 1),
            montantLeve: 2000000,
            valorisationPostMoney: 15000000,
          ).toCompanion(assetId),
        );
        expect(await db.fundingRoundsFor(assetId), hasLength(1));

        // La colonne ajoutée est bien requêtable.
        expect(await db.nextAssetSortOrder(), 1);

        await db.close();
        await dir.delete(recursive: true);
      },
    );
  });

  group('migration v3 -> v4', () {
    test('ajoute categorie sans perdre les fiches startup', () async {
      final dir = await Directory.systemTemp.createTemp('patrimoine_v3');
      final file = File('${dir.path}/v3.sqlite');

      final raw = sqlite.sqlite3.open(file.path);
      raw.execute('''
        CREATE TABLE assets (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          type TEXT NOT NULL,
          value REAL NOT NULL DEFAULT 0,
          currency TEXT NOT NULL DEFAULT 'EUR',
          institution TEXT,
          note TEXT,
          sort_order INTEGER NOT NULL DEFAULT 0,
          created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
        );
      ''');
      raw.execute('''
        CREATE TABLE startup_details (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          asset_id INTEGER NOT NULL UNIQUE REFERENCES assets(id) ON DELETE CASCADE,
          type_titre TEXT,
          quantite REAL NOT NULL DEFAULT 0,
          prix_entree REAL NOT NULL DEFAULT 0,
          frais REAL NOT NULL DEFAULT 0,
          date_investissement INTEGER,
          stade TEXT,
          prix_actuel REAL NOT NULL DEFAULT 0,
          date_valorisation INTEGER,
          valorisation_entreprise REAL NOT NULL DEFAULT 0,
          statut TEXT NOT NULL DEFAULT 'en_portefeuille',
          exit_date INTEGER,
          exit_produit REAL NOT NULL DEFAULT 0,
          exit_mode TEXT,
          note TEXT,
          created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
        );
      ''');
      raw.execute(
        "INSERT INTO assets (name, type, value) "
        "VALUES ('Qonto', 'startup', 12000)",
      );
      raw.execute(
        "INSERT INTO startup_details (asset_id, type_titre, quantite, "
        "prix_entree) VALUES (1, 'actions', 100, 10)",
      );
      raw.execute('PRAGMA user_version = 3');
      raw.close();

      final db = AppDatabase.forTesting(NativeDatabase(file));
      final assets = await db.allAssets();
      expect(assets, hasLength(1));

      final existing = await db.startupDetailsFor(assets.single.id);
      expect(existing, isNotNull);
      final detail = existing!;
      expect(detail.quantite, 100);
      expect(detail.categorie, isNull);

      // La nouvelle colonne est requêtable et modifiable.
      await db.saveStartupDetails(
        StartupDraft.fromDetail(detail).toCompanion(assets.single.id),
      );
      final unchanged = await db.startupDetailsFor(assets.single.id);
      expect(unchanged!.categorie, isNull);

      await db.saveStartupDetails(
        const StartupDraft(
          categorie: 'Europe Multi-Stage',
          quantite: 100,
          prixEntree: 10,
        ).toCompanion(assets.single.id),
      );
      final updated = await db.startupDetailsFor(assets.single.id);
      expect(updated!.categorie, 'Europe Multi-Stage');

      await db.close();
      await dir.delete(recursive: true);
    });
  });

  group('préférences d\'affichage', () {
    test('l\'ordre des blocs startups survit à une réouverture', () async {
      final dir = await Directory.systemTemp.createTemp('patrimoine_prefs');
      final file = File('${dir.path}/prefs.sqlite');

      var db = AppDatabase.forTesting(NativeDatabase(file));
      // Première ouverture : aucune préférence enregistrée.
      expect(await db.preferenceValue('startups.blockOrder'), isNull);
      await db.setPreference('startups.blockOrder', 'filters,tabs');
      await db.close();

      // Réouverture : la valeur est toujours là.
      db = AppDatabase.forTesting(NativeDatabase(file));
      expect(await db.preferenceValue('startups.blockOrder'), 'filters,tabs');
      // La mise à jour remplace la ligne (pas de doublon).
      await db.setPreference('startups.blockOrder', 'tabs,filters');
      expect(await db.preferenceValue('startups.blockOrder'), 'tabs,filters');
      expect(await db.select(db.preferences).get(), hasLength(1));
      await db.close();
      await dir.delete(recursive: true);
    });
  });
}
