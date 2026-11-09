import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/portfolio_controller.dart';
import '../../domain/startup.dart';
import '../../domain/startup_portfolio.dart';
import '../../models/startup.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../widgets/info_hint.dart';
import 'asset_detail_screen.dart';

/// Dashboard dédié aux startups : filtres transverses (catégorie, année,
/// statut), synthèse (KPIs, répartition, tableau par catégorie), liste triable
/// et journal des sorties.
class StartupsScreen extends StatefulWidget {
  const StartupsScreen({super.key});

  @override
  State<StartupsScreen> createState() => _StartupsScreenState();
}

enum _Section { synthesis, list, exits }

enum _SortKey {
  name,
  category,
  year,
  invested,
  value,
  pnl,
  realizedPnl,
  moic,
  tri,
  status,
}

const Map<String, Color> _categoryColors = {
  'Licornes pre-IPO': Color(0xFFF97316),
  'Europe Multi-Stage': Color(0xFF3B82F6),
  'Y Combinator Series A': Color(0xFF8B5CF6),
  'Y Combinator Seed Selection': Color(0xFF16C784),
  'Blast': Color(0xFFF59E0B),
};

Color _categoryColor(String key) =>
    _categoryColors[key] ?? const Color(0xFFEC4899);

String _moicLabel(double v) => '${v.toStringAsFixed(2)}×';

double _entryInvested(StartupEntry e) => investedCapital(e.detail);

/// PV latente d'une ligne : elle ne porte que sur les actions RESTANTES
/// (`quantité × (prix actuel − PRU)`) et vaut 0 pour une sortie ou une
/// radiation. Les reventes secondaires n'y entrent jamais.
double _entryUnrealizedPnl(StartupEntry e) =>
    unrealizedGain(e.detail, totalSold: e.totalVendu);

/// PV réalisée d'une ligne : produit de sortie (moins le capital investi) ou
/// perte définitive d'une radiation, **plus** la PV nette des reventes
/// secondaires. Elle reste toujours distincte de la PV latente.
double _entryRealizedPnl(StartupEntry e, double secondaryPvNet) {
  final base = switch (e.detail.statut) {
    'sorti' => realizedGain(e.detail),
    'radie' => -investedCapital(e.detail),
    _ => 0.0,
  };
  return base + secondaryPvNet;
}

/// Capital investi total du portefeuille : somme du capital investi de chaque
/// startup. `montant_investi_eur` contient déjà le primaire **et** les achats
/// du marché secondaire, donc il ne faut PAS ré-ajouter les achats secondaires
/// ici (sinon double comptage du Blast Market).
double _totalInvestedGlobal(PortfolioController controller) {
  var total = 0.0;
  for (final e in controller.startupEntries) {
    total += investedCapital(e.detail);
  }
  return total;
}

Color _signedColor(double v) =>
    v >= 0 ? AppColors.positive : AppColors.negative;

class _StartupsScreenState extends State<StartupsScreen> {
  final Set<String> _categories = <String>{};
  final TextEditingController _searchController = TextEditingController();
  int _year = 0; // 0 = toutes les années
  String _status = 'all';
  String _query = '';
  _Section _section = _Section.synthesis;
  _SortKey _sortKey = _SortKey.value;
  bool _ascending = false;

  bool get _hasFilters =>
      _categories.isNotEmpty ||
      _year != 0 ||
      _status != 'all' ||
      _query.trim().isNotEmpty;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _resetFilters() {
    setState(() {
      _categories.clear();
      _year = 0;
      _status = 'all';
      _query = '';
    });
    _searchController.clear();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
  }

  bool _matches(StartupEntry entry) {
    if (_categories.isNotEmpty &&
        !_categories.contains(startupCategoryKey(entry.detail.categorie))) {
      return false;
    }
    if (_year != 0 && entry.detail.dateInvestissement?.year != _year) {
      return false;
    }
    if (_status != 'all' && entry.detail.statut != _status) return false;
    if (!startupNameMatches(entry.asset.name, _query)) return false;
    return true;
  }

  List<StartupEntry> _sorted(
    List<StartupEntry> entries,
    Map<int, double> secondaryRealized,
  ) {
    final list = [...entries];
    list.sort((a, b) {
      final cmp = _compare(a, b, secondaryRealized);
      return _ascending ? cmp : -cmp;
    });
    return list;
  }

  int _compare(
    StartupEntry a,
    StartupEntry b,
    Map<int, double> secondaryRealized,
  ) {
    int cmp;
    switch (_sortKey) {
      case _SortKey.name:
        cmp = a.asset.name.toLowerCase().compareTo(b.asset.name.toLowerCase());
        break;
      case _SortKey.category:
        cmp = startupCategoryKey(a.detail.categorie)
            .compareTo(startupCategoryKey(b.detail.categorie));
        break;
      case _SortKey.year:
        cmp = (a.detail.dateInvestissement?.year ?? 0).compareTo(
          b.detail.dateInvestissement?.year ?? 0,
        );
        break;
      case _SortKey.invested:
        cmp = _entryInvested(a).compareTo(_entryInvested(b));
        break;
      case _SortKey.value:
        cmp = lineValue(a.detail).compareTo(lineValue(b.detail));
        break;
      case _SortKey.pnl:
        cmp = _entryUnrealizedPnl(a).compareTo(_entryUnrealizedPnl(b));
        break;
      case _SortKey.realizedPnl:
        cmp = _entryRealizedPnl(
          a,
          secondaryRealized[a.asset.id] ?? 0,
        ).compareTo(_entryRealizedPnl(b, secondaryRealized[b.asset.id] ?? 0));
        break;
      case _SortKey.moic:
        cmp = moic(a.detail).compareTo(moic(b.detail));
        break;
      case _SortKey.tri:
        cmp = triAnnualizedPct(a.detail).compareTo(triAnnualizedPct(b.detail));
        break;
      case _SortKey.status:
        cmp = startupStatusLabel(a.detail.statut)
            .compareTo(startupStatusLabel(b.detail.statut));
        break;
    }
    if (cmp == 0) {
      return a.asset.name.toLowerCase().compareTo(b.asset.name.toLowerCase());
    }
    return cmp;
  }

  void _sortBy(_SortKey key, bool ascending) {
    setState(() {
      _sortKey = key;
      _ascending = ascending;
    });
  }

  void _open(StartupEntry entry) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => AssetDetailScreen(asset: entry.asset),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PortfolioController>();
    if (controller.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final everyStartup = controller.startupEntries;
    if (everyStartup.isEmpty) return const _NoStartupState();

    // Liste de l'onglet « Startup » : uniquement les startups catégorisées.
    // Celles sans catégorie (portefeuille Blast) vivent dans l'onglet « Blast »,
    // mais leurs données restent intégrées à la synthèse globale (ci-dessous).
    final all = everyStartup
        .where((e) => hasStartupCategory(e.detail.categorie))
        .toList();
    if (all.isEmpty) return const _NoCategorizedState();

    final years =
        all
            .map((e) => e.detail.dateInvestissement?.year)
            .whereType<int>()
            .where((y) => y > 0)
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a));

    final filtered = all.where(_matches).toList();
    // Synthèse : tout le portefeuille (startups catégorisées + lignes Blast
    // sans catégorie), indépendamment des filtres appliqués à la liste.
    final summary = summarizeStartups(everyStartup);
    final totalInvestedGlobal = _totalInvestedGlobal(controller);

    // PV réalisée des reventes secondaires, par actif : affichée à part de la
    // PV latente, qui ne porte que sur les actions restantes.
    final secondaryRealizedByAsset = <int, double>{
      for (final e in everyStartup)
        e.asset.id: realizedSecondaryPvNet(
          e.detail,
          controller.secondaryTransactionsOf(e.asset.id),
        ),
    };
    final secondaryRealizedTotal = secondaryRealizedByAsset.values.fold<double>(
      0,
      (sum, v) => sum + v,
    );

    // Le contenu de section est toujours en bas : il reste attaché au
    // sélecteur d'onglets (il suit le choix courant) sans être réordonnable.
    final sectionContent = filtered.isEmpty
        ? _NoResultState(onReset: _resetFilters)
        : switch (_section) {
            _Section.synthesis => _SynthesisTab(
              summary: summary,
              totalInvestedGlobal: totalInvestedGlobal,
              secondaryRealizedTotal: secondaryRealizedTotal,
              onOpen: _open,
            ),
            _Section.list => _ListTab(
              entries: _sorted(filtered, secondaryRealizedByAsset),
              secondaryRealized: secondaryRealizedByAsset,
              sortKey: _sortKey,
              ascending: _ascending,
              onSort: _sortBy,
              onOpen: _open,
            ),
            _Section.exits => _ExitsTab(
              entries: filtered
                  .where((e) => e.detail.statut == 'sorti')
                  .toList(),
              onOpen: _open,
            ),
          };

    final blockOrder = controller.startupBlockOrder;

    return SafeArea(
      child: ReorderableListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        buildDefaultDragHandles: false,
        onReorderItem: (oldIndex, newIndex) {
          final order = [...blockOrder];
          order.insert(newIndex, order.removeAt(oldIndex));
          controller.reorderStartupBlocks(order);
        },
        footer: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: sectionContent,
        ),
        children: [
          for (var i = 0; i < blockOrder.length; i++)
            _buildBlock(blockOrder[i], i, years),
        ],
      ),
    );
  }

  /// Un bloc réordonnable : le sélecteur d'onglets ou la carte des filtres.
  Widget _buildBlock(String id, int index, List<int> years) {
    switch (id) {
      case 'tabs':
        return Padding(
          key: const ValueKey<String>('tabs'),
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Expanded(
                child: SegmentedButton<_Section>(
                  segments: const [
                    ButtonSegment(
                      value: _Section.synthesis,
                      label: Text('Synthèse'),
                    ),
                    ButtonSegment(value: _Section.list, label: Text('Liste')),
                    ButtonSegment(
                      value: _Section.exits,
                      label: Text('Sorties'),
                    ),
                  ],
                  selected: {_section},
                  showSelectedIcon: false,
                  onSelectionChanged: (s) =>
                      setState(() => _section = s.first),
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 13)),
                    foregroundColor: WidgetStatePropertyAll(
                      AppColors.textSecondary,
                    ),
                    backgroundColor: WidgetStatePropertyAll(
                      AppColors.surface,
                    ),
                    side: WidgetStatePropertyAll(
                      BorderSide(color: AppColors.divider),
                    ),
                  ),
                ),
              ),
              _DragHandle(index: index),
            ],
          ),
        );
      case 'filters':
      default:
        return Padding(
          key: const ValueKey<String>('filters'),
          padding: const EdgeInsets.only(bottom: 12),
          child: _FiltersCard(
            years: years,
            categories: _categories,
            year: _year,
            status: _status,
            hasFilters: _hasFilters,
            searchController: _searchController,
            query: _query,
            dragHandle: _DragHandle(index: index),
            onSearchChanged: (q) => setState(() => _query = q),
            onClearSearch: _clearSearch,
            onReset: _resetFilters,
            onToggleCategory: (c) => setState(() {
              if (!_categories.add(c)) _categories.remove(c);
            }),
            onYearChanged: (y) => setState(() => _year = y),
            onStatusChanged: (s) => setState(() => _status = s),
          ),
        );
    }
  }
}

/// Poignée de glisser-déposer d'un bloc (le glissement ne démarre que par
/// cette poignée, pour ne pas gêner la saisie dans les filtres).
class _DragHandle extends StatelessWidget {
  final int index;

  const _DragHandle({required this.index});

  @override
  Widget build(BuildContext context) {
    return ReorderableDragStartListener(
      index: index,
      child: Semantics(
        label: 'Réordonner le bloc',
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Icon(
            Icons.drag_indicator,
            size: 20,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filtres
// ---------------------------------------------------------------------------

/// Barre de filtres condensée sur une seule ligne : recherche, catégories
/// (multi-sélection), année et statut, puis « Réinitialiser ». Sur un écran
/// étroit, seule la zone des sélecteurs défile horizontalement ; le bouton
/// de réinitialisation reste toujours visible dès qu'un filtre est actif.
class _FiltersCard extends StatelessWidget {
  final List<int> years;
  final Set<String> categories;
  final int year;
  final String status;
  final bool hasFilters;
  final TextEditingController searchController;
  final String query;
  final Widget? dragHandle;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final VoidCallback onReset;
  final ValueChanged<String> onToggleCategory;
  final ValueChanged<int> onYearChanged;
  final ValueChanged<String> onStatusChanged;

  const _FiltersCard({
    required this.years,
    required this.categories,
    required this.year,
    required this.status,
    required this.hasFilters,
    required this.searchController,
    required this.query,
    this.dragHandle,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onReset,
    required this.onToggleCategory,
    required this.onYearChanged,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _Card(
      Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const Icon(
                    Icons.tune,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Filtres',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 180,
                    child: _SearchField(
                      controller: searchController,
                      hasText: query.isNotEmpty,
                      onChanged: onSearchChanged,
                      onClear: onClearSearch,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _CategoriesMenu(
                    options: startupCategories,
                    selected: categories,
                    onToggle: onToggleCategory,
                  ),
                  const SizedBox(width: 8),
                  _YearSelector(
                    years: years,
                    year: year,
                    onChanged: onYearChanged,
                  ),
                  const SizedBox(width: 8),
                  _StatusMenu(status: status, onChanged: onStatusChanged),
                ],
              ),
            ),
          ),
          if (hasFilters) ...[
            const SizedBox(width: 4),
            TextButton(
              onPressed: onReset,
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                minimumSize: const Size(0, 32),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                textStyle: const TextStyle(fontSize: 12),
              ),
              child: const Text('Réinitialiser'),
            ),
          ],
          ?dragHandle,
        ],
      ),
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
    );
  }
}

/// Style commun des menus de filtres (fond sombre, bordure discrète).
MenuStyle _filterMenuStyle() => MenuStyle(
  backgroundColor: const WidgetStatePropertyAll(AppColors.surfaceAlt),
  surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
  elevation: const WidgetStatePropertyAll(8.0),
  maximumSize: const WidgetStatePropertyAll(Size(300, 420)),
  padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 4)),
  shape: WidgetStatePropertyAll(
    RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: AppColors.divider),
    ),
  ),
);

/// Style compact des entrées de menu (aligné sur le reste de l'écran).
ButtonStyle _filterMenuItemStyle() => const ButtonStyle(
  visualDensity: VisualDensity.compact,
  minimumSize: WidgetStatePropertyAll(Size(0, 36)),
  padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 12)),
  textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 12)),
  foregroundColor: WidgetStatePropertyAll(AppColors.textPrimary),
);

/// Bouton d'ouverture d'un menu de filtre : libellé court, chevron, et
/// surbrillance verte quand le filtre est actif.
class _FilterButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final String tooltip;
  final VoidCallback onTap;

  const _FilterButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primary : AppColors.textSecondary;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: active
            ? AppColors.primary.withValues(alpha: 0.16)
            : AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: active ? AppColors.primary : AppColors.divider,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 15, color: color),
                const SizedBox(width: 6),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 160),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: active ? AppColors.primary : AppColors.textPrimary,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.expand_more, size: 16, color: color),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Sélecteur de catégories : menu à cases à cocher. La multi-sélection est
/// conservée — le menu reste ouvert d'une case à l'autre.
class _CategoriesMenu extends StatelessWidget {
  final List<String> options;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  const _CategoriesMenu({
    required this.options,
    required this.selected,
    required this.onToggle,
  });

  String get _label {
    if (selected.isEmpty) return 'Catégories';
    if (selected.length == 1) return selected.first;
    return 'Catégories (${selected.length})';
  }

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      style: _filterMenuStyle(),
      alignmentOffset: const Offset(0, 6),
      menuChildren: [
        MenuItemButton(
          // Décoche toutes les catégories actives (équivalent du chip « Toutes »).
          onPressed: selected.isEmpty
              ? null
              : () {
                  for (final c in [...selected]) {
                    onToggle(c);
                  }
                },
          leadingIcon: const Icon(
            Icons.done_all,
            size: 16,
            color: AppColors.textSecondary,
          ),
          style: _filterMenuItemStyle(),
          child: const Text('Toutes les catégories'),
        ),
        const Divider(height: 1, color: AppColors.divider),
        for (final c in options)
          CheckboxMenuButton(
            value: selected.contains(c),
            // Multi-sélection : le menu ne doit pas se refermer à chaque case.
            closeOnActivate: false,
            style: _filterMenuItemStyle(),
            onChanged: (_) => onToggle(c),
            child: Text(c),
          ),
      ],
      builder: (context, controller, _) => _FilterButton(
        icon: Icons.category_outlined,
        label: _label,
        active: selected.isNotEmpty,
        tooltip: 'Filtrer par catégorie',
        onTap: () => controller.isOpen ? controller.close() : controller.open(),
      ),
    );
  }
}

/// Sélecteur d'année : menu déroulant compact (0 = toutes les années).
class _YearSelector extends StatelessWidget {
  final List<int> years;
  final int year;
  final ValueChanged<int> onChanged;

  const _YearSelector({
    required this.years,
    required this.year,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final active = year != 0;

    return Container(
      height: 38,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 10, right: 4),
      decoration: BoxDecoration(
        color: active
            ? AppColors.primary.withValues(alpha: 0.16)
            : AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: active ? AppColors.primary : AppColors.divider,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: year,
          isDense: true,
          dropdownColor: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
          icon: Icon(
            Icons.expand_more,
            size: 16,
            color: active ? AppColors.primary : AppColors.textSecondary,
          ),
          style: TextStyle(
            fontSize: 12,
            color: active ? AppColors.primary : AppColors.textPrimary,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          ),
          items: [
            const DropdownMenuItem<int>(
              value: 0,
              child: Text('Toutes les années'),
            ),
            for (final y in years)
              DropdownMenuItem<int>(value: y, child: Text('$y')),
          ],
          onChanged: (v) => onChanged(v ?? 0),
        ),
      ),
    );
  }
}

/// Sélecteur de statut : menu compact à valeur unique.
class _StatusMenu extends StatelessWidget {
  final String status;
  final ValueChanged<String> onChanged;

  const _StatusMenu({required this.status, required this.onChanged});

  static const List<(String, String)> _options = [
    ('all', 'Tous les statuts'),
    ('en_portefeuille', 'En portefeuille'),
    ('sorti', 'Sorties'),
    ('radie', 'Radiées'),
  ];

  @override
  Widget build(BuildContext context) {
    final current = _options.firstWhere(
      (o) => o.$1 == status,
      orElse: () => _options.first,
    );

    return MenuAnchor(
      style: _filterMenuStyle(),
      alignmentOffset: const Offset(0, 6),
      menuChildren: [
        for (final o in _options)
          MenuItemButton(
            onPressed: () => onChanged(o.$1),
            leadingIcon: Icon(
              o.$1 == status ? Icons.check : null,
              size: 16,
              color: AppColors.primary,
            ),
            style: _filterMenuItemStyle(),
            child: Text(o.$2),
          ),
      ],
      builder: (context, controller, _) => _FilterButton(
        icon: Icons.filter_alt_outlined,
        label: current.$2,
        active: status != 'all',
        tooltip: 'Filtrer par statut',
        onTap: () => controller.isOpen ? controller.close() : controller.open(),
      ),
    );
  }
}

/// Recherche compacte (largeur fixée par la barre de filtres).
class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final bool hasText;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchField({
    required this.controller,
    required this.hasText,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        isDense: true,
        hintText: 'Rechercher…',
        hintStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
        ),
        prefixIcon: const Icon(
          Icons.search,
          size: 16,
          color: AppColors.textSecondary,
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 30,
          minHeight: 30,
        ),
        suffixIcon: hasText
            ? IconButton(
                onPressed: onClear,
                tooltip: 'Effacer la recherche',
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.close,
                  size: 15,
                  color: AppColors.textSecondary,
                ),
              )
            : null,
        suffixIconConstraints: const BoxConstraints(
          minWidth: 28,
          minHeight: 28,
        ),
        filled: true,
        fillColor: AppColors.surfaceAlt,
        contentPadding: const EdgeInsets.symmetric(vertical: 9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Synthèse
// ---------------------------------------------------------------------------

class _SynthesisTab extends StatelessWidget {
  final StartupPortfolioSummary summary;
  final double totalInvestedGlobal;

  /// PV réalisée nette des reventes du marché secondaire (hors sorties).
  final double secondaryRealizedTotal;
  final ValueChanged<StartupEntry> onOpen;

  const _SynthesisTab({
    required this.summary,
    required this.totalInvestedGlobal,
    required this.secondaryRealizedTotal,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final kpis = <Widget>[
      _KpiCard(
        label: 'Capital investi',
        value: formatEuro(totalInvestedGlobal),
        hint: 'Capital investi total du portefeuille : startups de toutes '
            'catégories, y compris Blast.',
      ),
      _KpiCard(
        label: 'Frais total',
        value: formatEuro(summary.totalFrais),
        sub: summary.totalInvested > 0
            ? '${formatShare(summary.totalFrais / summary.totalInvested * 100)} '
                  'du capital'
            : null,
        hint:
            'Somme des frais d\'entrée (dossier, commissions) de toutes les '
            'startups du portefeuille (y compris Blast), tous statuts confondus.',
      ),
      _KpiCard(
        label: 'Valorisation totale',
        value: formatEuro(summary.totalValue),
        hint:
            'Valeur des lignes : prix actuel manuel, produit de sortie, '
            'ou 0 pour une startup radiée.',
      ),
      _KpiCard(
        label: 'Plus-value latente',
        value: formatSignedEuro(summary.unrealizedGain),
        sub: '${formatPct(summary.unrealizedGainPct)} du capital investi',
        color: _signedColor(summary.unrealizedGain),
        hint:
            'PV latente des actions restantes : quantité détenue × '
            '(prix actuel − PRU). Hors PV déjà réalisée par des reventes. '
            'Le pourcentage rapporte cette plus-value au capital total.',
      ),
      if (secondaryRealizedTotal != 0)
        _KpiCard(
          label: 'PV secondaire réalisée',
          value: formatSignedEuro(secondaryRealizedTotal),
          sub: 'Reventes nettes de flat tax',
          color: _signedColor(secondaryRealizedTotal),
          hint:
              'Plus-value réalisée des reventes sur le marché secondaire : '
              'PV brute − commissions − frais − flat tax de 30 %. '
              'Distincte de la PV latente, qui ne porte que sur les actions '
              'restantes.',
        ),
      _KpiCard(
        label: 'Multiple MOIC',
        value: _moicLabel(summary.moic),
        sub: 'Valorisation ÷ capital',
        hint:
            'Valorisation totale ÷ capital investi total. '
            '1× = capital remboursé, 2× = capital doublé.',
      ),
      _KpiCard(
        label: 'TRI moyen',
        value: formatPct(summary.avgTriPct),
        color: _signedColor(summary.avgTriPct),
        hint:
            'Moyenne arithmétique des TRI annualisés des lignes datées et '
            'dotées d\'un capital investi > 0.',
      ),
      if (summary.realizedGain != 0 || summary.exitedCount > 0)
        _KpiCard(
          label: 'Plus-value réalisée',
          value: formatSignedEuro(summary.realizedGain),
          sub: '${summary.exitedCount} sortie(s)',
          color: _signedColor(summary.realizedGain),
          hint: 'Produit de sortie − capital investi, pour les lignes sorties.',
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _KpiGrid(cards: kpis),
        const SizedBox(height: 12),
        _CountersCard(summary: summary),
        const SizedBox(height: 16),
        // Répartition par catégorie et valorisation par année : côte à côte
        // (deux colonnes égales) sur écran large, empilées sur écran étroit.
        LayoutBuilder(
          builder: (context, constraints) {
            const gap = 16.0;
            final sideBySide = constraints.maxWidth >= 620;
            final columnWidth = sideBySide
                ? (constraints.maxWidth - gap) / 2
                : constraints.maxWidth;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                SizedBox(
                  width: columnWidth,
                  child: _CategoryDonut(values: summary.valueByCategory),
                ),
                SizedBox(
                  width: columnWidth,
                  child: _YearBars(
                    values: summary.valueByYear,
                    summary: summary,
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        _CategoryTable(summary: summary),
        const SizedBox(height: 16),
        _TopStartups(entries: summary.entries, onOpen: onOpen),
        const SizedBox(height: 4),
        Text(
          'KPIs calculés sur ${summary.totalCount} startup'
          '${summary.totalCount > 1 ? 's' : ''} au total (startups + Blast).',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _KpiGrid extends StatelessWidget {
  final List<Widget> cards;

  const _KpiGrid({required this.cards});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 620 ? 3 : 2;
        final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final card in cards) SizedBox(width: width, child: card),
          ],
        );
      },
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final String? sub;
  final String hint;
  final Color? color;

  const _KpiCard({
    required this.label,
    required this.value,
    required this.hint,
    this.sub,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 108,
      padding: const EdgeInsets.all(12),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ),
              InfoHint(hint, size: 12),
            ],
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: color ?? AppColors.textPrimary,
              ),
            ),
          ),
          if (sub != null)
            Text(
              sub!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
            ),
        ],
      ),
    );
  }
}

class _CountersCard extends StatelessWidget {
  final StartupPortfolioSummary summary;

  const _CountersCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _Card(
      Row(
        children: [
          const Icon(
            Icons.rocket_launch_outlined,
            size: 18,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${summary.activeCount} active'
              '${summary.activeCount > 1 ? 's' : ''} · '
              '${summary.exitedCount} sortie'
              '${summary.exitedCount > 1 ? 's' : ''} · '
              '${summary.writtenOffCount} radiée'
              '${summary.writtenOffCount > 1 ? 's' : ''}',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          const InfoHint(
            'Répartition des lignes filtrées par statut.',
            size: 13,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}

class _CategoryDonut extends StatelessWidget {
  final Map<String, double> values;

  const _CategoryDonut({required this.values});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final segments = values.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = segments.fold<double>(0, (s, e) => s + e.value);

    return _Card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(
            'Répartition par catégorie',
            hint:
                'Valorisation de la catégorie ÷ valorisation totale '
                'des startups filtrées.',
          ),
          const SizedBox(height: 16),
          if (segments.isEmpty)
            Text(
              'Valorisation nulle : aucune répartition à afficher.',
              style: theme.textTheme.bodySmall,
            )
          else ...[
            Center(
              child: SizedBox(
                width: 132,
                height: 132,
                child: CustomPaint(
                  painter: _DonutPainter(segments: segments, total: total),
                ),
              ),
            ),
            const SizedBox(height: 16),
            for (final e in segments)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _categoryColor(e.key),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        e.key,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formatEuro(e.value),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 52,
                      child: Text(
                        formatShare(e.value / total * 100),
                        textAlign: TextAlign.right,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<MapEntry<String, double>> segments;
  final double total;

  const _DonutPainter({required this.segments, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 8;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22;
    var start = -1.5707963267948966; // −π/2
    for (final seg in segments) {
      final sweep = seg.value / total * 6.283185307179586;
      paint.color = _categoryColor(seg.key);
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

class _YearBars extends StatelessWidget {
  final Map<int, double> values;
  final StartupPortfolioSummary summary;

  const _YearBars({required this.values, required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final years = values.keys.toList()..sort((a, b) => b.compareTo(a));
    final maxValue = years.isEmpty
        ? 0.0
        : years.map((y) => values[y]!).reduce((a, b) => a > b ? a : b);
    final undated = summary.entries
        .where((e) => e.detail.dateInvestissement == null)
        .length;

    return _Card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(
            'Valorisation par année d\'investissement',
            hint:
                'Somme des valorisations des startups dont la date '
                'd\'investissement tombe cette année-là.',
          ),
          const SizedBox(height: 14),
          if (years.isEmpty)
            Text(
              'Aucune date d\'investissement renseignée.',
              style: theme.textTheme.bodySmall,
            )
          else
            for (final y in years)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text('$y', style: theme.textTheme.bodyMedium),
                        ),
                        Text(
                          formatEuro(values[y]!),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: maxValue == 0 ? 0 : values[y]! / maxValue,
                        minHeight: 8,
                        backgroundColor: AppColors.surfaceAlt,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
          if (undated > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '$undated ligne${undated > 1 ? 's' : ''} sans date '
                'd\'investissement non représentée${undated > 1 ? 's' : ''}.',
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoryTable extends StatelessWidget {
  final StartupPortfolioSummary summary;

  const _CategoryTable({required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rows = summary.kpiByCategory.entries.toList()
      ..sort((a, b) => b.value.invested.compareTo(a.value.invested));
    if (rows.isEmpty) return const SizedBox.shrink();

    return _Card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(
            'Par catégorie',
            hint:
                'Agrégats calculés sur les startups filtrées. '
                'Le MOIC et le TRI sont des moyennes de la catégorie.',
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              horizontalMargin: 0,
              columnSpacing: 18,
              headingRowHeight: 38,
              dataRowMinHeight: 40,
              dataRowMaxHeight: 44,
              columns: const [
                DataColumn(label: Text('Catégorie')),
                DataColumn(label: Text('Investi'), numeric: true),
                DataColumn(label: Text('Frais'), numeric: true),
                DataColumn(label: Text('Valeur'), numeric: true),
                DataColumn(label: Text('PV latente'), numeric: true),
                DataColumn(label: Text('MOIC'), numeric: true),
                DataColumn(label: Text('TRI'), numeric: true),
                DataColumn(label: Text('N'), numeric: true),
              ],
              rows: [
                for (final e in rows)
                  DataRow(
                    cells: [
                      DataCell(
                        Text(
                          e.key,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      DataCell(Text(formatEuro(e.value.invested))),
                      DataCell(Text(formatEuro(e.value.frais))),
                      DataCell(Text(formatEuro(e.value.value))),
                      DataCell(
                        Text(
                          formatSignedEuro(e.value.unrealized),
                          style: TextStyle(
                            color: _signedColor(e.value.unrealized),
                          ),
                        ),
                      ),
                      DataCell(Text(_moicLabel(e.value.moic))),
                      DataCell(
                        Text(
                          formatPct(e.value.triPct),
                          style: TextStyle(color: _signedColor(e.value.triPct)),
                        ),
                      ),
                      DataCell(Text('${e.value.count}')),
                    ],
                  ),
                DataRow(
                  cells: [
                    DataCell(
                      Text(
                        'Total',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        formatEuro(summary.totalInvested),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    DataCell(
                      Text(
                        formatEuro(summary.totalFrais),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    DataCell(
                      Text(
                        formatEuro(summary.totalValue),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    DataCell(
                      Text(
                        formatSignedEuro(summary.unrealizedGain),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: _signedColor(summary.unrealizedGain),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        _moicLabel(summary.moic),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    DataCell(
                      Text(
                        formatPct(summary.avgTriPct),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: _signedColor(summary.avgTriPct),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '${summary.totalCount}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopStartups extends StatelessWidget {
  final List<StartupEntry> entries;
  final ValueChanged<StartupEntry> onOpen;

  const _TopStartups({required this.entries, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final top = entries.where((e) => lineValue(e.detail) > 0).toList()
      ..sort((a, b) => lineValue(b.detail).compareTo(lineValue(a.detail)));
    final visible = top.take(5).toList();

    return _Card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(
            'Top 5 par valorisation',
            hint:
                'Cinq lignes les plus valorisées de la sélection, '
                'avec leur multiple sur capital investi.',
          ),
          const SizedBox(height: 8),
          if (visible.isEmpty)
            Text(
              'Aucune valorisation positive sur la sélection.',
              style: theme.textTheme.bodySmall,
            )
          else
            for (var i = 0; i < visible.length; i++) ...[
              if (i > 0) const Divider(height: 1),
              InkWell(
                onTap: () => onOpen(visible[i]),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              visible[i].asset.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              startupCategoryKey(visible[i].detail.categorie),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            formatEuro(lineValue(visible[i].detail)),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'MOIC ${_moicLabel(moic(visible[i].detail))}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Liste
// ---------------------------------------------------------------------------

class _ListTab extends StatelessWidget {
  final List<StartupEntry> entries;

  /// PV réalisée nette des reventes secondaires, indexée par actif.
  final Map<int, double> secondaryRealized;
  final _SortKey sortKey;
  final bool ascending;
  final void Function(_SortKey key, bool ascending) onSort;
  final ValueChanged<StartupEntry> onOpen;

  const _ListTab({
    required this.entries,
    required this.secondaryRealized,
    required this.sortKey,
    required this.ascending,
    required this.onSort,
    required this.onOpen,
  });

  static const List<_SortKey> _columns = [
    _SortKey.name,
    _SortKey.category,
    _SortKey.year,
    _SortKey.invested,
    _SortKey.value,
    _SortKey.pnl,
    _SortKey.realizedPnl,
    _SortKey.moic,
    _SortKey.tri,
    _SortKey.status,
  ];

  static const List<String> _labels = [
    'Nom',
    'Catégorie',
    'Année',
    'Capital investi',
    'Valorisation',
    'PV latente',
    'PV réalisée',
    'MOIC',
    'TRI',
    'Statut',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final index = _columns.indexOf(sortKey);

    return _Card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            'Startups (${entries.length})',
            hint:
                'Touchez un en-tête pour trier. Touchez une ligne '
                'pour ouvrir la fiche complète.',
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              horizontalMargin: 0,
              columnSpacing: 18,
              headingRowHeight: 42,
              dataRowMinHeight: 44,
              dataRowMaxHeight: 48,
              sortColumnIndex: index,
              sortAscending: ascending,
              showCheckboxColumn: false,
              columns: [
                for (var i = 0; i < _columns.length; i++)
                  DataColumn(
                    label: Text(
                      _labels[i],
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    numeric: i >= 3 && i <= 8,
                    onSort: (_, asc) => onSort(_columns[i], asc),
                  ),
              ],
              rows: [
                for (final e in entries)
                  DataRow(
                    onSelectChanged: (_) => onOpen(e),
                    cells: [
                      DataCell(
                        Text(
                          e.asset.name,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      DataCell(Text(startupCategoryKey(e.detail.categorie))),
                      DataCell(
                        Text(
                          e.detail.dateInvestissement?.year.toString() ?? '—',
                        ),
                      ),
                      DataCell(Text(formatEuro(_entryInvested(e)))),
                      DataCell(Text(formatEuro(lineValue(e.detail)))),
                      DataCell(
                        Text(
                          formatSignedEuro(_entryUnrealizedPnl(e)),
                          style: TextStyle(
                            color: _signedColor(_entryUnrealizedPnl(e)),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          formatSignedEuro(
                            _entryRealizedPnl(
                              e,
                              secondaryRealized[e.asset.id] ?? 0,
                            ),
                          ),
                          style: TextStyle(
                            color: _signedColor(
                              _entryRealizedPnl(
                                e,
                                secondaryRealized[e.asset.id] ?? 0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      DataCell(Text(_moicLabel(moic(e.detail)))),
                      DataCell(
                        Text(
                          formatPct(triAnnualizedPct(e.detail)),
                          style: TextStyle(
                            color: _signedColor(triAnnualizedPct(e.detail)),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          startupStatusLabel(e.detail.statut),
                          style: TextStyle(
                            color: _statusColor(e.detail.statut),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Color _statusColor(String statut) {
  switch (statut) {
    case 'sorti':
      return const Color(0xFF3B82F6);
    case 'radie':
      return AppColors.negative;
    default:
      return AppColors.primary;
  }
}

// ---------------------------------------------------------------------------
// Sorties
// ---------------------------------------------------------------------------

class _ExitsTab extends StatelessWidget {
  final List<StartupEntry> entries;
  final ValueChanged<StartupEntry> onOpen;

  const _ExitsTab({required this.entries, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sorted = [...entries]
      ..sort((a, b) {
        final da = a.detail.exitDate;
        final db = b.detail.exitDate;
        if (da == null && db == null) {
          return a.asset.name.compareTo(b.asset.name);
        }
        if (da == null) return 1;
        if (db == null) return -1;
        return db.compareTo(da);
      });
    final realizedTotal = sorted.fold<double>(
      0,
      (s, e) => s + realizedGain(e.detail),
    );

    return _Card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            'Sorties (${sorted.length})',
            hint: 'Plus-value réalisée = produit de sortie − capital investi.',
          ),
          if (sorted.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'PV réalisée cumulée : ${formatSignedEuro(realizedTotal)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: _signedColor(realizedTotal),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            for (var i = 0; i < sorted.length; i++) ...[
              if (i > 0) const Divider(height: 1),
              InkWell(
                onTap: () => onOpen(sorted[i]),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sorted[i].asset.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${startupCategoryKey(sorted[i].detail.categorie)}'
                              ' · ${startupExitModeLabel(sorted[i].detail.exitMode)}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 11,
                              ),
                            ),
                            if (sorted[i].detail.exitDate != null)
                              Text(
                                'Sortie le '
                                '${formatDate(sorted[i].detail.exitDate!)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 11,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            formatSignedEuro(realizedGain(sorted[i].detail)),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: _signedColor(
                                realizedGain(sorted[i].detail),
                              ),
                            ),
                          ),
                          Text(
                            'MOIC ${_moicLabel(moic(sorted[i].detail))} · '
                            'TRI ${formatPct(triAnnualizedPct(sorted[i].detail))}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ] else
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Aucune sortie dans la sélection.',
                style: theme.textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// États vides
// ---------------------------------------------------------------------------

class _NoStartupState extends StatelessWidget {
  const _NoStartupState();

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
                Icons.rocket_launch_outlined,
                size: 44,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                'Ajoutez une startup pour voir ce dashboard',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Créez un actif de type Startups avec le bouton +, '
                'puis renseignez sa fiche pour suivre capital, valorisation, '
                'MOIC et TRI.',
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

class _NoCategorizedState extends StatelessWidget {
  const _NoCategorizedState();

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
                Icons.category_outlined,
                size: 44,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                'Aucune startup catégorisée',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Les startups sans catégorie sont regroupées dans l\'onglet '
                'Blast. Renseignez une catégorie dans leur fiche pour les '
                'faire apparaître ici.',
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

class _NoResultState extends StatelessWidget {
  final VoidCallback onReset;

  const _NoResultState({required this.onReset});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _Card(
      Column(
        children: [
          const Icon(
            Icons.filter_alt_off_outlined,
            size: 32,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            'Aucune startup ne correspond aux filtres ou à la recherche.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          TextButton(
            onPressed: onReset,
            child: const Text('Réinitialiser les filtres'),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
    );
  }
}

// ---------------------------------------------------------------------------
// Briques communes
// ---------------------------------------------------------------------------

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _Card(this.child, {this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: cardDecoration(),
      child: child,
    );
  }
}

class _CardHeader extends StatelessWidget {
  final String title;
  final String? hint;

  const _CardHeader(this.title, {this.hint});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        if (hint != null) InfoHint(hint!, size: 13),
      ],
    );
  }
}
