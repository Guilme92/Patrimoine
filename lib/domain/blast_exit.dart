/// Simulateur de sortie Blast : convertit une valorisation de sortie en valeur
/// des parts détenues, puis en plus-value latente brute et nette.
///
/// Toutes les fonctions sont pures (aucun accès base ni horloge) pour rester
/// testables en Dart pur.
library;

/// Taux d'imposition appliqué à la plus-value brute (prélèvement sur la PV,
/// communiqué par l'utilisateur).
const double blastExitTaxRate = 0.182;

/// Borne basse du simulateur : 500 M€.
const double blastExitValuationMin = 500e6;

/// Borne haute du simulateur : 10 Mrds €.
const double blastExitValuationMax = 10e9;

/// Valeur des parts à une valorisation donnée : `valorisation × détention %`.
double blastShareValue(double valuation, double stakePct) =>
    valuation * (stakePct / 100);

/// Plus-value latente brute : valeur des parts − capital investi.
double blastPvBrute(double valuation, double stakePct, double invested) =>
    blastShareValue(valuation, stakePct) - invested;

/// Plus-value nette : brute − impôt de [blastExitTaxRate] sur la base positive
/// (une moins-value n'est pas fiscalisée).
double blastPvNette(double pvBrute) =>
    pvBrute > 0 ? pvBrute * (1 - blastExitTaxRate) : pvBrute;
