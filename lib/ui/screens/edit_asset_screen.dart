import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/portfolio_controller.dart';
import '../../data/database.dart';
import '../../models/asset_type.dart';
import '../widgets/form_widgets.dart';

/// Édition complète d'un actif ou d'un passif existant.
class EditAssetScreen extends StatefulWidget {
  final Asset asset;
  const EditAssetScreen({super.key, required this.asset});

  @override
  State<EditAssetScreen> createState() => _EditAssetScreenState();
}

class _EditAssetScreenState extends State<EditAssetScreen> {
  static const _currencies = ['EUR', 'USD', 'CHF', 'GBP', 'CAD'];

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _value;
  late final TextEditingController _institution;
  late final TextEditingController _note;
  late AssetType _type;
  late String _currency;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final a = widget.asset;
    _name = TextEditingController(text: a.name);
    _value = TextEditingController(text: amountText(a.value));
    _institution = TextEditingController(text: a.institution ?? '');
    _note = TextEditingController(text: a.note ?? '');
    _type = assetTypeFrom(a.type);
    _currency = _currencies.contains(a.currency) ? a.currency : 'EUR';
  }

  @override
  void dispose() {
    _name.dispose();
    _value.dispose();
    _institution.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final institution = _institution.text.trim();
    final note = _note.text.trim();
    await context.read<PortfolioController>().updateAsset(
      id: widget.asset.id,
      name: _name.text.trim(),
      type: _type,
      value: parseAmount(_value.text),
      currency: _currency,
      institution: institution.isEmpty ? null : institution,
      note: note.isEmpty ? null : note,
    );
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modifier')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Type', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AssetType.values
                  .map(
                    (t) => ChoiceChip(
                      label: Text(assetTypeLabel(t)),
                      selected: _type == t,
                      onSelected: (_) => setState(() => _type = t),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Nom'),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Requis' : null,
            ),
            const SizedBox(height: 12),
            AmountField(
              controller: _value,
              label: 'Valeur',
              suffix: _currency == 'EUR' ? '€' : _currency,
              hint: 'Ex. 15000',
            ),
            if (supportsPositions(_type))
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'La valeur affichée est calculée à partir des positions ; '
                  'ce montant ne sert que si l\'actif n\'a aucune position.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _currency,
              decoration: const InputDecoration(labelText: 'Devise'),
              items: _currencies
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _currency = v ?? 'EUR'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _institution,
              decoration: const InputDecoration(
                labelText: 'Établissement (optionnel)',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _note,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Note (optionnel)',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Enregistrer les modifications'),
            ),
          ],
        ),
      ),
    );
  }
}
