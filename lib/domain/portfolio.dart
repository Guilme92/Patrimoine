import '../data/database.dart';
import '../models/asset_type.dart';
import 'startup.dart';

/// Valeur actuelle d'un actif :
/// - une fiche startup valorise l'actif (quantité × prix actuel manuel) ;
/// - sinon positions × prix de marché ;
/// - sinon la valeur manuelle saisie sur l'actif.
double assetValue({
  required Asset asset,
  required List<Position> positions,
  required Map<String, double> prices,
  StartupDetail? startup,
}) {
  if (startup != null) return lineValue(startup);
  if (positions.isEmpty) return asset.value;
  var total = 0.0;
  for (final pos in positions) {
    final price = prices[pos.symbol] ?? pos.unitCost;
    total += pos.quantity * price;
  }
  return total;
}

double positionValue(Position p, double price) => p.quantity * price;
double positionCost(Position p) => p.quantity * p.unitCost;
double positionPnl(Position p, double price) => positionValue(p, price) - positionCost(p);

double positionPnlPct(Position p, double price) {
  final cost = positionCost(p);
  if (cost == 0) return 0;
  return (positionValue(p, price) - cost) / cost * 100;
}

/// Synthèse globale du patrimoine.
class PortfolioSummary {
  final double totalAssets;
  final double totalLiabilities;
  final double netWorth;
  final Map<AssetType, double> allocation;
  final double totalPnl;
  final double totalPnlPct;

  const PortfolioSummary({
    required this.totalAssets,
    required this.totalLiabilities,
    required this.netWorth,
    required this.allocation,
    required this.totalPnl,
    required this.totalPnlPct,
  });
}

PortfolioSummary summarize({
  required List<Asset> assets,
  required Map<int, List<Position>> positionsByAsset,
  required Map<String, double> prices,
  Map<int, StartupDetail> startupsByAsset = const {},
}) {
  var assetsTotal = 0.0;
  var liabilitiesTotal = 0.0;
  var totalCost = 0.0;
  var totalPnl = 0.0;
  final allocation = <AssetType, double>{};

  for (final a in assets) {
    final type = assetTypeFrom(a.type);
    final positions = positionsByAsset[a.id] ?? const <Position>[];
    final v = assetValue(
      asset: a,
      positions: positions,
      prices: prices,
      startup: startupsByAsset[a.id],
    );

    if (isLiabilityType(type)) {
      liabilitiesTotal += v;
    } else {
      assetsTotal += v;
      allocation[type] = (allocation[type] ?? 0) + v;
      for (final pos in positions) {
        final price = prices[pos.symbol] ?? pos.unitCost;
        totalCost += positionCost(pos);
        totalPnl += positionPnl(pos, price);
      }
    }
  }

  return PortfolioSummary(
    totalAssets: assetsTotal,
    totalLiabilities: liabilitiesTotal,
    netWorth: assetsTotal - liabilitiesTotal,
    allocation: allocation,
    totalPnl: totalPnl,
    totalPnlPct: totalCost == 0 ? 0 : totalPnl / totalCost * 100,
  );
}
