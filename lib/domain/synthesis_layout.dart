/// Disposition de l'onglet « Synthèse » des startups : chaque bloc a un
/// identifiant stable et une largeur exprimée en colonnes d'une grille de
/// [synthesisGridColumns] colonnes.
///
/// Ce fichier ne contient que des fonctions pures (aucun import Flutter) :
/// l'encodage/décodage JSON et la normalisation sont testables isolément.
library;

import 'dart:convert';

/// Nombre de colonnes de la grille interne de la Synthèse.
const int synthesisGridColumns = 6;

/// Ordre et largeurs par défaut des blocs : donut et barres d'année côte à
/// côte (moitié de largeur), le reste en pleine largeur.
const List<String> synthesisBlockIds = <String>[
  'kpis',
  'counters',
  'category_donut',
  'year_bars',
  'category_table',
  'top_startups',
];

/// Largeur par défaut (en colonnes) de chaque bloc.
const Map<String, int> synthesisDefaultSpans = <String, int>{
  'kpis': 6,
  'counters': 6,
  'category_donut': 3,
  'year_bars': 3,
  'category_table': 6,
  'top_startups': 6,
};

/// Libellés affichés dans les contrôles du mode « Réorganiser ».
const Map<String, String> synthesisBlockLabels = <String, String>{
  'kpis': 'KPIs clés',
  'counters': 'Compteurs',
  'category_donut': 'Donut catégories',
  'year_bars': 'Barres par année',
  'category_table': 'Tableau catégories',
  'top_startups': 'Top 5',
};

/// Largeurs proposées à l'utilisateur : pleine (6), moitié (3), tiers (2).
const Set<int> synthesisAllowedSpans = <int>{2, 3, 6};

/// Libellés des trois largeurs, dans l'ordre d'affichage.
const Map<int, String> synthesisSpanLabels = <int, String>{
  6: 'Pleine',
  3: 'Moitié',
  2: 'Tiers',
};

/// Largeur par défaut d'un bloc (6 colonnes si l'identifiant est inconnu).
int synthesisDefaultSpan(String id) =>
    synthesisDefaultSpans[id] ?? synthesisGridColumns;

/// Libellé d'un bloc, ou son identifiant brut s'il est inconnu.
String synthesisBlockLabel(String id) => synthesisBlockLabels[id] ?? id;

/// Un bloc de la Synthèse : identifiant stable + largeur en colonnes.
class SynthesisBlockLayout {
  final String id;
  final int span;

  const SynthesisBlockLayout({required this.id, required this.span});

  SynthesisBlockLayout copyWith({String? id, int? span}) =>
      SynthesisBlockLayout(id: id ?? this.id, span: span ?? this.span);

  Map<String, Object?> toJson() => <String, Object?>{'id': id, 'span': span};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SynthesisBlockLayout && other.id == id && other.span == span;

  @override
  int get hashCode => Object.hash(id, span);

  @override
  String toString() => 'SynthesisBlockLayout($id, $span)';
}

/// Disposition par défaut (celle qui reproduit l'apparence historique).
List<SynthesisBlockLayout> defaultSynthesisLayout() => <SynthesisBlockLayout>[
  for (final id in synthesisBlockIds)
    SynthesisBlockLayout(id: id, span: synthesisDefaultSpan(id)),
];

/// Ramène une largeur à une valeur autorisée ; toute valeur absente,
/// illisible ou hors bornes retombe sur [fallback] (6 colonnes par défaut).
int normalizeSynthesisSpan(Object? raw, {int fallback = synthesisGridColumns}) {
  final value = switch (raw) {
    final int v => v,
    final num v => v.round(),
    final String v => int.tryParse(v.trim()),
    _ => null,
  };
  if (value != null && synthesisAllowedSpans.contains(value)) return value;
  return fallback;
}

/// Nettoie une disposition : identifiants inconnus et doublons ignorés,
/// largeurs invalides ramenées à 6 colonnes, blocs manquants ajoutés à la fin
/// avec leur largeur par défaut.
List<SynthesisBlockLayout> normalizeSynthesisLayout(
  Iterable<SynthesisBlockLayout> layout,
) {
  final seen = <String>{};
  final normalized = <SynthesisBlockLayout>[];
  for (final block in layout) {
    if (!synthesisBlockIds.contains(block.id)) continue;
    if (!seen.add(block.id)) continue;
    normalized.add(
      SynthesisBlockLayout(
        id: block.id,
        span: synthesisAllowedSpans.contains(block.span)
            ? block.span
            : synthesisGridColumns,
      ),
    );
  }
  for (final id in synthesisBlockIds) {
    if (seen.add(id)) {
      normalized.add(
        SynthesisBlockLayout(id: id, span: synthesisDefaultSpan(id)),
      );
    }
  }
  return normalized;
}

/// Décode une disposition persistée en JSON. Toute chaîne illisible ou de
/// forme inattendue retombe sur la disposition par défaut.
List<SynthesisBlockLayout> parseSynthesisLayout(String? raw) {
  final trimmed = raw?.trim() ?? '';
  if (trimmed.isEmpty) return defaultSynthesisLayout();

  Object? decoded;
  try {
    decoded = jsonDecode(trimmed);
  } on FormatException {
    return defaultSynthesisLayout();
  }
  if (decoded is! List) return defaultSynthesisLayout();

  final blocks = <SynthesisBlockLayout>[];
  for (final item in decoded) {
    if (item is! Map) continue;
    final id = item['id'];
    if (id is! String) continue;
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) continue;
    final span = item['span'];
    blocks.add(
      SynthesisBlockLayout(
        id: trimmedId,
        // Un span absent reprend la largeur par défaut du bloc ; un span
        // présent mais invalide est ramené à 6 colonnes.
        span: span == null
            ? synthesisDefaultSpan(trimmedId)
            : normalizeSynthesisSpan(span),
      ),
    );
  }
  return normalizeSynthesisLayout(blocks);
}

/// Encode une disposition en JSON compact (une entrée par bloc).
String encodeSynthesisLayout(Iterable<SynthesisBlockLayout> layout) =>
    jsonEncode(<Object?>[for (final block in layout) block.toJson()]);

/// Une ligne de la grille : les blocs qu'elle contient et le nombre de
/// colonnes consommées.
class SynthesisRow {
  final List<SynthesisBlockLayout> blocks;
  final int usedColumns;

  const SynthesisRow({required this.blocks, required this.usedColumns});

  int get freeColumns => synthesisGridColumns - usedColumns;

  @override
  String toString() => 'SynthesisRow($blocks, $usedColumns)';
}

/// Répartit les blocs en lignes de [columns] colonnes, dans l'ordre du
/// layout : un bloc dont la largeur dépasse les colonnes restantes passe à la
/// ligne suivante.
List<SynthesisRow> packSynthesisRows(
  Iterable<SynthesisBlockLayout> layout, {
  int columns = synthesisGridColumns,
}) {
  final rows = <SynthesisRow>[];
  var current = <SynthesisBlockLayout>[];
  var used = 0;
  for (final block in layout) {
    final span = block.span.clamp(1, columns);
    if (current.isNotEmpty && used + span > columns) {
      rows.add(
        SynthesisRow(blocks: List.unmodifiable(current), usedColumns: used),
      );
      current = <SynthesisBlockLayout>[];
      used = 0;
    }
    current.add(block);
    used += span;
  }
  if (current.isNotEmpty) {
    rows.add(
      SynthesisRow(blocks: List.unmodifiable(current), usedColumns: used),
    );
  }
  return rows;
}
