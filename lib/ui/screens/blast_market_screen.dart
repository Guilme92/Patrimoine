import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/portfolio_controller.dart';
import '../../data/database.dart';
import '../../domain/startup_portfolio.dart';
import '../../models/startup.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import 'asset_detail_screen.dart';

/// Onglet « Blast Market » : marché secondaire des startups.
///
/// Liste les startups qui portent au moins une transaction secondaire
/// (achat ou revente), avec le total acheté, le total revendu et le détail
/// daté des transactions. Un appui ouvre la fiche détail de la startup.
class BlastMarketScreen extends StatelessWidget {
  const BlastMarketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PortfolioController>();
    if (controller.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final rows = <_MarketRow>[];
    for (final entry in controller.startupEntries) {
      final transactions = controller.secondaryTransactionsOf(entry.asset.id);
      if (transactions.isEmpty) continue;
      rows.add(_MarketRow(entry: entry, transactions: transactions));
    }

    if (rows.isEmpty) return const _EmptyMarket();

    final totalAchat = rows.fold<double>(0, (s, r) => s + r.totalAchat);
    final totalRevente = rows.fold<double>(0, (s, r) => s + r.totalRevente);

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
                    const Icon(
                      Icons.swap_horiz,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Marché secondaire (${rows.length})',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _Total(
                        label: 'Total acheté',
                        value: formatEuro(totalAchat),
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Expanded(
                      child: _Total(
                        label: 'Total revendu',
                        value: formatEuro(totalRevente),
                        color: AppColors.primary,
                      ),
                    ),
                    Expanded(
                      child: _Total(
                        label: 'Solde net',
                        value: formatSignedEuro(totalRevente - totalAchat),
                        color: totalRevente - totalAchat >= 0
                            ? AppColors.positive
                            : AppColors.negative,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          for (final row in rows) _StartupMarketCard(row: row),
        ],
      ),
    );
  }
}

/// Une startup du marché secondaire et ses agrégats.
class _MarketRow {
  final StartupEntry entry;
  final List<SecondaryTransaction> transactions;

  const _MarketRow({required this.entry, required this.transactions});

  double get totalAchat => transactions
      .where((t) => t.type == 'achat')
      .fold<double>(0, (s, t) => s + t.montant);

  double get totalRevente => transactions
      .where((t) => t.type == 'revente')
      .fold<double>(0, (s, t) => s + t.montant);
}

class _StartupMarketCard extends StatelessWidget {
  final _MarketRow row;

  const _StartupMarketCard({required this.row});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final asset = row.entry.asset;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => AssetDetailScreen(asset: asset),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    asset.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _Total(
                    label: 'Acheté',
                    value: formatEuro(row.totalAchat),
                    color: AppColors.textPrimary,
                  ),
                ),
                Expanded(
                  child: _Total(
                    label: 'Revendu',
                    value: formatEuro(row.totalRevente),
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            for (var i = 0; i < row.transactions.length; i++) ...[
              if (i > 0) const SizedBox(height: 6),
              _TransactionLine(transaction: row.transactions[i]),
            ],
          ],
        ),
      ),
    );
  }
}

class _TransactionLine extends StatelessWidget {
  final SecondaryTransaction transaction;

  const _TransactionLine({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSale = transaction.type == 'revente';
    final color = isSale ? AppColors.primary : AppColors.textSecondary;
    return Row(
      children: [
        Icon(
          isSale ? Icons.south_west : Icons.north_east,
          size: 14,
          color: color,
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 74,
          child: Text(
            secondaryTransactionTypeLabel(transaction.type),
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
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
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _Total extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _Total({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodySmall?.copyWith(fontSize: 11)),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyMarket extends StatelessWidget {
  const _EmptyMarket();

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
              const Icon(
                Icons.swap_horiz,
                size: 44,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                'Aucune transaction secondaire',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Les achats et reventes importés depuis la colonne '
                '« marche_secondaire » du CSV apparaîtront ici.',
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
