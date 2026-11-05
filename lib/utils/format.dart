import 'package:intl/intl.dart';

final NumberFormat _euroWhole =
    NumberFormat.currency(locale: 'fr_FR', symbol: '€', decimalDigits: 0);
final NumberFormat _euroCents =
    NumberFormat.currency(locale: 'fr_FR', symbol: '€', decimalDigits: 2);

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
