import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';

import '../data/database.dart';
import '../data/market_data.dart';
import '../domain/portfolio.dart';
import '../models/asset_type.dart';

/// État central du patrimoine : charge les données, calcule la synthèse,
/// expose les mutations.
class PortfolioController extends ChangeNotifier {
  final AppDatabase db;
  final MarketDataService market;

  List<Asset> _assets = [];
  Map<int, List<Position>> _positions = {};
  Map<String, double> _prices = {};
  bool _loading = true;
  String? _error;

  PortfolioController(this.db, {MarketDataService? market})
      : market = market ?? MarketDataService();

  List<Asset> get assets => _assets;
  bool get loading => _loading;
  String? get error => _error;

  PortfolioSummary get summary => summarize(
        assets: _assets,
        positionsByAsset: _positions,
        prices: _prices,
      );

  List<Position> positionsOf(int assetId) => _positions[assetId] ?? const [];

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
    _prices = await db.cachedPricesFor(symbols);
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
    await db.addAsset(AssetsCompanion.insert(
      name: name,
      type: type.name,
      value: Value(value),
      currency: Value(currency),
      institution: Value(institution),
      note: Value(note),
    ));
    await load();
  }

  Future<void> updateAssetValue(int id, double value) async {
    final asset = _assets.firstWhere((a) => a.id == id);
    await db.updateAsset(asset.copyWith(value: value));
    await load();
  }

  Future<void> deleteAsset(int id) async {
    await db.deleteAsset(id);
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
    await db.addPosition(PositionsCompanion.insert(
      assetId: assetId,
      symbol: symbol,
      name: name,
      quantity: quantity,
      unitCost: unitCost,
      assetClass: Value(assetClass),
      sector: Value(sector),
      region: Value(region),
    ));
    await load();
  }

  Future<void> deletePosition(int id) async {
    await db.deletePosition(id);
    await load();
  }

  /// Rafraîchit les prix de marché de toutes les positions.
  Future<void> refreshPrices() async {
    final symbols =
        _positions.values.expand((l) => l).map((p) => p.symbol).toSet();
    if (symbols.isEmpty) return;
    final quotes = await market.fetchQuotes(symbols);
    for (final q in quotes.values) {
      await db.upsertPrice(q.symbol, q.price, q.currency);
    }
    await _reload();
    notifyListeners();
  }

  /// Sauvegarde un point d'historique du patrimoine net.
  Future<void> snapshot() async {
    await db.saveSnapshot(summary.netWorth);
  }
}
