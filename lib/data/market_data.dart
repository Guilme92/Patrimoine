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

/// Récupération des prix via l'API publique Yahoo Finance (non officielle).
///
/// Format des symboles :
///  - Action US : `AAPL`
///  - Action / ETF Euronext Paris : `AIR.PA`, `CW8.PA`
///  - Crypto : `BTC-USD`, `ETH-USD`
///  - Devise : `EURUSD=X`
///  - Or : `GC=F`
class MarketDataService {
  static const _base = 'https://query1.finance.yahoo.com/v8/finance/chart/';

  Future<MarketQuote?> fetchQuote(String symbol) async {
    final uri = Uri.parse(
        '$_base${Uri.encodeComponent(symbol)}?interval=1d&range=1d');
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
}
