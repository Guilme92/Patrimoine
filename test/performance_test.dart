import 'package:flutter_test/flutter_test.dart';

import 'package:patrimoine/data/database.dart';
import 'package:patrimoine/domain/performance.dart';
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

Position _position(
  int id,
  int assetId,
  String symbol,
  double qty,
  double unitCost, {
  double fees = 0,
}) => Position(
  id: id,
  assetId: assetId,
  symbol: symbol,
  name: symbol,
  quantity: qty,
  unitCost: unitCost,
  assetClass: null,
  sector: null,
  region: null,
  fees: fees,
  createdAt: DateTime(2026),
);

StartupDetail _startup(
  int id,
  int assetId, {
  double qty = 100,
  double pru = 10,
  double prixActuel = 25,
  double frais = 50,
  double montantInvesti = 0,
  String statut = 'en_portefeuille',
  double exitProduit = 0,
}) => StartupDetail(
  id: id,
  assetId: assetId,
  quantite: qty,
  prixEntree: pru,
  frais: frais,
  montantInvesti: montantInvesti,
  prixActuel: prixActuel,
  valorisationEntreprise: 0,
  statut: statut,
  exitProduit: exitProduit,
  createdAt: DateTime(2026),
);

void main() {
  group('computePerformance', () {
    test('agrège positions, startups et ignore les passifs', () {
      final assets = [
        _asset(1, 'Livret A', 'cash', 5000),
        _asset(2, 'PEA', 'investment', 0),
        _asset(3, 'Startup A', 'startup', 0),
        _asset(4, 'Startup B', 'startup', 0),
        _asset(5, 'Crédit immo', 'loan', 200000),
      ];
      final positions = {
        2: [_position(1, 2, 'CW8', 10, 100, fees: 12)],
      };
      final startups = {
        3: _startup(1, 3),
        4: _startup(
          2,
          4,
          qty: 100,
          pru: 10,
          prixActuel: 30,
          montantInvesti: 1000,
          statut: 'sorti',
          exitProduit: 3000,
        ),
      };

      final p = computePerformance(
        assets: assets,
        positionsByAsset: positions,
        prices: const {'CW8': 150.0},
        startupsByAsset: startups,
      );

      // 1 000 (position) + 1 050 + 1 000 (startups, frais inclus).
      expect(p.invested, 3050);
      // 500 sur la position + 1 450 sur la startup active (frais déduits).
      expect(p.unrealized, 1950);
      // 3 000 − 1 000 sur la startup sortie.
      expect(p.realized, 2000);
      expect(p.fees, 112);
      expect(p.totalGain, 3950);
      expect(p.totalGainPct, closeTo(129.51, 0.01));
      expect(p.unrealizedPct, closeTo(63.93, 0.01));

      final investment = p.byType.firstWhere(
        (t) => t.type == AssetType.investment,
      );
      expect(investment.value, 1500);
      expect(investment.tracked, isTrue);

      final startup = p.byType.firstWhere((t) => t.type == AssetType.startup);
      expect(startup.value, 5500);
      expect(startup.invested, 2050);
      expect(startup.unrealized, 1450);

      final cash = p.byType.firstWhere((t) => t.type == AssetType.cash);
      expect(cash.tracked, isFalse);
      expect(cash.unrealized, 0);
    });

    test('ne remonte que les contributeurs positifs, top 3', () {
      final assets = [_asset(1, 'PEA', 'investment', 0)];
      final positions = {
        1: [
          _position(1, 1, 'A', 1, 100),
          _position(2, 1, 'B', 1, 100),
          _position(3, 1, 'C', 1, 100),
          _position(4, 1, 'D', 1, 100),
        ],
      };
      final p = computePerformance(
        assets: assets,
        positionsByAsset: positions,
        prices: const {'A': 130.0, 'B': 120.0, 'C': 110.0, 'D': 90.0},
      );
      expect(p.topContributors.length, 3);
      expect(p.topContributors.first.name, 'A');
      expect(p.topContributors.map((c) => c.name), ['A', 'B', 'C']);
      expect(p.invested, 400);
      expect(p.unrealized, 50);
    });

    test('portefeuille sans placement suivi', () {
      final p = computePerformance(
        assets: [_asset(1, 'Livret A', 'cash', 5000)],
        positionsByAsset: const {},
        prices: const {},
      );
      expect(p.invested, 0);
      expect(p.totalGain, 0);
      expect(p.totalGainPct, 0);
      expect(p.hasInvestments, isFalse);
      expect(p.byType.single.tracked, isFalse);
    });
  });

  group('netWorthTrend', () {
    List<NetWorthSnapshot> snapshots() => [
      NetWorthSnapshot(id: 1, date: DateTime(2026, 9, 1), netWorth: 100000),
      NetWorthSnapshot(id: 2, date: DateTime(2026, 10, 20), netWorth: 110000),
      NetWorthSnapshot(id: 3, date: DateTime(2026, 11, 5), netWorth: 120000),
    ];

    test('variation sur 30 jours', () {
      final trend = netWorthTrend(
        snapshots(),
        days: 30,
        now: DateTime(2026, 11, 25),
      );
      expect(trend, isNotNull);
      expect(trend!.delta, 10000);
      expect(trend.pct, closeTo(9.09, 0.01));
      expect(trend.from, DateTime(2026, 10, 20));
    });

    test('variation depuis le début', () {
      final trend = netWorthTrend(snapshots());
      expect(trend!.delta, 20000);
      expect(trend.pct, 20);
      expect(trend.from, DateTime(2026, 9, 1));
    });

    test('pas de point de référence', () {
      expect(netWorthTrend(snapshots().take(1).toList()), isNull);
      expect(
        netWorthTrend(snapshots(), days: 30, now: DateTime(2026, 9, 10)),
        isNull,
      );
    });
  });
}
