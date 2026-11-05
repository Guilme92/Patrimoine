import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/portfolio_controller.dart';
import '../../models/asset_type.dart';
import '../../theme/app_theme.dart';
import '../../theme/palette.dart';
import '../../utils/format.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PortfolioController>();
    if (controller.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final summary = controller.summary;
    final allocation = summary.allocation.entries
        .where((e) => e.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          Text('Répartition par classe d\'actifs',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          if (allocation.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Ajoutez des actifs pour voir la répartition.'),
            )
          else
            for (final e in allocation)
              _AllocationBar(
                label: assetTypeLabel(e.key),
                value: e.value,
                total: summary.totalAssets,
                color: assetTypeColors[e.key]!,
              ),
          const SizedBox(height: 24),
          Text('Performance', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          _PerfRow(
            label: 'Plus-value latente',
            value: summary.totalPnl,
            pct: summary.totalPnlPct,
          ),
        ],
      ),
    );
  }
}

class _AllocationBar extends StatelessWidget {
  final String label;
  final double value;
  final double total;
  final Color color;
  const _AllocationBar({
    required this.label,
    required this.value,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : value / total;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child:
                    Text(label, style: Theme.of(context).textTheme.bodyMedium),
              ),
              Text(formatEuro(value),
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(width: 8),
              SizedBox(
                width: 56,
                child: Text(
                  formatShare(pct * 100),
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: AppColors.surfaceAlt,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _PerfRow extends StatelessWidget {
  final String label;
  final double value;
  final double pct;
  const _PerfRow({required this.label, required this.value, required this.pct});

  @override
  Widget build(BuildContext context) {
    final positive = value >= 0;
    final color = positive ? AppColors.positive : AppColors.negative;
    return Container(
      decoration: cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Text(
            formatSignedEuro(value),
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 8),
          Text(formatPct(pct), style: TextStyle(color: color)),
        ],
      ),
    );
  }
}
