import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/portfolio_controller.dart';
import '../../data/database.dart';
import '../../domain/startup_portfolio.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import 'blast_market_detail_screen.dart';

/// Onglet « Blast Market » : marché secondaire des startups.
///
/// Deux niveaux d'information :
/// 1. des KPIs agrégés sur le périmètre filtré (total acheté, total revendu,
///    solde net, plus-value brute et plus-value nette des ventes) ;
/// 2. une grille compacte de startups (2 à 4 cartes par ligne selon la
///    largeur) qui ne montre que les totaux achats / ventes avec le nombre
///    d'actions et le prix unitaire moyen de chaque sens.
///
/// Le détail ligne par ligne (date, type, actions, PU, frais, commission PV,
/// PV brute et PV nette) est déplacé dans [BlastMarketDetailScreen], ouvert au
/// clic sur une carte. Deux filtres s'appliquent à la grille ET aux KPIs :
/// type de transaction (tous / achats / ventes) et recherche par nom.
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
    // Le périmètre filtré alimente la grille comme les KPIs.
    final rows = <_MarketRow>[];
    for (final row in allRows) {
      if (!startupNameMatches(row.entry.asset.name, _query)) continue;
      final filtered = row.transactions
          .where((t) => secondaryTypeMatches(t.type, _filter))
          .toList();
      if (filtered.isEmpty) continue;
      rows.add(row.withTransactions(filtered));
    }

    var summary = SecondaryMarketSummary.empty;
    for (final row in rows) {
      summary = summary + row.summary;
    }

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            sliver: SliverList.list(
              children: [
                _MarketHeader(count: rows.length, summary: summary),
                const SizedBox(height: 12),
                _MarketFilters(
                  controller: _searchController,
                  filter: _filter,
                  onQueryChanged: (value) => setState(() => _query = value),
                  onFilterChanged: (value) => setState(() => _filter = value),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          if (rows.isEmpty)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(child: _NoMatch(query: _query)),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
              sliver: SliverGrid(
                key: const Key('market-grid'),
                gridDelegate:
                    const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 300,
                      mainAxisExtent: 172,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final row = rows[index];
                  return _StartupMarketCard(
                    key: ValueKey('market-card-${row.entry.asset.id}'),
                    row: row,
                    onTap: () => _openDetail(context, row),
                  );
                }, childCount: rows.length),
              ),
            ),
        ],
      ),
    );
  }

  void _openDetail(BuildContext context, _MarketRow row) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => BlastMarketDetailScreen(assetId: row.entry.asset.id),
      ),
    );
  }
}

/// En-tête : titre, totaux de flux et KPIs de plus-value du périmètre filtré.
class _MarketHeader extends StatelessWidget {
  final int count;
  final SecondaryMarketSummary summary;

  const _MarketHeader({required this.count, required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final solde = summary.totalRevente - summary.totalAchat;
    final pvBrute = summary.pvIndisponible
        ? '—'
        : formatSignedEuro(summary.pvBrute, cents: true);
    final pvNette = summary.pvIndisponible
        ? '—'
        : formatSignedEuro(summary.pvNette, cents: true);
    return Container(
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
                  'Marché secondaire ($count)',
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Total(
                  label: 'Total acheté',
                  value: formatEuro(summary.totalAchat),
                  color: AppColors.textPrimary,
                ),
              ),
              Expanded(
                child: _Total(
                  label: 'Total revendu',
                  value: formatEuro(summary.totalRevente),
                  color: AppColors.primary,
                ),
              ),
              Expanded(
                child: _Total(
                  label: 'Solde net',
                  value: formatSignedEuro(solde),
                  color: solde >= 0
                      ? AppColors.positive
                      : AppColors.negative,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _PvKpi(
                  key: const Key('kpi-pv-brute'),
                  label: 'Plus-value brute totale',
                  value: pvBrute,
                  color: summary.pvBrute >= 0
                      ? AppColors.positive
                      : AppColors.negative,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PvKpi(
                  key: const Key('kpi-pv-nette'),
                  label: 'Plus-value nette totale',
                  value: pvNette,
                  color: summary.pvNette >= 0
                      ? AppColors.positive
                      : AppColors.negative,
                ),
              ),
            ],
          ),
          if (summary.pvPartielle) ...[
            const SizedBox(height: 8),
            Text(
              'Estimation hors ventes sans PRU connu ni détail chiffré.',
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
            ),
          ],
        ],
      ),
    );
  }
}

/// Carte KPI de plus-value (fond légèrement contrasté).
class _PvKpi extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _PvKpi({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(fontSize: 10.5),
          ),
          const SizedBox(height: 3),
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
  final SecondaryMarketSummary summary;

  const _MarketRow._({
    required this.entry,
    required this.transactions,
    required this.summary,
  });

  factory _MarketRow({
    required StartupEntry entry,
    required List<SecondaryTransaction> transactions,
  }) => _MarketRow._(
    entry: entry,
    transactions: transactions,
    summary: SecondaryMarketSummary.of(
      transactions,
      pru: entry.detail.prixEntree,
    ),
  );

  /// Même startup, restreinte aux transactions qui passent le filtre de type.
  _MarketRow withTransactions(List<SecondaryTransaction> filtered) =>
      _MarketRow(entry: entry, transactions: filtered);
}

/// Carte compacte : nom + totaux achats / ventes (montant, actions, P.U.).
class _StartupMarketCard extends StatelessWidget {
  final _MarketRow row;
  final VoidCallback onTap;

  const _StartupMarketCard({
    super.key,
    required this.row,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final summary = row.summary;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    row.entry.asset.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: 10),
            _TypeTotals(
              label: 'ACHATS',
              color: AppColors.textSecondary,
              montant: summary.aDesAchats
                  ? formatEuro(summary.totalAchat)
                  : '—',
              actions: summary.actionsAchat,
              puMoyen: summary.puMoyenAchat,
            ),
            const Divider(height: 14),
            _TypeTotals(
              label: 'VENTES',
              color: AppColors.primary,
              montant: summary.aDesVentes
                  ? formatEuro(summary.totalRevente)
                  : '—',
              actions: summary.actionsVente,
              puMoyen: summary.puMoyenVente,
            ),
          ],
        ),
      ),
    );
  }
}

/// Bloc « sens de transaction » d'une carte compacte.
class _TypeTotals extends StatelessWidget {
  final String label;
  final Color color;
  final String montant;
  final int actions;
  final double puMoyen;

  const _TypeTotals({
    required this.label,
    required this.color,
    required this.montant,
    required this.actions,
    required this.puMoyen,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final details = actions > 0
        ? '${_actionsLabel(actions)} · PU ${formatEuro(puMoyen, cents: true)}'
        : '—';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.7,
            color: color,
          ),
        ),
        const SizedBox(height: 1),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            montant,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 1),
        SizedBox(
          width: double.infinity,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              details,
              maxLines: 1,
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
            ),
          ),
        ),
      ],
    );
  }

  static String _actionsLabel(int actions) =>
      actions == 1 ? '1 act.' : '$actions act.';
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
