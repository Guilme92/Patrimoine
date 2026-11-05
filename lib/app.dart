import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/portfolio_controller.dart';
import 'data/database.dart';
import 'theme/app_theme.dart';
import 'ui/screens/home_screen.dart';

class PatrimoineApp extends StatelessWidget {
  final AppDatabase db;
  const PatrimoineApp({super.key, required this.db});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PortfolioController(db)..load(),
      child: MaterialApp(
        title: 'Patrimoine',
        debugShowCheckedModeBanner: false,
        theme: buildDarkTheme(),
        home: const HomeScreen(),
      ),
    );
  }
}
