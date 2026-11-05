import 'package:intl/intl.dart';

final NumberFormat _euroWhole = NumberFormat.currency(
  locale: 'fr_FR',
  symbol: '€',
  decimalDigits: 0,
);
final NumberFormat _euroCents = NumberFormat.currency(
  locale: 'fr_FR',
  symbol: '€',
  decimalDigits: 2,
);

/// Montant en euros, sans décimales par défaut.
String formatEuro(double v, {bool cents = false}) =>
    cents ? _euroCents.format(v) : _euroWhole.format(v);

/// Montant signé (préfixe « + » pour les valeurs positives).
String formatSignedEuro(double v, {bool cents = false}) {
  final s = formatEuro(v, cents: cents);
  return v > 0 ? '+$s' : s;
}

/// Pourcentage signé.
String formatPct(double v) => '${v >= 0 ? '+' : ''}${v.toStringAsFixed(1)} %';

/// Pourcentage simple (part de répartition).
String formatShare(double v) => '${v.toStringAsFixed(1)} %';

/// Date complète (« 05/11/2026 »).
String formatDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

/// Date courte sans heure (« 05/11 »), pour les axes de graphique.
String formatShortDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

/// Montant compact pour un axe de graphique (« 1,2 M€ », « 500 k€ »).
String formatCompactEuro(double v) {
  final abs = v.abs();
  if (abs >= 1000000) return '${_compactNumber(v / 1000000)} M€';
  if (abs >= 1000) return '${_compactNumber(v / 1000)} k€';
  return '${_compactNumber(v)} €';
}

final NumberFormat _compact = NumberFormat('0.#', 'fr_FR');

String _compactNumber(double v) => _compact.format(v);

/// Heure/date courte pour l'affichage (« 05/11 20:15 »).
String formatTime(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')} '
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
