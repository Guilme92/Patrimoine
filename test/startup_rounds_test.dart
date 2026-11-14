import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrimoine/controllers/portfolio_controller.dart';
import 'package:patrimoine/data/csv_import.dart';
import 'package:patrimoine/data/database.dart';
import 'package:patrimoine/models/asset_type.dart';
import 'package:patrimoine/domain/startup_rounds.dart';
import 'package:patrimoine/models/startup.dart';

CsvImportRow _tour(
  String name, {
  required double quantite,
  required double prixEntree,
  required double frais,
  required DateTime date,
  required double valorisation,
  double prixActuel = 1,
  String? note,
}) => CsvImportRow(
  name: name,
  value: 0,
  currency: 'EUR',
  note: note,
  startup: StartupDraft(
    quantite: quantite,
    prixEntree: prixEntree,
    frais: frais,
    dateInvestissement: date,
    valorisationEntreprise: valorisation,
    prixActuel: prixActuel,
    note: note,
  ),
);

/// Deux tours de KEEWE : 279 titres à 1,00 € puis 500 titres à 1,00 €.
List<CsvImportRow> _keeweTours() => [
  _tour(
    'KEEWE',
    quantite: 279,
    prixEntree: 1,
    frais: 11.16,
    date: DateTime(2024, 3, 1),
    valorisation: 10000000,
    prixActuel: 1.5,
    note: 'Apport 2024',
  ),
  _tour(
    'KEEWE ROUND 2',
    quantite: 500,
    prixEntree: 1,
    frais: 20,
    date: DateTime(2026, 4, 30),
    valorisation: 26000000,
    prixActuel: 1.8,
    note: 'Suivi 2026',
  ),
];

void main() {
  group('parseStartupRound / baseStartupName', () {
    test('sans suffixe : premier tour, nom inchangé (trimé)', () {
      expect(baseStartupName('KEEWE'), 'KEEWE');
      expect(baseStartupName('  KEEWE  '), 'KEEWE');
      expect(parseStartupRound('KEEWE').round, 1);
      expect(parseStartupRound('KEEWE').hasSuffix, isFalse);
    });

    test('« ROUND n » suffixe, quelle que soit la casse', () {
      expect(baseStartupName('KEEWE ROUND 2'), 'KEEWE');
      expect(parseStartupRound('KEEWE ROUND 2').round, 2);
      expect(baseStartupName('FINOVOX - ROUND 2'), 'FINOVOX');
      expect(baseStartupName('WHEERE - ROUND 2'), 'WHEERE');
      expect(baseStartupName('keewe round 3').toString(), 'keewe');
      expect(parseStartupRound('keewe round 3').round, 3);
    });

    test('« Tranche n » et « TRANCH n »', () {
      expect(baseStartupName('HEXANA - Tranche 2'), 'HEXANA');
      expect(parseStartupRound('HEXANA - Tranche 2').round, 2);
      expect(baseStartupName('HEXANA TRANCH 2'), 'HEXANA');
      expect(parseStartupRound('HEXANA TRANCH 2').round, 2);
    });

    test('forme courte « R2 » / « R3 »', () {
      expect(baseStartupName('KEEWE R2'), 'KEEWE');
      expect(parseStartupRound('KEEWE R2').round, 2);
      expect(baseStartupName('KEEWE - R2'), 'KEEWE');
      expect(baseStartupName('WHEERE - R3'), 'WHEERE');
      expect(parseStartupRound('WHEERE - R3').round, 3);
    });

    test('un nombre en fin de nom n\'est pas un tour', () {
      expect(baseStartupName('Xavier 2'), 'Xavier 2');
      expect(parseStartupRound('Xavier 2').round, 1);
      expect(baseStartupName('Studio 54'), 'Studio 54');
      expect(parseStartupRound('Studio 54').round, 1);
    });

    test('la clé de regroupement ignore casse et accents', () {
      expect(
        startupRoundGroupKey('Éco-Logic ROUND 2'),
        startupRoundGroupKey('eco-logic'),
      );
      expect(
        startupRoundGroupKey('KEEWE'),
        startupRoundGroupKey('  keewe - R2 '),
      );
      expect(startupRoundGroupKey('KEEWE'), isNot(startupRoundGroupKey('FINOVOX')));
    });
  });

  group('mergeStartupTours', () {
    test('agrège quantités, frais, prix moyen pondéré et valorisation', () {
      final merged = mergeStartupTours(_keeweTours());
      final s = merged.startup!;

      expect(merged.name, 'KEEWE');
      expect(s.quantite, 779);
      expect(s.prixEntree, closeTo(1, 1e-9));
      expect(s.frais, closeTo(31.16, 1e-9));
      expect(s.valorisationEntreprise, 26000000);
      expect(s.dateInvestissement, DateTime(2024, 3, 1));
      // Le tour le plus récent porte les champs de fiche.
      expect(s.prixActuel, 1.8);
      expect(s.statut, 'en_portefeuille');
      // Les notes des tours sont conservées, dans l'ordre chronologique.
      expect(s.note, 'Apport 2024\nSuivi 2026');

      expect(merged.rounds, hasLength(2));
      final first = merged.rounds.first;
      expect(first.date, DateTime(2024, 3, 1));
      expect(first.montantLeve, closeTo(290.16, 1e-9));
      expect(first.valorisationPreMoney, 10000000);
      expect(first.prixParAction, closeTo(1, 1e-9));

      final second = merged.rounds.last;
      expect(second.date, DateTime(2026, 4, 30));
      expect(second.montantLeve, closeTo(520, 1e-9));
      expect(second.valorisationPreMoney, 26000000);
      expect(second.prixParAction, closeTo(1, 1e-9));
      expect(second.note, 'KEEWE ROUND 2');
    });

    test('prix moyen pondéré sur des prix d\'entrée différents', () {
      final merged = mergeStartupTours([
        _tour(
          'ACME',
          quantite: 100,
          prixEntree: 2,
          frais: 0,
          date: DateTime(2023, 1, 1),
          valorisation: 1000000,
        ),
        _tour(
          'ACME ROUND 2',
          quantite: 300,
          prixEntree: 4,
          frais: 0,
          date: DateTime(2024, 1, 1),
          valorisation: 5000000,
        ),
      ]);
      // (100 × 2 + 300 × 4) / 400 = 3,5 €.
      expect(merged.startup!.prixEntree, closeTo(3.5, 1e-9));
      expect(merged.startup!.quantite, 400);
    });

    test('les tours sont triés par date même si le CSV est désordonné', () {
      final rows = _keeweTours().reversed.toList();
      final merged = mergeStartupTours(rows);

      expect(merged.rounds.map((r) => r.date).toList(), [
        DateTime(2024, 3, 1),
        DateTime(2026, 4, 30),
      ]);
      // La valorisation reste celle du tour le plus récent (2026).
      expect(merged.startup!.valorisationEntreprise, 26000000);
      expect(merged.startup!.dateInvestissement, DateTime(2024, 3, 1));
    });

    test('repli sur la valorisation du tour précédent si la plus récente manque', () {
      final merged = mergeStartupTours([
        _tour(
          'ACME',
          quantite: 10,
          prixEntree: 1,
          frais: 0,
          date: DateTime(2023, 1, 1),
          valorisation: 7000000,
        ),
        _tour(
          'ACME ROUND 2',
          quantite: 10,
          prixEntree: 1,
          frais: 0,
          date: DateTime(2025, 1, 1),
          valorisation: 0,
        ),
      ]);
      expect(merged.startup!.valorisationEntreprise, 7000000);
    });

    test('une colonne levees déjà renseignée est conservée', () {
      final withRounds = CsvImportRow(
        name: 'ACME ROUND 2',
        value: 0,
        currency: 'EUR',
        startup: StartupDraft(
          quantite: 10,
          prixEntree: 5,
          frais: 0,
          dateInvestissement: DateTime(2025, 1, 1),
          valorisationEntreprise: 2000000,
        ),
        rounds: [
          FundingRoundDraft(
            date: DateTime(2024, 6, 1),
            montantLeve: 500000,
            valorisationPostMoney: 2000000,
            prixParAction: 5,
          ),
        ],
      );
      final merged = mergeStartupTours([
        _tour(
          'ACME',
          quantite: 10,
          prixEntree: 1,
          frais: 0,
          date: DateTime(2023, 1, 1),
          valorisation: 1000000,
        ),
        withRounds,
      ]);

      expect(merged.rounds, hasLength(2));
      expect(merged.rounds.map((r) => r.date).toList(), [
        DateTime(2023, 1, 1),
        DateTime(2024, 6, 1),
      ]);
      // Le tour explicite garde ses valeurs plutôt qu'une reconstitution.
      expect(merged.rounds.last.montantLeve, 500000);
    });

    test('une seule ligne est rendue inchangée', () {
      final single = _keeweTours().first;
      final merged = mergeStartupTours([single]);
      expect(identical(merged, single), isTrue);
    });
  });

  group('mergeStartupRows', () {
    test('fusionne les groupes et conserve les sociétés uniques', () {
      final rows = [
        ..._keeweTours(),
        _tour(
          'FINOVOX',
          quantite: 5,
          prixEntree: 10,
          frais: 1,
          date: DateTime(2025, 5, 5),
          valorisation: 3000000,
        ),
      ];
      final merged = mergeStartupRows(rows);

      expect(merged.map((r) => r.name).toList(), ['KEEWE', 'FINOVOX']);
      expect(merged.first.startup!.quantite, 779);
      expect(merged.first.rounds, hasLength(2));
      expect(merged.last.rounds, isEmpty);
    });

    test('regroupe malgré la casse et les accents', () {
      final rows = [
        _tour(
          'Keewé',
          quantite: 10,
          prixEntree: 1,
          frais: 0,
          date: DateTime(2024, 1, 1),
          valorisation: 1000000,
        ),
        _tour(
          'KEEWE - R2',
          quantite: 10,
          prixEntree: 1,
          frais: 0,
          date: DateTime(2025, 1, 1),
          valorisation: 2000000,
        ),
      ];
      final merged = mergeStartupRows(rows);
      expect(merged, hasLength(1));
      expect(merged.single.startup!.quantite, 20);
      expect(merged.single.rounds, hasLength(2));
    });
  });

  group('parseStartupCsv multi-tours', () {
    test('une ligne par tour devient une fiche unique', () {
      const csv = 'nom,quantite,prix_entree,frais,date_investissement,'
          'valorisation_entreprise,note\n'
          'KEEWE,279,1.00,11.16,2024-03-01,10000000,Apport 2024\n'
          'KEEWE ROUND 2,500,1.00,20,2026-04-30,26000000,Suivi 2026\n'
          'AUTRE,10,5,0,2025-01-01,1000000,\n';

      final parsed = parseStartupCsv(csv);
      expect(parsed.rows, hasLength(2));
      expect(parsed.skipped, 0);
      expect(parsed.rows.map((r) => r.name).toList(), ['KEEWE', 'AUTRE']);

      final keewe = parsed.rows.first;
      final s = keewe.startup!;
      expect(s.quantite, 779);
      expect(s.prixEntree, closeTo(1, 1e-9));
      expect(s.frais, closeTo(31.16, 1e-9));
      expect(s.valorisationEntreprise, 26000000);
      expect(s.dateInvestissement, DateTime(2024, 3, 1));
      expect(s.note, 'Apport 2024\nSuivi 2026');
      expect(keewe.note, 'Apport 2024');
      expect(keewe.rounds, hasLength(2));
      expect(keewe.rounds.first.date, DateTime(2024, 3, 1));
      expect(keewe.rounds.last.date, DateTime(2026, 4, 30));
      expect(keewe.rounds.last.valorisationPreMoney, 26000000);

      final autre = parsed.rows.last;
      expect(autre.startup!.quantite, 10);
      expect(autre.rounds, isEmpty);
    });

    test('un CSV mono-tour n\'est pas altéré', () {
      const csv = 'nom,quantite,prix_entree,levees\n'
          'Qonto,100,10,2023-01-15|500000|5000000|10\n';
      final row = parseStartupCsv(csv).rows.single;
      expect(row.name, 'Qonto');
      expect(row.rounds, hasLength(1));
      expect(row.rounds.single.montantLeve, 500000);
    });
  });

  group('import en base', () {
    test('trois tours donnent un seul actif et trois levées', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final controller = PortfolioController(db);
      const csv = 'nom,quantite,prix_entree,frais,date_investissement,'
          'valorisation_entreprise\n'
          'HEXANA,100,2,5,2023-01-01,5000000\n'
          'HEXANA - Tranche 2,200,3,10,2024-06-01,12000000\n'
          'HEXANA R3,300,4,15,2025-09-01,30000000\n'
          'AUTRE,10,5,0,2025-01-01,1000000\n';

      final result = await controller.importCsv(csv: csv, type: AssetType.startup);
      expect(result.imported, 2);

      final assets = await db.allAssets();
      expect(assets.map((a) => a.name).toList(), ['HEXANA', 'AUTRE']);

      final detail = await db.startupDetailsFor(assets.first.id);
      expect(detail!.quantite, 600);
      expect(detail.prixEntree, closeTo(2000 / 600, 1e-9));
      expect(detail.frais, 30);
      expect(detail.valorisationEntreprise, 30000000);
      expect(detail.dateInvestissement, DateTime(2023, 1, 1));

      // Tri décroissant côté base : le tour le plus récent d'abord.
      final rounds = await db.fundingRoundsFor(assets.first.id);
      expect(rounds, hasLength(3));
      expect(rounds.first.valorisationPreMoney, 30000000);
      expect(rounds.last.date, DateTime(2023, 1, 1));

      await db.close();
    });
  });
}
