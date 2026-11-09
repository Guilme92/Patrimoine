import 'dart:math';

import '../data/database.dart';

/// Indicateurs de performance d'une startup non cotée.
///
/// Le prix actuel est saisi MANUELLEMENT (aucune cotation de marché) ;
/// une sortie (`statut == 'sorti'`) se valorise au produit de sortie, et
/// une radiation vaut zéro.

/// Capital investi total (frais d'entrée INCLUS) : `montantInvesti` quand il
/// est renseigné (montant réellement investi, frais compris), sinon quantité
/// × prix d'entrée + frais. Indépendant du PRU corrigé des ventes.
double investedCapital(StartupDetail s) => s.montantInvesti > 0
    ? s.montantInvesti
    : s.quantite * s.prixEntree + s.frais;

/// Valeur de la ligne à date.
double lineValue(StartupDetail s) {
  if (s.statut == 'sorti') return s.exitProduit;
  if (s.statut == 'radie') return 0;
  return s.quantite * s.prixActuel;
}

/// Coût de revient des actions restantes (frais d'entrée inclus), réparti au
/// prorata des actions restantes sur les actions achetées ([totalSold] =
/// actions revendues). Le capital investi ([investedCapital]) porte déjà les
/// frais d'entrée.
double remainingCost(StartupDetail s, {double totalSold = 0}) {
  final bought = s.quantite + totalSold;
  if (bought <= 0) return 0;
  return investedCapital(s) * (s.quantite / bought);
}

/// Plus-value latente sur les actions RESTANTES : valeur restante − coût de
/// revient restant (frais inclus).
///
/// Les frais réduisent la plus-value (ils font partie du coût de revient).
/// Une sortie ou une radiation ne porte plus de PV latente.
double unrealizedGain(StartupDetail s, {double totalSold = 0}) {
  if (s.statut == 'sorti' || s.statut == 'radie') return 0;
  return s.quantite * s.prixActuel - remainingCost(s, totalSold: totalSold);
}

/// Plus-value latente en pourcentage du capital investi.
double unrealizedGainPct(StartupDetail s, {double totalSold = 0}) {
  final capital = investedCapital(s);
  if (capital <= 0) return 0;
  return unrealizedGain(s, totalSold: totalSold) / capital * 100;
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
