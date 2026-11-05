import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/portfolio_controller.dart';
import '../../data/database.dart';
import '../../models/asset_type.dart';
import '../../theme/palette.dart';
import '../widgets/asset_tile.dart';

class AssetsScreen extends StatelessWidget {
  const AssetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PortfolioController>();
    if (controller.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final assets = controller.assets;
    if (assets.isEmpty) {
      return const Center(child: Text('Aucun actif'));
    }
    final grouped = <AssetType, List<Asset>>{};
    for (final a in assets) {
      grouped.putIfAbsent(assetTypeFrom(a.type), () => []).add(a);
    }
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          for (final entry in grouped.entries) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Icon(assetTypeIcon(entry.key),
                      size: 18, color: assetTypeColors[entry.key]),
                  const SizedBox(width: 8),
                  Text(assetTypeLabel(entry.key),
                      style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            ),
            ...entry.value.map(
              (a) => AssetTile(
                asset: a,
                positions: controller.positionsOf(a.id),
                prices: controller.prices,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
