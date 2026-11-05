import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';

/// Courbe d'évolution du patrimoine net (un point par jour).
///
/// - aucun point : rien n'est affiché ;
/// - un seul point : la valeur et une explication ;
/// - deux points ou plus : courbe lissée avec remplissage dégradé.
class NetWorthChart extends StatelessWidget {
  final List<NetWorthSnapshot> snapshots;

  const NetWorthChart({super.key, required this.snapshots});

  @override
  Widget build(BuildContext context) {
    if (snapshots.isEmpty) return const SizedBox.shrink();

    final points = [...snapshots]..sort((a, b) => a.date.compareTo(b.date));
    final first = points.first.netWorth;
    final last = points.last.netWorth;
    final delta = last - first;
    final deltaPct = first == 0 ? 0.0 : delta / first.abs() * 100;

    return Container(
      decoration: cardDecoration(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Évolution du patrimoine',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          if (points.length == 1)
            _SinglePoint(value: last)
          else ...[
            _Variation(delta: delta, deltaPct: deltaPct),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: _Chart(points: points),
            ),
          ],
        ],
      ),
    );
  }
}

class _SinglePoint extends StatelessWidget {
  final double value;
  const _SinglePoint({required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          formatEuro(value),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'La courbe se construit au fil des jours',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _Variation extends StatelessWidget {
  final double delta;
  final double deltaPct;
  const _Variation({required this.delta, required this.deltaPct});

  @override
  Widget build(BuildContext context) {
    final positive = delta >= 0;
    final color = positive ? AppColors.positive : AppColors.negative;
    return Row(
      children: [
        Icon(
          positive ? Icons.arrow_upward : Icons.arrow_downward,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            '${formatSignedEuro(delta)} (${formatPct(deltaPct)})',
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 6),
        Text('depuis le début', style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _Chart extends StatelessWidget {
  final List<NetWorthSnapshot> points;
  const _Chart({required this.points});

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[
      for (var i = 0; i < points.length; i++)
        FlSpot(i.toDouble(), points[i].netWorth),
    ];
    final values = points.map((p) => p.netWorth);
    final high = values.reduce((a, b) => a > b ? a : b);
    final low = values.reduce((a, b) => a < b ? a : b);
    var range = high - low;
    if (range <= 0) range = high.abs() * 0.1 + 1;
    final minY = low - range * 0.15;
    final maxY = high + range * 0.15;
    final yInterval = (maxY - minY) / 3;
    final xInterval = (points.length / 4).ceilToDouble().clamp(1.0, 1000.0);

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (points.length - 1).toDouble(),
        minY: minY,
        maxY: maxY,
        clipData: const FlClipData.all(),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: yInterval,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: AppColors.divider, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 52,
              interval: yInterval,
              getTitlesWidget: (value, meta) {
                if (value <= minY || value >= maxY) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  meta: meta,
                  space: 6,
                  child: Text(
                    formatCompactEuro(value),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              interval: xInterval,
              getTitlesWidget: (value, meta) {
                final index = value.round();
                if ((value - index).abs() > 0.001 ||
                    index < 0 ||
                    index >= points.length) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  meta: meta,
                  space: 6,
                  child: Text(
                    formatShortDate(points[index].date),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.surfaceAlt,
            tooltipBorder: const BorderSide(color: AppColors.divider),
            getTooltipItems: (touched) => touched.map((spot) {
              final index = spot.x.round().clamp(0, points.length - 1);
              final point = points[index];
              return LineTooltipItem(
                '${formatDate(point.date)}\n${formatEuro(point.netWorth)}',
                const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              );
            }).toList(),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.25,
            preventCurveOverShooting: true,
            color: AppColors.positive,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: points.length <= 40,
              getDotPainter: (spot, percent, bar, index) =>
                  FlDotCirclePainter(
                    radius: 2.5,
                    color: AppColors.positive,
                    strokeWidth: 0,
                  ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.positive.withValues(alpha: 0.30),
                  AppColors.positive.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
