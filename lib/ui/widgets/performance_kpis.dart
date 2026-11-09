import 'package:flutter/material.dart';

import '../../domain/performance.dart';
import '../../domain/portfolio.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import 'info_hint.dart';

/// Grille de KPIs de performance (2 colonnes).
class PerformanceKpiGrid extends StatelessWidget {
  final PerformanceSummary performance;
  final PortfolioSummary summary;

  const PerformanceKpiGrid({
    super.key,
    required this.performance,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final p = performance;
    final debtRatio = summary.totalAssets > 0
        ? summary.totalLiabilities / summary.totalAssets * 100
        : null;
    final tiles = <_Kpi>[
      _Kpi(
        icon: Icons.savings_outlined,
        label: 'Capital investi',
        value: formatEuro(p.invested),
        caption: p.hasInvestments
            ? 'Bourse, crypto, startups'
            : 'Aucun placement suivi',
        hint:
            'Coût d\'achat des positions et capital investi des startups. '
            'L\'immobilier, les liquidités et les collections ne sont pas '
            'inclus (prix de revient non suivi).',
      ),
      _Kpi(
        icon: Icons.show_chart,
        label: 'Plus-value latente',
        value: formatSignedEuro(p.unrealized),
        caption: '${formatPct(p.unrealizedPct)} du capital investi',
        color: p.unrealized >= 0 ? AppColors.positive : AppColors.negative,
        hint:
            'Valeur actuelle − coût d\'achat des positions et des startups '
            'en portefeuille.',
      ),
      _Kpi(
        icon: Icons.check_circle_outline,
        label: 'Plus-value réalisée',
        value: formatSignedEuro(p.realized),
        caption: 'Cessions et sorties',
        color: p.realized >= 0 ? AppColors.positive : AppColors.negative,
        hint:
            'Plus-values des startups sorties + reventes sur le marché '
            'secondaire, nettes de commission et de flat tax (30 %).',
      ),
      _Kpi(
        icon: Icons.insights_outlined,
        label: 'Performance globale',
        value: formatPct(p.totalGainPct),
        caption: p.totalGain >= 0
            ? '${formatSignedEuro(p.totalGain)} gagnés'
            : '${formatSignedEuro(p.totalGain)} perdus',
        color: p.totalGain >= 0 ? AppColors.positive : AppColors.negative,
        hint:
            'Plus-value latente + plus-value réalisée, rapportées au capital '
            'investi.',
      ),
      _Kpi(
        icon: Icons.receipt_long_outlined,
        label: 'Frais cumulés',
        value: formatEuro(p.fees),
        caption: p.hasInvestments
            ? '${formatShare(p.feesPct)} du capital investi'
            : 'Aucun frais saisi',
        hint:
            'Frais saisis sur les positions, les fiches startup et les '
            'transactions secondaires.',
      ),
      _Kpi(
        icon: Icons.account_balance_outlined,
        label: 'Taux d\'endettement',
        value: debtRatio == null ? '—' : formatShare(debtRatio),
        caption: debtRatio == null
            ? 'Aucun actif valorisé'
            : '${formatEuro(summary.totalLiabilities)} de passifs',
        color: debtRatio != null && debtRatio > 50
            ? AppColors.negative
            : AppColors.textPrimary,
        hint:
            'Total des passifs ÷ total des actifs. Un taux élevé signale un '
            'patrimoine davantage financé par la dette.',
      ),
    ];

    return Column(
      children: [
        for (var i = 0; i < tiles.length; i += 2)
          Padding(
            padding: EdgeInsets.only(top: i == 0 ? 0 : 10),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _KpiTile(data: tiles[i])),
                  const SizedBox(width: 10),
                  Expanded(
                    child: i + 1 < tiles.length
                        ? _KpiTile(data: tiles[i + 1])
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _Kpi {
  final IconData icon;
  final String label;
  final String value;
  final String caption;
  final String hint;
  final Color? color;

  const _Kpi({
    required this.icon,
    required this.label,
    required this.value,
    required this.caption,
    required this.hint,
    this.color,
  });
}

class _KpiTile extends StatelessWidget {
  final _Kpi data;

  const _KpiTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final valueColor = data.color ?? AppColors.textPrimary;
    return Container(
      decoration: cardDecoration(),
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(data.icon, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  data.label,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(fontSize: 12, height: 1.15),
                  maxLines: 2,
                ),
              ),
              InfoHint(data.hint, size: 13),
            ],
          ),
          const SizedBox(height: 9),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              data.value,
              maxLines: 1,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: valueColor,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            data.caption,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(fontSize: 11),
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
