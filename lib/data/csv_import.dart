import 'package:csv/csv.dart';

import '../models/asset_type.dart';
import '../models/rental.dart';
import '../models/startup.dart';
import '../utils/choice.dart';

/// Résultat d'un import CSV.
class CsvImportResult {
  final int imported;
  final int skipped;
  const CsvImportResult({required this.imported, required this.skipped});

  int get total => imported + skipped;

  @override
  String toString() => 'CsvImportResult(imported: $imported, skipped: $skipped)';
}

/// Une ligne CSV normalisée, prête à être insérée par le contrôleur.
class CsvImportRow {
  final String name;
  final double value;
  final String currency;
  final String? institution;
  final String? note;
  final RentalDraft? rental;
  final StartupDraft? startup;
  final List<FundingRoundDraft> rounds;

  const CsvImportRow({
    required this.name,
    required this.value,
    required this.currency,
    this.institution,
    this.note,
    this.rental,
    this.startup,
    this.rounds = const [],
  });
}

/// Lignes valides + nombre de lignes ignorées (nom vide).
class CsvParseResult {
  final List<CsvImportRow> rows;
  final int skipped;
  const CsvParseResult({required this.rows, required this.skipped});

  bool get isEmpty => rows.isEmpty;
}

// ---------------------------------------------------------------------------
// Détection du type de fichier
// ---------------------------------------------------------------------------

/// Clés d'en-tête normalisées (snake_case) du fichier CSV.
List<String> csvHeaderKeys(String input) {
  final table = _decodeTable(input);
  return table == null ? const [] : table.header.keys.toList();
}

/// Détecte le type d'import d'après les colonnes présentes :
/// `loyer_hc` -> immobilier, `quantite`/`type_titre` -> startup.
AssetType? detectCsvAssetType(String input) {
  final keys = csvHeaderKeys(input).toSet();
  if (keys.contains('loyer_hc')) return AssetType.realEstate;
  if (keys.contains('quantite') || keys.contains('type_titre')) {
    return AssetType.startup;
  }
  return null;
}

// ---------------------------------------------------------------------------
// Parsing immobilier
// ---------------------------------------------------------------------------

const Set<String> _rentalKeys = {
  'statut',
  'type_bail',
  'locataire',
  'loyer_hc',
  'charges_locatives',
  'depot_garantie',
  'date_debut_bail',
  'date_fin_bail',
  'mode_gestion',
  'frais_gestion',
  'taxe_fonciere',
  'assurance_pno',
  'charges_copropriete',
  'travaux_entretien',
  'vacance_locative',
  'note_location',
  'a_un_credit',
  'montant_credit',
  'taux_credit_pct',
  'mensualite_credit',
  'duree_credit_mois',
  'capital_restant_du',
  'assurance_emprunteur',
};

CsvParseResult parseRealEstateCsv(String input) {
  final table = _decodeTable(input);
  if (table == null) return const CsvParseResult(rows: [], skipped: 0);

  final rows = <CsvImportRow>[];
  var skipped = 0;
  for (final cells in table.rows) {
    final row = _Row(table.header, cells);
    final name = row.text('nom');
    if (name == null) {
      skipped++;
      continue;
    }
    rows.add(
      CsvImportRow(
        name: name,
        value: row.number('valeur'),
        currency: (row.text('devise') ?? 'EUR').toUpperCase(),
        institution: row.text('etablissement'),
        note: row.text('note'),
        rental: row.hasAny(_rentalKeys)
            ? RentalDraft(
                statut: normalizeRentalStatus(row.text('statut')) ?? 'vacant',
                typeBail: normalizeRentalLeaseType(row.text('type_bail')),
                locataire: row.text('locataire'),
                loyerHc: row.number('loyer_hc'),
                chargesLocatives: row.number('charges_locatives'),
                depotGarantie: row.number('depot_garantie'),
                dateDebutBail: row.date('date_debut_bail'),
                dateFinBail: row.date('date_fin_bail'),
                modeGestion: normalizeRentalManagementMode(
                  row.text('mode_gestion'),
                ),
                fraisGestion: row.number('frais_gestion'),
                taxeFonciere: row.number('taxe_fonciere'),
                assurancePno: row.number('assurance_pno'),
                chargesCopropriete: row.number('charges_copropriete'),
                travauxEntretien: row.number('travaux_entretien'),
                vacanceLocative: row.number('vacance_locative'),
                note: row.text('note_location'),
                aUnCredit: row.flag('a_un_credit'),
                montantCredit: row.number('montant_credit'),
                tauxCreditPct: row.number('taux_credit_pct'),
                mensualiteCredit: row.number('mensualite_credit'),
                dureeCreditMois: row.number('duree_credit_mois').round(),
                capitalRestantDu: row.number('capital_restant_du'),
                assuranceEmprunteur: row.number('assurance_emprunteur'),
              )
            : null,
      ),
    );
  }
  return CsvParseResult(rows: rows, skipped: skipped);
}

// ---------------------------------------------------------------------------
// Parsing startups
// ---------------------------------------------------------------------------

CsvParseResult parseStartupCsv(String input) {
  final table = _decodeTable(input);
  if (table == null) return const CsvParseResult(rows: [], skipped: 0);

  final rows = <CsvImportRow>[];
  var skipped = 0;
  for (final cells in table.rows) {
    final row = _Row(table.header, cells);
    final name = row.text('nom');
    if (name == null) {
      skipped++;
      continue;
    }
    final statut = normalizeStartupStatus(row.text('statut'));
    rows.add(
      CsvImportRow(
        name: name,
        value: 0,
        currency: 'EUR',
        institution: row.text('etablissement'),
        note: row.text('note'),
        startup: StartupDraft(
          typeTitre: normalizeStartupInstrument(row.text('type_titre')),
          quantite: row.number('quantite'),
          prixEntree: row.number('prix_entree'),
          frais: row.number('frais'),
          dateInvestissement: row.date('date_investissement'),
          stade: normalizeStartupStage(row.text('stade')),
          prixActuel: row.number('prix_actuel'),
          dateValorisation: row.date('date_valorisation'),
          valorisationEntreprise: row.number('valorisation_entreprise'),
          statut: statut ?? 'en_portefeuille',
          exitDate: row.date('date_sortie'),
          exitProduit: row.number('produit_sortie'),
          exitMode: normalizeStartupExitMode(row.text('mode_sortie')),
        ),
        rounds: parseFundingRounds(row.text('levees')),
      ),
    );
  }
  return CsvParseResult(rows: rows, skipped: skipped);
}

/// Décode la colonne `levees` : rounds séparés par « ; », chaque round au
/// format `date|montant_leve|valorisation_post_money|prix_par_action`.
List<FundingRoundDraft> parseFundingRounds(String? raw) {
  if (raw == null || raw.trim().isEmpty) return const [];
  final rounds = <FundingRoundDraft>[];
  for (final chunk in raw.split(';')) {
    if (chunk.trim().isEmpty) continue;
    final parts = chunk.split('|').map((e) => e.trim()).toList();
    rounds.add(
      FundingRoundDraft(
        date: parseCsvDate(parts.isNotEmpty ? parts[0] : null),
        montantLeve: parseCsvNumber(parts.length > 1 ? parts[1] : null) ?? 0,
        valorisationPostMoney:
            parseCsvNumber(parts.length > 2 ? parts[2] : null) ?? 0,
        prixParAction: parseCsvNumber(parts.length > 3 ? parts[3] : null) ?? 0,
      ),
    );
  }
  return rounds;
}

// ---------------------------------------------------------------------------
// Conversions élémentaires (exposées pour les tests)
// ---------------------------------------------------------------------------

/// Nombre tolérant : virgule décimale, espaces, « € », « 1 234,56 ».
double? parseCsvNumber(String? raw) {
  if (raw == null) return null;
  var t = raw
      .trim()
      .replaceAll('\u00A0', '')
      .replaceAll(' ', '')
      .replaceAll('€', '')
      .replaceAll('%', '');
  if (t.isEmpty) return null;
  final hasComma = t.contains(',');
  final hasDot = t.contains('.');
  if (hasComma && hasDot) {
    if (t.lastIndexOf(',') > t.lastIndexOf('.')) {
      // 1.234,56 : le point sépare les milliers.
      t = t.replaceAll('.', '').replaceAll(',', '.');
    } else {
      // 1,234.56 : la virgule sépare les milliers.
      t = t.replaceAll(',', '');
    }
  } else if (hasComma) {
    t = t.replaceAll(',', '.');
  }
  return double.tryParse(t);
}

/// Date au format `YYYY-MM-DD`, avec tolérance `DD/MM/YYYY`.
DateTime? parseCsvDate(String? raw) {
  if (raw == null) return null;
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return null;
  final cleaned = trimmed.split(RegExp(r'[T ]')).first;

  if (cleaned.contains('/')) {
    final parts = cleaned.split('/');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    var year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    if (year < 100) year += 2000;
    return _safeDate(year, month, day);
  }

  final parts = cleaned.split('-');
  if (parts.length != 3) return null;
  final year = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final day = int.tryParse(parts[2]);
  if (day == null || month == null || year == null) return null;
  return _safeDate(year, month, day);
}

DateTime? _safeDate(int year, int month, int day) {
  if (month < 1 || month > 12 || day < 1 || day > 31) return null;
  final date = DateTime(year, month, day);
  if (date.month != month || date.day != day) return null;
  return date;
}

/// Booléen tolérant : « oui », « true », « 1 », « vrai », « yes ».
bool parseCsvBool(String? raw) {
  final t = (raw ?? '').trim().toLowerCase();
  return t == 'oui' || t == 'true' || t == '1' || t == 'vrai' || t == 'yes' ||
      t == 'o';
}

// ---------------------------------------------------------------------------
// Décodage CSV et accès aux cellules
// ---------------------------------------------------------------------------

class _Table {
  final Map<String, int> header;
  final List<List<String>> rows;
  _Table(this.header, this.rows);
}

_Table? _decodeTable(String input) {
  final text = input.startsWith('\uFEFF') ? input.substring(1) : input;
  if (text.trim().isEmpty) return null;
  final decoded = Csv().decode(text);
  if (decoded.isEmpty) return null;

  final headerCells = decoded.first.map((c) => c?.toString() ?? '').toList();
  final header = <String, int>{};
  for (var i = 0; i < headerCells.length; i++) {
    final key = _headerKey(headerCells[i]);
    if (key.isNotEmpty) header.putIfAbsent(key, () => i);
  }

  final rows = <List<String>>[];
  for (final raw in decoded.skip(1)) {
    final cells = raw.map((c) => c?.toString() ?? '').toList();
    if (cells.every((c) => c.trim().isEmpty)) continue;
    rows.add(cells);
  }
  return _Table(header, rows);
}

String _headerKey(String raw) {
  return stripAccents(raw)
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');
}

class _Row {
  final Map<String, int> header;
  final List<String> cells;
  const _Row(this.header, this.cells);

  String? text(String key) {
    final index = header[key];
    if (index == null || index >= cells.length) return null;
    final value = cells[index].trim();
    return value.isEmpty ? null : value;
  }

  double number(String key) => parseCsvNumber(text(key)) ?? 0;

  DateTime? date(String key) => parseCsvDate(text(key));

  bool flag(String key) => parseCsvBool(text(key));

  bool hasAny(Set<String> keys) => keys.any((k) => text(k) != null);
}
