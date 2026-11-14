import 'package:flutter_test/flutter_test.dart';
import 'package:patrimoine/data/database.dart';
import 'package:patrimoine/domain/funding_rounds.dart';
import 'package:patrimoine/domain/startup.dart';

FundingRound _round({
  required int id,
  double montantLeve = 0,
  double preMoney = 0,
  double postMoney = 0,
  DateTime? date,
}) => FundingRound(
  id: id,
  assetId: 1,
  date: date,
  montantLeve: montantLeve,
  valorisationPreMoney: preMoney,
  valorisationPostMoney: postMoney,
  dilution: 0,
  prixParAction: 0,
);

StartupDetail _detail({
  double quantite = 0,
  double prixActuel = 0,
  double montantInvesti = 0,
}) => StartupDetail(
  id: 1,
  assetId: 1,
  quantite: quantite,
  prixEntree: 1,
  frais: 0,
  montantInvesti: montantInvesti,
  prixActuel: prixActuel,
  valorisationEntreprise: 0,
  statut: 'en_portefeuille',
  exitProduit: 0,
  createdAt: DateTime(2024),
);

void main() {
  group('shareUnitPrice', () {
    test('un seul tour : PU = 1 € (base de calcul)', () {
      expect(shareUnitPrice([_round(id: 1, postMoney: 1000000)]), 1.0);
    });

    test('deux tours : PU = pre-money R2 ÷ post-money R1', () {
      final rounds = [
        _round(id: 1, postMoney: 27),
        _round(id: 2, preMoney: 33),
      ];
      expect(shareUnitPrice(rounds), closeTo(33 / 27, 1e-12));
    });

    test('trois tours : revalorisation enchaînée', () {
      final rounds = [
        _round(id: 1, postMoney: 10),
        _round(id: 2, preMoney: 20, postMoney: 40),
        _round(id: 3, preMoney: 80),
      ];
      // PU = 1 × (20/10) × (80/40) = 4.
      expect(shareUnitPrice(rounds), closeTo(4.0, 1e-12));
    });

    test('valorisation manquante → null', () {
      expect(
        shareUnitPrice([
          _round(id: 1, postMoney: 0),
          _round(id: 2, preMoney: 33),
        ]),
        isNull,
      );
    });

    test('liste vide → null', () {
      expect(shareUnitPrice(const []), isNull);
    });
  });

  group('fundingRoundsValue', () {
    test(
      'deux tours : investi_1 × (pre-money R2 ÷ post-money R1) + investi_2',
      () {
        final rounds = [
          _round(id: 1, montantLeve: 2718.45, postMoney: 27000000),
          _round(id: 2, montantLeve: 3224.00, preMoney: 33000000),
        ];
        final expected = 2718.45 * (33000000 / 27000000) + 3224.00;
        expect(fundingRoundsValue(rounds), closeTo(expected, 1e-9));
      },
    );

    test('un seul tour : valeur = investi', () {
      expect(
        fundingRoundsValue([_round(id: 1, montantLeve: 1000)]),
        closeTo(1000, 1e-9),
      );
    });

    test('trois tours : chaque investi revalorisé jusqu\'au dernier tour', () {
      final rounds = [
        _round(id: 1, montantLeve: 1000, postMoney: 10),
        _round(id: 2, montantLeve: 500, preMoney: 20, postMoney: 40),
        _round(id: 3, montantLeve: 300, preMoney: 80),
      ];
      // PU : [1, 2, 4]. Valeur = 1000×(4/1) + 500×(4/2) + 300×(4/4)
      // = 4000 + 1000 + 300 = 5300.
      expect(fundingRoundsValue(rounds), closeTo(5300, 1e-9));
    });

    test('valorisation manquante → null', () {
      expect(
        fundingRoundsValue([
          _round(id: 1, montantLeve: 1000, postMoney: 0),
          _round(id: 2, montantLeve: 500, preMoney: 33),
        ]),
        isNull,
      );
    });

    test('liste vide → null', () {
      expect(fundingRoundsValue(const []), isNull);
    });
  });

  group('startupValue (harmonisation avec les levées)', () {
    test('dès 2 tours exploitables, suit le calcul des levées', () {
      final detail = _detail(
        quantite: 5689,
        prixActuel: 1.22,
        montantInvesti: 5942.45,
      );
      final rounds = [
        _round(id: 1, montantLeve: 2718.45, postMoney: 27000000),
        _round(id: 2, montantLeve: 3224, preMoney: 33000000),
      ];
      // 2 718,45 × (33/27) + 3 224 = 6 546,55.
      expect(startupValue(detail, rounds), closeTo(6546.55, 1e-9));
    });

    test('sans tours, repli sur quantité × prix actuel', () {
      final detail = _detail(quantite: 100, prixActuel: 1.22);
      expect(startupValue(detail, const []), closeTo(122, 1e-9));
    });

    test('tours sans valorisations exploitables → repli', () {
      final detail = _detail(quantite: 100, prixActuel: 1.22);
      final rounds = [
        _round(id: 1, montantLeve: 100, postMoney: 0),
        _round(id: 2, montantLeve: 100, preMoney: 0),
      ];
      expect(startupValue(detail, rounds), closeTo(122, 1e-9));
    });

    test('PV latente cohérente avec la valorisation des levées', () {
      final detail = _detail(
        quantite: 5689,
        prixActuel: 1.22,
        montantInvesti: 5942.45,
      );
      final rounds = [
        _round(id: 1, montantLeve: 2718.45, postMoney: 27000000),
        _round(id: 2, montantLeve: 3224, preMoney: 33000000),
      ];
      // Valorisation 6 546,55 − capital 5 942,45 = 604,10 de PV latente.
      expect(unrealizedGain(detail, rounds: rounds), closeTo(604.10, 1e-9));
      // Cohérence interne : MOIC − 1 == PV latente en part du capital.
      expect(
        moic(detail, rounds: rounds) - 1,
        closeTo(unrealizedGain(detail, rounds: rounds) / investedCapital(detail), 1e-9),
      );
    });
  });
}
