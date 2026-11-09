import 'package:flutter/material.dart';

import '../../domain/performance.dart';
import '../../domain/portfolio.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import 'info_hint.dart';

/// Carte principale du tableau de bord : patrimoine net, variation récente et
/// répartition actifs / passifs.
class NetWorthCard extends StatelessWidget {
  final PortfolioSummary summary;
  final NetWorthTrend? trend30d;
  final NetWorthTrend? trendTotal;

  const NetWorthCard({
    super.key,
    required this.summary,
    this.trend30d,
    this.trendTotal,
  });

  @override
  Widget build(BuildContext context) {
    final hasTrends = trend30d != null || trendTotal != null;
    return Container(
      decoration: cardDecoration(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LabelWithHint(
            'Patrimoine net',
            message: 'Actifs − passifs',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formatEuro(summary.netWorth),
              maxLines: 1,
              style: Theme.of(context).textTheme.headlineMedium
                  ?.copyWith(fontSize: 32, fontWeight: FontWeight.w800),
            ),
          ),
          if (hasTrends) ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (trend30d != null)
                        _TrendBadge(label: '30 jours', trend: trend30d!),
                      if (trendTotal != null)
                        _TrendBadge(
                          label: 'Depuis le début',
                          trend: trendTotal!,
                        ),
                    ],
                  ),
                ),
                const InfoHint(
                  'Variation du patrimoine net depuis le point d\'historique '
                  'correspondant (un point est enregistré par jour).',
                  size: 13,
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _Stat(
                  label: 'Actifs',
                  value: formatEuro(summary.totalAssets),
                  color: AppColors.positive,
                ),
              ),
              Expanded(
                child: _Stat(
                  label: 'Passifs',
                  value: formatEuro(summary.totalLiabilities),
                  color: AppColors.negative,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrendBadge extends StatelessWidget {
  final String label;
  final NetWorthTrend trend;

  const _TrendBadge({required this.label, required this.trend});

  @override
  Widget build(BuildContext context) {
    final color = trend.delta > 0
        ? AppColors.positive
        : trend.delta < 0
        ? AppColors.negative
        : AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            formatPct(trend.pct),
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            formatSignedEuro(trend.delta),
            style: TextStyle(color: color, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _Stat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}
