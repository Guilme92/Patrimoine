import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/portfolio_controller.dart';
import '../../models/asset_type.dart';
import '../../theme/app_theme.dart';
import 'add_asset_screen.dart';
import 'analytics_screen.dart';
import 'assets_screen.dart';
import 'blast_market_screen.dart';
import 'blast_screen.dart';
import 'dashboard_screen.dart';
import 'startups_screen.dart';

/// Structure d'un onglet principal : libellé + écran conservé dans
/// l'IndexedStack (l'état de chaque onglet survit au changement d'onglet).
class _Tab {
  final String label;
  final IconData icon;
  final Widget screen;

  const _Tab(this.label, this.icon, this.screen);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  bool _refreshing = false;

  /// Les 8 onglets principaux, dans l'ordre d'affichage. Les onglets par type
  /// d'actif réutilisent [AssetsScreen] avec un filtre de types.
  static const List<_Tab> _tabs = [
    _Tab('Tableau de bord', Icons.dashboard_outlined, DashboardScreen()),
    _Tab(
      'Immobilier',
      Icons.home_outlined,
      AssetsScreen(types: {AssetType.realEstate}),
    ),
    _Tab(
      'Bourse et Crypto',
      Icons.show_chart,
      AssetsScreen(types: {AssetType.investment, AssetType.crypto}),
    ),
    _Tab('Startup', Icons.rocket_launch_outlined, StartupsScreen()),
    _Tab('Blast', Icons.bolt, BlastScreen()),
    _Tab('Blast Market', Icons.swap_horiz, BlastMarketScreen()),
    _Tab('Analyse', Icons.pie_chart_outline, AnalyticsScreen()),
    _Tab(
      'Autres',
      Icons.category_outlined,
      AssetsScreen(
        types: {
          AssetType.cash,
          AssetType.preciousMetals,
          AssetType.collectible,
          AssetType.other,
          AssetType.loan,
        },
      ),
    ),
  ];

  Future<void> _refreshPrices() async {
    final controller = context.read<PortfolioController>();
    setState(() => _refreshing = true);
    final result = await controller.refreshPrices();
    if (!mounted) return;
    setState(() => _refreshing = false);
    final msg = result.failed == 0
        ? '${result.updated} prix actualisés'
        : '${result.updated} prix actualisés · ${result.failed} introuvables';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patrimoine'),
        actions: [
          IconButton(
            onPressed: _refreshing ? null : _refreshPrices,
            tooltip: 'Actualiser les prix',
            icon: _refreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: _TopTabs(
            tabs: _tabs,
            index: _index,
            onSelected: (i) => setState(() => _index = i),
          ),
        ),
      ),
      body: IndexedStack(
        index: _index,
        children: [for (final tab in _tabs) tab.screen],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddAssetScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Barre d'onglets horizontale, défilable, placée sous l'AppBar.
class _TopTabs extends StatelessWidget {
  final List<_Tab> tabs;
  final int index;
  final ValueChanged<int> onSelected;

  const _TopTabs({
    required this.tabs,
    required this.index,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
        child: Row(
          children: [
            for (var i = 0; i < tabs.length; i++)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _TabPill(
                  label: tabs[i].label,
                  icon: tabs[i].icon,
                  selected: i == index,
                  onTap: () => onSelected(i),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _TabPill({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textSecondary;
    return Material(
      color: selected
          ? AppColors.primary.withValues(alpha: 0.16)
          : AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.divider,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: color,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
