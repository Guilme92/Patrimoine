import 'dart:math';

import 'package:flutter/material.dart';

import '../../models/asset_type.dart';
import '../../theme/app_theme.dart';
import '../../theme/palette.dart';
import '../../utils/format.dart';
import 'info_hint.dart';

class AllocationDonut extends StatelessWidget {
  final Map<AssetType, double> allocation;
  final double total;
  const AllocationDonut(
      {super.key, required this.allocation, required this.total});

  @override
  Widget build(BuildContext context) {
    final segments = allocation.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (segments.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: cardDecoration(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Répartition', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 110,
                height: 110,
                child: CustomPaint(
                  painter: _DonutPainter(segments: segments, total: total),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: segments.map((e) {
                    final pct = total == 0 ? 0.0 : e.value / total * 100;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: assetTypeColors[e.key],
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              assetTypeLabel(e.key),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                          Text(
                            formatShare(pct),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const InfoHint(
                            'Valeur de la catégorie ÷ total des actifs',
                            size: 13,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<MapEntry<AssetType, double>> segments;
  final double total;
  _DonutPainter({required this.segments, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 8;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22;
    var start = -pi / 2;
    for (final seg in segments) {
      final sweep = (seg.value / total) * 2 * pi;
      paint.color = assetTypeColors[seg.key]!;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        false,
        paint,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.total != total || old.segments != segments;
}
