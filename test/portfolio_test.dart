import 'package:flutter_test/flutter_test.dart';

import 'package:patrimoine/data/database.dart';
import 'package:patrimoine/domain/portfolio.dart';
import 'package:patrimoine/models/asset_type.dart';

Asset _asset(int id, String name, String type, double value) => Asset(
      id: id,
      name: name,
      type: type,
      value: value,
      currency: 'EUR',
      institution: null,
      note: null,
      sortOrder: 0,
      createdAt: DateTime(2026),
    );

Position _position(int id, int assetId, String symbol, double qty,
        double unitCost) =>
    Position(
      id: id,
      assetId: assetId,
      symbol: symbol,
      name: symbol,
      quantity: qty,
      unitCost: unitCost,
      assetClass: null,
      sector: null,
      region: null,
      fees: 0,
      createdAt: DateTime(2026),
    );

void main() {
  group('assetValue', () {
    test('sans positions, renvoie la valeur manuelle', () {
      final a = _asset(1, 'Livret A', 'cash', 5000);
      expect(assetValue(asset: a, positions: const [], prices: const {}), 5000);
    });

    test('avec positions, somme quantité × prix', () {
      final a = _asset(1, 'PEA', 'investment', 0);
      final positions = [
        _position(1, 1, 'AAPL', 10, 100),
        _position(2, 1, 'MSFT', 5, 200),
      ];
      final prices = {'AAPL': 150.0, 'MSFT': 250.0};
      // 10*150 + 5*250 = 1500 + 1250 = 2750
      expect(
        assetValue(asset: a, positions: positions, prices: prices),
        2750,
      );
    });

    test('utilise le prix de revient si pas de prix de marché', () {
      final a = _asset(1, 'PEA', 'investment', 0);
      final positions = [_position(1, 1, 'XXX', 10, 100)];
      expect(
        assetValue(asset: a, positions: positions, prices: const {}),
        1000,
      );
    });
  });

  group('performance', () {
    test('plus/moins-value latente', () {
      final p = _position(1, 1, 'AAPL', 10, 100);
      expect(positionPnl(p, 150), 500); // (150-100)*10
      expect(positionPnlPct(p, 150), 50);
      expect(positionPnl(p, 80), -200);
    });
  });

  group('summarize', () {
    test('calcule patrimoine net et répartition', () {
      final assets = [
        _asset(1, 'Livret A', 'cash', 5000),
        _asset(2, 'PEA', 'investment', 0),
        _asset(3, 'Crédit immo', 'loan', 200000),
      ];
      final positionsByAsset = {
        2: [_position(1, 2, 'AAPL', 10, 100)],
      };
      final prices = {'AAPL': 150.0};
      final s = summarize(
        assets: assets,
        positionsByAsset: positionsByAsset,
        prices: prices,
      );
      expect(s.totalAssets, 5000 + 1500);
      expect(s.totalLiabilities, 200000);
      expect(s.netWorth, 6500 - 200000);
      expect(s.allocation[AssetType.cash], 5000);
      expect(s.allocation[AssetType.investment], 1500);
      expect(s.totalPnl, 500);
    });

    test('répartition ignore les passifs', () {
      final assets = [_asset(3, 'Crédit', 'loan', 50000)];
      final s = summarize(
        assets: assets,
        positionsByAsset: const {},
        prices: const {},
      );
      expect(s.totalAssets, 0);
      expect(s.netWorth, -50000);
      expect(s.allocation.isEmpty, true);
    });
  });

  group('assetType', () {
    test('mapping et libellés', () {
      expect(assetTypeFrom('investment'), AssetType.investment);
      expect(assetTypeFrom('inconnu'), AssetType.other);
      expect(assetTypeLabel(AssetType.realEstate), 'Immobilier');
      expect(isLiabilityType(AssetType.loan), true);
      expect(supportsPositions(AssetType.crypto), true);
      expect(supportsPositions(AssetType.cash), false);
    });
  });
}
