import 'package:flutter/material.dart';

import '../../domain/portfolio.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import 'info_hint.dart';

class NetWorthCard extends StatelessWidget {
  final PortfolioSummary summary;
  const NetWorthCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final positive = summary.totalPnl >= 0;
    final pnlColor = positive ? AppColors.positive : AppColors.negative;
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
          Text(
            formatEuro(summary.netWorth),
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontSize: 32, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _Stat(
                  label: 'Actifs',
                  hint: 'Somme des valeurs de tous les actifs',
                  value: formatEuro(summary.totalAssets),
                  color: AppColors.positive,
                ),
              ),
              Expanded(
                child: _Stat(
                  label: 'Passifs',
                  hint: 'Somme des emprunts',
                  value: formatEuro(summary.totalLiabilities),
                  color: AppColors.negative,
                ),
              ),
            ],
          ),
          if (summary.totalPnl != 0) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(
                  positive ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 16,
                  color: pnlColor,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          'Plus-value latente',
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      InfoHint(
                        'Valeur actuelle − coût d\'achat, pour les positions',
                      ),
                    ],
                  ),
                ),
                Text(
                  formatSignedEuro(summary.totalPnl),
                  style: TextStyle(color: pnlColor, fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: 8),
                Text(
                  formatPct(summary.totalPnlPct),
                  style: TextStyle(color: pnlColor),
                ),
                InfoHint(
                  'Plus-value ÷ coût d\'achat des positions',
                  size: 13,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String hint;
  final String value;
  final Color color;
  const _Stat({
    required this.label,
    required this.hint,
    required this.value,
    required this.color,
  });

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
            InfoHint(hint),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}
