import 'package:flutter/material.dart';

import '../../domain/performance.dart';
import '../../models/asset_type.dart';
import '../../theme/app_theme.dart';
import '../../theme/palette.dart';
import '../../utils/format.dart';
import 'info_hint.dart';

/// Détail de la valeur et de la plus-value par classe d'actifs.
class PerformanceByTypeCard extends StatelessWidget {
  final PerformanceSummary performance;

  const PerformanceByTypeCard({super.key, required this.performance});

  @override
  Widget build(BuildContext context) {
    final rows = performance.byType;
    if (rows.isEmpty) return const SizedBox.shrink();
    final total = rows.fold<double>(0, (sum, row) => sum + row.value);
    return Container(
      decoration: cardDecoration(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Performance par classe',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const InfoHint(
                'Valeur actuelle, poids dans le patrimoine et plus-value '
                'latente par classe. La plus-value n\'est calculée que pour '
                'les classes dont le prix de revient est suivi (bourse, '
                'crypto, startups).',
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Valeur, poids et plus-value latente par classe.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const Divider(height: 18, color: AppColors.divider),
            _TypeRow(row: rows[i], total: total),
          ],
        ],
      ),
    );
  }
}

class _TypeRow extends StatelessWidget {
  final TypePerformance row;
  final double total;

  const _TypeRow({required this.row, required this.total});

  @override
  Widget build(BuildContext context) {
    final color = assetTypeColors[row.type] ?? AppColors.primary;
    final share = total > 0 ? (row.value / total).clamp(0.0, 1.0) : 0.0;
    final gainColor = row.unrealized >= 0
        ? AppColors.positive
        : AppColors.negative;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              assetTypeIcon(row.type),
              size: 14,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                assetTypeLabel(row.type),
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (row.tracked)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatSignedEuro(row.unrealized),
                    style: TextStyle(
                      color: gainColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    formatPct(row.gainPct),
                    style: TextStyle(color: gainColor, fontSize: 11),
                  ),
                ],
              )
            else
              Text('—', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: share,
                  minHeight: 6,
                  backgroundColor: AppColors.surfaceAlt,
                  color: color,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              formatEuro(row.value),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            SizedBox(
              width: 46,
              child: Text(
                formatShare(share * 100),
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(fontSize: 11),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Les trois lignes qui contribuent le plus à la plus-value latente.
class TopContributorsCard extends StatelessWidget {
  final List<PerformanceContributor> contributors;

  const TopContributorsCard({super.key, required this.contributors});

  @override
  Widget build(BuildContext context) {
    if (contributors.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: cardDecoration(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Meilleures performances',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const InfoHint(
                'Trois lignes avec la plus forte plus-value latente '
                '(positions et startups).',
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < contributors.length; i++) ...[
            if (i > 0) const Divider(height: 16, color: AppColors.divider),
            _ContributorRow(rank: i + 1, contributor: contributors[i]),
          ],
        ],
      ),
    );
  }
}

class _ContributorRow extends StatelessWidget {
  final int rank;
  final PerformanceContributor contributor;

  const _ContributorRow({required this.rank, required this.contributor});

  @override
  Widget build(BuildContext context) {
    final c = contributor;
    final color = c.gain >= 0 ? AppColors.positive : AppColors.negative;
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.surfaceAlt,
            shape: BoxShape.circle,
          ),
          child: Text(
            '$rank',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          assetTypeIcon(c.type),
          size: 14,
          color: assetTypeColors[c.type] ?? AppColors.textSecondary,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            c.name,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              formatSignedEuro(c.gain),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            Text(
              formatPct(c.gainPct),
              style: TextStyle(color: color, fontSize: 11),
            ),
          ],
        ),
      ],
    );
  }
}

/// Loyers, cashflow et rendement brut de l'ensemble des biens loués.
class RentalIncomeCard extends StatelessWidget {
  final PerformanceSummary performance;

  const RentalIncomeCard({super.key, required this.performance});

  @override
  Widget build(BuildContext context) {
    final p = performance;
    if (p.rentalCount == 0 || p.rentalValue <= 0) {
      return const SizedBox.shrink();
    }
    final cashflowColor = p.rentalMonthlyCashflow >= 0
        ? AppColors.positive
        : AppColors.negative;
    return Container(
      decoration: cardDecoration(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Revenus locatifs',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const InfoHint(
                'Loyers hors charges × 12, cashflow net de charges et de '
                'crédit, rendement brut moyen pondéré par la valeur des '
                'biens loués.',
              ),
            ],
          ),
          const SizedBox(height: 12),
          _RentalRow(
            icon: Icons.key_outlined,
            label: 'Loyers annuels',
            value: formatEuro(p.rentalAnnualRent),
          ),
          const Divider(height: 18, color: AppColors.divider),
          _RentalRow(
            icon: Icons.payments_outlined,
            label: 'Cashflow mensuel',
            value: formatSignedEuro(p.rentalMonthlyCashflow),
            color: cashflowColor,
          ),
          const Divider(height: 18, color: AppColors.divider),
          _RentalRow(
            icon: Icons.percent,
            label: 'Rendement brut moyen',
            value: formatShare(p.rentalGrossYieldPct),
          ),
        ],
      ),
    );
  }
}

class _RentalRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  const _RentalRow({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontSize: 15, color: color ?? AppColors.textPrimary),
        ),
      ],
    );
  }
}
