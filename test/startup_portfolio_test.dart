import 'package:flutter_test/flutter_test.dart';
import 'package:patrimoine/data/database.dart';
import 'package:patrimoine/domain/startup_portfolio.dart';

final DateTime _today = DateTime(2025, 1, 1);

Asset _asset(int id, String name) => Asset(
  id: id,
  name: name,
  type: 'startup',
  value: 0,
  currency: 'EUR',
  sortOrder: 0,
  createdAt: DateTime(2026),
);

StartupDetail _detail(
  int id, {
  String? categorie,
  String statut = 'en_portefeuille',
  double quantite = 100,
  double prixEntree = 10,
  double frais = 0,
  double prixActuel = 10,
  DateTime? dateInvestissement,
  double exitProduit = 0,
  DateTime? exitDate,
}) => StartupDetail(
  id: id,
  assetId: id,
  typeTitre: 'actions',
  categorie: categorie,
  quantite: quantite,
  prixEntree: prixEntree,
  frais: frais,
  dateInvestissement: dateInvestissement,
  stade: 'seed',
  prixActuel: prixActuel,
  dateValorisation: DateTime(2026, 1, 1),
  valorisationEntreprise: 1000000,
  statut: statut,
  exitDate: exitDate,
  exitProduit: exitProduit,
  exitMode: statut == 'sorti' ? 'acquisition' : null,
  createdAt: DateTime(2026),
);

StartupEntry _entry(
  int id,
  String name, {
  String? categorie,
  String statut = 'en_portefeuille',
  double quantite = 100,
  double prixEntree = 10,
  double frais = 0,
  double prixActuel = 10,
  DateTime? dateInvestissement,
  double exitProduit = 0,
  DateTime? exitDate,
}) => StartupEntry(
  asset: _asset(id, name),
  detail: _detail(
    id,
    categorie: categorie,
    statut: statut,
    quantite: quantite,
    prixEntree: prixEntree,
    frais: frais,
    prixActuel: prixActuel,
    dateInvestissement: dateInvestissement,
    exitProduit: exitProduit,
    exitDate: exitDate,
  ),
);

/// Portefeuille de référence :
/// - Alpha : Licornes, 1 000 € investis, valorisée 3 000 €, datée 2020.
/// - Beta  : Licornes, 1 000 € investis, valorisée 1 000 €, datée 2022.
/// - Gamma : Europe, 1 000 € investis, sortie à 2 500 € en 2023, datée 2020.
/// - Delta : sans catégorie, 500 € investis, radiée, non datée.
List<StartupEntry> _portfolio() => [
  _entry(
    1,
    'Alpha',
    categorie: 'Licornes pre-IPO',
    prixActuel: 30,
    dateInvestissement: DateTime(2020, 1, 1),
  ),
  _entry(
    2,
    'Beta',
    categorie: 'Licornes pre-IPO',
    dateInvestissement: DateTime(2022, 1, 1),
  ),
  _entry(
    3,
    'Gamma',
    categorie: 'Europe Multi-Stage',
    statut: 'sorti',
    prixActuel: 0,
    exitProduit: 2500,
    dateInvestissement: DateTime(2020, 1, 1),
    exitDate: DateTime(2023, 1, 1),
  ),
  _entry(
    4,
    'Delta',
    categorie: '  ',
    statut: 'radie',
    quantite: 50,
    prixActuel: 0,
  ),
];

void main() {
  group('summarizeStartups', () {
    test('agrège capital, valorisation et plus-values', () {
      final s = summarizeStartups(_portfolio(), today: _today);

      expect(s.totalInvested, 3500);
      expect(s.totalValue, 6500);
      expect(s.unrealizedGain, 2000);
      expect(s.unrealizedGainPct, closeTo(57.142857, 1e-5));
      expect(s.realizedGain, 1500);
      expect(s.moic, closeTo(1.857143, 1e-5));
      expect(s.entries, hasLength(4));
      expect(s.totalCount, 4);
    });

    test('compte les statuts', () {
      final s = summarizeStartups(_portfolio(), today: _today);
      expect(s.activeCount, 2);
      expect(s.exitedCount, 1);
      expect(s.writtenOffCount, 1);
    });

    test('TRI moyen : moyenne arithmétique des lignes datées', () {
      final s = summarizeStartups(_portfolio(), today: _today);
      // Alpha 24,562 % ; Beta 0 % ; Gamma 35,711 % ; Delta non datée exclue.
      expect(s.avgTriPct, closeTo(20.091095, 1e-5));
    });

    test('remplit la valeur par catégorie, vide -> « Sans catégorie »', () {
      final s = summarizeStartups(_portfolio(), today: _today);
      expect(s.valueByCategory['Licornes pre-IPO'], 4000);
      expect(s.valueByCategory['Europe Multi-Stage'], 2500);
      expect(s.valueByCategory['Sans catégorie'], 0);
      expect(s.valueByCategory.keys, hasLength(3));
    });

    test('répartit la valeur par année d\'investissement', () {
      final s = summarizeStartups(_portfolio(), today: _today);
      // 2020 : Alpha (3 000) + Gamma (2 500) ; 2022 : Beta (1 000).
      expect(s.valueByYear, {2020: 5500.0, 2022: 1000.0});
      // Delta n'a pas de date : aucune entrée pour elle.
      expect(s.valueByYear.containsKey(0), isFalse);
    });

    test('calcule un KPI par catégorie', () {
      final s = summarizeStartups(_portfolio(), today: _today);

      final licornes = s.kpiByCategory['Licornes pre-IPO']!;
      expect(licornes.count, 2);
      expect(licornes.invested, 2000);
      expect(licornes.frais, 0);
      expect(licornes.value, 4000);
      expect(licornes.unrealized, 2000);
      expect(licornes.realized, 0);
      expect(licornes.moic, 2);
      expect(licornes.triPct, closeTo(12.280929, 1e-5));

      final europe = s.kpiByCategory['Europe Multi-Stage']!;
      expect(europe.count, 1);
      expect(europe.invested, 1000);
      expect(europe.value, 2500);
      expect(europe.unrealized, 0);
      expect(europe.realized, 1500);
      expect(europe.moic, 2.5);
      expect(europe.triPct, closeTo(35.711426, 1e-5));

      final sansCategorie = s.kpiByCategory['Sans catégorie']!;
      expect(sansCategorie.count, 1);
      expect(sansCategorie.invested, 500);
      expect(sansCategorie.value, 0);
      expect(sansCategorie.realized, 0);
      expect(sansCategorie.moic, 0);
      expect(sansCategorie.triPct, 0);

      expect(s.kpiByCategory.keys, hasLength(3));
    });

    test('somme les frais de toutes les lignes du périmètre', () {
      final entries = [
        _entry(1, 'Alpha', categorie: 'Licornes pre-IPO', frais: 12.5),
        _entry(2, 'Beta', statut: 'sorti', exitProduit: 1200, frais: 7.5),
        _entry(3, 'Gamma', statut: 'radie', frais: 0),
      ];
      final s = summarizeStartups(entries, today: _today);

      expect(s.totalFrais, 20);
      // Les frais restent inclus dans le capital investi de chaque ligne.
      expect(s.totalInvested, 1000 + 12.5 + 1000 + 7.5 + 1000);
    });

    test('agrège les frais par catégorie', () {
      final entries = [
        _entry(1, 'Alpha', categorie: 'Licornes pre-IPO', frais: 12.5),
        _entry(2, 'Beta', categorie: 'Licornes pre-IPO', frais: 7.5),
        _entry(
          3,
          'Gamma',
          categorie: 'Europe Multi-Stage',
          statut: 'sorti',
          exitProduit: 1200,
          frais: 20,
        ),
        _entry(4, 'Delta', categorie: '  ', statut: 'radie', frais: 0),
      ];
      final s = summarizeStartups(entries, today: _today);

      expect(s.kpiByCategory['Licornes pre-IPO']!.frais, 20);
      expect(s.kpiByCategory['Europe Multi-Stage']!.frais, 20);
      expect(s.kpiByCategory['Sans catégorie']!.frais, 0);
      // Les frais d'une catégorie restent inclus dans son capital investi.
      expect(s.kpiByCategory['Licornes pre-IPO']!.invested, 2000 + 20);

      // La somme des frais par catégorie redonne le total du périmètre.
      final sumByCategory = s.kpiByCategory.values.fold<double>(
        0,
        (sum, kpi) => sum + kpi.frais,
      );
      expect(sumByCategory, s.totalFrais);
      expect(sumByCategory, 40);
    });

    test('portefeuille vide : tous les agrégats à zéro', () {
      final s = summarizeStartups([]);
      expect(s.totalInvested, 0);
      expect(s.totalFrais, 0);
      expect(s.totalValue, 0);
      expect(s.unrealizedGain, 0);
      expect(s.unrealizedGainPct, 0);
      expect(s.realizedGain, 0);
      expect(s.moic, 0);
      expect(s.avgTriPct, 0);
      expect(s.activeCount, 0);
      expect(s.exitedCount, 0);
      expect(s.writtenOffCount, 0);
      expect(s.valueByCategory, isEmpty);
      expect(s.valueByYear, isEmpty);
      expect(s.kpiByCategory, isEmpty);
      expect(s.entries, isEmpty);
    });

    test('le TRI ignore les lignes sans date ou sans capital', () {
      final entries = [
        _entry(
          1,
          'Datée',
          categorie: 'Licornes pre-IPO',
          prixActuel: 20,
          dateInvestissement: DateTime(2020, 1, 1),
        ),
        _entry(2, 'Sans date', categorie: 'Licornes pre-IPO', prixActuel: 50),
        _entry(
          3,
          'Sans capital',
          categorie: 'Licornes pre-IPO',
          quantite: 0,
          prixEntree: 0,
          prixActuel: 0,
          dateInvestissement: DateTime(2021, 1, 1),
        ),
      ];
      final s = summarizeStartups(entries, today: _today);
      // Seule la première ligne entre dans la moyenne :
      // (2000 / 1000)^(1/5,002) − 1 = 14,863 %.
      expect(s.avgTriPct, closeTo(14.863299, 1e-5));
      expect(s.kpiByCategory['Licornes pre-IPO']!.triPct, s.avgTriPct);
      expect(s.moic, 7000 / 2000);
      expect(s.unrealizedGain, 1000 + 4000); // active lines only
    });

    test('les lignes radiées valent zéro et n\'ont pas de PV latente', () {
      final entries = [
        _entry(
          1,
          'Perdue',
          categorie: 'Europe Multi-Stage',
          statut: 'radie',
          prixActuel: 99,
          dateInvestissement: DateTime(2021, 1, 1),
        ),
      ];
      final s = summarizeStartups(entries, today: _today);
      expect(s.totalInvested, 1000);
      expect(s.totalValue, 0);
      expect(s.unrealizedGain, 0);
      expect(s.realizedGain, 0);
      expect(s.moic, 0);
      expect(s.writtenOffCount, 1);
      expect(s.unrealizedGainPct, 0);
    });
  });

  group('startupCategoryKey', () {
    test('normalise les catégories vides', () {
      expect(startupCategoryKey(null), 'Sans catégorie');
      expect(startupCategoryKey(''), 'Sans catégorie');
      expect(startupCategoryKey('   '), 'Sans catégorie');
      expect(startupCategoryKey('  Licornes pre-IPO '), 'Licornes pre-IPO');
    });
  });

  group('recherche par nom', () {
    test('insensible à la casse, aux accents et sur sous-chaîne', () {
      expect(startupNameMatches('Éco-Logic', 'eco'), isTrue);
      expect(startupNameMatches('eco-logic', 'ÉCO'), isTrue);
      expect(startupNameMatches('Gamma', 'gämma'), isTrue);
      expect(startupNameMatches('Ma Société', 'soci'), isTrue);
      expect(startupNameMatches('Gamma', 'delta'), isFalse);
    });

    test('une requête vide accepte toutes les lignes', () {
      expect(startupNameMatches('Gamma', ''), isTrue);
      expect(startupNameMatches('Gamma', '   '), isTrue);
    });

    test('normalise la requête (minuscules, sans accents, bords retirés)', () {
      expect(normalizeStartupSearch('  ÉCO-Logic '), 'eco-logic');
    });
  });
}
