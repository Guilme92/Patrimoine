import '../data/database.dart';

/// Indicateurs de rentabilité d'une location.
///
/// Convention : les montants annuels de `chargesCopropriete`, `taxeFonciere`,
/// `assurancePno` et `travauxEntretien` sont annuels ; `fraisGestion`,
/// `vacanceLocative` (perte de loyer) et `assuranceEmprunteur` sont mensuels.

double annualGrossRent(Rental r) => r.loyerHc * 12;

/// Charges annuelles supportées par le propriétaire.
double annualOwnerCharges(Rental r) =>
    r.chargesLocatives * 12 +
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

/// Cashflow mensuel : loyer − charges − mensualité de crédit.
double monthlyCashflow(Rental r) =>
    r.loyerHc - monthlyOwnerCharges(r) - monthlyLoanPayment(r);

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
