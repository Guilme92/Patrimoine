import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:patrimoine/theme/app_theme.dart';
import 'package:patrimoine/ui/widgets/blast_exit_simulator.dart';

void main() {
  Widget wrap() => MaterialApp(
    theme: buildDarkTheme(),
    home: Scaffold(
      body: SingleChildScrollView(
        child: BlastExitSimulator(
          stakePct: 0.03246032,
          invested: 30060,
          onSaveParams: (_, _) async {},
        ),
      ),
    ),
  );

  testWidgets('affiche le simulateur et recalcule au glissement', (tester) async {
    tester.view.physicalSize = const Size(400, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    expect(find.text('Simulateur de sortie'), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);
    expect(find.text('Valeur de mes parts'), findsOneWidget);
    expect(find.text('PV brute'), findsOneWidget);
    expect(find.text('PV nette'), findsOneWidget);
    expect(find.textContaining('Détention'), findsOneWidget);

    final before = tester.widget<Slider>(find.byType(Slider)).value;
    await tester.drag(find.byType(Slider), const Offset(200, 0));
    await tester.pumpAndSettle();
    final after = tester.widget<Slider>(find.byType(Slider)).value;
    expect(after, isNot(equals(before)));
    expect(tester.takeException(), isNull);
  });

  testWidgets('le bouton d\'édition ouvre le dialogue de participation', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Paramètres de ma participation'));
    await tester.pumpAndSettle();

    expect(find.text('Ma participation Blast'), findsOneWidget);
    expect(find.text('Détention (%)'), findsOneWidget);
    expect(find.text('Capital investi (€)'), findsOneWidget);
  });
}
