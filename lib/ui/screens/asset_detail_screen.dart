import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/portfolio_controller.dart';
import '../../data/database.dart';
import '../../domain/portfolio.dart';
import '../../models/asset_type.dart';
import '../../theme/app_theme.dart';
import '../../theme/palette.dart';
import '../../utils/format.dart';
import 'add_position_screen.dart';

class AssetDetailScreen extends StatelessWidget {
  final Asset asset;
  const AssetDetailScreen({super.key, required this.asset});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PortfolioController>();
    final positions = controller.positionsOf(asset.id);
    final type = assetTypeFrom(asset.type);
    final value =
        assetValue(asset: asset, positions: positions, prices: controller.prices);

    return Scaffold(
      appBar: AppBar(
        title: Text(asset.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            decoration: cardDecoration(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(assetTypeIcon(type), color: assetTypeColors[type]),
                    const SizedBox(width: 8),
                    Text(assetTypeLabel(type),
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
                const SizedBox(height: 8),
                Text(formatEuro(value),
                    style: Theme.of(context).textTheme.headlineMedium),
                if (asset.institution != null) ...[
                  const SizedBox(height: 4),
                  Text(asset.institution!,
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (supportsPositions(type)) ...[
            Row(
              children: [
                Text('Positions', style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => AddPositionScreen(asset: asset)),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (positions.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child:
                    Text('Aucune position. Ajoutez vos titres ou cryptos.'),
              )
            else
              ...positions.map(
                (p) => _PositionTile(
                  position: p,
                  price: controller.prices[p.symbol],
                ),
              ),
          ],
          if (asset.note != null && asset.note!.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('Note', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(asset.note!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final controller = context.read<PortfolioController>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer ?'),
        content: Text('Supprimer « ${asset.name} » et toutes ses positions ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await controller.deleteAsset(asset.id);
      if (context.mounted) Navigator.pop(context);
    }
  }
}

class _PositionTile extends StatelessWidget {
  final Position position;
  final double? price;
  const _PositionTile({required this.position, this.price});

  @override
  Widget build(BuildContext context) {
    final p = price ?? position.unitCost;
    final pnl = positionPnl(position, p);
    final pnlPct = positionPnlPct(position, p);
    final positive = pnl >= 0;
    final color = positive ? AppColors.positive : AppColors.negative;
    return Container(
      decoration: cardDecoration(),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  position.name,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${_fmtQty(position.quantity)} × ${formatEuro(position.unitCost, cents: true)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatEuro(positionValue(position, p)),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 2),
              Text(
                '${formatSignedEuro(pnl)} (${formatPct(pnlPct)})',
                style: TextStyle(color: color, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _fmtQty(double q) {
    final s = q.toStringAsFixed(6);
    return s.replaceFirst(RegExp(r'\.?0+$'), '');
  }
}
