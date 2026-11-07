import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';

import '../../controllers/portfolio_controller.dart';
import '../../data/csv_import.dart';
import '../../data/csv_templates.dart';
import '../../data/database.dart';
import '../../models/asset_type.dart';
import '../../theme/app_theme.dart';
import '../../theme/palette.dart';
import '../widgets/asset_tile.dart';

/// Liste des actifs : filtre par catégorie et deux modes d'affichage
/// (« Par type » ou « Ordre manuel » avec drag & drop).
///
/// [types] restreint l'écran à un sous-ensemble de catégories (onglets
/// « Immobilier », « Bourse et Crypto », « Autres ») : les actifs des autres
/// types sont masqués et les FilterChip de type disparaissent.
class AssetsScreen extends StatefulWidget {
  final Set<AssetType>? types;

  const AssetsScreen({super.key, this.types});

  @override
  State<AssetsScreen> createState() => _AssetsScreenState();
}

class _AssetsScreenState extends State<AssetsScreen> {
  bool _manualOrder = false;
  final Set<AssetType> _selectedTypes = <AssetType>{};

  /// Écran restreint à un ou plusieurs types (pas de filtre manuel).
  bool get _restricted => widget.types != null;

  bool _matches(Asset a) {
    final type = assetTypeFrom(a.type);
    if (widget.types != null && !widget.types!.contains(type)) return false;
    return _selectedTypes.isEmpty || _selectedTypes.contains(type);
  }

  /// Types supprimables depuis cet onglet : ceux du périmètre qui ont au
  /// moins un actif.
  List<(AssetType, int)> _deletableTypes(PortfolioController controller) {
    final counts = <AssetType, int>{};
    for (final a in controller.assets) {
      final type = assetTypeFrom(a.type);
      if (widget.types != null && !widget.types!.contains(type)) continue;
      counts[type] = (counts[type] ?? 0) + 1;
    }
    return [
      for (final t in AssetType.values)
        if ((counts[t] ?? 0) > 0) (t, counts[t]!),
    ];
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// Choisit un CSV, détecte son type (immobilier ou startups) et l'importe.
  Future<void> _importCsv() async {
    final controller = context.read<PortfolioController>();
    PlatformFile? picked;
    try {
      picked = await FilePicker.pickFile(
        dialogTitle: 'Choisir un fichier CSV',
        type: FileType.custom,
        allowedExtensions: const ['csv'],
      );
    } catch (e) {
      _snack('Sélection impossible : $e');
      return;
    }
    if (picked == null) return;

    final String content;
    try {
      final bytes = await picked.readAsBytes();
      content = utf8.decode(bytes, allowMalformed: true);
    } catch (e) {
      _snack('Lecture impossible : $e');
      return;
    }
    if (!mounted) return;

    final type = detectCsvAssetType(content);
    if (type == null) {
      _snack(
        'Colonnes non reconnues : utilisez un modèle CSV de l\'application.',
      );
      return;
    }

    final CsvImportResult result;
    try {
      result = await controller.importCsv(csv: content, type: type);
    } catch (e) {
      _snack('Import impossible : $e');
      return;
    }

    final parts = <String>[
      result.imported == 1 ? '1 actif importé' : '${result.imported} actifs importés',
    ];
    if (result.updated > 0) {
      parts.add(result.updated == 1 ? '1 mis à jour' : '${result.updated} mis à jour');
    }
    if (result.skipped > 0) {
      parts.add(result.skipped == 1 ? '1 ligne ignorée' : '${result.skipped} lignes ignorées');
    }
    _snack(parts.join(' · '));
  }

  /// Écrit les deux modèles CSV dans le dossier documents de l'application.
  Future<void> _saveTemplates() async {
    final List<String> paths;
    try {
      paths = await writeCsvTemplates();
    } catch (e) {
      _snack('Écriture impossible : $e');
      return;
    }
    _snack(
      'Modèles enregistrés dans ${p.dirname(paths.first)} '
      '($realEstateTemplateName, $startupTemplateName)',
    );
  }

  /// Demande confirmation puis supprime tous les actifs du type donné.
  Future<void> _confirmDeleteType(
    PortfolioController controller,
    AssetType type,
    int count,
  ) async {
    final label = assetTypeLabel(type);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Supprimer « $label » ?'),
        content: Text(
          '$count actif${count > 1 ? 's' : ''} de cette catégorie '
          '${count > 1 ? 'seront supprimés' : 'sera supprimé'} avec leurs '
          'positions, leur fiche, leurs levées, leurs transactions '
          'secondaires et leurs documents. Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final deleted = await controller.deleteAssetsOfType(type);
    _snack(
      deleted == 1
          ? '1 actif supprimé ($label)'
          : '$deleted actifs supprimés ($label)',
    );
  }

  Future<void> _reorder(
    PortfolioController controller,
    List<Asset> visible,
    int oldIndex,
    int newIndex,
  ) async {
    final ids = visible.map((a) => a.id).toList();
    final moved = ids.removeAt(oldIndex);
    ids.insert(newIndex.clamp(0, ids.length), moved);
    await controller.reorderAssets(_mergeOrder(controller.assets, visible, ids));
  }

  /// Replace les identifiants visibles réordonnés dans la liste complète,
  /// en conservant la position relative des actifs masqués par le filtre.
  static List<int> _mergeOrder(
    List<Asset> all,
    List<Asset> visible,
    List<int> reorderedVisibleIds,
  ) {
    final visibleIds = visible.map((a) => a.id).toSet();
    final iterator = reorderedVisibleIds.iterator;
    final result = <int>[];
    for (final a in all) {
      if (visibleIds.contains(a.id)) {
        iterator.moveNext();
        result.add(iterator.current);
      } else {
        result.add(a.id);
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PortfolioController>();
    if (controller.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final all = controller.assets;
    final visible = all.where(_matches).toList();
    final deletable = _deletableTypes(controller);

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment(
                            value: false,
                            label: Text('Par type'),
                            icon: Icon(Icons.category_outlined, size: 18),
                          ),
                          ButtonSegment(
                            value: true,
                            label: Text('Ordre manuel'),
                            icon: Icon(Icons.drag_indicator, size: 18),
                          ),
                        ],
                        selected: {_manualOrder},
                        showSelectedIcon: false,
                        onSelectionChanged: (selection) =>
                            setState(() => _manualOrder = selection.first),
                      ),
                    ),
                    PopupMenuButton<String>(
                      tooltip: 'Import et modèles CSV',
                      icon: const Icon(Icons.more_vert),
                      onSelected: (value) {
                        if (value == 'import') {
                          _importCsv();
                        } else {
                          _saveTemplates();
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: 'import',
                          child: ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.upload_file_outlined),
                            title: Text('Importer CSV'),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'templates',
                          child: ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.description_outlined),
                            title: Text('Modèle CSV'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (deletable.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Supprimer une catégorie',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      PopupMenuButton<(AssetType, int)>(
                        tooltip: 'Supprimer une catégorie',
                        icon: const Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                        onSelected: (entry) =>
                            _confirmDeleteType(controller, entry.$1, entry.$2),
                        itemBuilder: (_) => [
                          for (final entry in deletable)
                            PopupMenuItem<(AssetType, int)>(
                              value: entry,
                              child: ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(
                                  assetTypeIcon(entry.$1),
                                  size: 18,
                                  color: assetTypeColors[entry.$1],
                                ),
                                title: Text(
                                  'Supprimer ${assetTypeLabel(entry.$1)}',
                                ),
                                subtitle: Text(
                                  '${entry.$2} actif${entry.$2 > 1 ? 's' : ''}',
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
                if (!_restricted) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 44,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: const Text('Tous'),
                            selected: _selectedTypes.isEmpty,
                            onSelected: (_) =>
                                setState(() => _selectedTypes.clear()),
                          ),
                        ),
                        for (final t in AssetType.values)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              avatar: Icon(
                                assetTypeIcon(t),
                                size: 16,
                                color: assetTypeColors[t],
                              ),
                              label: Text(assetTypeLabel(t)),
                              selected: _selectedTypes.contains(t),
                              onSelected: (selected) => setState(() {
                                if (selected) {
                                  _selectedTypes.add(t);
                                } else {
                                  _selectedTypes.remove(t);
                                }
                              }),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: visible.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        _restricted
                            ? 'Aucun actif dans cet onglet'
                            : all.isEmpty
                            ? 'Aucun actif'
                            : 'Aucun actif dans ces catégories.',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : _manualOrder
                ? _buildManualList(controller, visible)
                : _buildGroupedList(controller, visible),
          ),
        ],
      ),
    );
  }

  Widget _buildManualList(PortfolioController controller, List<Asset> visible) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      buildDefaultDragHandles: true,
      itemCount: visible.length,
      onReorderItem: (oldIndex, newIndex) =>
          _reorder(controller, visible, oldIndex, newIndex),
      itemBuilder: (context, index) {
        final a = visible[index];
        return AssetTile(
          key: ValueKey<int>(a.id),
          asset: a,
          positions: controller.positionsOf(a.id),
          prices: controller.prices,
          startup: controller.startupOf(a.id),
        );
      },
    );
  }

  Widget _buildGroupedList(
    PortfolioController controller,
    List<Asset> visible,
  ) {
    final grouped = <AssetType, List<Asset>>{};
    for (final a in visible) {
      grouped.putIfAbsent(assetTypeFrom(a.type), () => []).add(a);
    }
    final types = AssetType.values.where(grouped.containsKey);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: [
        for (final type in types) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Icon(
                  assetTypeIcon(type),
                  size: 18,
                  color: assetTypeColors[type],
                ),
                const SizedBox(width: 8),
                Text(
                  assetTypeLabel(type),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(width: 8),
                Text(
                  '${grouped[type]!.length}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          ...grouped[type]!.map(
            (a) => AssetTile(
              asset: a,
              positions: controller.positionsOf(a.id),
              prices: controller.prices,
              startup: controller.startupOf(a.id),
            ),
          ),
        ],
      ],
    );
  }
}
