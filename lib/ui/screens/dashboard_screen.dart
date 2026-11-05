import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/portfolio_controller.dart';
import '../../utils/format.dart';
import '../widgets/allocation_donut.dart';
import '../widgets/asset_tile.dart';
import '../widgets/net_worth_card.dart';
import '../widgets/net_worth_chart.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PortfolioController>();
    if (controller.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final summary = controller.summary;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: [
        NetWorthCard(summary: summary),
        if (controller.lastPriceUpdate != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Prix actualisés le ${formatTime(controller.lastPriceUpdate!)}',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.right,
            ),
          ),
        const SizedBox(height: 16),
        if (controller.snapshots.isNotEmpty) ...[
          NetWorthChart(snapshots: controller.snapshots),
          const SizedBox(height: 16),
        ],
        if (summary.totalAssets > 0)
          AllocationDonut(
            allocation: summary.allocation,
            total: summary.totalAssets,
          ),
        const SizedBox(height: 24),
        Text('Mes actifs', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        if (controller.assets.isEmpty)
          const _EmptyState()
        else
          ...controller.assets.map(
            (a) => AssetTile(
              asset: a,
              positions: controller.positionsOf(a.id),
              prices: controller.prices,
              startup: controller.startupOf(a.id),
            ),
          ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(
            Icons.add_chart,
            size: 48,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
          const SizedBox(height: 12),
          Text('Aucun actif pour le moment',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Appuyez sur « + » pour ajouter votre premier actif.',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
