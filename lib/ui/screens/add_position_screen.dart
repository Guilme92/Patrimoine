import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/portfolio_controller.dart';
import '../../data/database.dart';
import '../../data/market_data.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../widgets/form_widgets.dart';

/// Ajout ou modification d'une position (action, ETF, crypto…).
///
/// Si [position] est fournie, l'écran modifie cette position ; sinon il en
/// crée une nouvelle. Le champ « Symbole » propose une recherche par nom
/// (Yahoo Finance) avec le prix actuel pour éviter les codes incorrects.
class AddPositionScreen extends StatefulWidget {
  final Asset asset;
  final Position? position;
  const AddPositionScreen({super.key, required this.asset, this.position});

  @override
  State<AddPositionScreen> createState() => _AddPositionScreenState();
}

class _AddPositionScreenState extends State<AddPositionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _symbol = TextEditingController();
  final _name = TextEditingController();
  final _quantity = TextEditingController();
  final _unitCost = TextEditingController();
  final _assetClass = TextEditingController();
  final _sector = TextEditingController();
  final _region = TextEditingController();
  bool _saving = false;
  bool _searching = false;
  List<SymbolSearchResult> _results = const [];
  Timer? _debounce;
  int _searchSeq = 0;

  bool get _isEdit => widget.position != null;

  @override
  void initState() {
    super.initState();
    final p = widget.position;
    if (p != null) {
      _symbol.text = p.symbol;
      _name.text = p.name;
      _quantity.text = _fmtQty(p.quantity);
      _unitCost.text = amountText(p.unitCost);
      _assetClass.text = p.assetClass ?? '';
      _sector.text = p.sector ?? '';
      _region.text = p.region ?? '';
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _symbol.dispose();
    _name.dispose();
    _quantity.dispose();
    _unitCost.dispose();
    _assetClass.dispose();
    _sector.dispose();
    _region.dispose();
    super.dispose();
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Requis' : null;

  void _onSymbolChanged(String value) {
    _debounce?.cancel();
    final query = value.trim();
    if (query.length < 2) {
      setState(() {
        _results = const [];
        _searching = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () => _search(query));
  }

  Future<void> _search(String query) async {
    final seq = ++_searchSeq;
    final market = context.read<PortfolioController>().market;
    setState(() => _searching = true);
    final results = await market.searchSymbols(query);
    if (!mounted || seq != _searchSeq) return;
    setState(() {
      _results = results;
      _searching = false;
    });
  }

  void _pickSymbol(SymbolSearchResult r) {
    _symbol.text = r.symbol;
    _name.text = r.name;
    setState(() => _results = const []);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final qty = double.tryParse(_quantity.text.replaceAll(',', '.')) ?? 0;
    final cost = double.tryParse(_unitCost.text.replaceAll(',', '.')) ?? 0;
    final symbol = _symbol.text.trim();
    final name = _name.text.trim();
    String? optional(String v) => v.trim().isEmpty ? null : v.trim();

    final controller = context.read<PortfolioController>();
    final existing = widget.position;
    if (existing == null) {
      await controller.addPosition(
        assetId: widget.asset.id,
        symbol: symbol,
        name: name,
        quantity: qty,
        unitCost: cost,
        assetClass: optional(_assetClass.text),
        sector: optional(_sector.text),
        region: optional(_region.text),
      );
    } else {
      await controller.updatePosition(
        existing.copyWith(
          symbol: symbol,
          name: name,
          quantity: qty,
          unitCost: cost,
          assetClass: Value(optional(_assetClass.text)),
          sector: Value(optional(_sector.text)),
          region: Value(optional(_region.text)),
        ),
      );
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Modifier la position' : 'Position · ${widget.asset.name}')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _symbol,
              decoration: InputDecoration(
                labelText: 'Symbole',
                hintText: 'Ex. AAPL, CW8.PA, BTC-USD',
                suffixIcon: _searching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
              ),
              onChanged: _onSymbolChanged,
              validator: _required,
            ),
            if (_results.isNotEmpty)
              _SymbolSuggestions(results: _results, onPick: _pickSymbol),
            const SizedBox(height: 12),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Nom',
                hintText: 'Ex. Apple Inc.',
              ),
              validator: _required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _quantity,
              decoration: const InputDecoration(
                labelText: 'Quantité',
                hintText: 'Ex. 10',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: _required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _unitCost,
              decoration: const InputDecoration(
                labelText: 'Prix de revient unitaire (€)',
                hintText: 'Ex. 120.5',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: _required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _assetClass,
              decoration: const InputDecoration(
                labelText: 'Classe (optionnel)',
                hintText: 'Action, ETF, Obligation…',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _sector,
              decoration: const InputDecoration(
                labelText: 'Secteur (optionnel)',
                hintText: 'Technologie, Santé…',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _region,
              decoration: const InputDecoration(
                labelText: 'Zone (optionnel)',
                hintText: 'États-Unis, Europe…',
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_isEdit ? 'Enregistrer les modifications' : 'Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Suggestions de la recherche de symbole, avec nom, place et prix actuel.
class _SymbolSuggestions extends StatelessWidget {
  final List<SymbolSearchResult> results;
  final ValueChanged<SymbolSearchResult> onPick;
  const _SymbolSuggestions({required this.results, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (final r in results)
            ListTile(
              dense: true,
              title: Text(
                '${r.symbol} · ${r.name}',
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                [r.exchange, r.type].where((s) => s.isNotEmpty).join(' · '),
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Text(
                r.priceEur == null
                    ? '—'
                    : formatEuro(r.priceEur!, cents: true),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.positive,
                    ),
              ),
              onTap: () => onPick(r),
            ),
        ],
      ),
    );
  }
}

String _fmtQty(double q) {
  final s = q.toStringAsFixed(6);
  return s.replaceFirst(RegExp(r'\.?0+$'), '');
}
