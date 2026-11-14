import '../data/database.dart';
import '../models/asset_type.dart';
import 'portfolio.dart';
import 'rental.dart';
import 'startup.dart';
import 'startup_portfolio.dart';

/// Performance d'une classe d'actifs : valeur actuelle, capital investi et
/// plus-value latente.
///
/// [tracked] vaut faux pour les classes dont le prix de revient n'est pas
/// suivi (immobilier, liquidités, métaux, collections…) : seule leur valeur
/// est alors connue.
class TypePerformance {
  final AssetType type;
  final double value;
  final double invested;
  final double unrealized;
  final bool tracked;

  const TypePerformance({
    required this.type,
    required this.value,
    required this.invested,
    required this.unrealized,
    required this.tracked,
  });

  /// Plus-value latente en % du capital investi (0 si aucun coût connu).
  double get gainPct => invested > 0 ? unrealized / invested * 100 : 0;
}

/// Une ligne (position cotée ou startup) qui contribue à la performance.
class PerformanceContributor {
  final String name;
  final AssetType type;
  final double value;
  final double gain;
  final double gainPct;

  const PerformanceContributor({
    required this.name,
    required this.type,
    required this.value,
    required this.gain,
    required this.gainPct,
  });
}

/// Synthèse de performance du portefeuille.
///
/// Périmètre des montants investis / plus-values : positions cotées et fiches
/// startup, seules classes dont le prix de revient est connu. L'immobilier,
/// les liquidités et les objets de collection ne comptent que dans la valeur
/// du patrimoine, pas dans le capital investi.
class PerformanceSummary {
  final double invested;
  final double unrealized;
  final double realized;
  final double fees;
  final List<TypePerformance> byType;
  final List<PerformanceContributor> topContributors;
  final double rentalAnnualRent;
  final double rentalAnnualCashflow;
  final double rentalValue;
  final int rentalCount;

  const PerformanceSummary({
    required this.invested,
    required this.unrealized,
    required this.realized,
    required this.fees,
    required this.byType,
    required this.topContributors,
    required this.rentalAnnualRent,
    required this.rentalAnnualCashflow,
    required this.rentalValue,
    required this.rentalCount,
  });

  /// Plus-value latente + plus-value réalisée.
  double get totalGain => unrealized + realized;

  /// Performance globale en % du capital investi.
  double get totalGainPct => invested > 0 ? totalGain / invested * 100 : 0;

  double get unrealizedPct => invested > 0 ? unrealized / invested * 100 : 0;

  double get feesPct => invested > 0 ? fees / invested * 100 : 0;

  /// Rendement locatif brut moyen, pondéré par la valeur des biens loués.
  double get rentalGrossYieldPct =>
      rentalValue > 0 ? rentalAnnualRent / rentalValue * 100 : 0;

  double get rentalMonthlyCashflow => rentalAnnualCashflow / 12;

  bool get hasInvestments => invested > 0;
}

/// Calcule la synthèse de performance du portefeuille.
///
/// Fonction pure : aucune horloge ni accès base, les transactions secondaires
/// et les locations sont injectées par l'appelant.
PerformanceSummary computePerformance({
  required List<Asset> assets,
  required Map<int, List<Position>> positionsByAsset,
  required Map<String, double> prices,
  Map<int, StartupDetail> startupsByAsset = const {},
  Map<int, Rental> rentalsByAsset = const {},
  Map<int, List<SecondaryTransaction>> secondaryByAsset = const {},
  Map<int, List<FundingRound>> roundsByAsset = const {},
}) {
  var invested = 0.0;
  var unrealized = 0.0;
  var realized = 0.0;
  var fees = 0.0;
  var rentalAnnualRent = 0.0;
  var rentalAnnualCashflow = 0.0;
  var rentalValue = 0.0;
  var rentalCount = 0;

  final accumulators = <AssetType, _TypeAccumulator>{};
  final contributors = <PerformanceContributor>[];

  for (final asset in assets) {
    final type = assetTypeFrom(asset.type);
    if (isLiabilityType(type)) continue;

    final positions = positionsByAsset[asset.id] ?? const <Position>[];
    final startup = startupsByAsset[asset.id];
    final value = assetValue(
      asset: asset,
      positions: positions,
      prices: prices,
      startup: startup,
      rounds: roundsByAsset[asset.id] ?? const [],
    );
    final accumulator = accumulators.putIfAbsent(type, _TypeAccumulator.new);
    accumulator.value += value;

    for (final position in positions) {
      final cost = positionCost(position);
      final price = prices[position.symbol] ?? position.unitCost;
      final gain = positionValue(position, price) - cost;
      invested += cost;
      unrealized += gain;
      fees += position.fees;
      accumulator.invested += cost;
      accumulator.unrealized += gain;
      if (cost > 0) {
        contributors.add(
          PerformanceContributor(
            name: position.name,
            type: type,
            value: positionValue(position, price),
            gain: gain,
            gainPct: cost > 0 ? gain / cost * 100 : 0,
          ),
        );
      }
    }

    if (startup != null) {
      final capital = investedCapital(startup);
      final secondary =
          secondaryByAsset[asset.id] ?? const <SecondaryTransaction>[];
      var totalSold = 0.0;
      for (final transaction in secondary) {
        if (transaction.type == 'revente') {
          totalSold += transaction.actions;
        }
      }
      // PV latente sur les titres restants, coût de revient au prorata des
      // actions revendues (frais d'entrée inclus dans le coût).
      final gain = unrealizedGain(startup, totalSold: totalSold);
      invested += capital;
      unrealized += gain;
      fees += startup.frais;
      accumulator.invested += capital;
      accumulator.unrealized += gain;
      realized += realizedGain(startup);
      if (capital > 0) {
        contributors.add(
          PerformanceContributor(
            name: asset.name,
            type: type,
            value: startupValue(startup, roundsByAsset[asset.id] ?? const []),
            gain: gain,
            gainPct: capital > 0 ? gain / capital * 100 : 0,
          ),
        );
      }

      if (secondary.isNotEmpty) {
        realized += realizedSecondaryPvNet(startup, secondary);
        for (final transaction in secondary) {
          fees += transaction.frais;
        }
      }
    }

    final rental = rentalsByAsset[asset.id];
    if (rental != null) {
      rentalCount += 1;
      rentalAnnualRent += annualGrossRent(rental);
      rentalAnnualCashflow += annualCashflow(rental);
      rentalValue += value;
    }
  }

  final byType = <TypePerformance>[
    for (final entry in accumulators.entries)
      TypePerformance(
        type: entry.key,
        value: entry.value.value,
        invested: entry.value.invested,
        unrealized: entry.value.unrealized,
        tracked: entry.value.invested > 0,
      ),
  ]..sort((a, b) => b.value.compareTo(a.value));

  contributors.sort((a, b) => b.gain.compareTo(a.gain));

  return PerformanceSummary(
    invested: invested,
    unrealized: unrealized,
    realized: realized,
    fees: fees,
    byType: List.unmodifiable(byType),
    topContributors: List.unmodifiable(
      contributors.where((c) => c.gain > 0).take(3),
    ),
    rentalAnnualRent: rentalAnnualRent,
    rentalAnnualCashflow: rentalAnnualCashflow,
    rentalValue: rentalValue,
    rentalCount: rentalCount,
  );
}

/// Variation du patrimoine net entre deux points de l'historique.
class NetWorthTrend {
  final double delta;
  final double pct;
  final DateTime from;

  const NetWorthTrend({
    required this.delta,
    required this.pct,
    required this.from,
  });
}

/// Variation du patrimoine net sur [days] jours (ou depuis le premier point
/// quand [days] est nul), calculée sur les snapshots triés.
///
/// Renvoie null s'il n'existe pas de point de référence (historique trop
/// court, ou aucun point antérieur à la fenêtre demandée).
NetWorthTrend? netWorthTrend(
  List<NetWorthSnapshot> snapshots, {
  int? days,
  DateTime? now,
}) {
  if (snapshots.length < 2) return null;
  final points = [...snapshots]..sort((a, b) => a.date.compareTo(b.date));
  final last = points.last;

  NetWorthSnapshot? reference;
  if (days == null) {
    reference = points.first;
  } else {
    final cutoff = (now ?? DateTime.now()).subtract(Duration(days: days));
    for (final point in points) {
      if (!point.date.isAfter(cutoff)) reference = point;
    }
  }
  if (reference == null) return null;

  final delta = last.netWorth - reference.netWorth;
  final base = reference.netWorth.abs();
  return NetWorthTrend(
    delta: delta,
    pct: base == 0 ? 0 : delta / base * 100,
    from: reference.date,
  );
}

class _TypeAccumulator {
  double value = 0;
  double invested = 0;
  double unrealized = 0;
}
