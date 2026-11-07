import '../data/csv_import.dart';
import '../models/startup.dart';
import 'startup_portfolio.dart' show normalizeStartupSearch;

/// Détection et fusion des tours de financement d'une même startup.
///
/// Une ligne CSV dont le nom porte un suffixe de tour (« KEEWE ROUND 2 »,
/// « HEXANA - Tranche 2 », « WHEERE - R2 »…) désigne un nouveau tour de la
/// même société, pas une société distincte. Les fonctions ci-dessous sont
/// pures : aucun accès base, horloge ou UI.

/// Tour déduit d'un nom de ligne : nom de base + numéro de tour (≥ 1).
class StartupRoundRef {
  /// Nom de société sans le suffixe de tour, trimé.
  final String base;

  /// Numéro du tour (1 lorsque le nom ne porte aucun suffixe).
  final int round;

  const StartupRoundRef({required this.base, required this.round});

  bool get hasSuffix => round > 1;

  @override
  String toString() => 'StartupRoundRef(base: $base, round: $round)';
}

/// « ROUND 2 », « ROUND 3 », « TOUR 2 », « Tranche 2 », « TRANCH 2 »…
final RegExp _roundWordRe = RegExp(
  r'^(.*?)[\s\-–—:·]+(?:round|tour|tranche|tranch)[\s\-–—:#°n]*(\d{1,3})$',
  caseSensitive: false,
);

/// Forme courte « R2 », « R3 », « - R2 ». Le chiffre doit suivre
/// immédiatement le « R » : un nom comme « Xavier 2 » n'est pas un tour.
final RegExp _roundShortRe = RegExp(
  r'^(.*?)[\s\-–—:·]+r[-–—:#]?(\d{1,3})$',
  caseSensitive: false,
);

/// Suffixe de tour final (sans lui, le nom est un premier tour).
String _stripTrailingSeparators(String s) =>
    s.replaceAll(RegExp(r'[\s\-–—:·]+$'), '').trim();

/// Décompose un nom de startup en (nom de base, numéro de tour).
///
/// Insensible à la casse et aux variantes de séparateurs. Sans suffixe
/// reconnu, le nom est rendu tel quel (trimé) avec `round = 1`.
StartupRoundRef parseStartupRound(String name) {
  final trimmed = name.trim();
  for (final re in [_roundWordRe, _roundShortRe]) {
    final match = re.firstMatch(trimmed);
    if (match == null) continue;
    final base = _stripTrailingSeparators(match.group(1) ?? '');
    final round = int.tryParse(match.group(2) ?? '');
    if (base.isEmpty || round == null || round < 1) continue;
    return StartupRoundRef(base: base, round: round);
  }
  return StartupRoundRef(base: trimmed, round: 1);
}

/// Nom de société sans suffixe de tour (« KEEWE ROUND 2 » -> « KEEWE »).
String baseStartupName(String name) => parseStartupRound(name).base;

/// Clé de regroupement : nom de base normalisé (casse, accents, espaces).
String startupRoundGroupKey(String name) =>
    normalizeStartupSearch(baseStartupName(name));

// ---------------------------------------------------------------------------
// Fusion
// ---------------------------------------------------------------------------

/// Fusionne plusieurs lignes d'une même startup (une par tour) en une fiche.
///
/// - `quantite` et `frais` : sommes ;
/// - `prixEntree` : moyenne pondérée nette Σ(quantité × prix) / Σ quantités ;
/// - `dateInvestissement` : la plus ancienne ;
/// - `valorisationEntreprise` : celle du tour le plus récent (par date) ;
/// - `rounds` : un tour par ligne, trié par date croissante, alimenté par la
///   colonne `levees` de la ligne si elle existe, sinon reconstruit à partir
///   de la ligne (montant brut = prix × quantité + frais).
///
/// Les champs de fiche (instrument, catégorie, stade, prix actuel, statut)
/// suivent le tour le plus récent, avec repli sur les tours précédents ;
/// `institution` et `note` gardent la première valeur renseignée.
CsvImportRow mergeStartupTours(List<CsvImportRow> rows) {
  assert(rows.isNotEmpty, 'mergeStartupTours attend au moins une ligne');
  if (rows.length == 1) return rows.first;

  final ordered = _sortByDate(rows);

  var quantite = 0.0;
  var frais = 0.0;
  var montantNet = 0.0;
  DateTime? dateInvestissement;

  for (final row in rows) {
    final draft = row.startup;
    if (draft == null) continue;
    quantite += draft.quantite;
    frais += draft.frais;
    montantNet += draft.quantite * draft.prixEntree;
    final date = draft.dateInvestissement;
    if (date != null &&
        (dateInvestissement == null || date.isBefore(dateInvestissement))) {
      dateInvestissement = date;
    }
  }

  // Tour le plus récent : la dernière ligne datée, sinon la dernière du CSV.
  final dated = ordered.where((r) => r.startup?.dateInvestissement != null);
  final latest = dated.isNotEmpty ? dated.last : ordered.last;
  final latestDraft = latest.startup;

  final valorisation = _latestValuation(ordered) ?? 0;

  final rounds = <FundingRoundDraft>[];
  for (final row in ordered) {
    rounds.addAll(_roundsOf(row));
  }
  rounds.sort((a, b) {
    final da = a.date;
    final db = b.date;
    if (da == null && db == null) return 0;
    if (da == null) return 1;
    if (db == null) return -1;
    return da.compareTo(db);
  });

  final mergedDraft = StartupDraft(
    typeTitre: _latestNonNull(ordered, (d) => d.typeTitre),
    categorie: _latestNonNull(ordered, (d) => d.categorie),
    quantite: quantite,
    prixEntree: quantite > 0 ? montantNet / quantite : 0,
    frais: frais,
    dateInvestissement: dateInvestissement,
    stade: _latestNonNull(ordered, (d) => d.stade),
    prixActuel: latestDraft?.prixActuel ?? 1,
    dateValorisation: _latestDate(ordered, (d) => d.dateValorisation),
    valorisationEntreprise: valorisation,
    statut: latestDraft?.statut ?? 'en_portefeuille',
    exitDate: _latestDate(ordered, (d) => d.exitDate),
    exitProduit: _exitProduit(ordered),
    exitMode: _latestNonNull(ordered, (d) => d.exitMode),
    note: _mergedNote(ordered),
  );

  return CsvImportRow(
    name: baseStartupName(rows.first.name),
    value: 0,
    currency: rows.first.currency,
    institution: _firstNonNull(rows, (r) => r.institution),
    note: _firstNonNull(rows, (r) => r.note),
    startup: mergedDraft,
    rounds: rounds,
  );
}

/// Regroupe des lignes de startups par nom de base et fusionne les groupes de
/// plusieurs tours. L'ordre d'apparition des sociétés est conservé ; les
/// sociétés à une seule ligne sont rendues inchangées.
List<CsvImportRow> mergeStartupRows(List<CsvImportRow> rows) {
  final groups = <String, List<CsvImportRow>>{};
  for (final row in rows) {
    groups.putIfAbsent(startupRoundGroupKey(row.name), () => []).add(row);
  }

  final merged = <CsvImportRow>[];
  final emitted = <String>{};
  for (final row in rows) {
    final key = startupRoundGroupKey(row.name);
    if (!emitted.add(key)) continue;
    final group = groups[key]!;
    merged.add(group.length == 1 ? group.first : mergeStartupTours(group));
  }
  return merged;
}

// ---------------------------------------------------------------------------
// Aides internes
// ---------------------------------------------------------------------------

/// Tri stable par date d'investissement croissante, lignes non datées à la fin.
List<CsvImportRow> _sortByDate(List<CsvImportRow> rows) {
  final indexed = [
    for (var i = 0; i < rows.length; i++) (index: i, row: rows[i]),
  ];
  indexed.sort((a, b) {
    final da = a.row.startup?.dateInvestissement;
    final db = b.row.startup?.dateInvestissement;
    if (da == null && db == null) return a.index.compareTo(b.index);
    if (da == null) return 1;
    if (db == null) return -1;
    final cmp = da.compareTo(db);
    return cmp != 0 ? cmp : a.index.compareTo(b.index);
  });
  return [for (final e in indexed) e.row];
}

/// Un tour par ligne : la colonne `levees` prime, sinon la ligne est convertie
/// en un tour unique (montant brut = prix net × quantité + frais).
List<FundingRoundDraft> _roundsOf(CsvImportRow row) {
  if (row.rounds.isNotEmpty) return row.rounds;

  final draft = row.startup;
  if (draft == null) return const [];

  final ref = parseStartupRound(row.name);
  final brut = draft.quantite * draft.prixEntree + draft.frais;
  return [
    FundingRoundDraft(
      date: draft.dateInvestissement,
      montantLeve: brut,
      valorisationPostMoney: draft.valorisationEntreprise,
      prixParAction: draft.prixEntree,
      note: ref.hasSuffix ? row.name : null,
    ),
  ];
}

/// Note de la fiche : notes des tours, sans doublon, dans l'ordre chronologique.
String? _mergedNote(List<CsvImportRow> ordered) {
  final seen = <String>{};
  final parts = <String>[];
  for (final row in ordered) {
    final note = row.startup?.note?.trim();
    if (note == null || note.isEmpty || !seen.add(note)) continue;
    parts.add(note);
  }
  return parts.isEmpty ? null : parts.join('\n');
}

/// Valorisation du tour le plus récent, en remontant les tours si elle manque.
double? _latestValuation(List<CsvImportRow> ordered) {
  for (final row in ordered.reversed) {
    final draft = row.startup;
    if (draft == null) continue;
    if (draft.valorisationEntreprise > 0) return draft.valorisationEntreprise;
    for (final round in row.rounds.reversed) {
      if (round.valorisationPostMoney > 0) return round.valorisationPostMoney;
    }
  }
  return null;
}

double _exitProduit(List<CsvImportRow> ordered) {
  for (final row in ordered.reversed) {
    final draft = row.startup;
    if (draft == null) continue;
    if (draft.exitDate != null || draft.exitProduit > 0) return draft.exitProduit;
  }
  return 0;
}

T? _latestNonNull<T>(List<CsvImportRow> ordered, T? Function(StartupDraft) pick) {
  for (final row in ordered.reversed) {
    final draft = row.startup;
    if (draft == null) continue;
    final value = pick(draft);
    if (value != null) return value;
  }
  return null;
}

DateTime? _latestDate(
  List<CsvImportRow> ordered,
  DateTime? Function(StartupDraft) pick,
) => _latestNonNull<DateTime>(ordered, pick);

T? _firstNonNull<T>(List<CsvImportRow> rows, T? Function(CsvImportRow) pick) {
  for (final row in rows) {
    final value = pick(row);
    if (value != null) return value;
  }
  return null;
}
