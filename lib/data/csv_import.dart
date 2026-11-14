import 'package:csv/csv.dart';

import '../domain/startup_rounds.dart';
import '../models/asset_type.dart';
import '../models/rental.dart';
import '../models/startup.dart';
import '../utils/choice.dart';

/// Résultat d'un import CSV.
class CsvImportResult {
  final int imported;
  final int updated;
  final int skipped;
  const CsvImportResult({
    required this.imported,
    this.updated = 0,
    required this.skipped,
  });

  int get total => imported + updated + skipped;

  @override
  String toString() =>
      'CsvImportResult(imported: $imported, updated: $updated, skipped: $skipped)';
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
  final List<SecondaryTransactionDraft> secondaryTransactions;

  const CsvImportRow({
    required this.name,
    required this.value,
    required this.currency,
    this.institution,
    this.note,
    this.rental,
    this.startup,
    this.rounds = const [],
    this.secondaryTransactions = const [],
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
/// `loyer_hc` -> immobilier, `quantite`/`type_titre`/`instrument` -> startup.
AssetType? detectCsvAssetType(String input) {
  final keys = csvHeaderKeys(input).toSet();
  if (keys.contains('loyer_hc')) return AssetType.realEstate;
  if (keys.contains('quantite') ||
      keys.contains('type_titre') ||
      keys.contains('instrument') ||
      keys.contains('montant_investi_eur') ||
      keys.contains('lien_blast')) {
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

/// Parse un CSV de startups : template historique (`type_titre`, `prix_entree`,
/// `note`, `levees`…) et export Blast enrichi (`categorie`, `instrument`,
/// `montant_investi_eur`, `prix_entree_eur`, `valorisation_entree_eur`,
/// `valorisation_entree`, `lien_blast`). Les colonnes historiques restent
/// prioritaires lorsqu'elles sont renseignées.
///
/// Les lignes d'une même société portant un suffixe de tour (« KEEWE »,
/// « KEEWE ROUND 2 »…) sont fusionnées en une seule fiche (voir
/// [mergeStartupRows]).
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
    final quantite = row.number('quantite');

    // Prix d'entrée : colonne historique, alias Blast, puis montant investi
    // réparti sur la quantité (0 si la quantité est inconnue).
    var prixEntree = row.number('prix_entree');
    if (prixEntree == 0) prixEntree = row.number('prix_entree_eur');
    if (prixEntree == 0) {
      final montantInvesti = row.number('montant_investi_eur');
      if (montantInvesti != 0 && quantite != 0) {
        prixEntree = montantInvesti / quantite;
      }
    }

    // Valorisation : colonne historique, puis alias Blast.
    var valorisationEntreprise = row.number('valorisation_entreprise');
    if (valorisationEntreprise == 0) {
      valorisationEntreprise = row.number('valorisation_entree_eur');
    }

    // Note enrichie : note d'origine, précision texte sur la valorisation
    // (si aucune valorisation chiffrée), lien vers la fiche Blast.
    final noteParts = <String>[];
    final baseNote = row.text('note');
    if (baseNote != null) noteParts.add(baseNote);
    final valorisationTexte = row.text('valorisation_entree');
    if (valorisationEntreprise == 0 && valorisationTexte != null) {
      noteParts.add(valorisationTexte);
    }
    final lienBlast = row.text('lien_blast');
    if (lienBlast != null) noteParts.add('Blast: $lienBlast');
    final note = noteParts.isEmpty ? null : noteParts.join('\n');

    // Prix actuel par défaut : 1 €/action si non renseigné.
    var prixActuel = row.number('prix_actuel');
    if (row.text('prix_actuel') == null) prixActuel = 1;

    rows.add(
      CsvImportRow(
        name: name,
        value: 0,
        currency: 'EUR',
        institution: row.text('etablissement'),
        note: baseNote,
        startup: StartupDraft(
          typeTitre:
              normalizeStartupInstrument(row.text('type_titre')) ??
              _blastInstrument(row.text('instrument')),
          categorie: row.text('categorie'),
          quantite: quantite,
          prixEntree: prixEntree,
          frais: row.number('frais'),
          montantInvesti: row.number('montant_investi_eur'),
          dateInvestissement: row.date('date_investissement'),
          stade: normalizeStartupStage(row.text('stade')),
          prixActuel: prixActuel,
          dateValorisation: row.date('date_valorisation'),
          valorisationEntreprise: valorisationEntreprise,
          statut: statut ?? 'en_portefeuille',
          exitDate: row.date('date_sortie'),
          exitProduit: row.number('produit_sortie'),
          exitMode: normalizeStartupExitMode(row.text('mode_sortie')),
          note: note,
        ),
        rounds: parseFundingRounds(row.text('levees')),
        secondaryTransactions: parseSecondaryTransactions(
          row.text('marche_secondaire'),
        ),
      ),
    );
  }
  return CsvParseResult(rows: mergeStartupRows(rows), skipped: skipped);
}

/// Traduit l'instrument d'un export Blast (`SAFE`, `Actions`) vers le
/// vocabulaire interne ; toute autre valeur reste non renseignée.
String? _blastInstrument(String? raw) {
  final t = raw?.trim().toLowerCase();
  if (t == null || t.isEmpty) return null;
  if (t == 'safe' || t.startsWith('safe ')) return 'safe';
  if (t == 'actions' || t == 'action' || t.startsWith('action ')) {
    return 'actions';
  }
  return null;
}

/// Décode la colonne `levees` : rounds séparés par « ; », chaque round au
/// format `date|montant|valorisation_pre_money|prix|valorisation_post_money|dilution`.
///
/// Le 3e champ est la valorisation PRE-money : c'est ce que fournit l'export
/// Blast (« valorisation » = pre-money, `montant` = votre part investie).
/// Les champs post-money (5e) et dilution (6e) sont optionnels : absents, ils
/// valent 0 (ancien format à 4 champs toujours accepté).
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
        valorisationPreMoney:
            parseCsvNumber(parts.length > 2 ? parts[2] : null) ?? 0,
        prixParAction: parseCsvNumber(parts.length > 3 ? parts[3] : null) ?? 0,
        valorisationPostMoney:
            parseCsvNumber(parts.length > 4 ? parts[4] : null) ?? 0,
        dilution: parseCsvNumber(parts.length > 5 ? parts[5] : null) ?? 0,
      ),
    );
  }
  return rounds;
}

/// Décode la colonne `marche_secondaire` : transactions séparées par « ; »,
/// chacune au format `date|type|actions|prix|frais|commission_pv`
/// (type : achat | revente).
///
/// Ex. `2025-10-27|revente|500|3,29|0,00|229,00`.
///
/// Tolérances :
/// - champ absent ou vide → 0 (frais et commission sont souvent omis) ;
/// - date invalide → transaction conservée, non datée ;
/// - type inconnu ou vide → transaction ignorée ;
/// - ancien format `date|type|montant` (3 champs) → le 3e champ est interprété
///   comme le montant payé/reçu, sans détail chiffré.
List<SecondaryTransactionDraft> parseSecondaryTransactions(String? raw) {
  if (raw == null || raw.trim().isEmpty) return const [];
  final transactions = <SecondaryTransactionDraft>[];
  for (final chunk in raw.split(';')) {
    if (chunk.trim().isEmpty) continue;
    final parts = chunk.split('|').map((e) => e.trim()).toList();
    final type = normalizeSecondaryTransactionType(
      parts.length > 1 ? parts[1] : null,
    );
    if (type == null) continue;

    final montantOuActions = parseCsvNumber(
      parts.length > 2 ? parts[2] : null,
    );
    // Un 4e champ (prix) signe le format enrichi ; sinon on retombe sur
    // l'ancien format où le 3e champ était le montant global.
    final hasDetail = parts.length > 3;
    final prix = hasDetail ? parseCsvNumber(parts[3]) ?? 0 : 0.0;
    final frais = hasDetail
        ? (parts.length > 4 ? parseCsvNumber(parts[4]) ?? 0 : 0.0)
        : 0.0;
    final commissionPv = hasDetail
        ? (parts.length > 5 ? parseCsvNumber(parts[5]) ?? 0 : 0.0)
        : 0.0;

    transactions.add(
      SecondaryTransactionDraft(
        date: parseCsvDate(parts.isNotEmpty ? parts[0] : null),
        type: type,
        actions: hasDetail ? (montantOuActions ?? 0).round() : 0,
        prix: prix,
        frais: frais,
        commissionPv: commissionPv,
        montant: hasDetail ? null : montantOuActions,
      ),
    );
  }
  return transactions;
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
