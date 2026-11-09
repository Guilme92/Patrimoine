import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../domain/portfolio.dart';
import '../../domain/rental.dart';
import '../../models/asset_type.dart';
import '../../models/rental.dart';
import '../../theme/app_theme.dart';
import '../../theme/palette.dart';
import '../../utils/format.dart';
import '../screens/asset_detail_screen.dart';

/// Carte d'un actif dans les onglets par type.
///
/// Selon le type, elle enrichit l'en-tête (icône + nom + valeur) d'un corps
/// spécifique :
/// - immobilier loué : loyer, charges locataire, rendements, cashflow, crédit ;
/// - bourse / crypto : une ligne par position (P.U. actuel, P.U. acheté,
///   quantité, PV latente, total) ;
/// - autres : affichage simple.
class AssetTile extends StatelessWidget {
  final Asset asset;
  final List<Position> positions;
  final Map<String, double> prices;
  final StartupDetail? startup;
  final Rental? rental;

  const AssetTile({
    super.key,
    required this.asset,
    required this.positions,
    required this.prices,
    this.startup,
    this.rental,
  });

  @override
  Widget build(BuildContext context) {
    final type = assetTypeFrom(asset.type);
    final value = assetValue(
      asset: asset,
      positions: positions,
      prices: prices,
      startup: startup,
    );
    final color = assetTypeColors[type] ?? AppColors.primary;

    final Widget? body;
    if (type == AssetType.realEstate && rental != null) {
      body = _RentalBody(rental: rental!, assetValue: value);
    } else if (positions.isNotEmpty) {
      body = _PositionsBody(positions: positions, prices: prices);
    } else {
      body = null;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AssetDetailScreen(asset: asset)),
      ),
      child: Container(
        decoration: cardDecoration(),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(assetTypeIcon(type), color: color, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        asset.name,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _subtitle(type),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  formatEuro(value),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            if (body != null) ...[
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),
              body,
            ],
          ],
        ),
      ),
    );
  }

  String _subtitle(AssetType type) {
    if (type == AssetType.realEstate && rental != null) {
      return rentalStatusLabel(rental!.statut);
    }
    if (positions.isEmpty) return assetTypeLabel(type);
    return '${assetTypeLabel(type)} · ${positions.length} '
        'position${positions.length > 1 ? 's' : ''}';
  }
}

/// Corps d'une tuile immobilier : indicateurs de rentabilité de la location.
class _RentalBody extends StatelessWidget {
  final Rental rental;
  final double assetValue;

  const _RentalBody({required this.rental, required this.assetValue});

  @override
  Widget build(BuildContext context) {
    final cashflow = monthlyCashflow(rental);
    final cashflowColor = cashflow > 0
        ? AppColors.positive
        : cashflow < 0
        ? AppColors.negative
        : AppColors.textSecondary;
    final items = <_StatItem>[
      _StatItem('Loyer HC', formatEuro(rental.loyerHc)),
      _StatItem('Charges locataire', formatEuro(rental.chargesLocatives)),
      _StatItem('Rend. brut', formatPctFixed(grossYieldPct(rental, assetValue))),
      _StatItem('Rend. net', formatPctFixed(netYieldPct(rental, assetValue))),
      _StatItem(
        'Cashflow /mois',
        formatSignedEuro(cashflow),
        valueColor: cashflowColor,
      ),
      _StatItem('Crédit', rental.aUnCredit ? 'Oui' : 'Non'),
    ];
    return Column(
      children: [
        for (var i = 0; i < items.length; i += 2)
          Padding(
            padding: EdgeInsets.only(bottom: i + 2 < items.length ? 10 : 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: items[i]),
                const SizedBox(width: 10),
                Expanded(
                  child: i + 1 < items.length
                      ? items[i + 1]
                      : const SizedBox(),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Petite valeur libellée (« Loyer HC / 900 € »).
class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _StatItem(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(fontSize: 10.5),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// Corps d'une tuile bourse / crypto : un tableau ligne par ligne des
/// positions, avec prix unitaire actuel, prix de revient, quantité, PV latente
/// et total.
class _PositionsBody extends StatelessWidget {
  final List<Position> positions;
  final Map<String, double> prices;

  const _PositionsBody({required this.positions, required this.prices});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _PositionsHeader(),
        const SizedBox(height: 4),
        for (final p in positions)
          _PositionRow(
            position: p,
            price: prices[p.symbol] ?? p.unitCost,
          ),
      ],
    );
  }
}

class _PositionsHeader extends StatelessWidget {
  const _PositionsHeader();

  static const _labelStyle = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 0.3,
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(flex: 3, child: Text('Actif', style: _labelStyle)),
        Expanded(
          flex: 2,
          child: Text('P.U. actuel', textAlign: TextAlign.right, style: _labelStyle),
        ),
        Expanded(
          flex: 2,
          child: Text('P.U. acheté', textAlign: TextAlign.right, style: _labelStyle),
        ),
        const Expanded(
          flex: 1,
          child: Text('Qté', textAlign: TextAlign.right, style: _labelStyle),
        ),
        Expanded(
          flex: 2,
          child: Text('PV latente', textAlign: TextAlign.right, style: _labelStyle),
        ),
        const Expanded(
          flex: 2,
          child: Text('Total', textAlign: TextAlign.right, style: _labelStyle),
        ),
      ],
    );
  }
}

class _PositionRow extends StatelessWidget {
  final Position position;
  final double price;

  const _PositionRow({required this.position, required this.price});

  @override
  Widget build(BuildContext context) {
    final pnl = positionPnl(position, price);
    final total = positionValue(position, price);
    final pnlColor = pnl > 0
        ? AppColors.positive
        : pnl < 0
        ? AppColors.negative
        : AppColors.textSecondary;
    final name = position.name.trim().isEmpty ? position.symbol : position.name;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: _Cell(formatEuro(price, cents: true)),
          ),
          Expanded(
            flex: 2,
            child: _Cell(formatEuro(position.unitCost, cents: true)),
          ),
          Expanded(
            flex: 1,
            child: _Cell(formatQty(position.quantity)),
          ),
          Expanded(
            flex: 2,
            child: _Cell(
              formatSignedEuro(pnl, cents: true),
              color: pnlColor,
            ),
          ),
          Expanded(
            flex: 2,
            child: _Cell(formatEuro(total), bold: true),
          ),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final String text;
  final Color? color;
  final bool bold;

  const _Cell(this.text, {this.color, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.right,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 12.5,
        color: color ?? AppColors.textPrimary,
        fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
      ),
    );
  }
}
