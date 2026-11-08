import 'dart:convert';

import 'package:http/http.dart' as http;

/// Cotation d'un symbole.
class MarketQuote {
  final String symbol;
  final double price;
  final String currency;
  const MarketQuote({
    required this.symbol,
    required this.price,
    required this.currency,
  });
}

/// Résultat de la recherche d'un symbole boursier.
class SymbolSearchResult {
  final String symbol;
  final String name;
  final String exchange;
  final String type;

  /// Prix actuel converti en EUR (null si la cotation est indisponible).
  double? priceEur;

  SymbolSearchResult({
    required this.symbol,
    required this.name,
    required this.exchange,
    required this.type,
    this.priceEur,
  });
}

/// Récupération des prix de marché.
///
/// - Yahoo Finance (non officiel) pour actions, ETF, devises, grandes cryptos :
///   `AAPL`, `AIR.PA`, `CW8.PA`, `BTC-USD`, `EURUSD=X`, `GC=F`.
/// - CoinGecko en repli pour les petites cryptos absentes de Yahoo.
class MarketDataService {
  static const _yahooBase =
      'https://query1.finance.yahoo.com/v8/finance/chart/';
  static const _coingeckoBase = 'https://api.coingecko.com/api/v3/';

  final Map<String, String> _coinIdCache = {};

  Future<MarketQuote?> fetchQuote(String symbol) async {
    final uri = Uri.parse(
        '$_yahooBase${Uri.encodeComponent(symbol)}?interval=1d&range=1d');
    try {
      final res = await http
          .get(uri, headers: const {'User-Agent': 'Mozilla/5.0'})
          .timeout(const Duration(seconds: 15));
      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final result = (data['chart']?['result'] as List?)?.first;
      if (result == null) return null;
      final meta = result['meta'] as Map<String, dynamic>;
      final price = (meta['regularMarketPrice'] as num?)?.toDouble();
      if (price == null || price <= 0) return null;
      final currency = (meta['currency'] as String?) ?? 'USD';
      return MarketQuote(symbol: symbol, price: price, currency: currency);
    } catch (_) {
      return null;
    }
  }

  /// Récupère plusieurs cotations en parallèle. Ignore les symboles introuvables.
  Future<Map<String, MarketQuote>> fetchQuotes(Iterable<String> symbols) async {
    final unique = symbols.toSet();
    final results = await Future.wait(unique.map(fetchQuote));
    final map = <String, MarketQuote>{};
    for (final q in results) {
      if (q != null) map[q.symbol] = q;
    }
    return map;
  }

  /// Recherche un symbole boursier par nom (ex. « hermes » → RMS.PA).
  ///
  /// Interroge la recherche Yahoo Finance puis enrichit chaque résultat avec
  /// son prix actuel converti en EUR quand la cotation est disponible.
  /// Les symboles sans cotation (fonds non référencés, titres retirés) sont
  /// renvoyés sans prix. Retourne une liste vide en cas d'échec.
  Future<List<SymbolSearchResult>> searchSymbols(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const [];
    final uri = Uri.parse(
      'https://query1.finance.yahoo.com/v1/finance/search'
      '?q=${Uri.encodeComponent(trimmed)}'
      '&quotesCount=8&newsCount=0&listsCount=0',
    );
    try {
      final res = await http
          .get(uri, headers: const {'User-Agent': 'Mozilla/5.0'})
          .timeout(const Duration(seconds: 12));
      if (res.statusCode != 200) return const [];
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final quotes = (data['quotes'] as List?) ?? const [];
      final results = <SymbolSearchResult>[];
      for (final q in quotes) {
        if (q is! Map<String, dynamic>) continue;
        final symbol = (q['symbol'] as String?)?.trim() ?? '';
        if (symbol.isEmpty || q['isYahooFinance'] != true) continue;
        results.add(
          SymbolSearchResult(
            symbol: symbol,
            name: _nameOrFallback(q['shortname'] as String?, symbol),
            exchange: (q['exchDisp'] as String?) ??
                (q['exchange'] as String?) ??
                '',
            type: (q['typeDisp'] as String?) ??
                (q['quoteType'] as String?) ??
                '',
          ),
        );
      }
      await _attachPrices(results);
      return results;
    } catch (_) {
      return const [];
    }
  }

  /// Remplit `priceEur` de chaque résultat (cotation convertie en EUR).
  Future<void> _attachPrices(List<SymbolSearchResult> results) async {
    final quotesMap = await fetchQuotes(results.map((r) => r.symbol));
    final rates = <String, double>{};
    for (final r in results) {
      final q = quotesMap[r.symbol];
      if (q == null || q.price <= 0) continue;
      var price = q.price;
      if (q.currency != 'EUR') {
        if (!rates.containsKey(q.currency)) {
          final rate = await eurRateFor(q.currency);
          rates[q.currency] = rate ?? 0;
        }
        final rate = rates[q.currency]!;
        if (rate > 0) price = q.price * rate;
      }
      r.priceEur = price;
    }
  }

  /// Taux de conversion « 1 `currency` = X EUR ». Retourne null si indisponible.
  /// `EURUSD=X` donne le nombre de USD pour 1 EUR, donc 1 USD = 1 / prix.
  Future<double?> eurRateFor(String currency) async {
    if (currency == 'EUR') return 1.0;
    final q = await fetchQuote('EUR$currency=X');
    if (q == null || q.price <= 0) return null;
    return 1.0 / q.price;
  }

  /// Prix d'une crypto via CoinGecko (repli pour les tokens absents de Yahoo).
  /// Retourne le prix en EUR, ou null si le token est introuvable.
  Future<MarketQuote?> fetchCryptoPrice(String symbol) async {
    final target = symbol.toLowerCase();
    try {
      var id = _coinIdCache[target];
      id ??= await _searchCoinId(target);
      if (id == null) return null;
      _coinIdCache[target] = id;

      final uri = Uri.parse(
          '${_coingeckoBase}simple/price?ids=${Uri.encodeComponent(id)}&vs_currencies=eur');
      final res = await http
          .get(uri, headers: const {'User-Agent': 'Mozilla/5.0'})
          .timeout(const Duration(seconds: 15));
      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final eur = (data[id]?['eur'] as num?)?.toDouble();
      if (eur == null || eur <= 0) return null;
      return MarketQuote(symbol: symbol, price: eur, currency: 'EUR');
    } catch (_) {
      return null;
    }
  }

  /// Trouve l'id CoinGecko d'un symbole (préfère la plus grosse capitalisation).
  Future<String?> _searchCoinId(String query) async {
    final uri = Uri.parse(
        '${_coingeckoBase}search?query=${Uri.encodeComponent(query)}');
    final res = await http
        .get(uri, headers: const {'User-Agent': 'Mozilla/5.0'})
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) return null;
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final coins = data['coins'] as List? ?? const [];
    String? bestId;
    int? bestRank;
    for (final c in coins) {
      final sym = (c['symbol'] as String? ?? '').toLowerCase();
      if (sym != query) continue;
      final rank = (c['market_cap_rank'] as num?)?.toInt();
      if (bestId == null || (rank != null && (bestRank == null || rank < bestRank))) {
        bestId = c['id'] as String?;
        bestRank = rank;
      }
    }
    return bestId;
  }
}

String _nameOrFallback(String? name, String symbol) {
  final n = name?.trim();
  return (n == null || n.isEmpty) ? symbol : n;
}
