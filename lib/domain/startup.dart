import 'dart:math';

import '../data/database.dart';

/// Indicateurs de performance d'une startup non cotée.
///
/// Le prix actuel est saisi MANUELLEMENT (aucune cotation de marché) ;
/// une sortie (`statut == 'sorti'`) se valorise au produit de sortie, et
/// une radiation vaut zéro.

/// Capital investi : quantité × prix d'entrée + frais.
double investedCapital(StartupDetail s) => s.quantite * s.prixEntree + s.frais;

/// Valeur de la ligne à date.
double lineValue(StartupDetail s) {
  if (s.statut == 'sorti') return s.exitProduit;
  if (s.statut == 'radie') return 0;
  return s.quantite * s.prixActuel;
}

/// Plus-value latente (valeur − capital investi).
double unrealizedGain(StartupDetail s) => lineValue(s) - investedCapital(s);

/// Plus-value latente en pourcentage du capital investi.
double unrealizedGainPct(StartupDetail s) {
  final capital = investedCapital(s);
  if (capital <= 0) return 0;
  return unrealizedGain(s) / capital * 100;
}

/// Multiple sur capital investi (1× = capital remboursé).
double moic(StartupDetail s) {
  final capital = investedCapital(s);
  if (capital <= 0) return 0;
  return lineValue(s) / capital;
}

/// Plus-value réalisée : uniquement pour une ligne sortie.
double realizedGain(StartupDetail s) =>
    s.statut == 'sorti' ? s.exitProduit - investedCapital(s) : 0;

/// TRI annualisé en % : (valeur / capital)^(1/années) − 1.
///
/// [today] permet de figer la date de valorisation dans les tests. La période
/// court de la date d'investissement à la date de sortie, ou à aujourd'hui.
double triAnnualizedPct(StartupDetail s, {DateTime? today}) {
  final capital = investedCapital(s);
  final start = s.dateInvestissement;
  if (capital <= 0 || start == null) return 0;
  final end = (s.statut == 'sorti' && s.exitDate != null)
      ? s.exitDate!
      : (today ?? DateTime.now());
  if (!end.isAfter(start)) return 0;
  final years = end.difference(start).inDays / 365.25;
  if (years <= 0) return 0;
  return (pow(lineValue(s) / capital, 1 / years) - 1) * 100;
}
