import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:patrimoine/data/database.dart';
import 'package:patrimoine/theme/app_theme.dart';
import 'package:patrimoine/ui/widgets/asset_tile.dart';

Asset _asset(String type, {double value = 0}) => Asset(
  id: 1,
  name: 'Bien test',
  type: type,
  value: value,
  currency: 'EUR',
  institution: null,
  note: null,
  sortOrder: 0,
  createdAt: DateTime(2026),
);

Rental _rental() => Rental(
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
  aUnCredit: true,
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

void main() {
  testWidgets('tile immobilier affiche les KPIs de location', (tester) async {
    await tester.pumpWidget(
      _wrap(
        AssetTile(
          asset: _asset('realEstate', value: 200000),
          positions: const [],
          prices: const {},
          rental: _rental(),
        ),
      ),
    );

    expect(find.text('Loyer HC'), findsOneWidget);
    expect(find.text('Charges locataire'), findsOneWidget);
    expect(find.text('Rend. brut'), findsOneWidget);
    expect(find.text('Rend. net'), findsOneWidget);
    expect(find.text('Cashflow /mois'), findsOneWidget);
    expect(find.text('Crédit'), findsOneWidget);
    expect(find.text('Oui'), findsOneWidget);
  });

  testWidgets('tile bourse affiche les colonnes par position', (tester) async {
    await tester.pumpWidget(
      _wrap(
        AssetTile(
          asset: _asset('investment'),
          positions: [_position()],
          prices: const {'AAPL': 150.0},
        ),
      ),
    );

    expect(find.text('P.U. actuel'), findsOneWidget);
    expect(find.text('P.U. acheté'), findsOneWidget);
    expect(find.text('Qté'), findsOneWidget);
    expect(find.text('PV latente'), findsOneWidget);
    expect(find.text('Total'), findsOneWidget);
    expect(find.text('Apple'), findsOneWidget);
  });
}
