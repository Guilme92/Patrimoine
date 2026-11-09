import 'package:flutter/material.dart';

import '../../domain/blast_exit.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';

/// Simulateur de sortie Blast : un curseur de valorisation (500 M€ → 10 Mrd €)
/// recalcule en direct la valeur des parts, la PV brute et la PV nette
/// (imposition de 18,2 % sur la PV brute).
///
/// La participation ([stakePct] en % et [invested] en €) est fournie par le
/// contrôleur et modifiable via le bouton d'édition.
class BlastExitSimulator extends StatefulWidget {
  final double stakePct;
  final double invested;
  final Future<void> Function(double stakePct, double invested) onSaveParams;

  const BlastExitSimulator({
    super.key,
    required this.stakePct,
    required this.invested,
    required this.onSaveParams,
  });

  @override
  State<BlastExitSimulator> createState() => _BlastExitSimulatorState();
}

class _BlastExitSimulatorState extends State<BlastExitSimulator> {
  double _valuation = 1e9; // 1 Mrd € par défaut

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shareValue = blastShareValue(_valuation, widget.stakePct);
    final pvBrute = blastPvBrute(_valuation, widget.stakePct, widget.invested);
    final pvNette = blastPvNette(pvBrute);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Simulateur de sortie',
                  style: theme.textTheme.titleMedium,
                ),
              ),
              IconButton(
                tooltip: 'Paramètres de ma participation',
                icon: const Icon(Icons.edit_outlined, size: 18),
                onPressed: _editParams,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Valorisation de sortie de Blast : '
            '${formatValuationEuro(_valuation)}',
            style: theme.textTheme.bodySmall,
          ),
          Slider(
            value: _valuation,
            min: blastExitValuationMin,
            max: blastExitValuationMax,
            onChanged: (v) => setState(() => _valuation = v),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '500 M€',
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                ),
                Text(
                  '10 Mrd €',
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Kpi(
                  label: 'Valeur de mes parts',
                  value: formatEuro(shareValue),
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Kpi(
                  label: 'PV brute',
                  value: formatSignedEuro(pvBrute),
                  color: _pnlColor(pvBrute),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Kpi(
                  label: 'PV nette',
                  value: formatSignedEuro(pvNette),
                  color: _pnlColor(pvNette),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Détention ${formatQty(widget.stakePct)} % · '
            'Capital investi ${formatEuro(widget.invested)}',
            style: theme.textTheme.bodySmall?.copyWith(fontSize: 10.5),
          ),
          const SizedBox(height: 2),
          Text(
            'PV nette = PV brute − 18,2 % (impôt sur la plus-value)',
            style: theme.textTheme.bodySmall?.copyWith(fontSize: 10.5),
          ),
        ],
      ),
    );
  }

  Color _pnlColor(double v) => v > 0
      ? AppColors.positive
      : v < 0
      ? AppColors.negative
      : AppColors.textSecondary;

  Future<void> _editParams() async {
    final stakeController = TextEditingController(
      text: _fmtInitial(widget.stakePct),
    );
    final investedController = TextEditingController(
      text: _fmtInitial(widget.invested),
    );
    final result = await showDialog<(double, double)>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Ma participation Blast'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: stakeController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Détention (%)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: investedController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Capital investi (€)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              final stake = _parseFrNum(stakeController.text);
              final invested = _parseFrNum(investedController.text);
              if (stake == null ||
                  invested == null ||
                  stake < 0 ||
                  invested < 0) {
                return;
              }
              Navigator.pop(dialogContext, (stake, invested));
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
    stakeController.dispose();
    investedController.dispose();
    if (result != null) {
      await widget.onSaveParams(result.$1, result.$2);
    }
  }

  static String _fmtInitial(double v) => v == v.roundToDouble()
      ? v.round().toString()
      : v.toString().replaceAll('.', ',');

  static double? _parseFrNum(String raw) {
    final t = raw
        .replaceAll(' ', '')
        .replaceAll('\u202F', '')
        .replaceAll('\u00A0', '')
        .replaceAll(',', '.');
    return double.tryParse(t);
  }
}

/// Carte KPI compacte du simulateur (fond légèrement contrasté).
class _Kpi extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _Kpi({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(fontSize: 10.5),
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
