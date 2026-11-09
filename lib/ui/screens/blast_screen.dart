import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/portfolio_controller.dart';
import '../../domain/startup.dart';
import '../../domain/startup_portfolio.dart';
import '../../models/startup.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../widgets/asset_tile.dart';
import '../widgets/blast_exit_simulator.dart';

/// Onglet « Blast » : simulateur de sortie sur les parts Blast + startups du
/// portefeuille SANS catégorie (imports Blast Round 1 / Round 2).
class BlastScreen extends StatefulWidget {
  const BlastScreen({super.key});

  @override
  State<BlastScreen> createState() => _BlastScreenState();
}

class _BlastScreenState extends State<BlastScreen> {
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PortfolioController>();
    if (controller.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final entries = controller.startupEntries
        .where((e) => !hasStartupCategory(e.detail.categorie))
        .toList();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          BlastExitSimulator(
            stakePct: controller.blastStakePct,
            invested: controller.blastInvested,
            onSaveParams: (stake, invested) => controller.setBlastExitParams(
              stakePct: stake,
              invested: invested,
            ),
          ),
          const SizedBox(height: 12),
          if (entries.isEmpty)
            const _EmptyBlastNote()
          else ...[
            _BlastHeader(entries: entries),
            const SizedBox(height: 12),
            for (final e in entries)
              AssetTile(
                asset: e.asset,
                positions: controller.positionsOf(e.asset.id),
                prices: controller.prices,
                startup: e.detail,
              ),
          ],
        ],
      ),
    );
  }
}

/// En-tête du bloc startups : titre et totaux (capital investi, valorisation).
class _BlastHeader extends StatelessWidget {
  final List<StartupEntry> entries;

  const _BlastHeader({required this.entries});

  @override
  Widget build(BuildContext context) {
    final totalValue = entries.fold<double>(
      0,
      (sum, e) => sum + lineValue(e.detail),
    );
    final totalInvested = entries.fold<double>(
      0,
      (sum, e) => sum + investedCapital(e.detail),
    );

    return Container(
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
    );
  }
}

class _EmptyBlastNote extends StatelessWidget {
  const _EmptyBlastNote();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: cardDecoration(),
      child: Column(
        children: [
          const Icon(Icons.bolt, size: 32, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text(
            'Aucune startup Blast',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            'Les imports Blast sans catégorie apparaîtront ici.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
