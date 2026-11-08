import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/portfolio_controller.dart';
import '../../data/database.dart';
import '../../domain/startup_portfolio.dart';
import '../../models/startup.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import 'asset_detail_screen.dart';

/// Détail du marché secondaire d'une startup.
///
/// Ouvert depuis la carte compacte de [BlastMarketScreen] : reprend le détail
/// ligne par ligne auparavant affiché en ligne — date, type, nombre d'actions,
/// prix unitaire, frais, commission de PV, PV brute et PV nette (flat tax
/// incluse) — ainsi que le rappel des totaux de la startup.
class BlastMarketDetailScreen extends StatelessWidget {
  final int assetId;

  const BlastMarketDetailScreen({super.key, required this.assetId});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PortfolioController>();
    final asset = controller.assetById(assetId);
    if (asset == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Marché secondaire')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('Cette startup a été supprimée.'),
          ),
        ),
      );
    }

    final startup = controller.startupOf(assetId);
    final pru = startup?.prixEntree ?? 0;
    final transactions = controller.secondaryTransactionsOf(assetId);
    final summary = SecondaryMarketSummary.of(transactions, pru: pru);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(asset.name),
        actions: [
          IconButton(
            tooltip: 'Fiche de la startup',
            icon: const Icon(Icons.open_in_new, size: 20),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => AssetDetailScreen(asset: asset),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _SummaryCard(summary: summary, pru: pru),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Transactions (${transactions.length})',
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (transactions.isEmpty)
            Text(
              'Aucune transaction secondaire pour cette startup.',
              style: theme.textTheme.bodySmall,
            )
          else
            for (final transaction in transactions)
              _TransactionDetailCard(transaction: transaction, pru: pru),
          const SizedBox(height: 6),
          Text(
            'La plus-value est estimée à partir du PRU de la fiche '
            '(${pru > 0 ? formatEuro(pru, cents: true) : 'inconnu'}) : '
            'approximation sans suivi FIFO des lots. La PV nette déduit la '
            'commission, les frais puis la flat tax de 30 %.',
            style: theme.textTheme.bodySmall?.copyWith(fontSize: 10.5),
          ),
        ],
      ),
    );
  }
}

/// Rappel des totaux de la startup (mêmes agrégats que la carte compacte).
class _SummaryCard extends StatelessWidget {
  final SecondaryMarketSummary summary;
  final double pru;

  const _SummaryCard({required this.summary, required this.pru});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pvNette = summary.pvIndisponible
        ? '—'
        : formatSignedEuro(summary.pvNette);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _Metric(
                  label: 'Total acheté',
                  value: formatEuro(summary.totalAchat),
                  color: AppColors.textPrimary,
                ),
              ),
              Expanded(
                child: _Metric(
                  label: 'Total revendu',
                  value: formatEuro(summary.totalRevente),
                  color: AppColors.primary,
                ),
              ),
              Expanded(
                child: _Metric(
                  label: 'PV nette totale',
                  value: pvNette,
                  color: summary.pvNette >= 0
                      ? AppColors.positive
                      : AppColors.negative,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'P.U. moyen d\'achat : '
            '${summary.actionsAchat > 0 ? formatEuro(summary.puMoyenAchat, cents: true) : '—'}'
            '   ·   P.U. moyen de vente : '
            '${summary.actionsVente > 0 ? formatEuro(summary.puMoyenVente, cents: true) : '—'}',
            style: theme.textTheme.bodySmall?.copyWith(fontSize: 10.5),
          ),
        ],
      ),
    );
  }
}

/// Une transaction du marché secondaire, entièrement détaillée.
class _TransactionDetailCard extends StatelessWidget {
  final SecondaryTransaction transaction;

  /// PRU (prix moyen d'acquisition) de la startup, 0 si inconnu.
  final double pru;

  const _TransactionDetailCard({required this.transaction, required this.pru});

  bool get _isSale => transaction.type == 'revente';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _isSale ? AppColors.primary : AppColors.textSecondary;
    final hasDetail = transaction.actions > 0 && transaction.prix > 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isSale ? Icons.south_west : Icons.north_east,
                      size: 12,
                      color: color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      secondaryTransactionTypeLabel(transaction.type),
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  transaction.date == null
                      ? 'Date inconnue'
                      : formatDate(transaction.date!),
                  style: theme.textTheme.bodySmall,
                ),
              ),
              Text(
                formatEuro(transaction.montant, cents: true),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            _isSale ? 'Montant net reçu' : 'Montant payé',
            style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
          ),
          const Divider(height: 18),
          if (!hasDetail)
            Text(
              'Détail non renseigné',
              style: theme.textTheme.bodySmall,
            )
          else ...[
            _DetailRow(
              label: 'Actions',
              value: _actionsLabel(transaction.actions),
            ),
            _DetailRow(
              label: 'Prix unitaire',
              value: formatEuro(transaction.prix, cents: true),
            ),
            _DetailRow(
              label: 'Frais',
              value: formatEuro(transaction.frais, cents: true),
            ),
            if (_isSale) ...[
              _DetailRow(
                label: 'Commission PV',
                value: formatEuro(transaction.commissionPv, cents: true),
              ),
              if (secondaryPruAvailable(pru)) ...[
                _DetailRow(
                  label: 'PV brute',
                  value: formatSignedEuro(
                    secondaryPvBrut(
                      transaction.actions.toDouble(),
                      transaction.prix,
                      pru,
                    ),
                    cents: true,
                  ),
                  color: AppColors.textPrimary,
                ),
                _DetailRow(
                  label: 'PV nette',
                  value: formatSignedEuro(
                    secondaryPvNet(
                      transaction.actions.toDouble(),
                      transaction.prix,
                      pru,
                      transaction.commissionPv,
                      transaction.frais,
                    ),
                    cents: true,
                  ),
                  color: AppColors.primary,
                ),
              ] else ...[
                const _DetailRow(label: 'PV brute', value: '—'),
                const _DetailRow(label: 'PV nette', value: '—'),
              ],
            ],
          ],
        ],
      ),
    );
  }

  static String _actionsLabel(int actions) =>
      actions == 1 ? '1 action' : '$actions actions';
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _DetailRow({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 11.5),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _Metric({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodySmall?.copyWith(fontSize: 10.5)),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
