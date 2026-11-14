import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrimoine/controllers/portfolio_controller.dart';
import 'package:patrimoine/data/csv_import.dart';
import 'package:patrimoine/data/csv_templates.dart';
import 'package:patrimoine/data/database.dart';
import 'package:patrimoine/models/asset_type.dart';
import 'package:patrimoine/models/rental.dart';
import 'package:patrimoine/models/startup.dart';

final String _immoCsv = [
  realEstateCsvHeader,
  'Appartement Lyon,250000,EUR,Crédit Mutuel,Apport 2021,loué,bail meublé,'
      'M. Dupont,900,50,1800,2024-01-01,31/12/2026,Agence,60,1200,240,600,'
      '300,0,Bail 2024,oui,200000,2.5,700,180,150000,30',
  ',150000,EUR',
  'Studio Villeurbanne,120000,eur,,,loue,vide,,550',
].join('\n');

final String _startupCsv = [
  startupCsvHeader,
  'Qonto,Boursorama,Crowdfunding,actions,100,10,50,2021-05-01,Série B,25,'
      '2025-01-15,5000000,en portefeuille,,,,'
      '2023-01-15|500000|5000000|10;2024-06-01|2000000|25000000|25',
  'Sortie SAS,,,BSPCE,10,5,0,01/02/2020,seed,0,,0,sorti,2024-01-01,3000,'
      'acquisition,',
].join('\n');

/// Export Blast enrichi : la quantité et le montant investi remplacent le
/// prix d'entrée, la catégorie et le lien enrichissent la fiche.
final String _blastCsv = [
  'nom,categorie,instrument,quantite,montant_investi_eur,'
      'date_investissement,valorisation_entree_eur,valorisation_entree,'
      'statut,lien_blast',
  'Mistral AI,Europe Multi-Stage,SAFE,100,10000,2024-03-01,5000000,'
      'SAFE · -10 % prochain tour,en_portefeuille,'
      'https://blast.example/mistral',
  'Qonto,Licornes pre-IPO,Actions,50,,2023-06-15,,,en portefeuille,',
].join('\n');

/// Export « Excel FR » : séparateur `;`, décimales à virgule et colonne
/// `levees` citée — elle contient elle-même des `;` (séparateur de tours) et
/// des virgules (décimales), d'où les guillemets obligatoires.
final String _keeweQuotedCsv = [
  'nom;etablissement;quantite;prix_entree;date_investissement;levees',
  'KEEWE;;100;290,16;2024-03-01;'
      '"2024-03-01|290,16|10000000|1,0000;2026-04-30|520,00|26000000|1,0000"',
].join('\n');

/// Même startup, fichier à séparateur `,` (en-tête du modèle) et levées citées.
final String _keeweV1 = [
  startupCsvHeader,
  'KEEWE,,,actions,100,290.16,0,2023-06-01,serie_a,500,2026-04-30,26000000,'
      'en portefeuille,,,,"2023-06-01|150,00|5000000|0,5000"',
].join('\n');

/// Ré-import : trois tours, dont deux nouveaux, et l'ancien tour (2023-06-01)
/// qui doit disparaître.
final String _keeweV2 = [
  startupCsvHeader,
  'KEEWE,,,actions,120,290.16,0,2024-03-01,serie_a,520,2026-04-30,26000000,'
      'en portefeuille,,,,"2024-03-01|290,16|10000000|1,0000;'
      '2025-09-15|400,00|18000000|1,5000;2026-04-30|520,00|26000000|1,0000"',
].join('\n');

void main() {
  group('conversions élémentaires', () {
    test('nombres : virgule, espaces, milliers, symboles', () {
      expect(parseCsvNumber('1 234,56'), closeTo(1234.56, 1e-9));
      expect(parseCsvNumber('1.234,56'), closeTo(1234.56, 1e-9));
      expect(parseCsvNumber('1,234.56'), closeTo(1234.56, 1e-9));
      expect(parseCsvNumber('900 €'), 900);
      expect(parseCsvNumber('12.5%'), 12.5);
      expect(parseCsvNumber(''), isNull);
      expect(parseCsvNumber(null), isNull);
    });

    test('dates : ISO et JJ/MM/AAAA, invalides ignorées', () {
      expect(parseCsvDate('2024-01-15'), DateTime(2024, 1, 15));
      expect(parseCsvDate('15/01/2024'), DateTime(2024, 1, 15));
      expect(parseCsvDate('15/01/24'), DateTime(2024, 1, 15));
      expect(parseCsvDate('2024-01-15T10:30:00'), DateTime(2024, 1, 15));
      expect(parseCsvDate('31/02/2024'), isNull);
      expect(parseCsvDate('n/a'), isNull);
      expect(parseCsvDate(null), isNull);
    });

    test('booléens a_un_credit', () {
      expect(parseCsvBool('oui'), isTrue);
      expect(parseCsvBool('OUI'), isTrue);
      expect(parseCsvBool('true'), isTrue);
      expect(parseCsvBool('1'), isTrue);
      expect(parseCsvBool('non'), isFalse);
      expect(parseCsvBool(''), isFalse);
      expect(parseCsvBool(null), isFalse);
    });
  });

  group('normalisation des énumérations', () {
    test('location : clé ou libellé français', () {
      expect(normalizeRentalStatus('loué'), 'loue');
      expect(normalizeRentalStatus('Loué'), 'loue');
      expect(normalizeRentalStatus('vacant'), 'vacant');
      expect(normalizeRentalStatus("n'importe quoi"), isNull);
      expect(normalizeRentalLeaseType('meublé'), 'meuble');
      expect(normalizeRentalLeaseType('bail meublé'), 'meuble');
      expect(normalizeRentalLeaseType('Bail vide (non meublé)'), 'vide');
      expect(normalizeRentalLeaseType('commercial'), 'commercial');
      expect(normalizeRentalLeaseType(''), isNull);
      expect(normalizeRentalManagementMode('Agence'), 'agence');
      expect(normalizeRentalManagementMode('Gestion directe'), 'direct');
    });

    test('startup : clé ou libellé français', () {
      expect(normalizeStartupInstrument('Actions de préférence'),
          'actions_preference');
      expect(normalizeStartupInstrument('BSPCE'), 'bspce');
      expect(normalizeStartupInstrument('BSA-AIR'), 'bsa_air');
      expect(normalizeStartupInstrument('Obligations convertibles'),
          'obligations_convertibles');
      expect(normalizeStartupStage('Série A'), 'serie_a');
      expect(normalizeStartupStage('Amorçage (seed)'), 'seed');
      expect(normalizeStartupStage('Late stage'), 'late_stage');
      expect(normalizeStartupStatus('en portefeuille'), 'en_portefeuille');
      expect(normalizeStartupStatus('Radié (perte totale)'), 'radie');
      expect(normalizeStartupExitMode('Introduction en bourse (IPO)'), 'ipo');
      expect(normalizeStartupExitMode('Marché secondaire'), 'secondaire');
    });
  });

  group('détection du type de fichier', () {
    test('colonnes immobilier / startup / inconnues', () {
      expect(detectCsvAssetType(_immoCsv), AssetType.realEstate);
      expect(detectCsvAssetType(_startupCsv), AssetType.startup);
      expect(detectCsvAssetType('nom,valeur\nA,1'), isNull);
      expect(detectCsvAssetType(''), isNull);
    });
  });

  group('parsing immobilier', () {
    test('chaque colonne est reprise dans l\'actif et la location', () {
      final parsed = parseRealEstateCsv(_immoCsv);
      expect(parsed.rows, hasLength(2));
      expect(parsed.skipped, 1); // la ligne sans nom est ignorée

      final row = parsed.rows.first;
      expect(row.name, 'Appartement Lyon');
      expect(row.value, 250000);
      expect(row.currency, 'EUR');
      expect(row.institution, 'Crédit Mutuel');
      expect(row.note, 'Apport 2021');

      final rental = row.rental!;
      expect(rental.statut, 'loue');
      expect(rental.typeBail, 'meuble');
      expect(rental.locataire, 'M. Dupont');
      expect(rental.loyerHc, 900);
      expect(rental.chargesLocatives, 50);
      expect(rental.depotGarantie, 1800);
      expect(rental.dateDebutBail, DateTime(2024, 1, 1));
      expect(rental.dateFinBail, DateTime(2026, 12, 31));
      expect(rental.modeGestion, 'agence');
      expect(rental.fraisGestion, 60);
      expect(rental.taxeFonciere, 1200);
      expect(rental.assurancePno, 240);
      expect(rental.chargesCopropriete, 600);
      expect(rental.travauxEntretien, 300);
      expect(rental.vacanceLocative, 0);
      expect(rental.note, 'Bail 2024');
      expect(rental.aUnCredit, isTrue);
      expect(rental.montantCredit, 200000);
      expect(rental.tauxCreditPct, 2.5);
      expect(rental.mensualiteCredit, 700);
      expect(rental.dureeCreditMois, 180);
      expect(rental.capitalRestantDu, 150000);
      expect(rental.assuranceEmprunteur, 30);
    });

    test('une ligne sans donnée de location ne crée pas de fiche', () {
      final parsed = parseRealEstateCsv('nom,valeur\nGarage,15000\n');
      expect(parsed.rows, hasLength(1));
      expect(parsed.rows.single.rental, isNull);
      expect(parsed.rows.single.value, 15000);
    });

    test('fichier exporté par Excel (séparateur « ; » et virgule décimale)', () {
      const export = 'nom;valeur;devise;loyer_hc;charges_locatives\n'
          'Garage;15000;EUR;450,50;20,25\n';
      expect(detectCsvAssetType(export), AssetType.realEstate);

      final parsed = parseRealEstateCsv(export);
      expect(parsed.rows, hasLength(1));
      final row = parsed.rows.single;
      expect(row.name, 'Garage');
      expect(row.value, 15000);
      expect(row.rental!.loyerHc, closeTo(450.50, 1e-9));
      expect(row.rental!.chargesLocatives, closeTo(20.25, 1e-9));
    });
  });

  group('parsing startups', () {
    test('fiche, champs et levées sérialisées', () {
      final parsed = parseStartupCsv(_startupCsv);
      expect(parsed.rows, hasLength(2));
      expect(parsed.skipped, 0);

      final qonto = parsed.rows.first;
      expect(qonto.name, 'Qonto');
      expect(qonto.institution, 'Boursorama');
      expect(qonto.note, 'Crowdfunding');
      final s = qonto.startup!;
      expect(s.typeTitre, 'actions');
      expect(s.quantite, 100);
      expect(s.prixEntree, 10);
      expect(s.frais, 50);
      expect(s.dateInvestissement, DateTime(2021, 5, 1));
      expect(s.stade, 'serie_b');
      expect(s.prixActuel, 25);
      expect(s.dateValorisation, DateTime(2025, 1, 15));
      expect(s.valorisationEntreprise, 5000000);
      expect(s.statut, 'en_portefeuille');
      expect(s.categorie, isNull);
      expect(s.note, 'Crowdfunding');

      expect(qonto.rounds, hasLength(2));
      expect(qonto.rounds.first.date, DateTime(2023, 1, 15));
      expect(qonto.rounds.first.montantLeve, 500000);
      expect(qonto.rounds.first.valorisationPostMoney, 5000000);
      expect(qonto.rounds.first.prixParAction, 10);
      expect(qonto.rounds.last.date, DateTime(2024, 6, 1));
      expect(qonto.rounds.last.montantLeve, 2000000);

      final sortie = parsed.rows.last;
      expect(sortie.startup!.statut, 'sorti');
      expect(sortie.startup!.exitMode, 'acquisition');
      expect(sortie.startup!.exitDate, DateTime(2024, 1, 1));
      expect(sortie.startup!.exitProduit, 3000);
      expect(sortie.rounds, isEmpty);
    });

    test('colonne levees absente ou vide', () {
      expect(parseFundingRounds(null), isEmpty);
      expect(parseFundingRounds('  '), isEmpty);
      expect(parseFundingRounds('2023-01-15|500000'), hasLength(1));
      expect(parseFundingRounds('2023-01-15|500000|5000000|10;'),
          hasLength(1));
    });

    test('colonne levees enrichie : pre-money et dilution', () {
      // Ancien format à 4 champs : pre-money et dilution valent 0.
      final legacy = parseFundingRounds('2023-01-15|500000|5000000|10').single;
      expect(legacy.valorisationPreMoney, 0);
      expect(legacy.dilution, 0);

      // Nouveau format à 6 champs : pre-money et dilution sont lus.
      final enriched = parseFundingRounds(
        '2024-11-07|2718,45|15000000|1,0052|27000000|18,2',
      ).single;
      expect(enriched.montantLeve, closeTo(2718.45, 1e-9));
      expect(enriched.valorisationPostMoney, 15000000);
      expect(enriched.prixParAction, closeTo(1.0052, 1e-9));
      expect(enriched.valorisationPreMoney, 27000000);
      expect(enriched.dilution, closeTo(18.2, 1e-9));
    });

    test('colonne levees citée (séparateur « ; », décimales à virgule)',
        () {
      // Le champ cité contient des « ; » : il ne doit pas être découpé en
      // colonnes, et les tours restent séparés par « ; » dans la valeur.
      expect(detectCsvAssetType(_keeweQuotedCsv), AssetType.startup);
      final parsed = parseStartupCsv(_keeweQuotedCsv);
      expect(parsed.skipped, 0);
      expect(parsed.rows, hasLength(1));

      final row = parsed.rows.single;
      expect(row.name, 'KEEWE');
      expect(row.startup!.quantite, 100);
      expect(row.startup!.prixEntree, closeTo(290.16, 1e-9));

      expect(row.rounds, hasLength(2));
      expect(row.rounds.first.date, DateTime(2024, 3, 1));
      expect(row.rounds.first.montantLeve, closeTo(290.16, 1e-9));
      expect(row.rounds.first.valorisationPostMoney, 10000000);
      expect(row.rounds.first.prixParAction, 1);
      expect(row.rounds.last.date, DateTime(2026, 4, 30));
      expect(row.rounds.last.montantLeve, closeTo(520, 1e-9));
      expect(row.rounds.last.valorisationPostMoney, 26000000);
      expect(row.rounds.last.prixParAction, 1);
    });

    test('export Blast enrichi : catégorie, instrument, montant, lien', () {
      expect(detectCsvAssetType(_blastCsv), AssetType.startup);
      final parsed = parseStartupCsv(_blastCsv);
      expect(parsed.rows, hasLength(2));
      expect(parsed.skipped, 0);

      final mistral = parsed.rows.first.startup!;
      expect(mistral.categorie, 'Europe Multi-Stage');
      expect(mistral.typeTitre, 'safe');
      expect(mistral.quantite, 100);
      // 10 000 € investis pour 100 titres -> 100 € l'unité.
      expect(mistral.prixEntree, closeTo(100, 1e-9));
      expect(mistral.dateInvestissement, DateTime(2024, 3, 1));
      expect(mistral.valorisationEntreprise, 5000000);
      expect(mistral.statut, 'en_portefeuille');
      // La valorisation chiffrée existe : le texte libre reste hors note.
      expect(mistral.note, 'Blast: https://blast.example/mistral');

      final qonto = parsed.rows.last.startup!;
      expect(qonto.categorie, 'Licornes pre-IPO');
      expect(qonto.typeTitre, 'actions');
      expect(qonto.quantite, 50);
      // Ni montant ni prix unitaire : le prix d'entrée reste à 0.
      expect(qonto.prixEntree, 0);
      expect(qonto.valorisationEntreprise, 0);
      expect(qonto.note, isNull);
    });

    test('export Blast : alias prix_entree_eur et texte de valorisation', () {
      const csv = 'nom,instrument,quantite,prix_entree_eur,'
          'valorisation_entree,note\n'
          'Alan,SAFE,200,12.5,SAFE · -20 % prochain tour,Apport 2024\n';
      final s = parseStartupCsv(csv).rows.single.startup!;
      expect(s.typeTitre, 'safe');
      expect(s.prixEntree, closeTo(12.5, 1e-9));
      expect(s.valorisationEntreprise, 0);
      expect(s.categorie, isNull);
      // Sans valorisation chiffrée, le texte Blast rejoint la note.
      expect(s.note, 'Apport 2024\nSAFE · -20 % prochain tour');
    });

    test('prix actuel : 1 €/action par défaut si non renseigné', () {
      const csv = 'nom,quantite,prix_entree\nStartup A,100,2\n';
      final s = parseStartupCsv(csv).rows.single.startup!;
      expect(s.prixActuel, 1);
    });
  });

  group('import en base via le contrôleur', () {
    late AppDatabase db;
    late PortfolioController controller;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      controller = PortfolioController(db);
    });

    tearDown(() => db.close());

    test('immobilier : actifs, fiches de location et ordre manuel', () async {
      final result = await controller.importCsv(
        csv: _immoCsv,
        type: AssetType.realEstate,
      );

      expect(result.imported, 2);
      expect(result.skipped, 1);

      final assets = await db.allAssets();
      expect(assets.map((a) => a.name).toList(),
          ['Appartement Lyon', 'Studio Villeurbanne']);
      expect(assets.every((a) => a.type == 'realEstate'), isTrue);
      expect(assets.map((a) => a.sortOrder).toList(), [1, 2]);

      final rental = await db.rentalFor(assets.first.id);
      expect(rental, isNotNull);
      expect(rental!.loyerHc, 900);
      expect(rental.aUnCredit, isTrue);
      expect(rental.typeBail, 'meuble');

      final second = await db.rentalFor(assets.last.id);
      expect(second!.statut, 'loue');
      expect(second.aUnCredit, isFalse);
      expect(second.loyerHc, 550);

      // Le contrôleur a bien rechargé son état après l'import.
      expect(controller.assets, hasLength(2));
      expect(controller.summary.netWorth, 370000);
    });

    test('startups : fiche + levées, avec un seul rechargement', () async {
      var notifications = 0;
      controller.addListener(() => notifications++);

      final result = await controller.importCsv(
        csv: _startupCsv,
        type: AssetType.startup,
      );

      expect(result.imported, 2);
      expect(result.skipped, 0);

      final assets = await db.allAssets();
      expect(assets.map((a) => a.name).toList(), ['Qonto', 'Sortie SAS']);

      final detail = await db.startupDetailsFor(assets.first.id);
      expect(detail, isNotNull);
      expect(detail!.quantite, 100);
      expect(detail.stade, 'serie_b');
      expect(await db.fundingRoundsFor(assets.first.id), hasLength(2));

      final exited = await db.startupDetailsFor(assets.last.id);
      expect(exited!.statut, 'sorti');
      expect(exited.exitProduit, 3000);

      // load() notifie 2 fois (début + fin), pas une fois par ligne.
      expect(notifications, lessThanOrEqualTo(2));
      expect(controller.assets, hasLength(2));
    });

    test('startups Blast : catégorie et montant persistés en base', () async {
      final result = await controller.importCsv(
        csv: _blastCsv,
        type: AssetType.startup,
      );
      expect(result.imported, 2);
      expect(result.skipped, 0);

      final assets = await db.allAssets();
      final detail = await db.startupDetailsFor(assets.first.id);
      expect(detail, isNotNull);
      expect(detail!.categorie, 'Europe Multi-Stage');
      expect(detail.typeTitre, 'safe');
      expect(detail.prixEntree, closeTo(100, 1e-9));
      expect(detail.valorisationEntreprise, 5000000);
      expect(detail.note, contains('https://blast.example/mistral'));
    });

    test('ré-import : met à jour au lieu de dupliquer', () async {
      final first = await controller.importCsv(
        csv: _blastCsv,
        type: AssetType.startup,
      );
      expect(first.imported, 2);
      expect(first.updated, 0);

      // Second import du même fichier : tout doit être mis à jour, sans doublon.
      final second = await controller.importCsv(
        csv: _blastCsv,
        type: AssetType.startup,
      );
      expect(second.imported, 0);
      expect(second.updated, 2);

      final assets = await db.allAssets();
      expect(assets, hasLength(2));
    });

    test('ré-import : les levées de fonds sont remplacées, sans orpheline',
        () async {
      final first = await controller.importCsv(
        csv: _keeweV1,
        type: AssetType.startup,
      );
      expect(first.imported, 1);
      expect(first.updated, 0);

      final assets = await db.allAssets();
      expect(assets, hasLength(1));
      final assetId = assets.single.id;
      final initial = await db.fundingRoundsFor(assetId);
      expect(initial, hasLength(1));
      expect(initial.single.date, DateTime(2023, 6, 1));

      // Ré-import de la MÊME startup : la fiche est mise à jour et les tours
      // remplacés (l'ancien tour du 01/06/2023 ne doit pas subsister).
      final second = await controller.importCsv(
        csv: _keeweV2,
        type: AssetType.startup,
      );
      expect(second.imported, 0);
      expect(second.updated, 1);
      expect(await db.allAssets(), hasLength(1));

      final detail = await db.startupDetailsFor(assetId);
      expect(detail!.quantite, 120);

      final rounds = await db.fundingRoundsFor(assetId);
      expect(rounds, hasLength(3));
      expect(rounds.map((r) => r.date).toList(), [
        DateTime(2026, 4, 30),
        DateTime(2025, 9, 15),
        DateTime(2024, 3, 1),
      ]);
      expect(rounds[0].montantLeve, closeTo(520, 1e-9));
      expect(rounds[0].valorisationPostMoney, closeTo(26000000, 1e-9));
      expect(rounds[1].montantLeve, closeTo(400, 1e-9));
      expect(rounds[1].valorisationPostMoney, closeTo(18000000, 1e-9));
      expect(rounds[1].prixParAction, closeTo(1.5, 1e-9));
      expect(rounds[2].montantLeve, closeTo(290.16, 1e-9));

      // Aucune levée orpheline : la table ne contient que ces trois tours.
      final all = await db.allFundingRounds();
      expect(all, hasLength(3));
      expect(all.every((r) => r.assetId == assetId), isTrue);
      expect(all.where((r) => r.date == DateTime(2023, 6, 1)), isEmpty);
    });

    test('ré-import sans levées : les tours existants sont conservés', () async {
      await controller.importCsv(csv: _keeweV2, type: AssetType.startup);
      final assetId = (await db.allAssets()).single.id;
      expect(await db.fundingRoundsFor(assetId), hasLength(3));

      // Fiche mise à jour, colonne `levees` vide : on ne supprime rien.
      final noRounds = [
        startupCsvHeader,
        'KEEWE,,,actions,150,290.16,0,2024-03-01,serie_a,520,2026-04-30,'
            '26000000,en portefeuille,,,,',
      ].join('\n');
      final result = await controller.importCsv(
        csv: noRounds,
        type: AssetType.startup,
      );
      expect(result.imported, 0);
      expect(result.updated, 1);
      expect((await db.startupDetailsFor(assetId))!.quantite, 150);
      expect(await db.fundingRoundsFor(assetId), hasLength(3));
    });

    test('un fichier vide ou sans nom n\'insère rien', () async {
      final empty = await controller.importCsv(csv: '', type: AssetType.startup);
      expect(empty.imported, 0);
      expect(empty.skipped, 0);

      final noName = await controller.importCsv(
        csv: 'nom,valeur\n,1000\n',
        type: AssetType.realEstate,
      );
      expect(noName.imported, 0);
      expect(noName.skipped, 1);
      expect(await db.allAssets(), isEmpty);
    });
  });

  group('modèles CSV livrés', () {
    test('les fichiers d\'assets reprennent les en-têtes attendus', () {
      final immo = File('assets/templates/$realEstateTemplateName')
          .readAsStringSync()
          .trim();
      final startups = File('assets/templates/$startupTemplateName')
          .readAsStringSync()
          .trim();

      expect(immo, realEstateCsvHeader);
      expect(startups, startupCsvHeader);

      // Les modèles sont des en-têtes seuls : aucune ligne de données.
      expect(immo.split('\n'), hasLength(1));
      expect(startups.split('\n'), hasLength(1));
      expect(immo, contains('loyer_hc'));
      expect(startups, contains('levees'));
    });

    test('le modèle immobilier est importable tel quel (0 ligne)', () {
      final header = File(
        'assets/templates/$realEstateTemplateName',
      ).readAsStringSync();
      final parsed = parseRealEstateCsv(header);
      expect(parsed.rows, isEmpty);
      expect(detectCsvAssetType(header), AssetType.realEstate);
    });
  });
}
