import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/portfolio_controller.dart';
import '../../domain/startup.dart';
import '../../models/startup.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../widgets/asset_tile.dart';

/// Onglet « Blast » : startups du portefeuille SANS catégorie
/// (imports Blast Round 1 / Round 2). Présentation simple, chaque ligne
/// ouvre la fiche détail existante.
class BlastScreen extends StatelessWidget {
  const BlastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PortfolioController>();
    if (controller.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final entries = controller.startupEntries
        .where((e) => !hasStartupCategory(e.detail.categorie))
        .toList();

    if (entries.isEmpty) {
      return const _EmptyBlast();
    }

    final totalValue = entries.fold<double>(
      0,
      (sum, e) => sum + lineValue(e.detail),
    );
    final totalInvested = entries.fold<double>(
      0,
      (sum, e) => sum + investedCapital(e.detail),
    );

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.bolt, size: 20, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Blast (${entries.length})',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Startups importées sans catégorie. '
                  'Capital investi ${formatEuro(totalInvested)} · '
                  'valorisation ${formatEuro(totalValue)}.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          for (final e in entries)
            AssetTile(
              asset: e.asset,
              positions: controller.positionsOf(e.asset.id),
              prices: controller.prices,
              startup: e.detail,
            ),
        ],
      ),
    );
  }
}

class _EmptyBlast extends StatelessWidget {
  const _EmptyBlast();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.bolt, size: 44, color: AppColors.textSecondary),
              const SizedBox(height: 16),
              Text(
                'Aucune startup Blast',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Toutes les startups du portefeuille ont une catégorie. '
                'Les imports Blast sans catégorie apparaîtront ici.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
