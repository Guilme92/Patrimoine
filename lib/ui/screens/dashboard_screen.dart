import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/portfolio_controller.dart';
import '../../data/database.dart';
import '../../domain/performance.dart';
import '../../utils/format.dart';
import '../widgets/allocation_donut.dart';
import '../widgets/net_worth_card.dart';
import '../widgets/net_worth_chart.dart';
import '../widgets/performance_breakdown.dart';
import '../widgets/performance_kpis.dart';

/// Tableau de bord : vue de performance globale du portefeuille.
///
/// Pas de liste d'actifs ici — chaque type a son onglet dédié. Ce tableau de
/// bord agrège les KPIs, l'évolution et les performances par classe.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PortfolioController>();
    if (controller.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.assets.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: const [_EmptyState()],
      );
    }

    final summary = controller.summary;
    final rentals = <int, Rental>{};
    final secondary = <int, List<SecondaryTransaction>>{};
    for (final asset in controller.assets) {
      final rental = controller.rentalOf(asset.id);
      if (rental != null) rentals[asset.id] = rental;
      final transactions = controller.secondaryTransactionsOf(asset.id);
      if (transactions.isNotEmpty) secondary[asset.id] = transactions;
    }

    final performance = computePerformance(
      assets: controller.assets,
      positionsByAsset: {
        for (final asset in controller.assets)
          asset.id: controller.positionsOf(asset.id),
      },
      prices: controller.prices,
      startupsByAsset: {
        for (final asset in controller.assets)
          if (controller.startupOf(asset.id) != null)
            asset.id: controller.startupOf(asset.id)!,
      },
      rentalsByAsset: rentals,
      secondaryByAsset: secondary,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: [
        NetWorthCard(
          summary: summary,
          trend30d: netWorthTrend(controller.snapshots, days: 30),
          trendTotal: netWorthTrend(controller.snapshots),
        ),
        if (controller.lastPriceUpdate != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Prix actualisés le ${formatTime(controller.lastPriceUpdate!)}',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.right,
            ),
          ),
        if (controller.snapshots.isNotEmpty) ...[
          const SizedBox(height: 16),
          NetWorthChart(snapshots: controller.snapshots),
        ],
        const SizedBox(height: 20),
        Text(
          'Performance des placements',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 3),
        Text(
          'Bourse, crypto et startups : les classes dont le prix de revient '
          'est suivi.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 10),
        PerformanceKpiGrid(performance: performance, summary: summary),
        if (summary.totalAssets > 0) ...[
          const SizedBox(height: 16),
          AllocationDonut(
            allocation: summary.allocation,
            total: summary.totalAssets,
          ),
        ],
        const SizedBox(height: 16),
        PerformanceByTypeCard(performance: performance),
        if (performance.topContributors.isNotEmpty) ...[
          const SizedBox(height: 16),
          TopContributorsCard(contributors: performance.topContributors),
        ],
        if (performance.rentalCount > 0) ...[
          const SizedBox(height: 16),
          RentalIncomeCard(performance: performance),
        ],
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Column(
        children: [
          Icon(
            Icons.insights_outlined,
            size: 56,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
          const SizedBox(height: 14),
          Text(
            'Aucun actif pour le moment',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            'Appuyez sur « + » pour ajouter votre premier actif :\n'
            'votre performance globale apparaîtra ici.',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
