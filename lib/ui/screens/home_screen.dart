import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/portfolio_controller.dart';
import 'add_asset_screen.dart';
import 'analytics_screen.dart';
import 'assets_screen.dart';
import 'dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  bool _refreshing = false;

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
      ),
      body: IndexedStack(
        index: _index,
        children: const [
          DashboardScreen(),
          AssetsScreen(),
          AnalyticsScreen(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddAssetScreen()),
        ),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Tableau de bord',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Actifs',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline),
            selectedIcon: Icon(Icons.pie_chart),
            label: 'Analyses',
          ),
        ],
      ),
    );
  }
}
