import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:patrimoine/data/database.dart';
import 'package:patrimoine/theme/app_theme.dart';
import 'package:patrimoine/ui/widgets/asset_tile.dart';
import 'package:patrimoine/utils/format.dart';

Asset _asset(String type, {double value = 0, String name = 'Bien test'}) =>
    Asset(
      id: 1,
      name: name,
      type: type,
      value: value,
      currency: 'EUR',
      institution: null,
      note: null,
      sortOrder: 0,
      createdAt: DateTime(2026),
    );

Rental _rental({bool credit = true}) => Rental(
  id: 1,
  assetId: 1,
  statut: 'loue',
  typeBail: 'vide',
  locataire: 'M. Dupont',
  loyerHc: 900,
  chargesLocatives: 50,
  depotGarantie: 1800,
  dateDebutBail: DateTime(2025),
  dateFinBail: null,
  modeGestion: 'direct',
  fraisGestion: 60,
  taxeFonciere: 1200,
  assurancePno: 240,
  chargesCopropriete: 600,
  travauxEntretien: 300,
  vacanceLocative: 0,
  note: null,
  aUnCredit: credit,
  montantCredit: 180000,
  tauxCreditPct: 2.5,
  mensualiteCredit: 700,
  dureeCreditMois: 180,
  capitalRestantDu: 120000,
  assuranceEmprunteur: 30,
  createdAt: DateTime(2026),
);

Position _position() => Position(
  id: 1,
  assetId: 1,
  symbol: 'AAPL',
  name: 'Apple',
  quantity: 10,
  unitCost: 100,
  assetClass: null,
  sector: null,
  region: null,
  fees: 0,
  createdAt: DateTime(2026),
);

Widget _wrap(Widget child) => MaterialApp(
  theme: buildDarkTheme(),
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

/// Rangée la plus externe qui contient [text] : sert à vérifier que deux
/// libellés sont rendus sur la même ligne horizontale.
Element? _outermostRow(WidgetTester tester, String text) {
  Element? row;
  tester.element(find.text(text)).visitAncestorElements((ancestor) {
    if (ancestor.widget is Row) row = ancestor;
    return true;
  });
  return row;
}

Widget _rentedTile({bool credit = true, String name = 'Bien test'}) =>
    AssetTile(
      asset: _asset('realEstate', value: 200000, name: name),
      positions: const [],
      prices: const {},
      rental: _rental(credit: credit),
    );

void main() {
  testWidgets('tile immobilier : tous les indicateurs sur une seule ligne', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(_rentedTile()));

    // Libellés complets sur écran large.
    expect(find.text('Loyer HC'), findsOneWidget);
    expect(find.text('Charges locataire'), findsOneWidget);
    expect(find.text('Rend. brut'), findsOneWidget);
    expect(find.text('Rend. net'), findsOneWidget);
    expect(find.text('Cashflow /mois'), findsOneWidget);
    expect(find.text('Crédit'), findsOneWidget);
    expect(find.text('Valeur'), findsOneWidget);

    // Valeurs.
    expect(find.text('Oui'), findsOneWidget);
    expect(find.text(formatEuro(900)), findsOneWidget);
    expect(find.text(formatEuro(50)), findsOneWidget);
    expect(find.text(formatPctFixed(5.4)), findsOneWidget);
    expect(find.text(formatPctFixed(3.87)), findsOneWidget);
    expect(find.text(formatSignedEuro(-35)), findsOneWidget);
    expect(find.text(formatEuro(200000)), findsOneWidget);

    // Une seule rangée : tous les libellés appartiennent au même Row.
    final row = _outermostRow(tester, 'Loyer HC');
    for (final label in [
      'Charges locataire',
      'Rend. brut',
      'Rend. net',
      'Cashflow /mois',
      'Crédit',
      'Valeur',
    ]) {
      expect(_outermostRow(tester, label), same(row));
    }

    // Carte compacte : une rangée de ~46 dp au lieu de l'en-tête + grille.
    expect(tester.getSize(find.byType(AssetTile)).height, lessThan(70));
  });

  testWidgets('tile immobilier à 360 dp : compacte et sans débordement', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _wrap(_rentedTile(name: 'Appartement Lyon 3e')),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    // Libellés abrégés, valeurs toujours présentes.
    expect(find.text('Loyer'), findsOneWidget);
    expect(find.text('Charges'), findsOneWidget);
    expect(find.text('Brut'), findsOneWidget);
    expect(find.text('Net'), findsOneWidget);
    expect(find.text('Cash'), findsOneWidget);
    expect(find.text('Crédit'), findsOneWidget);
    expect(find.text('Valeur'), findsOneWidget);

    expect(find.text(formatEuro(900)), findsOneWidget);
    expect(find.text(formatEuro(50)), findsOneWidget);
    expect(find.text(formatPctFixed(5.4)), findsOneWidget);
    expect(find.text(formatPctFixed(3.87)), findsOneWidget);
    expect(find.text(formatSignedEuro(-35)), findsOneWidget);
    expect(find.text('Oui'), findsOneWidget);
    // Valeur monétaire compactée pour tenir à 360 dp.
    expect(find.text('200 k€'), findsOneWidget);

    // Toujours une seule rangée, sans dépasser la largeur de l'écran.
    final row = _outermostRow(tester, 'Loyer');
    for (final label in ['Charges', 'Brut', 'Net', 'Cash', 'Crédit', 'Valeur']) {
      expect(_outermostRow(tester, label), same(row));
    }
    expect(tester.getSize(find.byType(AssetTile)).height, lessThan(70));
    expect(
      tester.getTopRight(find.byType(AssetTile)).dx,
      lessThanOrEqualTo(360),
    );
  });

  testWidgets('cashflow coloré : rouge si négatif, vert si positif', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(_rentedTile()));
    expect(
      tester.widget<Text>(find.text(formatSignedEuro(-35))).style?.color,
      AppColors.negative,
    );

    await tester.pumpWidget(_wrap(_rentedTile(credit: false)));
    expect(find.text('Non'), findsOneWidget);
    expect(
      tester.widget<Text>(find.text(formatSignedEuro(695))).style?.color,
      AppColors.positive,
    );
  });

  testWidgets('tile bourse : une rangée compacte par position', (tester) async {
    await tester.pumpWidget(
      _wrap(
        AssetTile(
          asset: _asset('investment'),
          positions: [_position()],
          prices: const {'AAPL': 150.0},
        ),
      ),
    );

    // Écran large : libellés complets, portés par chaque rangée (plus
    // d'en-tête de colonnes séparé).
    expect(find.text('P.U. actuel'), findsOneWidget);
    expect(find.text('P.U. acheté'), findsOneWidget);
    expect(find.text('Qté'), findsOneWidget);
    expect(find.text('PV latente'), findsOneWidget);
    expect(find.text('Total'), findsOneWidget);
    expect(find.text('Actif'), findsNothing);
    expect(find.text('Apple'), findsOneWidget);
    expect(find.text('AAPL'), findsOneWidget);

    // Valeurs de la position (le total apparaît aussi dans l'en-tête).
    expect(find.text(formatEuro(150, cents: true)), findsOneWidget);
    expect(find.text(formatEuro(100, cents: true)), findsOneWidget);
    expect(find.text(formatQty(10)), findsOneWidget);
    expect(find.text(formatSignedEuro(500, cents: true)), findsOneWidget);
    expect(find.text(formatEuro(1500)), findsNWidgets(2));

    // PV latente positive : verte.
    expect(
      tester.widget<Text>(find.text(formatSignedEuro(500, cents: true))).style?.color,
      AppColors.positive,
    );

    // Tout sur une seule rangée.
    final row = _outermostRow(tester, 'P.U. actuel');
    for (final label in ['P.U. acheté', 'Qté', 'PV latente', 'Total', 'Apple']) {
      expect(_outermostRow(tester, label), same(row));
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('tile bourse à 360 dp : libellés abrégés, sans débordement', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _wrap(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AssetTile(
            asset: _asset('investment', name: 'Compte-titres'),
            positions: [_position()],
            prices: const {'AAPL': 150.0},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    // Libellés abrégés, une seule rangée.
    expect(find.text('Cours'), findsOneWidget);
    expect(find.text('Achat'), findsOneWidget);
    expect(find.text('Qté'), findsOneWidget);
    expect(find.text('PV'), findsOneWidget);
    expect(find.text('Total'), findsOneWidget);

    // Montants arrondis à l'euro, total compacté : rien n'est tronqué.
    expect(find.text(formatEuro(150)), findsOneWidget);
    expect(find.text(formatEuro(100)), findsOneWidget);
    expect(find.text(formatSignedEuro(500)), findsOneWidget);
    expect(find.text(formatCompactEuro(1500)), findsOneWidget);

    final row = _outermostRow(tester, 'Cours');
    for (final label in ['Achat', 'Qté', 'PV', 'Total', 'Apple']) {
      expect(_outermostRow(tester, label), same(row));
    }
    expect(
      tester.getTopRight(find.byType(AssetTile)).dx,
      lessThanOrEqualTo(360),
    );
  });

  testWidgets('tile bourse : PV négative en rouge, plusieurs positions', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        AssetTile(
          asset: _asset('investment', name: 'PEA'),
          positions: [
            _position(),
            Position(
              id: 2,
              assetId: 1,
              symbol: 'MC.PA',
              name: 'LVMH',
              quantity: 2,
              unitCost: 700,
              assetClass: null,
              sector: null,
              region: null,
              fees: 0,
              createdAt: DateTime(2026),
            ),
          ],
          prices: const {'AAPL': 150.0, 'MC.PA': 600.0},
        ),
      ),
    );

    expect(
      tester.widget<Text>(find.text(formatSignedEuro(-200, cents: true))).style?.color,
      AppColors.negative,
    );
    expect(find.text('LVMH'), findsOneWidget);
    expect(find.text('Apple'), findsOneWidget);
    // Une seule rangée de libellés par position (les libellés sont portés par
    // chaque ligne, il n'y a plus d'en-tête de tableau).
    expect(find.text('Qté'), findsNWidgets(2));
    expect(find.text('P.U. actuel'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });
}
