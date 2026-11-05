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

@DriftDatabase(tables: [Assets, Positions, PriceCache, Snapshots])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // ---- Assets ----
  Future<List<Asset>> allAssets() =>
      (select(assets)..orderBy([(t) => OrderingTerm.asc(t.createdAt)])).get();

  Future<int> addAsset(AssetsCompanion entry) => into(assets).insert(entry);

  Future<void> updateAsset(Asset asset) =>
      update(assets).replace(asset);

  Future<void> deleteAsset(int id) =>
      (delete(assets)..where((t) => t.id.equals(id))).go();

  // ---- Positions ----
  Future<List<Position>> positionsFor(int assetId) =>
      (select(positions)..where((t) => t.assetId.equals(assetId))).get();

  Future<List<Position>> allPositions() => select(positions).get();

  Future<int> addPosition(PositionsCompanion entry) =>
      into(positions).insert(entry);

  Future<void> deletePosition(int id) =>
      (delete(positions)..where((t) => t.id.equals(id))).go();

  // ---- Prix ----
  Future<MarketPrice?> priceFor(String symbol) =>
      (select(priceCache)..where((t) => t.symbol.equals(symbol))).getSingleOrNull();

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
    final rows = await (select(priceCache)..where((t) => t.symbol.isIn(symbols)))
        .get();
    return {for (final r in rows) r.symbol: r.price};
  }

  Future<DateTime?> latestPriceUpdate() async {
    final rows = await select(priceCache).get();
    if (rows.isEmpty) return null;
    return rows.map((r) => r.updatedAt).reduce((a, b) => a.isAfter(b) ? a : b);
  }

  // ---- Snapshots ----
  Future<void> saveSnapshot(double netWorth) => into(snapshots).insert(
        SnapshotsCompanion.insert(
          date: DateTime.now(),
          netWorth: netWorth,
        ),
      );

  Future<List<NetWorthSnapshot>> allSnapshots() =>
      (select(snapshots)..orderBy([(t) => OrderingTerm.asc(t.date)])).get();

  Future<void> pruneSnapshots(int keepDays) async {
    final cutoff = DateTime.now().subtract(Duration(days: keepDays));
    await (delete(snapshots)..where((t) => t.date.isSmallerThanValue(cutoff)))
        .go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'patrimoine.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
