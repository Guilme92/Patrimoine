import 'package:flutter_test/flutter_test.dart';

import 'package:patrimoine/domain/blast_exit.dart';

void main() {
  group('simulateur de sortie Blast', () {
    test('valeur des parts = valorisation × détention en %', () {
      expect(blastShareValue(1e9, 0.03246032), closeTo(324603.2, 1e-6));
      expect(blastShareValue(500e6, 0.03246032), closeTo(162301.6, 1e-6));
    });

    test('PV brute = valeur des parts − capital investi', () {
      const invested = 30060.0;
      expect(
        blastPvBrute(1e9, 0.03246032, invested),
        closeTo(324603.2 - 30060, 1e-6),
      );
    });

    test('PV nette = PV brute × (1 − 18,2 %)', () {
      expect(blastExitTaxRate, closeTo(0.182, 1e-12));
      expect(blastPvNette(100), closeTo(81.8, 1e-9));
      expect(
        blastPvNette(324603.2 - 30060),
        closeTo((324603.2 - 30060) * 0.818, 1e-6),
      );
    });

    test('moins-value non fiscalisée', () {
      expect(blastPvNette(-100), -100);
      expect(blastPvNette(0), 0);
    });

    test('bornes du simulateur : 500 M€ → 10 Mrd €', () {
      expect(blastExitValuationMin, 500e6);
      expect(blastExitValuationMax, 10e9);
    });
  });
}
