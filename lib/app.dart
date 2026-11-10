import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
      create: (_) {
        final controller = PortfolioController(db);
        controller.load().then(
          (_) => controller.refreshPrices(missingOnly: true),
        );
        return controller;
      },
      child: Builder(
        builder: (context) {
          // Échelle de police réglée dans l'interface, appliquée à tout le
          // texte de l'app. On l'injecte via `MaterialApp.builder` (sous le
          // MediaQuery de l'app) : posé au-dessus, le MediaQuery serait
          // remplacé par celui que MaterialApp construit depuis la vue.
          final scale = context.watch<PortfolioController>().fontScale;
          return MaterialApp(
            title: 'Patrimoine',
            debugShowCheckedModeBanner: false,
            theme: buildDarkTheme(),
            locale: const Locale('fr'),
            supportedLocales: const [Locale('fr'), Locale('en')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(scale)),
              child: child ?? const SizedBox.shrink(),
            ),
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
