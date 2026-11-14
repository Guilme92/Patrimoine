import 'package:flutter_test/flutter_test.dart';
import 'package:patrimoine/domain/synthesis_layout.dart';

/// Fonctions pures de la disposition de la Synthèse : encodage/décodage JSON,
/// normalisation (identifiants inconnus, doublons, largeurs invalides, blocs
/// manquants) et répartition en lignes de la grille.
void main() {
  group('defaultSynthesisLayout', () {
    test('reproduit la disposition historique', () {
      final layout = defaultSynthesisLayout();
      expect(layout.map((b) => b.id).toList(), synthesisBlockIds);
      expect(layout.map((b) => b.span).toList(), <int>[6, 6, 3, 3, 6, 6]);
    });
  });

  group('encode / parse', () {
    test("l'aller-retour conserve l'ordre et les largeurs", () {
      final layout = <SynthesisBlockLayout>[
        const SynthesisBlockLayout(id: 'top_startups', span: 2),
        const SynthesisBlockLayout(id: 'kpis', span: 3),
        const SynthesisBlockLayout(id: 'category_donut', span: 6),
        const SynthesisBlockLayout(id: 'year_bars', span: 2),
        const SynthesisBlockLayout(id: 'counters', span: 2),
        const SynthesisBlockLayout(id: 'category_table', span: 3),
      ];
      final encoded = encodeSynthesisLayout(layout);
      expect(encoded.contains('"id":"top_startups"'), isTrue);
      expect(parseSynthesisLayout(encoded), layout);
    });

    test('valeur absente ou vide : disposition par défaut', () {
      expect(parseSynthesisLayout(null), defaultSynthesisLayout());
      expect(parseSynthesisLayout(''), defaultSynthesisLayout());
      expect(parseSynthesisLayout('   '), defaultSynthesisLayout());
    });

    test('JSON illisible ou de mauvaise forme : disposition par défaut', () {
      expect(parseSynthesisLayout('{oups'), defaultSynthesisLayout());
      expect(parseSynthesisLayout('{"id":"kpis"}'), defaultSynthesisLayout());
      expect(parseSynthesisLayout('42'), defaultSynthesisLayout());
    });
  });

  group('parseSynthesisLayout', () {
    test('identifiants inconnus ignorés, doublons supprimés', () {
      final layout = parseSynthesisLayout(
        '[{"id":"inconnu","span":6},{"id":"counters","span":3},'
        '{"id":"counters","span":2},{"id":"kpis","span":6}]',
      );
      expect(layout.first.id, 'counters');
      expect(layout.first.span, 3, reason: 'la première occurrence gagne');
      expect(layout.map((b) => b.id), isNot(contains('inconnu')));
      expect(layout.map((b) => b.id).toSet().length, layout.length);
    });

    test('blocs manquants ajoutés à la fin avec leur largeur par défaut', () {
      final layout = parseSynthesisLayout('[{"id":"top_startups","span":3}]');
      expect(layout.first.id, 'top_startups');
      expect(layout.map((b) => b.id).toList(), <String>[
        'top_startups',
        'kpis',
        'counters',
        'category_donut',
        'year_bars',
        'category_table',
      ]);
      // Largeur par défaut du donut : moitié.
      expect(layout.firstWhere((b) => b.id == 'category_donut').span, 3);
      expect(layout.firstWhere((b) => b.id == 'kpis').span, 6);
    });

    test('largeur absente : largeur par défaut du bloc', () {
      final layout = parseSynthesisLayout('[{"id":"year_bars"}]');
      expect(layout.first.span, 3);
    });

    test('largeur invalide ramenée à la pleine largeur', () {
      final layout = parseSynthesisLayout(
        '[{"id":"category_donut","span":5},{"id":"kpis","span":"Large"}]',
      );
      expect(layout.first.span, 6);
      expect(layout[1].span, 6);
    });
  });

  group('normalizeSynthesisLayout', () {
    test('ajoute les blocs manquants sans toucher aux largeurs valides', () {
      final layout = normalizeSynthesisLayout(const [
        SynthesisBlockLayout(id: 'year_bars', span: 2),
      ]);
      expect(layout.first.id, 'year_bars');
      expect(layout.first.span, 2);
      expect(layout.length, synthesisBlockIds.length);
    });

    test('une largeur non autorisée devient la pleine largeur', () {
      final layout = normalizeSynthesisLayout(const [
        SynthesisBlockLayout(id: 'kpis', span: 4),
      ]);
      expect(layout.first.span, 6);
    });
  });

  group('packSynthesisRows', () {
    test('deux moitiés tiennent sur la même ligne', () {
      final rows = packSynthesisRows(defaultSynthesisLayout());
      expect(rows.length, 5);
      expect(rows[0].blocks.map((b) => b.id), ['kpis']);
      expect(rows[1].blocks.map((b) => b.id), ['counters']);
      expect(rows[2].blocks.map((b) => b.id), ['category_donut', 'year_bars']);
      expect(rows[2].usedColumns, 6);
      expect(rows[2].freeColumns, 0);
      expect(rows[3].blocks.map((b) => b.id), ['category_table']);
      expect(rows[4].blocks.map((b) => b.id), ['top_startups']);
    });

    test('un bloc trop large pour la place restante passe à la ligne', () {
      final rows = packSynthesisRows(const [
        SynthesisBlockLayout(id: 'kpis', span: 2),
        SynthesisBlockLayout(id: 'counters', span: 2),
        SynthesisBlockLayout(id: 'category_donut', span: 3),
        SynthesisBlockLayout(id: 'year_bars', span: 2),
      ]);
      expect(rows.length, 2);
      expect(rows[0].blocks.map((b) => b.id), ['kpis', 'counters']);
      expect(rows[0].usedColumns, 4);
      expect(rows[0].freeColumns, 2);
      // 3 colonnes ne tiennent pas dans les 2 restantes : nouvelle ligne.
      expect(rows[1].blocks.map((b) => b.id), [
        'category_donut',
        'year_bars',
      ]);
      expect(rows[1].usedColumns, 5);
    });

    test('trois tiers partagent une ligne', () {
      final rows = packSynthesisRows(const [
        SynthesisBlockLayout(id: 'kpis', span: 2),
        SynthesisBlockLayout(id: 'counters', span: 2),
        SynthesisBlockLayout(id: 'category_donut', span: 2),
      ]);
      expect(rows.length, 1);
      expect(rows.single.usedColumns, 6);
    });

    test('disposition vide : aucune ligne', () {
      expect(packSynthesisRows(const []), isEmpty);
    });
  });
}
