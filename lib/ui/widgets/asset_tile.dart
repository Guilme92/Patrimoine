import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../domain/portfolio.dart';
import '../../models/asset_type.dart';
import '../../theme/app_theme.dart';
import '../../theme/palette.dart';
import '../../utils/format.dart';
import '../screens/asset_detail_screen.dart';

class AssetTile extends StatelessWidget {
  final Asset asset;
  final List<Position> positions;
  final Map<String, double> prices;
  final StartupDetail? startup;
  const AssetTile({
    super.key,
    required this.asset,
    required this.positions,
    required this.prices,
    this.startup,
  });

  @override
  Widget build(BuildContext context) {
    final type = assetTypeFrom(asset.type);
    final value = assetValue(
      asset: asset,
      positions: positions,
      prices: prices,
      startup: startup,
    );
    final color = assetTypeColors[type] ?? AppColors.primary;
    final subtitle = positions.isEmpty
        ? assetTypeLabel(type)
        : '${assetTypeLabel(type)} · ${positions.length} position${positions.length > 1 ? 's' : ''}';
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AssetDetailScreen(asset: asset)),
      ),
      child: Container(
        decoration: cardDecoration(),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(assetTypeIcon(type), color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    asset.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            Text(
              formatEuro(value),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
