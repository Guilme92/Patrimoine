import '../data/database.dart';

/// Indicateurs de rentabilité d'une location.
///
/// Convention : les montants annuels de `chargesCopropriete`, `taxeFonciere`,
/// `assurancePno` et `travauxEntretien` sont annuels ; `fraisGestion`,
/// `vacanceLocative` (perte de loyer) et `assuranceEmprunteur` sont mensuels.

double annualGrossRent(Rental r) => r.loyerHc * 12;

/// Charges annuelles supportées par le propriétaire.
///
/// Les charges locatives sont exclues : elles sont refacturées au locataire
/// et comptent donc comme un revenu, pas comme une charge du propriétaire.
double annualOwnerCharges(Rental r) =>
    r.taxeFonciere +
    r.assurancePno +
    r.chargesCopropriete +
    r.travauxEntretien +
    r.fraisGestion * 12 +
    r.vacanceLocative * 12;

double monthlyOwnerCharges(Rental r) => annualOwnerCharges(r) / 12;

/// Mensualité de crédit (assurance emprunteur incluse) si un crédit existe.
double monthlyLoanPayment(Rental r) =>
    r.aUnCredit ? r.mensualiteCredit + r.assuranceEmprunteur : 0;

/// Revenu locatif mensuel encaissé : loyer hors charges + charges locatives
/// refacturées au locataire.
double monthlyRentalIncome(Rental r) => r.loyerHc + r.chargesLocatives;

/// Cashflow mensuel : revenu locatif − charges du propriétaire − mensualité
/// de crédit.
double monthlyCashflow(Rental r) =>
    monthlyRentalIncome(r) - monthlyOwnerCharges(r) - monthlyLoanPayment(r);

double annualCashflow(Rental r) => monthlyCashflow(r) * 12;

/// Rendement brut : loyer annuel hors charges / valeur du bien.
double grossYieldPct(Rental r, double assetValue) {
  if (assetValue <= 0) return 0;
  return annualGrossRent(r) / assetValue * 100;
}

/// Rendement net de charges : (loyer annuel − charges annuelles) / valeur.
double netYieldPct(Rental r, double assetValue) {
  if (assetValue <= 0) return 0;
  return (annualGrossRent(r) - annualOwnerCharges(r)) / assetValue * 100;
}

/// Capital restant dû, ou 0 si pas de crédit.
double outstandingLoan(Rental r) => r.aUnCredit ? r.capitalRestantDu : 0;
