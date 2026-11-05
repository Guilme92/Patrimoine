# Patrimoine

Application de suivi et de gestion de patrimoine personnel — local-first, en français.
MVP : centraliser ses actifs, suivre leur performance et analyser sa diversification, sans dépendre d'un serveur.

## Fonctionnalités (MVP)

- Actifs manuels : cash, comptes d'investissement (PEA/CTO), crypto, immobilier, métaux, collections + passifs (emprunts)
- Prix de marché automatiques : crypto (CoinGecko), actions/ETF (Yahoo Finance)
- Positions & performance : PRU, plus/moins-value latente
- Analyses : répartition par classe d'actifs, scanner de frais, dividendes
- Dashboard : patrimoine net, évolution, répartition
- Import CSV des transactions

## Stack

- **Flutter** (Dart) — une seule base de code, Android + Windows natifs
- **drift / SQLite** — stockage local
- **fl_chart** — graphiques

## Build local

```bash
flutter pub get
flutter run            # debug
flutter build apk      # Android
flutter build windows  # Windows (sur une machine Windows uniquement)
```

## CI/CD

À chaque push sur `main`, GitHub Actions build automatiquement :
- l'**APK Android** (runner Ubuntu)
- l'**exécutable Windows** (runner Windows)

Les binaires sont disponibles dans l'onglet **Actions** → le build → **Artifacts**.

## Structure

```
lib/
  main.dart          # point d'entrée
  theme/             # design system (couleurs, typographie, thème sombre)
  models/            # modèles de données
  data/              # base de données + repositories + service de prix
  domain/            # calculs de patrimoine net et de performance
  ui/                # écrans et widgets
```
