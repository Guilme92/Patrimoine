import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrimoine/data/database.dart';
import 'package:patrimoine/domain/rental.dart';
import 'package:patrimoine/models/rental.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

Rental _rental({
  String statut = 'loue',
  double loyerHc = 900,
  double chargesLocatives = 50,
  double fraisGestion = 60,
  double taxeFonciere = 1200,
  double assurancePno = 240,
  double chargesCopropriete = 600,
  double travauxEntretien = 300,
  double vacanceLocative = 0,
  bool aUnCredit = true,
  double mensualiteCredit = 700,
  double assuranceEmprunteur = 30,
  double capitalRestantDu = 120000,
}) => Rental(
  id: 1,
  assetId: 1,
  statut: statut,
  typeBail: 'vide',
  locataire: 'M. Dupont',
  loyerHc: loyerHc,
  chargesLocatives: chargesLocatives,
  depotGarantie: 1800,
  dateDebutBail: DateTime(2025, 1, 1),
  dateFinBail: DateTime(2027, 12, 31),
  modeGestion: 'direct',
  fraisGestion: fraisGestion,
  taxeFonciere: taxeFonciere,
  assurancePno: assurancePno,
  chargesCopropriete: chargesCopropriete,
  travauxEntretien: travauxEntretien,
  vacanceLocative: vacanceLocative,
  note: null,
  aUnCredit: aUnCredit,
  montantCredit: 180000,
  tauxCreditPct: 2.5,
  mensualiteCredit: mensualiteCredit,
  dureeCreditMois: 180,
  capitalRestantDu: capitalRestantDu,
  assuranceEmprunteur: assuranceEmprunteur,
  createdAt: DateTime(2026),
);

void main() {
  group('indicateurs de location', () {
    test('loyer annuel et rendement brut', () {
      final r = _rental();
      expect(annualGrossRent(r), 10800);
      expect(grossYieldPct(r, 200000), closeTo(5.4, 1e-9));
    });

    test('rendement protégé contre une valeur nulle', () {
      final r = _rental();
      expect(grossYieldPct(r, 0), 0);
      expect(netYieldPct(r, 0), 0);
    });

    test('charges annuelles et mensualisées', () {
      final r = _rental();
      // 50*12 + 1200 + 240 + 600 + 300 + 60*12 = 3660
      expect(annualOwnerCharges(r), 3660);
      expect(monthlyOwnerCharges(r), closeTo(305, 1e-9));
    });

    test('cashflow mensuel avec crédit', () {
      final r = _rental();
      // 900 - 305 - (700 + 30)
      expect(monthlyLoanPayment(r), 730);
      expect(monthlyCashflow(r), closeTo(-135, 1e-9));
      expect(annualCashflow(r), closeTo(-1620, 1e-9));
    });

    test('cashflow mensuel sans crédit', () {
      final r = _rental(aUnCredit: false);
      expect(monthlyLoanPayment(r), 0);
      expect(monthlyCashflow(r), closeTo(595, 1e-9));
      expect(outstandingLoan(r), 0);
    });

    test('rendement net de charges', () {
      final r = _rental();
      expect(netYieldPct(r, 200000), closeTo(3.57, 1e-9));
    });
  });

  group('RentalDraft', () {
    test('convertit les champs vides en NULL', () {
      const draft = RentalDraft(locataire: '   ', typeBail: '');
      final c = draft.toCompanion(7);
      expect(c.assetId.value, 7);
      expect(c.locataire.value, isNull);
      expect(c.typeBail.value, isNull);
    });

    test('aller-retour depuis une fiche existante', () {
      final r = _rental();
      final d = RentalDraft.fromRental(r);
      expect(d.loyerHc, 900);
      expect(d.aUnCredit, isTrue);
      expect(d.dateDebutBail, DateTime(2025, 1, 1));
      expect(
        RentalDraft.fromRental(r).toCompanion(1).mensualiteCredit.value,
        700,
      );
    });
  });

  group('persistance', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting(
        NativeDatabase.memory(
          setup: (raw) => raw.execute('PRAGMA foreign_keys = ON'),
        ),
      );
    });

    tearDown(() => db.close());

    test('crée puis met à jour une seule fiche de location', () async {
      final assetId = await db.addAsset(
        AssetsCompanion.insert(
          name: 'Appartement Lyon',
          type: 'realEstate',
          value: const Value(200000),
        ),
      );

      await db.saveRental(const RentalDraft(loyerHc: 900).toCompanion(assetId));
      var r = await db.rentalFor(assetId);
      expect(r, isNotNull);
      expect(r!.loyerHc, 900);
      expect(r.statut, 'vacant');

      await db.saveRental(
        RentalDraft(
          statut: 'loue',
          loyerHc: 950,
          aUnCredit: true,
          mensualiteCredit: 700,
        ).toCompanion(assetId),
      );

      r = await db.rentalFor(assetId);
      expect(r!.loyerHc, 950);
      expect(r.statut, 'loue');
      expect(await db.allRentals(), hasLength(1));
    });

    test('documents : ajout, lecture et suppression', () async {
      final assetId = await db.addAsset(
        AssetsCompanion.insert(
          name: 'Résidence secondaire',
          type: 'realEstate',
        ),
      );
      final docId = await db.addDocument(
        DocumentsCompanion.insert(
          assetId: assetId,
          label: 'Bail signé',
          fileName: 'bail.pdf',
          filePath: '/tmp/documents/$assetId/bail.pdf',
          note: const Value('Bail 2025'),
        ),
      );

      final docs = await db.documentsFor(assetId);
      expect(docs, hasLength(1));
      expect(docs.single.label, 'Bail signé');
      expect(docs.single.note, 'Bail 2025');

      await db.deleteDocument(docId);
      expect(await db.documentsFor(assetId), isEmpty);
    });

    test('la suppression d\'un actif supprime location et documents', () async {
      final assetId = await db.addAsset(
        AssetsCompanion.insert(name: 'Studio', type: 'realEstate'),
      );
      await db.saveRental(const RentalDraft(loyerHc: 500).toCompanion(assetId));
      await db.addDocument(
        DocumentsCompanion.insert(
          assetId: assetId,
          label: 'Bail',
          fileName: 'bail.pdf',
          filePath: '/tmp/bail.pdf',
        ),
      );

      await db.deleteAsset(assetId);

      expect(await db.allRentals(), isEmpty);
      expect(await db.allDocuments(), isEmpty);
    });
  });

  group('migration v1 -> v2', () {
    test(
      'ajoute les tables location et documents sans perdre les actifs',
      () async {
        final dir = await Directory.systemTemp.createTemp('patrimoine_migr');
        final file = File('${dir.path}/v1.sqlite');

        final raw = sqlite.sqlite3.open(file.path);
        raw.execute('''
        CREATE TABLE assets (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          type TEXT NOT NULL,
          value REAL NOT NULL DEFAULT 0,
          currency TEXT NOT NULL DEFAULT 'EUR',
          institution TEXT,
          note TEXT,
          created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
        );
      ''');
        raw.execute(
          "INSERT INTO assets (name, type, value) VALUES ('Livret A', 'cash', 5000)",
        );
        raw.execute('PRAGMA user_version = 1');
        raw.close();

        final db = AppDatabase.forTesting(NativeDatabase(file));
        final assets = await db.allAssets();
        expect(assets, hasLength(1));
        expect(assets.single.name, 'Livret A');
        expect(await db.allRentals(), isEmpty);
        expect(await db.allDocuments(), isEmpty);

        // Les nouvelles tables sont utilisables après migration.
        await db.saveRental(
          const RentalDraft(loyerHc: 800).toCompanion(assets.single.id),
        );
        expect((await db.rentalFor(assets.single.id))!.loyerHc, 800);

        await db.close();
        await dir.delete(recursive: true);
      },
    );
  });
}
