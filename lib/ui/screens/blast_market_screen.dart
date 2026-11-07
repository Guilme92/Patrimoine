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
/// daté des transactions (nombre d'actions, prix unitaire, frais, commission
/// de plus-value, PV brute et PV nette pour les ventes). Deux filtres :
/// type de transaction (tous / achats / ventes) et recherche par nom de
/// startup. Un appui sur une carte ouvre la fiche détail de la startup.
class BlastMarketScreen extends StatefulWidget {
  const BlastMarketScreen({super.key});

  @override
  State<BlastMarketScreen> createState() => _BlastMarketScreenState();
}

class _BlastMarketScreenState extends State<BlastMarketScreen> {
  final TextEditingController _searchController = TextEditingController();
  SecondaryTypeFilter _filter = SecondaryTypeFilter.tous;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PortfolioController>();
    if (controller.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Toutes les startups ayant au moins une transaction secondaire.
    final allRows = <_MarketRow>[];
    for (final entry in controller.startupEntries) {
      final transactions = controller.secondaryTransactionsOf(entry.asset.id);
      if (transactions.isEmpty) continue;
      allRows.add(_MarketRow(entry: entry, transactions: transactions));
    }
    if (allRows.isEmpty) return const _EmptyMarket();

    // Filtres : nom de startup (insensible casse/accents) puis type.
    final rows = <_MarketRow>[];
    for (final row in allRows) {
      if (!startupNameMatches(row.entry.asset.name, _query)) continue;
      final filtered = row.transactions
          .where((t) => secondaryTypeMatches(t.type, _filter))
          .toList();
      if (filtered.isEmpty) continue;
      rows.add(_MarketRow(entry: row.entry, transactions: filtered));
    }

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
          _MarketFilters(
            controller: _searchController,
            filter: _filter,
            onQueryChanged: (value) => setState(() => _query = value),
            onFilterChanged: (value) => setState(() => _filter = value),
          ),
          const SizedBox(height: 12),
          if (rows.isEmpty)
            _NoMatch(query: _query)
          else
            for (final row in rows) _StartupMarketCard(row: row),
        ],
      ),
    );
  }
}

/// Barre de recherche + filtre de type des transactions.
class _MarketFilters extends StatelessWidget {
  final TextEditingController controller;
  final SecondaryTypeFilter filter;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<SecondaryTypeFilter> onFilterChanged;

  const _MarketFilters({
    required this.controller,
    required this.filter,
    required this.onQueryChanged,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          onChanged: onQueryChanged,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            isDense: true,
            hintText: 'Rechercher une startup',
            prefixIcon: const Icon(Icons.search, size: 18),
            suffixIcon: controller.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Effacer',
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () {
                      controller.clear();
                      onQueryChanged('');
                    },
                  ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<SecondaryTypeFilter>(
            showSelectedIcon: false,
            segments: [
              for (final option in SecondaryTypeFilter.values)
                ButtonSegment<SecondaryTypeFilter>(
                  value: option,
                  label: Text(
                    secondaryTypeFilterLabel(option),
                    style: theme.textTheme.bodySmall,
                  ),
                ),
            ],
            selected: {filter},
            onSelectionChanged: (selection) => onFilterChanged(selection.first),
          ),
        ),
      ],
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

  /// PV nette cumulée des ventes, uniquement si le PRU est connu.
  double get totalPvNet {
    final pru = entry.detail.prixEntree;
    if (!secondaryPruAvailable(pru)) return 0;
    return transactions
        .where((t) => t.type == 'revente' && t.actions > 0 && t.prix > 0)
        .fold<double>(
          0,
          (s, t) =>
              s +
              secondaryPvNet(
                t.actions.toDouble(),
                t.prix,
                pru,
                t.commissionPv,
                t.frais,
              ),
        );
  }
}

class _StartupMarketCard extends StatelessWidget {
  final _MarketRow row;

  const _StartupMarketCard({required this.row});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final asset = row.entry.asset;
    final pru = row.entry.detail.prixEntree;
    final pvNet = row.totalPvNet;
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
                if (pvNet != 0)
                  Expanded(
                    child: _Total(
                      label: 'PV nette',
                      value: formatSignedEuro(pvNet),
                      color: pvNet >= 0
                          ? AppColors.positive
                          : AppColors.negative,
                    ),
                  ),
              ],
            ),
            const Divider(height: 20),
            for (var i = 0; i < row.transactions.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              _TransactionLine(transaction: row.transactions[i], pru: pru),
            ],
          ],
        ),
      ),
    );
  }
}

class _TransactionLine extends StatelessWidget {
  final SecondaryTransaction transaction;

  /// PRU (prix moyen d'acquisition) de la startup, 0 si inconnu.
  final double pru;

  const _TransactionLine({required this.transaction, required this.pru});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSale = transaction.type == 'revente';
    final color = isSale ? AppColors.primary : AppColors.textSecondary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              isSale ? Icons.south_west : Icons.north_east,
              size: 14,
              color: color,
            ),
            const SizedBox(width: 6),
            SizedBox(
              width: 66,
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
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20, top: 2),
          child: Text(
            _detailLabel(),
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  /// Détail chiffré de la transaction.
  ///
  /// Achat : « N actions · PU X € · Frais Y € ».
  /// Vente : idem + commission de PV, PV brute et PV nette (flat tax 30 %
  /// incluse). La PV est une estimation fondée sur le PRU moyen de la fiche
  /// startup ; elle reste « — » quand ce PRU est inconnu.
  String _detailLabel() {
    if (transaction.actions <= 0 || transaction.prix <= 0) {
      return 'Détail non renseigné';
    }
    final parts = <String>[
      _actionsLabel(transaction.actions),
      'PU ${formatEuro(transaction.prix, cents: true)}',
      'Frais ${formatEuro(transaction.frais, cents: true)}',
    ];
    if (transaction.type == 'revente') {
      parts.add(
        'Commission PV ${formatEuro(transaction.commissionPv, cents: true)}',
      );
      if (secondaryPruAvailable(pru)) {
        final actions = transaction.actions.toDouble();
        final brut = secondaryPvBrut(actions, transaction.prix, pru);
        final net = secondaryPvNet(
          actions,
          transaction.prix,
          pru,
          transaction.commissionPv,
          transaction.frais,
        );
        parts.add('PV brut ${formatSignedEuro(brut, cents: true)}');
        parts.add('PV net ${formatSignedEuro(net, cents: true)}');
      } else {
        parts.add('PV brut —');
        parts.add('PV net —');
      }
    }
    return parts.join(' · ');
  }

  static String _actionsLabel(int actions) =>
      actions == 1 ? '1 action' : '$actions actions';
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

/// Aucune transaction ne correspond aux filtres courants.
class _NoMatch extends StatelessWidget {
  final String query;

  const _NoMatch({required this.query});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: cardDecoration(),
      child: Column(
        children: [
          const Icon(
            Icons.filter_alt_off,
            size: 28,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 10),
          Text(
            query.trim().isEmpty
                ? 'Aucune transaction pour ce filtre'
                : 'Aucune startup pour « ${query.trim()} »',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 6),
          Text(
            'Modifiez la recherche ou le filtre de type.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
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
