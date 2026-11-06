import 'package:drift/drift.dart' show Value;

import '../data/database.dart';
import '../utils/choice.dart';

/// Valeurs de `StartupDetails.typeTitre`.
const List<String> startupInstruments = [
  'actions',
  'actions_preference',
  'bsa',
  'bsa_air',
  'bspce',
  'obligations_convertibles',
  'safe',
  'autre',
];

String startupInstrumentLabel(String? s) {
  switch (s) {
    case 'actions':
      return 'Actions ordinaires';
    case 'actions_preference':
      return 'Actions de préférence';
    case 'bsa':
      return 'BSA';
    case 'bsa_air':
      return 'BSA-AIR';
    case 'bspce':
      return 'BSPCE';
    case 'obligations_convertibles':
      return 'Obligations convertibles';
    case 'safe':
      return 'SAFE';
    case 'autre':
      return 'Autre';
    default:
      return 'Non renseigné';
  }
}

/// Catégories proposées pour une startup (import Blast, portefeuilles
/// thématiques…). La valeur est stockée telle quelle dans
/// `StartupDetails.categorie`.
const List<String> startupCategories = [
  'Licornes pre-IPO',
  'Europe Multi-Stage',
  'Y Combinator Series A',
  'Y Combinator Seed Selection',
];

/// Libellé affiché pour une catégorie (vide -> « Non renseigné »).
String startupCategoryLabel(String? c) {
  final t = c?.trim();
  return (t == null || t.isEmpty) ? 'Non renseigné' : t;
}

/// Valeurs de `StartupDetails.stade`.
const List<String> startupStages = [
  'seed',
  'serie_a',
  'serie_b',
  'serie_c',
  'late_stage',
  'autre',
];

String startupStageLabel(String? s) {
  switch (s) {
    case 'seed':
      return 'Amorçage (seed)';
    case 'serie_a':
      return 'Série A';
    case 'serie_b':
      return 'Série B';
    case 'serie_c':
      return 'Série C';
    case 'late_stage':
      return 'Late stage';
    case 'autre':
      return 'Autre';
    default:
      return 'Non renseigné';
  }
}

/// Valeurs de `StartupDetails.statut`.
const List<String> startupStatuses = ['en_portefeuille', 'sorti', 'radie'];

String startupStatusLabel(String? s) {
  switch (s) {
    case 'en_portefeuille':
      return 'En portefeuille';
    case 'sorti':
      return 'Sorti';
    case 'radie':
      return 'Radié (perte totale)';
    default:
      return 'Non renseigné';
  }
}

/// Valeurs de `StartupDetails.exitMode`.
const List<String> startupExitModes = [
  'acquisition',
  'ipo',
  'secondaire',
  'liquidation',
  'autre',
];

String startupExitModeLabel(String? s) {
  switch (s) {
    case 'acquisition':
      return 'Acquisition';
    case 'ipo':
      return 'Introduction en bourse (IPO)';
    case 'secondaire':
      return 'Marché secondaire';
    case 'liquidation':
      return 'Liquidation';
    case 'autre':
      return 'Autre';
    default:
      return 'Non renseigné';
  }
}

/// Normalise l'instrument détenu (« actions de préférence » ->
/// `actions_preference`).
String? normalizeStartupInstrument(String? raw) =>
    matchChoice(raw, startupInstruments, startupInstrumentLabel);

/// Normalise le stade (« Série A » -> `serie_a`).
String? normalizeStartupStage(String? raw) =>
    matchChoice(raw, startupStages, startupStageLabel);

/// Normalise le statut (« Sorti » -> `sorti`).
String? normalizeStartupStatus(String? raw) =>
    matchChoice(raw, startupStatuses, startupStatusLabel);

/// Normalise le mode de sortie (« IPO » -> `ipo`).
String? normalizeStartupExitMode(String? raw) =>
    matchChoice(raw, startupExitModes, startupExitModeLabel);

String? _blankToNull(String? v) {
  final t = v?.trim();
  return (t == null || t.isEmpty) ? null : t;
}

/// Données saisies dans le formulaire startup, converties en companion drift.
class StartupDraft {
  final String? typeTitre;
  final String? categorie;
  final double quantite;
  final double prixEntree;
  final double frais;
  final DateTime? dateInvestissement;
  final String? stade;
  final double prixActuel;
  final DateTime? dateValorisation;
  final double valorisationEntreprise;
  final String statut;
  final DateTime? exitDate;
  final double exitProduit;
  final String? exitMode;
  final String? note;

  const StartupDraft({
    this.typeTitre,
    this.categorie,
    this.quantite = 0,
    this.prixEntree = 0,
    this.frais = 0,
    this.dateInvestissement,
    this.stade,
    this.prixActuel = 0,
    this.dateValorisation,
    this.valorisationEntreprise = 0,
    this.statut = 'en_portefeuille',
    this.exitDate,
    this.exitProduit = 0,
    this.exitMode,
    this.note,
  });

  factory StartupDraft.fromDetail(StartupDetail s) => StartupDraft(
    typeTitre: s.typeTitre,
    categorie: s.categorie,
    quantite: s.quantite,
    prixEntree: s.prixEntree,
    frais: s.frais,
    dateInvestissement: s.dateInvestissement,
    stade: s.stade,
    prixActuel: s.prixActuel,
    dateValorisation: s.dateValorisation,
    valorisationEntreprise: s.valorisationEntreprise,
    statut: s.statut,
    exitDate: s.exitDate,
    exitProduit: s.exitProduit,
    exitMode: s.exitMode,
    note: s.note,
  );

  StartupDetailsCompanion toCompanion(int assetId) => StartupDetailsCompanion.insert(
    assetId: assetId,
    typeTitre: Value(_blankToNull(typeTitre)),
    categorie: Value(_blankToNull(categorie)),
    quantite: Value(quantite),
    prixEntree: Value(prixEntree),
    frais: Value(frais),
    dateInvestissement: Value(dateInvestissement),
    stade: Value(_blankToNull(stade)),
    prixActuel: Value(prixActuel),
    dateValorisation: Value(dateValorisation),
    valorisationEntreprise: Value(valorisationEntreprise),
    statut: Value(statut),
    exitDate: Value(exitDate),
    exitProduit: Value(exitProduit),
    exitMode: Value(_blankToNull(exitMode)),
    note: Value(_blankToNull(note)),
  );
}

/// Levée de fonds saisie dans l'interface.
class FundingRoundDraft {
  final DateTime? date;
  final double montantLeve;
  final double valorisationPostMoney;
  final double prixParAction;
  final String? note;

  const FundingRoundDraft({
    this.date,
    this.montantLeve = 0,
    this.valorisationPostMoney = 0,
    this.prixParAction = 0,
    this.note,
  });

  FundingRoundsCompanion toCompanion(int assetId) =>
      FundingRoundsCompanion.insert(
        assetId: assetId,
        date: Value(date),
        montantLeve: Value(montantLeve),
        valorisationPostMoney: Value(valorisationPostMoney),
        prixParAction: Value(prixParAction),
        note: Value(_blankToNull(note)),
      );
}
