import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

/// Un actif (ou passif) : un compte, un bien, un portefeuille…
@DataClassName('Asset')
class Assets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get type => text()(); // AssetType.name
  RealColumn get value => real().withDefault(const Constant(0))();
  TextColumn get currency => text().withDefault(const Constant('EUR'))();
  TextColumn get institution => text().nullable()();
  TextColumn get note => text().nullable()();

  /// Position dans l'ordre manuel choisi par l'utilisateur (drag & drop).
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Une ligne au sein d'un actif (action, ETF, crypto…).
@DataClassName('Position')
class Positions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get assetId =>
      integer().references(Assets, #id, onDelete: KeyAction.cascade)();
  TextColumn get symbol => text()();
  TextColumn get name => text()();
  RealColumn get quantity => real()();
  RealColumn get unitCost => real()(); // prix de revient unitaire
  TextColumn get assetClass => text().nullable()();
  TextColumn get sector => text().nullable()();
  TextColumn get region => text().nullable()();
  RealColumn get fees => real().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Cache des prix de marché par symbole.
@DataClassName('MarketPrice')
class PriceCache extends Table {
  TextColumn get symbol => text()();
  RealColumn get price => real()();
  TextColumn get currency => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {symbol};
}

/// Historique du patrimoine net (pour la courbe d'évolution).
@DataClassName('NetWorthSnapshot')
class Snapshots extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  RealColumn get netWorth => real()();
}

/// Détails de la location d'un bien immobilier.
/// Une seule fiche de location par bien (`assetId` unique).
@DataClassName('Rental')
class Rentals extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get assetId =>
      integer().references(Assets, #id, onDelete: KeyAction.cascade).unique()();

  /// loue | vacant | autre
  TextColumn get statut => text().withDefault(const Constant('vacant'))();

  /// vide | meuble | commercial | saisonnier | colocation | autre
  TextColumn get typeBail => text().nullable()();
  TextColumn get locataire => text().nullable()();

  RealColumn get loyerHc => real().withDefault(const Constant(0))();
  RealColumn get chargesLocatives => real().withDefault(const Constant(0))();
  RealColumn get depotGarantie => real().withDefault(const Constant(0))();

  DateTimeColumn get dateDebutBail => dateTime().nullable()();
  DateTimeColumn get dateFinBail => dateTime().nullable()();

  /// direct | agence | autre
  TextColumn get modeGestion => text().nullable()();
  RealColumn get fraisGestion => real().withDefault(const Constant(0))();

  RealColumn get taxeFonciere => real().withDefault(const Constant(0))();
  RealColumn get assurancePno => real().withDefault(const Constant(0))();
  RealColumn get chargesCopropriete => real().withDefault(const Constant(0))();
  RealColumn get travauxEntretien => real().withDefault(const Constant(0))();
  RealColumn get vacanceLocative => real().withDefault(const Constant(0))();

  TextColumn get note => text().nullable()();

  BoolColumn get aUnCredit => boolean().withDefault(const Constant(false))();
  RealColumn get montantCredit => real().withDefault(const Constant(0))();
  RealColumn get tauxCreditPct => real().withDefault(const Constant(0))();
  RealColumn get mensualiteCredit => real().withDefault(const Constant(0))();
  IntColumn get dureeCreditMois => integer().withDefault(const Constant(0))();
  RealColumn get capitalRestantDu => real().withDefault(const Constant(0))();
  RealColumn get assuranceEmprunteur => real().withDefault(const Constant(0))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Document rattaché à un actif (bail, facture, relevé…).
/// Le fichier est copié dans `<documents>/documents/<assetId>/<fileName>`.
@DataClassName('AssetDocument')
class Documents extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get assetId =>
      integer().references(Assets, #id, onDelete: KeyAction.cascade)();
  TextColumn get label => text()();
  TextColumn get fileName => text()();
  TextColumn get filePath => text()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Détails d'une startup non cotée.
/// Une seule fiche par startup (`assetId` unique).
@DataClassName('StartupDetail')
class StartupDetails extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get assetId =>
      integer().references(Assets, #id, onDelete: KeyAction.cascade).unique()();

  /// actions | actions_preference | bsa | bsa_air | bspce |
  /// obligations_convertibles | safe | autre
  TextColumn get typeTitre => text().nullable()();

  /// Catégorie libre (ex. « Europe Multi-Stage », « Y Combinator Seed »).
  TextColumn get categorie => text().nullable()();

  RealColumn get quantite => real().withDefault(const Constant(0))();
  RealColumn get prixEntree => real().withDefault(const Constant(0))();
  RealColumn get frais => real().withDefault(const Constant(0))();
  DateTimeColumn get dateInvestissement => dateTime().nullable()();

  /// seed | serie_a | serie_b | serie_c | late_stage | autre
  TextColumn get stade => text().nullable()();

  /// Mise à jour MANUELLE (pas de cotation pour une startup).
  RealColumn get prixActuel => real().withDefault(const Constant(0))();
  DateTimeColumn get dateValorisation => dateTime().nullable()();
  RealColumn get valorisationEntreprise =>
      real().withDefault(const Constant(0))();

  /// en_portefeuille | sorti | radie
  TextColumn get statut =>
      text().withDefault(const Constant('en_portefeuille'))();

  DateTimeColumn get exitDate => dateTime().nullable()();
  RealColumn get exitProduit => real().withDefault(const Constant(0))();

  /// acquisition | ipo | secondaire | liquidation | autre
  TextColumn get exitMode => text().nullable()();

  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Levée de fonds d'une startup (une ligne par tour).
@DataClassName('FundingRound')
class FundingRounds extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get assetId =>
      integer().references(Assets, #id, onDelete: KeyAction.cascade)();

  DateTimeColumn get date => dateTime().nullable()();
  RealColumn get montantLeve => real().withDefault(const Constant(0))();
  RealColumn get valorisationPostMoney =>
      real().withDefault(const Constant(0))();
  RealColumn get prixParAction => real().withDefault(const Constant(0))();
  TextColumn get note => text().nullable()();
}

/// Transaction passée sur le marché secondaire d'une startup
/// (achat ou revente de titres).
@DataClassName('SecondaryTransaction')
class SecondaryTransactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get assetId =>
      integer().references(Assets, #id, onDelete: KeyAction.cascade)();

  /// achat | revente
  TextColumn get type => text()();
  DateTimeColumn get date => dateTime().nullable()();
  RealColumn get montant => real().withDefault(const Constant(0))();
}

/// Préférences d'affichage clé/valeur (ex. ordre des blocs du dashboard
/// startups). Petite table dédiée pour éviter un couplage aux tables métier.
@DataClassName('Preference')
class Preferences extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(
  tables: [
    Assets,
    Positions,
    PriceCache,
    Snapshots,
    Rentals,
    Documents,
    StartupDetails,
    FundingRounds,
    SecondaryTransactions,
    Preferences,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Constructeur pour les tests (base en mémoire, exécuteur fourni).
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(rentals);
        await m.createTable(documents);
      }
      if (from < 3) {
        await m.addColumn(assets, assets.sortOrder);
        await m.createTable(startupDetails);
        await m.createTable(fundingRounds);
      } else if (from < 4) {
        // `createTable` ci-dessus crée déjà `categorie` (schéma courant) :
        // l'ajout ne concerne que les bases déjà en v3.
        await m.addColumn(startupDetails, startupDetails.categorie);
      }
      if (from < 5) {
        // Préférences d'affichage (ordre des blocs du dashboard startups).
        await m.createTable(preferences);
      }
      if (from < 6) {
        // Marché secondaire des startups (migration purement additive).
        await m.createTable(secondaryTransactions);
      }
    },
    beforeOpen: (details) async {
      // Cascade des suppressions (positions, fiches, documents, levées,
      // transactions secondaires) : SQLite ne l'active pas par défaut.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  // ---- Assets ----
  /// Ordre manuel (`sortOrder`), puis date de création.
  Future<List<Asset>> allAssets() => (select(assets)..orderBy([
    (t) => OrderingTerm.asc(t.sortOrder),
    (t) => OrderingTerm.asc(t.createdAt),
  ])).get();

  Future<int> addAsset(AssetsCompanion entry) => into(assets).insert(entry);

  Future<void> updateAsset(Asset asset) => update(assets).replace(asset);

  /// Supprime un actif et toutes ses données rattachées.
  ///
  /// Les enfants sont supprimés explicitement (et non seulement par la
  /// cascade SQLite) pour rester correct même si `PRAGMA foreign_keys` est
  /// désactivé sur la connexion.
  Future<void> deleteAsset(int id) async {
    await transaction(() async {
      await _deleteAssetChildren(id);
      await (delete(assets)..where((t) => t.id.equals(id))).go();
    });
  }

  /// Supprime tous les actifs d'un type (`AssetType.name`) et leurs données
  /// rattachées. Renvoie le nombre d'actifs supprimés.
  Future<int> deleteAssetsOfType(String type) async {
    final rows = await (select(
      assets,
    )..where((t) => t.type.equals(type))).get();
    await transaction(() async {
      for (final row in rows) {
        await _deleteAssetChildren(row.id);
        await (delete(assets)..where((t) => t.id.equals(row.id))).go();
      }
    });
    return rows.length;
  }

  Future<void> _deleteAssetChildren(int assetId) async {
    await (delete(positions)..where((t) => t.assetId.equals(assetId))).go();
    await (delete(rentals)..where((t) => t.assetId.equals(assetId))).go();
    await (delete(documents)..where((t) => t.assetId.equals(assetId))).go();
    await (delete(
      startupDetails,
    )..where((t) => t.assetId.equals(assetId))).go();
    await (delete(fundingRounds)..where((t) => t.assetId.equals(assetId))).go();
    await (delete(
      secondaryTransactions,
    )..where((t) => t.assetId.equals(assetId))).go();
  }

  /// Prochaine position libre de l'ordre manuel (max + 1).
  Future<int> nextAssetSortOrder() async {
    final maxOrder = assets.sortOrder.max();
    final row = await (selectOnly(assets)..addColumns([maxOrder])).getSingle();
    return (row.read(maxOrder) ?? 0) + 1;
  }

  /// Réécrit `sortOrder` selon l'ordre fourni (index 0, 1, 2…).
  Future<void> reorderAssets(List<int> orderedIds) async {
    await transaction(() async {
      for (var i = 0; i < orderedIds.length; i++) {
        await (update(assets)..where((t) => t.id.equals(orderedIds[i])))
            .write(AssetsCompanion(sortOrder: Value(i)));
      }
    });
  }

  // ---- Positions ----
  Future<List<Position>> positionsFor(int assetId) =>
      (select(positions)..where((t) => t.assetId.equals(assetId))).get();

  Future<List<Position>> allPositions() => select(positions).get();

  Future<int> addPosition(PositionsCompanion entry) =>
      into(positions).insert(entry);

  Future<void> deletePosition(int id) =>
      (delete(positions)..where((t) => t.id.equals(id))).go();

  // ---- Prix ----
  Future<MarketPrice?> priceFor(String symbol) => (select(
    priceCache,
  )..where((t) => t.symbol.equals(symbol))).getSingleOrNull();

  Future<void> upsertPrice(String symbol, double price, String currency) =>
      into(priceCache).insertOnConflictUpdate(
        PriceCacheCompanion.insert(
          symbol: symbol,
          price: price,
          currency: currency,
          updatedAt: DateTime.now(),
        ),
      );

  Future<Map<String, double>> cachedPricesFor(Set<String> symbols) async {
    if (symbols.isEmpty) return {};
    final rows = await (select(
      priceCache,
    )..where((t) => t.symbol.isIn(symbols))).get();
    return {for (final r in rows) r.symbol: r.price};
  }

  Future<DateTime?> latestPriceUpdate() async {
    final rows = await select(priceCache).get();
    if (rows.isEmpty) return null;
    return rows.map((r) => r.updatedAt).reduce((a, b) => a.isAfter(b) ? a : b);
  }

  // ---- Snapshots ----
  Future<void> saveSnapshot(double netWorth) => into(
    snapshots,
  ).insert(SnapshotsCompanion.insert(date: DateTime.now(), netWorth: netWorth));

  Future<List<NetWorthSnapshot>> allSnapshots() =>
      (select(snapshots)..orderBy([(t) => OrderingTerm.asc(t.date)])).get();

  Future<void> pruneSnapshots(int keepDays) async {
    final cutoff = DateTime.now().subtract(Duration(days: keepDays));
    await (delete(
      snapshots,
    )..where((t) => t.date.isSmallerThanValue(cutoff))).go();
  }

  // ---- Location ----
  Future<Rental?> rentalFor(int assetId) => (select(
    rentals,
  )..where((t) => t.assetId.equals(assetId))).getSingleOrNull();

  Future<List<Rental>> allRentals() => select(rentals).get();

  /// Crée ou met à jour la fiche de location du bien.
  Future<void> saveRental(RentalsCompanion entry) async {
    final existing = await rentalFor(entry.assetId.value);
    if (existing == null) {
      await into(rentals).insert(entry);
    } else {
      await (update(rentals)..where((t) => t.id.equals(existing.id))).write(
        entry.copyWith(id: Value(existing.id)),
      );
    }
  }

  Future<void> deleteRental(int assetId) =>
      (delete(rentals)..where((t) => t.assetId.equals(assetId))).go();

  // ---- Documents ----
  Future<List<AssetDocument>> documentsFor(int assetId) =>
      (select(documents)
            ..where((t) => t.assetId.equals(assetId))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();

  Future<List<AssetDocument>> allDocuments() => select(documents).get();

  Future<int> addDocument(DocumentsCompanion entry) =>
      into(documents).insert(entry);

  Future<void> deleteDocument(int id) =>
      (delete(documents)..where((t) => t.id.equals(id))).go();

  // ---- Startups ----
  Future<StartupDetail?> startupDetailsFor(int assetId) => (select(
    startupDetails,
  )..where((t) => t.assetId.equals(assetId))).getSingleOrNull();

  Future<List<StartupDetail>> allStartupDetails() => select(startupDetails).get();

  /// Crée ou met à jour la fiche startup de l'actif.
  Future<void> saveStartupDetails(StartupDetailsCompanion entry) async {
    final existing = await startupDetailsFor(entry.assetId.value);
    if (existing == null) {
      await into(startupDetails).insert(entry);
    } else {
      await (update(
        startupDetails,
      )..where((t) => t.id.equals(existing.id))).write(
        entry.copyWith(id: Value(existing.id)),
      );
    }
  }

  Future<void> deleteStartupDetails(int assetId) =>
      (delete(startupDetails)..where((t) => t.assetId.equals(assetId))).go();

  /// Levées de fonds de la startup, de la plus récente à la plus ancienne
  /// (les dates inconnues passent en dernier).
  Future<List<FundingRound>> fundingRoundsFor(int assetId) async {
    final rows = await (select(
      fundingRounds,
    )..where((t) => t.assetId.equals(assetId))).get();
    rows.sort((a, b) {
      final da = a.date;
      final db = b.date;
      if (da == null && db == null) return a.id.compareTo(b.id);
      if (da == null) return 1;
      if (db == null) return -1;
      return db.compareTo(da);
    });
    return rows;
  }

  Future<List<FundingRound>> allFundingRounds() => select(fundingRounds).get();

  Future<int> addFundingRound(FundingRoundsCompanion entry) =>
      into(fundingRounds).insert(entry);

  Future<void> deleteFundingRound(int id) =>
      (delete(fundingRounds)..where((t) => t.id.equals(id))).go();

  /// Supprime toutes les levées de fonds d'un actif (remplacement en bloc lors
  /// d'un ré-import CSV).
  Future<void> deleteFundingRounds(int assetId) =>
      (delete(fundingRounds)..where((t) => t.assetId.equals(assetId))).go();

  // ---- Marché secondaire ----

  /// Transactions secondaires d'un actif, de la plus ancienne à la plus
  /// récente (les dates inconnues passent en dernier).
  Future<List<SecondaryTransaction>> secondaryTransactionsFor(
    int assetId,
  ) async {
    final rows = await (select(
      secondaryTransactions,
    )..where((t) => t.assetId.equals(assetId))).get();
    rows.sort(_compareSecondary);
    return rows;
  }

  Future<List<SecondaryTransaction>> allSecondaryTransactions() async {
    final rows = await select(secondaryTransactions).get();
    rows.sort((a, b) {
      final cmp = _compareSecondary(a, b);
      return cmp != 0 ? cmp : a.assetId.compareTo(b.assetId);
    });
    return rows;
  }

  Future<int> addSecondaryTransaction(SecondaryTransactionsCompanion entry) =>
      into(secondaryTransactions).insert(entry);

  Future<void> deleteSecondaryTransaction(int id) =>
      (delete(secondaryTransactions)..where((t) => t.id.equals(id))).go();

  /// Supprime toutes les transactions secondaires d'un actif (remplacement en
  /// bloc lors d'un ré-import CSV).
  Future<void> deleteSecondaryTransactions(int assetId) => (delete(
    secondaryTransactions,
  )..where((t) => t.assetId.equals(assetId))).go();

  // ---- Préférences ----
  /// Valeur d'une préférence d'affichage, ou null si la clé est absente.
  Future<String?> preferenceValue(String key) async {
    final row = await (select(
      preferences,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  /// Crée ou met à jour une préférence d'affichage.
  Future<void> setPreference(String key, String value) =>
      into(preferences).insertOnConflictUpdate(
        PreferencesCompanion.insert(key: key, value: value),
      );
}

/// Ordre d'affichage des transactions secondaires : date croissante, dates
/// inconnues en dernier, puis identifiant (ordre de saisie).
int _compareSecondary(SecondaryTransaction a, SecondaryTransaction b) {
  final da = a.date;
  final db = b.date;
  if (da == null && db == null) return a.id.compareTo(b.id);
  if (da == null) return 1;
  if (db == null) return -1;
  final cmp = da.compareTo(db);
  return cmp != 0 ? cmp : a.id.compareTo(b.id);
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'patrimoine.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
