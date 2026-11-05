/// Types d'actifs et libellés français.
enum AssetType {
  cash,
  investment,
  crypto,
  realEstate,
  preciousMetals,
  collectible,
  other,
  loan,
}

AssetType assetTypeFrom(String s) =>
    AssetType.values.firstWhere((e) => e.name == s, orElse: () => AssetType.other);

bool isLiabilityType(AssetType t) => t == AssetType.loan;

String assetTypeLabel(AssetType t) {
  switch (t) {
    case AssetType.cash:
      return 'Liquidités';
    case AssetType.investment:
      return 'Investissements';
    case AssetType.crypto:
      return 'Crypto';
    case AssetType.realEstate:
      return 'Immobilier';
    case AssetType.preciousMetals:
      return 'Métaux précieux';
    case AssetType.collectible:
      return 'Collections';
    case AssetType.other:
      return 'Autres';
    case AssetType.loan:
      return 'Emprunts';
  }
}

/// Types d'actifs qui peuvent porter des positions (titres, cryptos).
bool supportsPositions(AssetType t) =>
    t == AssetType.investment || t == AssetType.crypto;
