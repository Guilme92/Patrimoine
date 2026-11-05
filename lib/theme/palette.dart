import 'package:flutter/material.dart';

import '../models/asset_type.dart';

/// Couleur attribuée à chaque type d'actif (charts, icônes).
const Map<AssetType, Color> assetTypeColors = {
  AssetType.cash: Color(0xFF16C784),
  AssetType.investment: Color(0xFF3B82F6),
  AssetType.crypto: Color(0xFFF59E0B),
  AssetType.realEstate: Color(0xFF8B5CF6),
  AssetType.preciousMetals: Color(0xFFFACC15),
  AssetType.collectible: Color(0xFFEC4899),
  AssetType.other: Color(0xFF6B7280),
  AssetType.loan: Color(0xFFEA3943),
};

IconData assetTypeIcon(AssetType t) {
  switch (t) {
    case AssetType.cash:
      return Icons.account_balance_wallet_outlined;
    case AssetType.investment:
      return Icons.trending_up;
    case AssetType.crypto:
      return Icons.currency_bitcoin;
    case AssetType.realEstate:
      return Icons.home_outlined;
    case AssetType.preciousMetals:
      return Icons.monetization_on;
    case AssetType.collectible:
      return Icons.watch;
    case AssetType.other:
      return Icons.category_outlined;
    case AssetType.loan:
      return Icons.request_quote;
  }
}
