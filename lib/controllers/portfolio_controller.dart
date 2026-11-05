import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../data/database.dart';
import '../data/document_store.dart';
import '../data/market_data.dart';
import '../domain/portfolio.dart';
import '../models/asset_type.dart';
import '../models/rental.dart';

/// Résultat d'un rafraîchissement des prix.
class PriceRefreshResult {
  final int updated;
  final int failed;
  const PriceRefreshResult({required this.updated, required this.failed});
}

/// État central du patrimoine : charge les données, calcule la synthèse,
/// expose les mutations.
class PortfolioController extends ChangeNotifier {
  final AppDatabase db;
  final MarketDataService market;
  final DocumentStore documentStore;

  List<Asset> _assets = [];
  Map<int, List<Position>> _positions = {};
  Map<int, Rental> _rentals = {};
  Map<int, List<AssetDocument>> _documents = {};
  Map<String, double> _prices = {};
  DateTime? _lastPriceUpdate;
  bool _loading = true;
  String? _error;

  PortfolioController(
    this.db, {
    MarketDataService? market,
    DocumentStore? documentStore,
  }) : market = market ?? MarketDataService(),
       documentStore = documentStore ?? const DocumentStore();

  List<Asset> get assets => _assets;
  bool get loading => _loading;
  String? get error => _error;
  DateTime? get lastPriceUpdate => _lastPriceUpdate;

  PortfolioSummary get summary =>
      summarize(assets: _assets, positionsByAsset: _positions, prices: _prices);

  List<Position> positionsOf(int assetId) => _positions[assetId] ?? const [];

  /// Actif courant (rafraîchi après mutation), ou null s'il a été supprimé.
  Asset? assetById(int id) {
    for (final a in _assets) {
      if (a.id == id) return a;
    }
    return null;
  }

  Rental? rentalOf(int assetId) => _rentals[assetId];

  List<AssetDocument> documentsOf(int assetId) =>
      _documents[assetId] ?? const [];

  Map<String, double> get prices => _prices;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _reload();
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> _reload() async {
    _assets = await db.allAssets();
    final pos = <int, List<Position>>{};
    final symbols = <String>{};
    for (final a in _assets) {
      final list = await db.positionsFor(a.id);
      pos[a.id] = list;
      symbols.addAll(list.map((p) => p.symbol));
    }
    _positions = pos;

    final rentals = <int, Rental>{};
    for (final r in await db.allRentals()) {
      rentals[r.assetId] = r;
    }
    _rentals = rentals;

    final docs = <int, List<AssetDocument>>{};
    for (final d in await db.allDocuments()) {
      docs.putIfAbsent(d.assetId, () => []).add(d);
    }
    for (final list in docs.values) {
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    _documents = docs;

    _prices = await db.cachedPricesFor(symbols);
    _lastPriceUpdate = await db.latestPriceUpdate();
  }

  // ---- Mutations ----

  Future<void> addAsset({
    required String name,
    required AssetType type,
    double value = 0,
    String currency = 'EUR',
    String? institution,
    String? note,
  }) async {
    await db.addAsset(
      AssetsCompanion.insert(
        name: name,
        type: type.name,
        value: Value(value),
        currency: Value(currency),
        institution: Value(institution),
        note: Value(note),
      ),
    );
    await load();
  }

  /// Met à jour un actif existant (nom, type, valeur, devise, établissement,
  /// note).
  Future<void> updateAsset({
    required int id,
    required String name,
    required AssetType type,
    required double value,
    required String currency,
    String? institution,
    String? note,
  }) async {
    final asset = assetById(id);
    if (asset == null) return;
    await db.updateAsset(
      asset.copyWith(
        name: name,
        type: type.name,
        value: value,
        currency: currency,
        institution: Value(institution),
        note: Value(note),
      ),
    );
    await load();
  }

  Future<void> updateAssetValue(int id, double value) async {
    final asset = _assets.firstWhere((a) => a.id == id);
    await db.updateAsset(asset.copyWith(value: value));
    await load();
  }

  Future<void> deleteAsset(int id) async {
    final docs = documentsOf(id);
    await db.deleteAsset(id);
    for (final d in docs) {
      await documentStore.deleteFile(d.filePath);
    }
    await load();
  }

  Future<void> addPosition({
    required int assetId,
    required String symbol,
    required String name,
    required double quantity,
    required double unitCost,
    String? assetClass,
    String? sector,
    String? region,
  }) async {
    await db.addPosition(
      PositionsCompanion.insert(
        assetId: assetId,
        symbol: symbol,
        name: name,
        quantity: quantity,
        unitCost: unitCost,
        assetClass: Value(assetClass),
        sector: Value(sector),
        region: Value(region),
      ),
    );
    await load();
  }

  Future<void> deletePosition(int id) async {
    await db.deletePosition(id);
    await load();
  }

  // ---- Location ----

  /// Crée ou met à jour la fiche de location du bien.
  Future<void> saveRental({
    required int assetId,
    required RentalDraft draft,
  }) async {
    await db.saveRental(draft.toCompanion(assetId));
    await load();
  }

  Future<void> deleteRental(int assetId) async {
    await db.deleteRental(assetId);
    await load();
  }

  // ---- Documents ----

  /// Copie [file] dans le stockage de l'app puis l'attache à l'actif.
  Future<void> attachDocument({
    required int assetId,
    required File file,
    required String label,
    String? note,
  }) async {
    final copied = await documentStore.copyIn(assetId: assetId, source: file);
    await db.addDocument(
      DocumentsCompanion.insert(
        assetId: assetId,
        label: label.trim(),
        fileName: p.basename(copied.path),
        filePath: copied.path,
        note: Value(_trimOrNull(note)),
      ),
    );
    await load();
  }

  /// Supprime la ligne et le fichier copié sur le disque.
  Future<void> removeDocument(AssetDocument doc) async {
    await db.deleteDocument(doc.id);
    await documentStore.deleteFile(doc.filePath);
    await load();
  }

  /// Rafraîchit les prix de marché des positions.
  /// [missingOnly] : ne récupère que les symboles sans prix en cache.
  Future<PriceRefreshResult> refreshPrices({bool missingOnly = false}) async {
    final all = _positions.values.expand((l) => l).map((p) => p.symbol).toSet();
    final targets = missingOnly
        ? all.where((s) => !_prices.containsKey(s)).toSet()
        : all;
    if (targets.isEmpty) {
      return const PriceRefreshResult(updated: 0, failed: 0);
    }
    return _fetchAndStore(targets);
  }

  Future<PriceRefreshResult> _fetchAndStore(Set<String> symbols) async {
    final quotes = <String, MarketQuote>{};
    quotes.addAll(await market.fetchQuotes(symbols));

    // Repli CoinGecko pour les symboles introuvables (petites cryptos).
    final missing = symbols.difference(quotes.keys.toSet());
    for (final s in missing) {
      final cq = await market.fetchCryptoPrice(s);
      if (cq != null) quotes[s] = cq;
    }

    // Devises à convertir vers EUR.
    final currencies = quotes.values
        .map((q) => q.currency)
        .where((c) => c != 'EUR')
        .toSet();
    final eurRates = <String, double>{};
    for (final c in currencies) {
      final rate = await market.eurRateFor(c);
      if (rate != null) eurRates[c] = rate;
    }

    var updated = 0;
    for (final q in quotes.values) {
      var price = q.price;
      if (q.currency != 'EUR' && eurRates.containsKey(q.currency)) {
        price = q.price * eurRates[q.currency]!;
      }
      await db.upsertPrice(q.symbol, price, 'EUR');
      updated++;
    }

    await _reload();
    notifyListeners();
    return PriceRefreshResult(
      updated: updated,
      failed: symbols.length - updated,
    );
  }

  /// Sauvegarde un point d'historique du patrimoine net.
  Future<void> snapshot() async {
    await db.saveSnapshot(summary.netWorth);
  }
}

String? _trimOrNull(String? v) {
  final t = v?.trim();
  return (t == null || t.isEmpty) ? null : t;
}
