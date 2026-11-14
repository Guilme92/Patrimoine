import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrimoine/controllers/portfolio_controller.dart';
import 'package:patrimoine/data/database.dart';
import 'package:patrimoine/domain/synthesis_layout.dart';
import 'package:patrimoine/models/startup.dart';
import 'package:patrimoine/theme/app_theme.dart';
import 'package:patrimoine/ui/screens/startups_screen.dart';
import 'package:provider/provider.dart';

/// Disposition de l'onglet Synthèse : « Répartition par catégorie » et
/// « Valorisation par année d'investissement » côte à côte sur écran large,
/// empilées sur écran étroit, puis mode « Réorganiser » (ordre + largeurs
/// persistés).
void main() {
  late AppDatabase db;
  late PortfolioController controller;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    controller = PortfolioController(db);
  });

  tearDown(() => db.close());

  Future<void> seed() async {
    Future<void> add(String name, StartupDraft draft) async {
      final id = await db.addAsset(
        AssetsCompanion.insert(name: name, type: 'startup'),
      );
      await db.saveStartupDetails(draft.toCompanion(id));
    }

    await add(
      'Alpha',
      StartupDraft(
        categorie: 'Licornes pre-IPO',
        quantite: 100,
        prixEntree: 10,
        prixActuel: 30,
        frais: 12,
        dateInvestissement: DateTime(2020, 1, 1),
      ),
    );
    await add(
      'Beta',
      StartupDraft(
        categorie: 'Europe Multi-Stage',
        quantite: 100,
        prixEntree: 10,
        prixActuel: 10,
        frais: 8,
        dateInvestissement: DateTime(2022, 1, 1),
      ),
    );
  }

  Future<void> pumpScreen(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.runAsync(() => controller.load());
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: MaterialApp(
          theme: buildDarkTheme(),
          home: const Scaffold(body: StartupsScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('écran large : les deux cartes partagent la même ligne', (
    tester,
  ) async {
    await seed();
    await pumpScreen(tester, const Size(1000, 3000));

    expect(tester.takeException(), isNull);
    final donut = tester.getRect(find.text('Répartition par catégorie'));
    final bars = tester.getRect(
      find.text("Valorisation par année d'investissement"),
    );
    // Même ligne : les deux en-têtes sont alignés en haut.
    expect((donut.top - bars.top).abs(), lessThan(1));
    // Deux colonnes : la seconde commence après la première.
    expect(bars.left, greaterThan(donut.right));
  });

  testWidgets('écran étroit : les deux cartes sont empilées', (tester) async {
    await seed();
    await pumpScreen(tester, const Size(360, 3000));

    expect(tester.takeException(), isNull);
    final donut = tester.getRect(find.text('Répartition par catégorie'));
    final bars = tester.getRect(
      find.text("Valorisation par année d'investissement"),
    );
    // Empilement : même colonne, l'une sous l'autre.
    expect(bars.top, greaterThan(donut.bottom));
    expect((donut.left - bars.left).abs(), lessThan(1));
  });

  group('mode Réorganiser', () {
    Finder controlsOf(String id) =>
        find.byKey(ValueKey<String>('layout-controls-$id'));

    IconButton buttonOf(WidgetTester tester, Finder tooltip) => tester.widget(
      find.ancestor(of: tooltip, matching: find.byType(IconButton)).first,
    );

    testWidgets('bascule le mode et expose les contrôles des 6 blocs', (
      tester,
    ) async {
      await seed();
      await pumpScreen(tester, const Size(1000, 3000));

      expect(find.text('Réorganiser'), findsOneWidget);
      expect(find.text('Terminer'), findsNothing);
      expect(controlsOf('kpis'), findsNothing);

      await tester.tap(find.text('Réorganiser'));
      await tester.pumpAndSettle();

      expect(find.text('Terminer'), findsOneWidget);
      for (final id in synthesisBlockIds) {
        expect(controlsOf(id), findsOneWidget, reason: 'bloc $id');
      }

      // Extrémités : monter désactivé en haut, descendre désactivé en bas.
      expect(
        buttonOf(
          tester,
          find.descendant(
            of: controlsOf('kpis'),
            matching: find.byTooltip('Monter'),
          ),
        ).onPressed,
        isNull,
      );
      expect(
        buttonOf(
          tester,
          find.descendant(
            of: controlsOf('top_startups'),
            matching: find.byTooltip('Descendre'),
          ),
        ).onPressed,
        isNull,
      );
      // Milieu : les deux flèches sont actives.
      expect(
        buttonOf(
          tester,
          find.descendant(
            of: controlsOf('counters'),
            matching: find.byTooltip('Monter'),
          ),
        ).onPressed,
        isNotNull,
      );

      await tester.tap(find.text('Terminer'));
      await tester.pumpAndSettle();
      expect(find.text('Réorganiser'), findsOneWidget);
      expect(controlsOf('kpis'), findsNothing);
    });

    testWidgets('descendre un bloc le déplace dans le flux', (tester) async {
      await seed();
      await pumpScreen(tester, const Size(1000, 3000));
      await tester.tap(find.text('Réorganiser'));
      await tester.pumpAndSettle();

      final kpiTop = tester.getTopLeft(find.text('Capital investi')).dy;
      await tester.tap(
        find.descendant(
          of: controlsOf('kpis'),
          matching: find.byTooltip('Descendre'),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        controller.synthesisLayout.take(3).map((b) => b.id).toList(),
        <String>['counters', 'kpis', 'category_donut'],
      );
      // Les compteurs passent au-dessus des KPIs.
      final countersTop = tester.getTopLeft(find.textContaining('active')).dy;
      final kpiTopAfter = tester.getTopLeft(find.text('Capital investi')).dy;
      expect(countersTop, lessThan(kpiTopAfter));
      expect(kpiTopAfter, greaterThan(kpiTop));
    });

    testWidgets(
      'passer le donut en pleine largeur le met sur sa propre ligne',
      (tester) async {
        await seed();
        await pumpScreen(tester, const Size(1000, 3000));
        await tester.tap(find.text('Réorganiser'));
        await tester.pumpAndSettle();

        final donutControls = controlsOf('category_donut');
        await tester.ensureVisible(donutControls);
        await tester.pumpAndSettle();
        await tester.tap(
          find.descendant(of: donutControls, matching: find.text('Pleine')),
        );
        await tester.pumpAndSettle();

        expect(
          controller.synthesisLayout
              .firstWhere((b) => b.id == 'category_donut')
              .span,
          6,
        );
        final donut = tester.getRect(find.text('Répartition par catégorie'));
        final bars = tester.getRect(
          find.text("Valorisation par année d'investissement"),
        );
        expect(bars.top, greaterThan(donut.bottom));
      },
    );

    testWidgets('écran étroit : le mode édition ne déborde pas', (
      tester,
    ) async {
      await seed();
      await pumpScreen(tester, const Size(360, 3000));

      await tester.tap(find.text('Réorganiser'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(controlsOf('kpis'), findsOneWidget);
      expect(find.text('Pleine'), findsWidgets);
    });
  });

  group('persistance du layout', () {
    test('la disposition est encodée en base et relue au chargement', () async {
      const layout = <SynthesisBlockLayout>[
        SynthesisBlockLayout(id: 'counters', span: 6),
        SynthesisBlockLayout(id: 'kpis', span: 2),
        SynthesisBlockLayout(id: 'category_donut', span: 6),
        SynthesisBlockLayout(id: 'year_bars', span: 3),
        SynthesisBlockLayout(id: 'category_table', span: 2),
        SynthesisBlockLayout(id: 'top_startups', span: 2),
      ];

      await controller.setSynthesisLayout(layout);
      expect(
        await db.preferenceValue(synthesisLayoutKey),
        encodeSynthesisLayout(layout),
      );

      final reloaded = PortfolioController(db);
      await reloaded.load();
      expect(reloaded.synthesisLayout, layout);
    });

    test(
      'une disposition incomplète est complétée par les blocs manquants',
      () async {
        await controller.setSynthesisLayout(const [
          SynthesisBlockLayout(id: 'year_bars', span: 3),
        ]);

        expect(controller.synthesisLayout.length, synthesisBlockIds.length);
        expect(controller.synthesisLayout.first.id, 'year_bars');
        expect(
          controller.synthesisLayout.map((b) => b.id).toSet(),
          synthesisBlockIds.toSet(),
        );
      },
    );

    test(
      'une préférence corrompue retombe sur la disposition par défaut',
      () async {
        await db.setPreference(synthesisLayoutKey, 'pas du json');

        final reloaded = PortfolioController(db);
        await reloaded.load();
        expect(reloaded.synthesisLayout, defaultSynthesisLayout());
      },
    );
  });
}
