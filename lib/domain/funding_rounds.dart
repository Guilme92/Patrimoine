import '../data/database.dart';

/// Valorisation des actions de l'utilisateur à travers les tours de
/// financement, selon la convention du user :
///
/// - les actions valent 1 € au premier tour (base de calcul) ;
/// - le prix unitaire (PU) suit la revalorisation de l'entreprise entre deux
///   tours : PU_après tour k = PU(k−1) × (preMoney_k / postMoney_(k−1)) ;
/// - la valeur des actions après le dernier tour vaut
///   Σ_k (investi_k × PU_dernier / PU_k).
///
/// Exemple (2 tours) : PU = 1 × (preMoney_2 / postMoney_1) ;
/// valeur = investi_1 × (preMoney_2 / postMoney_1) + investi_2.

/// Rounds triés du plus ancien au plus récent (dates inconnues en dernier,
/// puis identifiant de saisie).
List<FundingRound> _chronological(List<FundingRound> rounds) {
  final copy = [...rounds];
  copy.sort((a, b) {
    final da = a.date;
    final db = b.date;
    if (da == null && db == null) return a.id.compareTo(b.id);
    if (da == null) return 1;
    if (db == null) return -1;
    final cmp = da.compareTo(db);
    return cmp != 0 ? cmp : a.id.compareTo(b.id);
  });
  return copy;
}

/// Prix unitaire des actions après le dernier tour, base 1 € au premier tour.
///
/// Retourne `null` si la liste est vide, ou si une valorisation nécessaire au
/// calcul manque (pre-money ou post-money à 0 sur la chaîne de tours).
double? shareUnitPrice(List<FundingRound> rounds) {
  final ordered = _chronological(rounds);
  if (ordered.isEmpty) return null;
  var pu = 1.0;
  for (var i = 1; i < ordered.length; i++) {
    final previous = ordered[i - 1];
    final current = ordered[i];
    final postPrev = previous.valorisationPostMoney;
    final preCur = current.valorisationPreMoney;
    if (postPrev <= 0 || preCur <= 0) return null;
    pu *= preCur / postPrev;
  }
  return pu;
}

/// Valeur estimée des actions de l'utilisateur après le dernier tour :
/// Σ_k investi_k × (PU_dernier / PU_k), avec PU_1 = 1 €.
///
/// Pour deux tours, se réduit à
/// `investi_1 × (preMoney_2 / postMoney_1) + investi_2`.
/// Retourne `null` si la liste est vide ou si une valorisation manque.
double? fundingRoundsValue(List<FundingRound> rounds) {
  final ordered = _chronological(rounds);
  if (ordered.isEmpty) return null;

  final unitPrices = <double>[1.0];
  for (var i = 1; i < ordered.length; i++) {
    final previous = ordered[i - 1];
    final current = ordered[i];
    final postPrev = previous.valorisationPostMoney;
    final preCur = current.valorisationPreMoney;
    if (postPrev <= 0 || preCur <= 0) return null;
    unitPrices.add(unitPrices[i - 1] * preCur / postPrev);
  }

  final lastPu = unitPrices.last;
  var total = 0.0;
  for (var i = 0; i < ordered.length; i++) {
    total += ordered[i].montantLeve * (lastPu / unitPrices[i]);
  }
  return total;
}
