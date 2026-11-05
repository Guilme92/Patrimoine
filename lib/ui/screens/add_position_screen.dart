import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/portfolio_controller.dart';
import '../../data/database.dart';

class AddPositionScreen extends StatefulWidget {
  final Asset asset;
  const AddPositionScreen({super.key, required this.asset});

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

  @override
  void dispose() {
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final qty = double.tryParse(_quantity.text.replaceAll(',', '.')) ?? 0;
    final cost = double.tryParse(_unitCost.text.replaceAll(',', '.')) ?? 0;
    await context.read<PortfolioController>().addPosition(
          assetId: widget.asset.id,
          symbol: _symbol.text.trim(),
          name: _name.text.trim(),
          quantity: qty,
          unitCost: cost,
          assetClass: _assetClass.text.trim().isEmpty
              ? null
              : _assetClass.text.trim(),
          sector: _sector.text.trim().isEmpty ? null : _sector.text.trim(),
          region: _region.text.trim().isEmpty ? null : _region.text.trim(),
        );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Position · ${widget.asset.name}')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _symbol,
              decoration: const InputDecoration(
                labelText: 'Symbole',
                hintText: 'Ex. AAPL, CW8.PA, BTC-USD',
              ),
              validator: _required,
            ),
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
                  : const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }
}
