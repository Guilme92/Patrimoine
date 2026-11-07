import '../data/database.dart';
import '../models/startup.dart';
import '../utils/choice.dart';
import 'startup.dart';

/// Agrégats du portefeuille de startups.
///
/// Toutes les fonctions ci-dessous sont pures : elles n'accèdent ni à la base
/// ni à l'horloge (la date de référence est injectable via [today]).

/// Une startup = son actif (nom, tri) + sa fiche chiffrée.
class StartupEntry {
  final Asset asset;
  final StartupDetail detail;

  const StartupEntry({required this.asset, required this.detail});
}

/// Agrégats d'une catégorie de startups.
class CategoryKpi {
  final double invested;

  /// Frais d'entrée cumulés de la catégorie (inclus dans [invested]).
  final double frais;
  final double value;
  final double unrealized;
  final double realized;
  final double moic;
  final double triPct;
  final int count;

  const CategoryKpi({
    required this.invested,
    required this.frais,
    required this.value,
    required this.unrealized,
    required this.realized,
    required this.moic,
    required this.triPct,
    required this.count,
  });
}

/// Synthèse complète d'un lot de startups (après filtres côté UI).
class StartupPortfolioSummary {
  final double totalInvested;
  final double totalFrais;
  final double totalValue;
  final double unrealizedGain;
  final double unrealizedGainPct;
  final double realizedGain;
  final double moic;
  final double avgTriPct;
  final int activeCount;
  final int exitedCount;
  final int writtenOffCount;
  final Map<String, double> valueByCategory;
  final Map<int, double> valueByYear;
  final Map<String, CategoryKpi> kpiByCategory;
  final List<StartupEntry> entries;

  const StartupPortfolioSummary({
    required this.totalInvested,
    required this.totalFrais,
    required this.totalValue,
    required this.unrealizedGain,
    required this.unrealizedGainPct,
    required this.realizedGain,
    required this.moic,
    required this.avgTriPct,
    required this.activeCount,
    required this.exitedCount,
    required this.writtenOffCount,
    required this.valueByCategory,
    required this.valueByYear,
    required this.kpiByCategory,
    required this.entries,
  });

  int get totalCount => entries.length;
}

/// Clé de regroupement d'une catégorie : une catégorie vide ou blanche est
/// rattachée à « Sans catégorie ».
String startupCategoryKey(String? categorie) {
  final t = categorie?.trim();
  return (t == null || t.isEmpty) ? 'Sans catégorie' : t;
}

// ---------------------------------------------------------------------------
// Marché secondaire : montants, plus-values et filtres
// ---------------------------------------------------------------------------

/// Taux de flat tax (prélèvement forfaitaire unique) appliqué aux plus-values
/// de cession de titres non cotés.
const double secondaryFlatTaxRate = 0.30;

/// Vrai si le PRU (prix de revient unitaire) est exploitable, c'est-à-dire
/// strictement positif. Un PRU nul signifie « inconnu » et interdit tout
/// calcul de plus-value crédible.
bool secondaryPruAvailable(double pru) => pru > 0;

/// Montant payé (achat) ou reçu (vente) d'une transaction secondaire :
/// achat = actions × prix + frais ; vente = actions × prix − commission PV.
///
/// Alias de [secondaryTransactionMontant] (défini avec le modèle, pour rester
/// utilisable aussi depuis les tests de domaine).
double secondaryMontant(
  String type,
  double actions,
  double prix,
  double frais,
  double commissionPv,
) => secondaryTransactionMontant(type, actions, prix, frais, commissionPv);

/// Plus-value brute d'une revente secondaire : `actions × (prix − PRU)`.
///
/// Approximation assumée : le PRU retenu est le prix moyen d'acquisition de la
/// fiche startup (`StartupDetails.prixEntree`), et non le coût réel des titres
/// cédés (pas de suivi FIFO des lots). Les frais d'acquisition initiaux ne
/// sont donc pas réimputés ici : ils le sont au niveau de la ligne de vente via
/// [secondaryPvNet], qui déduit la commission et les frais de la transaction.
double secondaryPvBrut(double actions, double prix, double pru) =>
    actions * (prix - pru);

/// Plus-value nette d'une revente secondaire, flat tax incluse :
/// PV brute − commission PV − frais, puis flat tax de 30 % sur la base
/// positive restante.
///
/// `base = PV brute − commission − frais` ; `flat tax = 30 % × max(0, base)` ;
/// `PV nette = PV brute − commission − frais − flat tax`. Une moins-value n'est
/// pas fiscalisée (flat tax nulle) mais reste imputée en totalité.
double secondaryPvNet(
  double actions,
  double prix,
  double pru,
  double commission,
  double frais,
) {
  final brut = secondaryPvBrut(actions, prix, pru);
  final base = brut - commission - frais;
  final flatTax = base > 0 ? base * secondaryFlatTaxRate : 0.0;
  return base - flatTax;
}

/// Filtre d'affichage des transactions du marché secondaire.
enum SecondaryTypeFilter { tous, achat, revente }

/// Libellé du filtre (« Tous », « Achats », « Ventes »).
String secondaryTypeFilterLabel(SecondaryTypeFilter filter) {
  switch (filter) {
    case SecondaryTypeFilter.tous:
      return 'Tous';
    case SecondaryTypeFilter.achat:
      return 'Achats';
    case SecondaryTypeFilter.revente:
      return 'Ventes';
  }
}

/// Vrai si une transaction de type [type] (`achat` | `revente`) passe le
/// filtre [filter].
bool secondaryTypeMatches(String type, SecondaryTypeFilter filter) {
  switch (filter) {
    case SecondaryTypeFilter.tous:
      return true;
    case SecondaryTypeFilter.achat:
      return type == 'achat';
    case SecondaryTypeFilter.revente:
      return type == 'revente';
  }
}

/// Normalise un texte pour la recherche par nom : minuscules, sans accents,
/// espaces de bord retirés.
String normalizeStartupSearch(String raw) =>
    stripAccents(raw.toLowerCase()).trim();

/// Vrai si [name] contient [query] (sous-chaîne, insensible à la casse et
/// aux accents). Une requête vide accepte tout.
bool startupNameMatches(String name, String query) {
  final q = normalizeStartupSearch(query);
  if (q.isEmpty) return true;
  return normalizeStartupSearch(name).contains(q);
}

/// Agrège [entries] en une synthèse unique.
///
/// - `totalInvested` / `totalValue` portent sur toutes les lignes ;
/// - `totalFrais` est la somme des frais d'entrée de toutes les lignes ;
/// - `unrealizedGain` ne compte que les lignes en portefeuille ;
/// - `realizedGain` ne compte que les lignes sorties ;
/// - le MOIC global est valorisation totale ÷ capital investi total ;
/// - le TRI moyen est la moyenne arithmétique des TRI des lignes datées et
///   dotées d'un capital > 0.
StartupPortfolioSummary summarizeStartups(
  List<StartupEntry> entries, {
  DateTime? today,
}) {
  var totalInvested = 0.0;
  var totalFrais = 0.0;
  var totalValue = 0.0;
  var unrealized = 0.0;
  var realized = 0.0;
  var triSum = 0.0;
  var triCount = 0;
  var activeCount = 0;
  var exitedCount = 0;
  var writtenOffCount = 0;

  final valueByCategory = <String, double>{};
  final valueByYear = <int, double>{};
  final accumulators = <String, _CategoryAccumulator>{};

  for (final entry in entries) {
    final detail = entry.detail;
    final invested = investedCapital(detail);
    final value = lineValue(detail);

    totalInvested += invested;
    totalFrais += detail.frais;
    totalValue += value;

    final category = startupCategoryKey(detail.categorie);
    valueByCategory[category] = (valueByCategory[category] ?? 0) + value;

    final year = detail.dateInvestissement?.year;
    if (year != null && year > 0) {
      valueByYear[year] = (valueByYear[year] ?? 0) + value;
    }

    final kpi = accumulators.putIfAbsent(category, _CategoryAccumulator.new);
    kpi.invested += invested;
    kpi.frais += detail.frais;
    kpi.value += value;
    kpi.count += 1;

    switch (detail.statut) {
      case 'sorti':
        exitedCount += 1;
        final gain = realizedGain(detail);
        realized += gain;
        kpi.realized += gain;
        break;
      case 'radie':
        writtenOffCount += 1;
        break;
      default:
        activeCount += 1;
        final gain = unrealizedGain(detail);
        unrealized += gain;
        kpi.unrealized += gain;
        break;
    }

    if (invested > 0 && detail.dateInvestissement != null) {
      final tri = triAnnualizedPct(detail, today: today);
      triSum += tri;
      triCount += 1;
      kpi.triSum += tri;
      kpi.triCount += 1;
    }
  }

  final kpiByCategory = <String, CategoryKpi>{
    for (final e in accumulators.entries)
      e.key: CategoryKpi(
        invested: e.value.invested,
        frais: e.value.frais,
        value: e.value.value,
        unrealized: e.value.unrealized,
        realized: e.value.realized,
        moic: e.value.moic,
        triPct: e.value.triPct,
        count: e.value.count,
      ),
  };

  return StartupPortfolioSummary(
    totalInvested: totalInvested,
    totalFrais: totalFrais,
    totalValue: totalValue,
    unrealizedGain: unrealized,
    unrealizedGainPct: totalInvested > 0 ? unrealized / totalInvested * 100 : 0,
    realizedGain: realized,
    moic: totalInvested > 0 ? totalValue / totalInvested : 0,
    avgTriPct: triCount > 0 ? triSum / triCount : 0,
    activeCount: activeCount,
    exitedCount: exitedCount,
    writtenOffCount: writtenOffCount,
    valueByCategory: valueByCategory,
    valueByYear: valueByYear,
    kpiByCategory: kpiByCategory,
    entries: List.unmodifiable(entries),
  );
}

class _CategoryAccumulator {
  double invested = 0;
  double frais = 0;
  double value = 0;
  double unrealized = 0;
  double realized = 0;
  double triSum = 0;
  int triCount = 0;
  int count = 0;

  double get moic => invested > 0 ? value / invested : 0;
  double get triPct => triCount > 0 ? triSum / triCount : 0;
}
