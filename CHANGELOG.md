# Notes de version — Patrimoine

Les 14 builds de Patrimoine, du premier MVP au suivi multi-tours des startups : un historique complet des fonctionnalités livrées, build par build.

## Table des matières

- **[Phase 1 — Fondations](#phase-1--fondations)**
  - [Build 1 — MVP initial (5 novembre 2026)](#build-1--mvp-initial-5-novembre-2026)
  - [Build 2 — Builds automatiques Windows et Android (5 novembre 2026)](#build-2--builds-automatiques-windows-et-android-5-novembre-2026)
  - [Build 3 — APK allégé (5 novembre 2026)](#build-3--apk-allégé-5-novembre-2026)
- **[Phase 2 — Automatisation et données de marché](#phase-2--automatisation-et-données-de-marché)**
  - [Build 4 — Prix de marché en euros (5 novembre 2026)](#build-4--prix-de-marché-en-euros-5-novembre-2026)
  - [Build 5 — Repli CoinGecko pour les cryptos (5 novembre 2026)](#build-5--repli-coingecko-pour-les-cryptos-5-novembre-2026)
  - [Build 6 — Immobilier locatif détaillé (5 novembre 2026)](#build-6--immobilier-locatif-détaillé-5-novembre-2026)
- **[Phase 3 — Startups et analyse](#phase-3--startups-et-analyse)**
  - [Build 7 — Startups non cotées (5 novembre 2026)](#build-7--startups-non-cotées-5-novembre-2026)
  - [Build 8 — Courbe d'évolution et import CSV (5 novembre 2026)](#build-8--courbe-dévolution-et-import-csv-5-novembre-2026)
  - [Build 9 — Catégorie startups et import Blast (6 novembre 2026)](#build-9--catégorie-startups-et-import-blast-6-novembre-2026)
  - [Build 10 — Onglet Startups avancé (6 novembre 2026)](#build-10--onglet-startups-avancé-6-novembre-2026)
- **[Phase 4 — Fiabilité et confort d'usage](#phase-4--fiabilité-et-confort-dusage)**
  - [Build 11 — Import sans doublons (6 novembre 2026)](#build-11--import-sans-doublons-6-novembre-2026)
  - [Build 12 — KPI frais et recherche (6 novembre 2026)](#build-12--kpi-frais-et-recherche-6-novembre-2026)
  - [Build 13 — Frais par catégorie et blocs réordonnables (6 novembre 2026)](#build-13--frais-par-catégorie-et-blocs-réordonnables-6-novembre-2026)
  - [Build 14 — Startups multi-tours (7 novembre 2026)](#build-14--startups-multi-tours-7-novembre-2026)
  - [Build 15 — Levées de fonds synchronisées au ré-import (7 novembre 2026)](#build-15--levées-de-fonds-synchronisées-au-ré-import-7-novembre-2026)
  - [Build 16 — Refonte de la navigation et Blast Market (7 novembre 2026)](#build-16--refonte-de-la-navigation-et-blast-market-7-novembre-2026)
  - [Build 17 — Blast Market détaillé (PV + filtres) (7 novembre 2026)](#build-17--blast-market-détaillé-pv--filtres-7-novembre-2026)
  - [Build 18 — Blast Market compact + emplacement des documents (8 novembre 2026)](#build-18--blast-market-compact--emplacement-des-documents-8-novembre-2026)
  - [Build 19 — Cashflow immobilier : charges locatives en revenu (8 novembre 2026)](#build-19--cashflow-immobilier--charges-locatives-en-revenu-8-novembre-2026)
  - [Build 20 — Onglets actifs simplifiés + type Bourse (8 novembre 2026)](#build-20--onglets-actifs-simplifiés--type-bourse-8-novembre-2026)

## Phase 1 — Fondations

### Build 1 — MVP initial (5 novembre 2026)

- Application Flutter de suivi de patrimoine, 100 % local-first : vos données restent sur l'appareil.
- Gestion manuelle des actifs (cash, investissements, crypto, immobilier, métaux, collections) et des passifs.
- Dashboard du patrimoine net avec répartition par classe d'actifs, interface française en thème sombre fintech.

### Build 2 — Builds automatiques Windows et Android (5 novembre 2026)

- Un build Windows (.exe) et un build Android (APK) générés automatiquement à chaque mise à jour.
- Artefacts téléchargeables directement, sans compilation locale.

### Build 3 — APK allégé (5 novembre 2026)

- APK découpé par architecture : chaque téléphone ne télécharge que la version dont il a besoin.
- Téléchargement plus léger et installation plus rapide sur arm64.

## Phase 2 — Automatisation et données de marché

### Build 4 — Prix de marché en euros (5 novembre 2026)

- Rafraîchissement automatique des cours via Yahoo Finance.
- Conversion automatique en euros (taux EUR/USD) et bouton de rafraîchissement manuel.

### Build 5 — Repli CoinGecko pour les cryptos (5 novembre 2026)

- CoinGecko prend le relais quand Yahoo Finance ne connaît pas une crypto.
- Les petites capitalisations (ex. ZAMA) sont désormais valorisées correctement.

### Build 6 — Immobilier locatif détaillé (5 novembre 2026)

- Fiche location : loyer, charges, crédit, rendement brut et net, cashflow.
- Pièces jointes (bail, diagnostics…) et édition des actifs comme des passifs.

## Phase 3 — Startups et analyse

### Build 7 — Startups non cotées (5 novembre 2026)

- Section startups à mise à jour manuelle, avec KPIs pro : PV latente, MOIC, TRI, exit.
- Info-bulles sur les calculs internes, filtre par catégorie et réorganisation par glisser-déposer.

### Build 8 — Courbe d'évolution et import CSV (5 novembre 2026)

- Courbe d'évolution du patrimoine dans le temps.
- Import CSV pour l'immobilier et les startups, avec modèle fourni.

### Build 9 — Catégorie startups et import Blast (6 novembre 2026)

- Champ catégorie sur chaque startup pour classer le portefeuille.
- Import CSV Blast : les colonnes Blast sont reconnues sans retraitement.

### Build 10 — Onglet Startups avancé (6 novembre 2026)

- Trois sous-onglets : Synthèse, Liste et Sorties.
- Filtres par catégorie, année et statut.
- KPIs pro (capital investi, valorisation, PV latente, MOIC, TRI, PV réalisée), répartitions par catégorie et vintage, top 5 valorisation.

## Phase 4 — Fiabilité et confort d'usage

### Build 11 — Import sans doublons (6 novembre 2026)

- Déduplication à l'import CSV : ré-importer met à jour les lignes existantes au lieu de les dupliquer.
- Prix actuel par défaut à 1 €/action pour les lignes sans cours.

### Build 12 — KPI frais et recherche (6 novembre 2026)

- KPI « Frais total » dans la Synthèse.
- Recherche par nom, insensible à la casse et aux accents.

### Build 13 — Frais par catégorie et blocs réordonnables (6 novembre 2026)

- Colonne « Frais » dans la synthèse par catégorie.
- Onglets Synthèse, Liste et Sorties remontés en haut de l'écran.
- Blocs (onglets, filtres) réordonnables par glisser-déposer, ordre conservé d'une session à l'autre.

### Build 14 — Startups multi-tours (7 novembre 2026)

- Détection des suffixes de tour (ROUND 2, Tranche 2, R2…).
- Fusion automatique à l'import : prix moyen pondéré net, frais cumulés, valorisation du dernier tour.
- Liste des levées de fonds, tour par tour.

### Build 15 — Levées de fonds synchronisées au ré-import (7 novembre 2026)

- Les levées de fonds (tours) sont synchronisées lors d'un ré-import CSV, plus seulement à la création d'une startup.

### Build 16 — Refonte de la navigation et Blast Market (7 novembre 2026)

- Navigation repensée : les 8 onglets principaux passent en haut de l'écran.
- Onglets dédiés par type d'actif : Immobilier, Bourse et Crypto, Autres.
- Onglet Blast (investissements dans Blast) et Blast Market (marché secondaire : achats + reventes).
- Suppression d'une catégorie d'actif.

### Build 17 — Blast Market détaillé (PV + filtres) (7 novembre 2026)

- Détail par transaction : nb actions, prix unitaire, frais, commission de plus-value.
- Plus-value brute et nette calculées sur les ventes (flat tax 30 %).
- Filtre achats/ventes et recherche par startup.

### Build 18 — Blast Market compact + emplacement des documents (8 novembre 2026)

- Blast Market : grille compacte (3 à 4 startups par ligne), carte récapitulative (totaux + P.U. moyen), détail ligne par ligne au clic.
- KPIs plus-value brute et plus-value nette totales.
- Documents : option « Ouvrir l'emplacement du dossier » (explorateur de fichiers).

### Build 19 — Cashflow immobilier : charges locatives en revenu (8 novembre 2026)

- Charges locatives refacturées au locataire : comptées comme revenu, plus comme dépense.
- Nouveau calcul : cashflow = loyer + charges locatives − charges du propriétaire − mensualité de crédit.

### Build 20 — Onglets actifs simplifiés + type Bourse (8 novembre 2026)

- Onglets Immobilier / Bourse et Crypto / Autres : suppression du tri « Par type / Ordre manuel » (liste simple groupée par type).
- Type « Investissements » renommé « Bourse » : créer une action cotée reliée à Yahoo Finance via son symbole.
