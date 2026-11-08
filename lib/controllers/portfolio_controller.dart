import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../data/database.dart';
import '../data/csv_import.dart';
import '../data/document_store.dart';
import '../data/market_data.dart';
import '../domain/portfolio.dart';
import '../domain/startup_portfolio.dart';
import '../models/asset_type.dart';
import '../models/rental.dart';
import '../models/startup.dart';

/// Résultat d'un rafraîchissement des prix.
class PriceRefreshResult {
  final int updated;
  final int failed;
  const PriceRefreshResult({required this.updated, required this.failed});
}

/// Blocs réordonnables du dashboard startups (ordre par défaut :
/// onglets puis filtres).
const List<String> startupBlockIds = ['tabs', 'filters'];

/// Clé de préférence persistée pour l'ordre des blocs startups.
const String startupBlockOrderKey = 'startups.blockOrder';

/// Décode un ordre persisté (« tabs,filters ») en liste fiable : identifiants
/// inconnus ou doublons ignorés, blocs manquants ajoutés à la fin.
List<String> parseStartupBlockOrder(String? raw) {
  final seen = <String>{};
  final order = <String>[];
  final trimmed = raw?.trim() ?? '';
  if (trimmed.isNotEmpty) {
    for (final part in trimmed.split(',')) {
      final id = part.trim();
      if (id.isEmpty || !startupBlockIds.contains(id)) continue;
      if (seen.add(id)) order.add(id);
    }
  }
  for (final id in startupBlockIds) {
    if (seen.add(id)) order.add(id);
  }
  return order;
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
  Map<int, StartupDetail> _startups = {};
  Map<int, List<FundingRound>> _fundingRounds = {};
  Map<int, List<SecondaryTransaction>> _secondaryTransactions = {};
  Map<int, List<AssetDocument>> _documents = {};
  Map<String, double> _prices = {};
  Set<String> _failedSymbols = {};
  DateTime? _lastPriceUpdate;
  List<NetWorthSnapshot> _snapshots = [];
  List<String> _startupBlockOrder = List.unmodifiable(startupBlockIds);
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

  /// Historique du patrimoine net, un point par jour (ordre chronologique).
  List<NetWorthSnapshot> get snapshots => _snapshots;

  PortfolioSummary get summary => summarize(
    assets: _assets,
    positionsByAsset: _positions,
    prices: _prices,
    startupsByAsset: _startups,
  );

  List<Position> positionsOf(int assetId) => _positions[assetId] ?? const [];

  /// Ordre d'affichage des blocs du dashboard startups (persisté en base).
  List<String> get startupBlockOrder => _startupBlockOrder;

  /// Réordonne les blocs startups et persiste le nouvel ordre.
  Future<void> reorderStartupBlocks(List<String> order) async {
    final normalized = parseStartupBlockOrder(order.join(','));
    if (listEquals(normalized, _startupBlockOrder)) return;
    _startupBlockOrder = List.unmodifiable(normalized);
    notifyListeners();
    await db.setPreference(startupBlockOrderKey, normalized.join(','));
  }

  /// Actif courant (rafraîchi après mutation), ou null s'il a été supprimé.
  Asset? assetById(int id) {
    for (final a in _assets) {
      if (a.id == id) return a;
    }
    return null;
  }

  Rental? rentalOf(int assetId) => _rentals[assetId];

  StartupDetail? startupOf(int assetId) => _startups[assetId];

  /// Startups du portefeuille, prêtes pour le dashboard.
  ///
  /// Chaque actif de type startup est associé à sa fiche ; une startup créée
  /// sans fiche est exposée avec une fiche vide (quantités et prix à 0) pour
  /// rester visible et modifiable depuis l'onglet.
  /// Tri : date d'investissement croissante, non datées en dernier, puis nom.
  List<StartupEntry> get startupEntries {
    final list = <StartupEntry>[];
    for (final asset in _assets) {
      if (assetTypeFrom(asset.type) != AssetType.startup) continue;
      final detail = _startups[asset.id] ?? _emptyStartupDetail(asset);
      list.add(StartupEntry(asset: asset, detail: detail));
    }
    list.sort((a, b) {
      final da = a.detail.dateInvestissement;
      final dbDate = b.detail.dateInvestissement;
      if (da == null && dbDate == null) return _compareNames(a, b);
      if (da == null) return 1;
      if (dbDate == null) return -1;
      final cmp = da.compareTo(dbDate);
      return cmp != 0 ? cmp : _compareNames(a, b);
    });
    return list;
  }

  List<FundingRound> fundingRoundsOf(int assetId) =>
      _fundingRounds[assetId] ?? const [];

  /// Transactions de marché secondaire d'un actif, de la plus ancienne à la
  /// plus récente.
  List<SecondaryTransaction> secondaryTransactionsOf(int assetId) =>
      _secondaryTransactions[assetId] ?? const [];

  /// Valeur d'un actif (positions × prix, fiche startup, ou valeur manuelle).
  double valueOf(Asset asset) => assetValue(
    asset: asset,
    positions: positionsOf(asset.id),
    prices: _prices,
    startup: _startups[asset.id],
  );

  List<AssetDocument> documentsOf(int assetId) =>
      _documents[assetId] ?? const [];

  Map<String, double> get prices => _prices;

  /// Symboles pour lesquels la dernière tentative de rafraîchissement n'a
  /// remonté aucune cotation (Yahoo ni CoinGecko). Sert à signaler dans l'UI
  /// les positions dont le code boursier est probablement incorrect.
  Set<String> get failedSymbols => _failedSymbols;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _reload();
      await _maybeSnapshot();
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

    final startups = <int, StartupDetail>{};
    for (final s in await db.allStartupDetails()) {
      startups[s.assetId] = s;
    }
    _startups = startups;

    final rounds = <int, List<FundingRound>>{};
    for (final r in await db.allFundingRounds()) {
      rounds.putIfAbsent(r.assetId, () => []).add(r);
    }
    for (final entry in rounds.entries) {
      entry.value.sort((a, b) {
        final da = a.date;
        final db2 = b.date;
        if (da == null && db2 == null) return a.id.compareTo(b.id);
        if (da == null) return 1;
        if (db2 == null) return -1;
        return db2.compareTo(da);
      });
    }
    _fundingRounds = rounds;

    final secondary = <int, List<SecondaryTransaction>>{};
    for (final t in await db.allSecondaryTransactions()) {
      secondary.putIfAbsent(t.assetId, () => []).add(t);
    }
    _secondaryTransactions = secondary;

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
    _snapshots = await db.allSnapshots();
    _startupBlockOrder = parseStartupBlockOrder(
      await db.preferenceValue(startupBlockOrderKey),
    );
  }

  /// Enregistre un point du jour si l'historique n'en a pas encore :
  /// un seul snapshot par jour, capturé à la première ouverture ou
  /// modification de la journée.
  Future<void> _maybeSnapshot() async {
    // Rien à historiser tant qu'aucun actif n'existe (évite un point à 0 €).
    if (_assets.isEmpty) return;
    final now = DateTime.now();
    if (_snapshots.isNotEmpty) {
      final last = _snapshots.last.date;
      if (last.year == now.year &&
          last.month == now.month &&
          last.day == now.day) {
        return;
      }
    }
    await db.saveSnapshot(summary.netWorth);
    _snapshots = await db.allSnapshots();
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
        sortOrder: Value(await db.nextAssetSortOrder()),
      ),
    );
    await load();
  }

  /// Réordonne les actifs (drag & drop) : `sortOrder` = index de la liste.
  Future<void> reorderAssets(List<int> orderedIds) async {
    await db.reorderAssets(orderedIds);
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

  /// Supprime tous les actifs d'une catégorie (positions, fiches, documents,
  /// levées et transactions secondaires compris). Renvoie le nombre d'actifs
  /// supprimés.
  Future<int> deleteAssetsOfType(AssetType type) async {
    final docs = [
      for (final a in _assets)
        if (assetTypeFrom(a.type) == type) ...documentsOf(a.id),
    ];
    final deleted = await db.deleteAssetsOfType(type.name);
    for (final d in docs) {
      await documentStore.deleteFile(d.filePath);
    }
    await load();
    return deleted;
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

  Future<void> updatePosition(Position position) async {
    await db.updatePosition(position);
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

  // ---- Startups ----

  /// Crée ou met à jour la fiche startup de l'actif.
  Future<void> saveStartupDetails({
    required int assetId,
    required StartupDraft draft,
  }) async {
    await db.saveStartupDetails(draft.toCompanion(assetId));
    await load();
  }

  Future<void> deleteStartupDetails(int assetId) async {
    await db.deleteStartupDetails(assetId);
    await load();
  }

  Future<void> addFundingRound({
    required int assetId,
    required FundingRoundDraft draft,
  }) async {
    await db.addFundingRound(draft.toCompanion(assetId));
    await load();
  }

  Future<void> deleteFundingRound(int id) async {
    await db.deleteFundingRound(id);
    await load();
  }

  Future<void> addSecondaryTransaction({
    required int assetId,
    required SecondaryTransactionDraft draft,
  }) async {
    await db.addSecondaryTransaction(draft.toCompanion(assetId));
    await load();
  }

  Future<void> deleteSecondaryTransaction(int id) async {
    await db.deleteSecondaryTransaction(id);
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
    _failedSymbols = symbols.difference(quotes.keys.toSet());
    notifyListeners();
    return PriceRefreshResult(
      updated: updated,
      failed: symbols.length - updated,
    );
  }

  /// Sauvegarde un point d'historique du patrimoine net.
  Future<void> snapshot() async {
    await db.saveSnapshot(summary.netWorth);
    _snapshots = await db.allSnapshots();
    notifyListeners();
  }

  // ---- Import CSV ----

  /// Importe un lot d'actifs (immobilier ou startups) depuis un contenu CSV.
  ///
  /// Les lignes sont insérées directement via `db.*` puis un unique [load()]
  /// recharge l'état : les méthodes publiques (`addAsset`, `saveRental`,
  /// `saveStartupDetails`) déclenchent chacune un rechargement complet, ce qui
  /// serait bien trop lent pour N lignes.
  Future<CsvImportResult> importCsv({
    required String csv,
    required AssetType type,
  }) async {
    final parsed = type == AssetType.startup
        ? parseStartupCsv(csv)
        : parseRealEstateCsv(csv);
    if (parsed.rows.isEmpty) {
      return CsvImportResult(imported: 0, skipped: parsed.skipped);
    }

    // Déduplication : nom (insensible à la casse) -> id d'actif existant.
    final nameToId = <String, int>{};
    for (final a in _assets) {
      if (a.type == type.name) {
        nameToId[a.name.trim().toLowerCase()] = a.id;
      }
    }

    var imported = 0;
    var updated = 0;
    var sortOrder = await db.nextAssetSortOrder();
    await db.transaction(() async {
      for (final row in parsed.rows) {
        final key = row.name.trim().toLowerCase();
        var assetId = nameToId[key];
        final isNew = assetId == null;
        if (isNew) {
          assetId = await db.addAsset(
            AssetsCompanion.insert(
              name: row.name,
              type: type.name,
              value: Value(row.value),
              currency: Value(row.currency),
              institution: Value(row.institution),
              note: Value(row.note),
              sortOrder: Value(sortOrder++),
            ),
          );
          nameToId[key] = assetId;
        }
        final rental = row.rental;
        if (rental != null) {
          await db.saveRental(rental.toCompanion(assetId));
        }
        final startup = row.startup;
        if (startup != null) {
          await db.saveStartupDetails(startup.toCompanion(assetId));
        }
        // Levées de fonds : la colonne `levees` fait foi, à la création comme
        // au ré-import. On remplace les tours existants pour ne pas conserver
        // de levée obsolète ; une colonne vide laisse les tours en place
        // (saisies manuelles préservées).
        if (row.rounds.isNotEmpty) {
          await db.deleteFundingRounds(assetId);
          for (final round in row.rounds) {
            await db.addFundingRound(round.toCompanion(assetId));
          }
        }
        // Marché secondaire : même règle que les levées — la colonne fait foi
        // quand elle est renseignée, une colonne vide ne supprime rien.
        if (row.secondaryTransactions.isNotEmpty) {
          await db.deleteSecondaryTransactions(assetId);
          for (final tx in row.secondaryTransactions) {
            await db.addSecondaryTransaction(tx.toCompanion(assetId));
          }
        }
        if (isNew) {
          imported++;
        } else {
          updated++;
        }
      }
    });

    await load();
    return CsvImportResult(
      imported: imported,
      updated: updated,
      skipped: parsed.skipped,
    );
  }
}

String? _trimOrNull(String? v) {
  final t = v?.trim();
  return (t == null || t.isEmpty) ? null : t;
}

/// Fiche neutre pour une startup créée mais pas encore renseignée.
StartupDetail _emptyStartupDetail(Asset asset) => StartupDetail(
  id: 0,
  assetId: asset.id,
  quantite: 0,
  prixEntree: 0,
  frais: 0,
  prixActuel: 0,
  valorisationEntreprise: 0,
  statut: 'en_portefeuille',
  exitProduit: 0,
  createdAt: asset.createdAt,
);

int _compareNames(StartupEntry a, StartupEntry b) =>
    a.asset.name.toLowerCase().compareTo(b.asset.name.toLowerCase());
