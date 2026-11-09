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
import 'info_hint.dart';

/// Carte d'un actif dans les onglets par type.
///
/// Selon le type, elle enrichit l'en-tête (icône + nom + valeur) d'un corps
/// spécifique :
/// - immobilier loué : tout tient sur une seule rangée (nom, loyer, charges,
///   rendements, cashflow, crédit, valeur), pour rester compact ;
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

    // Un bien immobilier loué tient sur une seule rangée : pas d'en-tête
    // séparé ni de grille de statistiques, donc une carte deux fois moins
    // haute que les autres.
    final rented = type == AssetType.realEstate && rental != null;

    final Widget? body = !rented && positions.isNotEmpty
        ? _PositionsBody(positions: positions, prices: prices)
        : null;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AssetDetailScreen(asset: asset)),
      ),
      child: Container(
        decoration: cardDecoration(),
        margin: const EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.symmetric(
          horizontal: 14,
          vertical: rented ? 10 : 14,
        ),
        child: rented
            ? _RentalRow(
                asset: asset,
                rental: rental!,
                assetValue: value,
                accent: color,
              )
            : Column(
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
                        child: Icon(
                          assetTypeIcon(type),
                          color: color,
                          size: 22,
                        ),
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

/// Rangée unique d'un bien immobilier loué.
///
/// Pastille de type, nom du bien, puis chaque indicateur en micro-colonne
/// (libellé au-dessus de la valeur) : le tout sur une seule rangée, sans
/// en-tête ni grille. Chaque colonne est un `FittedBox` : sur écran étroit
/// (360 dp) elle rétrécit au lieu de déborder, et rien n'est empilé.
class _RentalRow extends StatelessWidget {
  final Asset asset;
  final Rental rental;
  final double assetValue;
  final Color accent;

  const _RentalRow({
    required this.asset,
    required this.rental,
    required this.assetValue,
    required this.accent,
  });

  /// En dessous, les libellés sont abrégés et les valeurs monétaires
  /// compactées pour tenir sur 360 dp.
  static const double _wideBreakpoint = 700;

  /// En dessous, les info-bulles n'apparaissent pas : elles mangeraient la
  /// place nécessaire aux valeurs.
  static const double _hintBreakpoint = 1000;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cashflow = monthlyCashflow(rental);
    final cashflowColor = cashflow > 0
        ? AppColors.positive
        : cashflow < 0
        ? AppColors.negative
        : AppColors.textSecondary;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final wide = width >= _wideBreakpoint;
        final withHints = width >= _hintBreakpoint;

        final metrics = <_Metric>[
          _Metric(wide ? 'Loyer HC' : 'Loyer', formatEuro(rental.loyerHc)),
          _Metric(
            wide ? 'Charges locataire' : 'Charges',
            formatEuro(rental.chargesLocatives),
          ),
          _Metric(
            wide ? 'Rend. brut' : 'Brut',
            formatPctFixed(grossYieldPct(rental, assetValue)),
            hint: withHints
                ? 'Loyer annuel hors charges / valeur du bien'
                : null,
          ),
          _Metric(
            wide ? 'Rend. net' : 'Net',
            formatPctFixed(netYieldPct(rental, assetValue)),
            hint: withHints
                ? 'Loyer annuel − charges du propriétaire, / valeur du bien'
                : null,
          ),
          _Metric(
            wide ? 'Cashflow /mois' : 'Cash',
            formatSignedEuro(cashflow),
            color: cashflowColor,
            hint: withHints
                ? 'Loyer + charges refacturées − charges du propriétaire '
                      '− crédit (assurance incluse)'
                : null,
          ),
          _Metric('Crédit', rental.aUnCredit ? 'Oui' : 'Non'),
          _Metric(
            'Valeur',
            wide ? formatEuro(assetValue) : formatCompactEuro(assetValue),
            emphasis: true,
          ),
        ];

        return Row(
          // Les colonnes gardent leur largeur naturelle : l'espace restant
          // est réparti entre elles plutôt que laissé vide à droite.
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (wide)
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  assetTypeIcon(AssetType.realEstate),
                  color: accent,
                  size: 19,
                ),
              )
            else
              // Barre d'accent : même repère visuel que l'icône, en 4 dp.
              Container(
                width: 4,
                height: 26,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            SizedBox(width: wide ? 12 : 8),
            Expanded(
              flex: wide ? 3 : 5,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    asset.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: wide ? 15 : 12,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    rentalStatusLabel(rental.statut),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: wide ? 10.5 : 8.5,
                      height: 1.15,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            for (final metric in metrics) ...[
              SizedBox(width: wide ? 10 : 5),
              Flexible(
                flex: 2,
                child: _MetricCell(
                  metric: metric,
                  labelSize: wide ? 9 : 8,
                  valueSize: wide ? 13 : 10.5,
                  alignEnd: metric.emphasis,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Indicateur affiché en micro-colonne (libellé + valeur).
class _Metric {
  final String label;
  final String value;
  final String? hint;
  final Color? color;

  /// Valeur mise en avant (valeur du bien), alignée à droite de la carte.
  final bool emphasis;

  const _Metric(
    this.label,
    this.value, {
    this.hint,
    this.color,
    this.emphasis = false,
  });
}

/// Colonne compacte d'une rangée : libellé (et info-bulle si la place le
/// permet) au-dessus de la valeur.
class _MetricCell extends StatelessWidget {
  final _Metric metric;
  final double labelSize;
  final double valueSize;
  final bool alignEnd;

  const _MetricCell({
    required this.metric,
    required this.labelSize,
    required this.valueSize,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    // Pas de Flexible/Expanded ici : le contenu est mesuré sans contrainte
    // puis réduit par le FittedBox.
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: alignEnd
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                metric.label,
                maxLines: 1,
                style: TextStyle(
                  fontSize: labelSize,
                  height: 1.1,
                  color: AppColors.textSecondary,
                ),
              ),
              if (metric.hint != null)
                InfoHint(metric.hint!, size: labelSize + 3),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            metric.value,
            maxLines: 1,
            style: TextStyle(
              fontSize: valueSize,
              height: 1.15,
              fontWeight: metric.emphasis ? FontWeight.w700 : FontWeight.w600,
              color: metric.color ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
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
