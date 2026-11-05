import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/portfolio_controller.dart';
import '../../data/database.dart';
import '../../models/asset_type.dart';
import '../../theme/palette.dart';
import '../widgets/asset_tile.dart';

/// Liste des actifs : filtre par catégorie et deux modes d'affichage
/// (« Par type » ou « Ordre manuel » avec drag & drop).
class AssetsScreen extends StatefulWidget {
  const AssetsScreen({super.key});

  @override
  State<AssetsScreen> createState() => _AssetsScreenState();
}

class _AssetsScreenState extends State<AssetsScreen> {
  bool _manualOrder = false;
  final Set<AssetType> _selectedTypes = <AssetType>{};

  bool _matches(Asset a) =>
      _selectedTypes.isEmpty ||
      _selectedTypes.contains(assetTypeFrom(a.type));

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

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SegmentedButton<bool>(
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
            ),
          ),
          Expanded(
            child: all.isEmpty
                ? const Center(child: Text('Aucun actif'))
                : visible.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Aucun actif dans ces catégories.',
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
