import 'dart:math';

import '../data/database.dart';
import 'funding_rounds.dart';

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

/// Valeur de la ligne startup, harmonisée avec les levées de fonds.
///
/// Dès qu'au moins 2 tours exploitables existent, la valeur suit le calcul de
/// valorisation des actions (base 1 € au 1er tour, revalorisée à chaque tour) ;
/// sinon, repli sur `quantité × prix actuel`. Sortie et radiation inchangées.
double startupValue(StartupDetail s, List<FundingRound> rounds) {
  if (s.statut == 'en_portefeuille' && rounds.length >= 2) {
    final value = fundingRoundsValue(rounds);
    if (value != null) return value;
  }
  return lineValue(s);
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

/// Plus-value latente : valeur de la ligne − coût de revient des actions
/// restantes (frais inclus).
///
/// La valeur suit [startupValue] (calcul des levées dès 2 tours, sinon
/// quantité × prix actuel) ; le coût est réparti au prorata des actions
/// restantes ([totalSold] = actions revendues). Une sortie ou une radiation
/// ne porte plus de PV latente.
double unrealizedGain(
  StartupDetail s, {
  List<FundingRound> rounds = const [],
  double totalSold = 0,
}) {
  if (s.statut == 'sorti' || s.statut == 'radie') return 0;
  return startupValue(s, rounds) - remainingCost(s, totalSold: totalSold);
}

/// Plus-value latente en pourcentage du capital investi.
double unrealizedGainPct(
  StartupDetail s, {
  List<FundingRound> rounds = const [],
  double totalSold = 0,
}) {
  final capital = investedCapital(s);
  if (capital <= 0) return 0;
  return unrealizedGain(s, rounds: rounds, totalSold: totalSold) / capital * 100;
}

/// Multiple sur capital investi (1× = capital remboursé).
double moic(StartupDetail s, {List<FundingRound> rounds = const []}) {
  final capital = investedCapital(s);
  if (capital <= 0) return 0;
  return startupValue(s, rounds) / capital;
}

/// Plus-value réalisée : uniquement pour une ligne sortie.
double realizedGain(StartupDetail s) =>
    s.statut == 'sorti' ? s.exitProduit - investedCapital(s) : 0;

/// TRI annualisé en % : (valeur / capital)^(1/années) − 1.
///
/// [today] permet de figer la date de valorisation dans les tests. La période
/// court de la date d'investissement à la date de sortie, ou à aujourd'hui.
double triAnnualizedPct(
  StartupDetail s, {
  List<FundingRound> rounds = const [],
  DateTime? today,
}) {
  final capital = investedCapital(s);
  final start = s.dateInvestissement;
  if (capital <= 0 || start == null) return 0;
  final end = (s.statut == 'sorti' && s.exitDate != null)
      ? s.exitDate!
      : (today ?? DateTime.now());
  if (!end.isAfter(start)) return 0;
  final years = end.difference(start).inDays / 365.25;
  if (years <= 0) return 0;
  return (pow(startupValue(s, rounds) / capital, 1 / years) - 1) * 100;
}
