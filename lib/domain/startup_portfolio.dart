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
/// rattachée à « Blast » (investissements dans les fonds Blast, sans catégorie).
String startupCategoryKey(String? categorie) {
  final t = categorie?.trim();
  return (t == null || t.isEmpty) ? 'Blast' : t;
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

/// Agrégats du marché secondaire pour un lot de transactions.
///
/// Les montants [totalAchat] / [totalRevente] somment les `montant` des
/// transactions (frais inclus à l'achat, commission de PV déduite à la vente)
/// et ne dépendent donc pas du PRU. Les plus-values, elles, ne sont calculées
/// que sur les ventes dont le détail chiffré est connu **et** dont le PRU de
/// la startup est exploitable ; les autres sont comptées dans
/// [ventesNonEvaluees] pour que l'UI puisse signaler un total partiel plutôt
/// que d'afficher un chiffre trompeur.
class SecondaryMarketSummary {
  final double totalAchat;
  final double totalRevente;
  final int actionsAchat;
  final int actionsVente;

  /// Σ(actions × prix) des achats : base du P.U. moyen d'achat.
  final double basePrixAchat;

  /// Σ(actions × prix) des ventes : base du P.U. moyen de vente.
  final double basePrixVente;

  final double pvBrute;
  final double pvNette;

  /// Ventes effectivement prises en compte dans [pvBrute] / [pvNette].
  final int ventesEvaluees;

  /// Ventes écartées du calcul de PV (PRU inconnu ou détail absent).
  final int ventesNonEvaluees;

  const SecondaryMarketSummary({
    required this.totalAchat,
    required this.totalRevente,
    required this.actionsAchat,
    required this.actionsVente,
    required this.basePrixAchat,
    required this.basePrixVente,
    required this.pvBrute,
    required this.pvNette,
    required this.ventesEvaluees,
    required this.ventesNonEvaluees,
  });

  /// Agrégat neutre, utilisable comme élément initial d'un `fold`.
  static const SecondaryMarketSummary empty = SecondaryMarketSummary(
    totalAchat: 0,
    totalRevente: 0,
    actionsAchat: 0,
    actionsVente: 0,
    basePrixAchat: 0,
    basePrixVente: 0,
    pvBrute: 0,
    pvNette: 0,
    ventesEvaluees: 0,
    ventesNonEvaluees: 0,
  );

  /// Agrège [transactions] pour une startup dont le PRU est [pru].
  factory SecondaryMarketSummary.of(
    Iterable<SecondaryTransaction> transactions, {
    double pru = 0,
  }) {
    var totalAchat = 0.0;
    var totalRevente = 0.0;
    var actionsAchat = 0;
    var actionsVente = 0;
    var basePrixAchat = 0.0;
    var basePrixVente = 0.0;
    var pvBrute = 0.0;
    var pvNette = 0.0;
    var ventesEvaluees = 0;
    var ventesNonEvaluees = 0;
    final pruConnu = secondaryPruAvailable(pru);

    for (final t in transactions) {
      if (t.type == 'revente') {
        totalRevente += t.montant;
        actionsVente += t.actions;
        basePrixVente += t.actions * t.prix;
        if (pruConnu && t.actions > 0 && t.prix > 0) {
          final actions = t.actions.toDouble();
          pvBrute += secondaryPvBrut(actions, t.prix, pru);
          pvNette += secondaryPvNet(
            actions,
            t.prix,
            pru,
            t.commissionPv,
            t.frais,
          );
          ventesEvaluees += 1;
        } else {
          ventesNonEvaluees += 1;
        }
      } else {
        totalAchat += t.montant;
        actionsAchat += t.actions;
        basePrixAchat += t.actions * t.prix;
      }
    }

    return SecondaryMarketSummary(
      totalAchat: totalAchat,
      totalRevente: totalRevente,
      actionsAchat: actionsAchat,
      actionsVente: actionsVente,
      basePrixAchat: basePrixAchat,
      basePrixVente: basePrixVente,
      pvBrute: pvBrute,
      pvNette: pvNette,
      ventesEvaluees: ventesEvaluees,
      ventesNonEvaluees: ventesNonEvaluees,
    );
  }

  SecondaryMarketSummary operator +(SecondaryMarketSummary other) =>
      SecondaryMarketSummary(
        totalAchat: totalAchat + other.totalAchat,
        totalRevente: totalRevente + other.totalRevente,
        actionsAchat: actionsAchat + other.actionsAchat,
        actionsVente: actionsVente + other.actionsVente,
        basePrixAchat: basePrixAchat + other.basePrixAchat,
        basePrixVente: basePrixVente + other.basePrixVente,
        pvBrute: pvBrute + other.pvBrute,
        pvNette: pvNette + other.pvNette,
        ventesEvaluees: ventesEvaluees + other.ventesEvaluees,
        ventesNonEvaluees: ventesNonEvaluees + other.ventesNonEvaluees,
      );

  /// Prix unitaire moyen pondéré des achats : Σ(actions × prix) / Σ(actions).
  /// Vaut 0 quand aucune action n'est connue (ancien format sans détail).
  double get puMoyenAchat =>
      actionsAchat > 0 ? basePrixAchat / actionsAchat : 0;

  /// Prix unitaire moyen pondéré des ventes.
  double get puMoyenVente =>
      actionsVente > 0 ? basePrixVente / actionsVente : 0;

  bool get aDesAchats => actionsAchat > 0 || totalAchat != 0;

  bool get aDesVentes => actionsVente > 0 || totalRevente != 0;

  /// Vrai si au moins une vente échappe au calcul de plus-value.
  bool get pvPartielle => ventesNonEvaluees > 0;

  /// Vrai si aucune plus-value n'a pu être calculée alors que des ventes
  /// existent : l'UI doit afficher « — » plutôt que 0 €.
  bool get pvIndisponible => ventesEvaluees == 0 && ventesNonEvaluees > 0;
}

/// Plus-value réalisée nette des reventes secondaires d'une startup.
///
/// S'appuie sur [SecondaryMarketSummary.of] avec le PRU de la fiche : PV brute
/// des reventes − commissions − frais − flat tax de 30 %. Vaut 0 quand aucune
/// vente n'est exploitable (PRU inconnu ou transactions sans détail chiffré) :
/// la PV réalisée ne doit jamais être inventée.
double realizedSecondaryPvNet(
  StartupDetail detail,
  List<SecondaryTransaction> transactions,
) {
  final summary = SecondaryMarketSummary.of(
    transactions,
    pru: detail.prixEntree,
  );
  return summary.pvIndisponible ? 0 : summary.pvNette;
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
