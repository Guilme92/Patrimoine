import 'package:drift/drift.dart' show Value;

import '../data/database.dart';

/// Valeurs de `Rentals.statut`.
const List<String> rentalStatuses = ['loue', 'vacant', 'autre'];

String rentalStatusLabel(String? s) {
  switch (s) {
    case 'loue':
      return 'Loué';
    case 'vacant':
      return 'Vacant';
    case 'autre':
      return 'Autre';
    default:
      return 'Non renseigné';
  }
}

/// Valeurs de `Rentals.typeBail`.
const List<String> rentalLeaseTypes = [
  'vide',
  'meuble',
  'commercial',
  'saisonnier',
  'colocation',
  'autre',
];

String rentalLeaseTypeLabel(String? s) {
  switch (s) {
    case 'vide':
      return 'Bail vide (non meublé)';
    case 'meuble':
      return 'Bail meublé';
    case 'commercial':
      return 'Commercial';
    case 'saisonnier':
      return 'Saisonnier';
    case 'colocation':
      return 'Colocation';
    case 'autre':
      return 'Autre';
    default:
      return 'Non renseigné';
  }
}

/// Valeurs de `Rentals.modeGestion`.
const List<String> rentalManagementModes = ['direct', 'agence', 'autre'];

String rentalManagementModeLabel(String? s) {
  switch (s) {
    case 'direct':
      return 'Gestion directe';
    case 'agence':
      return 'Agence';
    case 'autre':
      return 'Autre';
    default:
      return 'Non renseigné';
  }
}

String? _blankToNull(String? v) {
  final t = v?.trim();
  return (t == null || t.isEmpty) ? null : t;
}

/// Données saisies dans le formulaire de location, converties en companion
/// drift pour la persistance.
class RentalDraft {
  final String statut;
  final String? typeBail;
  final String? locataire;
  final double loyerHc;
  final double chargesLocatives;
  final double depotGarantie;
  final DateTime? dateDebutBail;
  final DateTime? dateFinBail;
  final String? modeGestion;
  final double fraisGestion;
  final double taxeFonciere;
  final double assurancePno;
  final double chargesCopropriete;
  final double travauxEntretien;
  final double vacanceLocative;
  final String? note;
  final bool aUnCredit;
  final double montantCredit;
  final double tauxCreditPct;
  final double mensualiteCredit;
  final int dureeCreditMois;
  final double capitalRestantDu;
  final double assuranceEmprunteur;

  const RentalDraft({
    this.statut = 'vacant',
    this.typeBail,
    this.locataire,
    this.loyerHc = 0,
    this.chargesLocatives = 0,
    this.depotGarantie = 0,
    this.dateDebutBail,
    this.dateFinBail,
    this.modeGestion,
    this.fraisGestion = 0,
    this.taxeFonciere = 0,
    this.assurancePno = 0,
    this.chargesCopropriete = 0,
    this.travauxEntretien = 0,
    this.vacanceLocative = 0,
    this.note,
    this.aUnCredit = false,
    this.montantCredit = 0,
    this.tauxCreditPct = 0,
    this.mensualiteCredit = 0,
    this.dureeCreditMois = 0,
    this.capitalRestantDu = 0,
    this.assuranceEmprunteur = 0,
  });

  factory RentalDraft.fromRental(Rental r) => RentalDraft(
    statut: r.statut,
    typeBail: r.typeBail,
    locataire: r.locataire,
    loyerHc: r.loyerHc,
    chargesLocatives: r.chargesLocatives,
    depotGarantie: r.depotGarantie,
    dateDebutBail: r.dateDebutBail,
    dateFinBail: r.dateFinBail,
    modeGestion: r.modeGestion,
    fraisGestion: r.fraisGestion,
    taxeFonciere: r.taxeFonciere,
    assurancePno: r.assurancePno,
    chargesCopropriete: r.chargesCopropriete,
    travauxEntretien: r.travauxEntretien,
    vacanceLocative: r.vacanceLocative,
    note: r.note,
    aUnCredit: r.aUnCredit,
    montantCredit: r.montantCredit,
    tauxCreditPct: r.tauxCreditPct,
    mensualiteCredit: r.mensualiteCredit,
    dureeCreditMois: r.dureeCreditMois,
    capitalRestantDu: r.capitalRestantDu,
    assuranceEmprunteur: r.assuranceEmprunteur,
  );

  RentalsCompanion toCompanion(int assetId) => RentalsCompanion.insert(
    assetId: assetId,
    statut: Value(statut),
    typeBail: Value(_blankToNull(typeBail)),
    locataire: Value(_blankToNull(locataire)),
    loyerHc: Value(loyerHc),
    chargesLocatives: Value(chargesLocatives),
    depotGarantie: Value(depotGarantie),
    dateDebutBail: Value(dateDebutBail),
    dateFinBail: Value(dateFinBail),
    modeGestion: Value(_blankToNull(modeGestion)),
    fraisGestion: Value(fraisGestion),
    taxeFonciere: Value(taxeFonciere),
    assurancePno: Value(assurancePno),
    chargesCopropriete: Value(chargesCopropriete),
    travauxEntretien: Value(travauxEntretien),
    vacanceLocative: Value(vacanceLocative),
    note: Value(_blankToNull(note)),
    aUnCredit: Value(aUnCredit),
    montantCredit: Value(montantCredit),
    tauxCreditPct: Value(tauxCreditPct),
    mensualiteCredit: Value(mensualiteCredit),
    dureeCreditMois: Value(dureeCreditMois),
    capitalRestantDu: Value(capitalRestantDu),
    assuranceEmprunteur: Value(assuranceEmprunteur),
  );
}
