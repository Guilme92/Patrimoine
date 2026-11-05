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
