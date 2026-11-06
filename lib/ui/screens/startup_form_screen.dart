import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/portfolio_controller.dart';
import '../../data/database.dart';
import '../../models/startup.dart';
import '../../theme/app_theme.dart';
import '../widgets/form_widgets.dart';

/// Saisie / modification de la fiche d'une startup non cotée.
///
/// Le prix actuel est mis à jour MANUELLEMENT : aucune cotation n'existe.
class StartupDetailsFormScreen extends StatefulWidget {
  final Asset asset;
  const StartupDetailsFormScreen({super.key, required this.asset});

  @override
  State<StartupDetailsFormScreen> createState() =>
      _StartupDetailsFormScreenState();
}

class _StartupDetailsFormScreenState extends State<StartupDetailsFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _hadDetails = false;

  String _statut = 'en_portefeuille';
  String _typeTitre = '';
  String _categorie = '';
  String _stade = '';
  String _exitMode = '';
  late final TextEditingController _quantite;
  late final TextEditingController _prixEntree;
  late final TextEditingController _frais;
  late final TextEditingController _prixActuel;
  late final TextEditingController _valorisationEntreprise;
  late final TextEditingController _exitProduit;
  late final TextEditingController _note;
  DateTime? _dateInvestissement;
  DateTime? _dateValorisation;
  DateTime? _exitDate;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final existing = context.read<PortfolioController>().startupOf(
      widget.asset.id,
    );
    _hadDetails = existing != null;
    final d = existing == null
        ? const StartupDraft()
        : StartupDraft.fromDetail(existing);
    _statut = startupStatuses.contains(d.statut) ? d.statut : 'en_portefeuille';
    _typeTitre = startupInstruments.contains(d.typeTitre)
        ? d.typeTitre!
        : '';
    _stade = startupStages.contains(d.stade) ? d.stade! : '';
    _categorie = d.categorie?.trim() ?? '';
    _exitMode = startupExitModes.contains(d.exitMode) ? d.exitMode! : '';
    _quantite = TextEditingController(text: amountText(d.quantite));
    _prixEntree = TextEditingController(text: amountText(d.prixEntree));
    _frais = TextEditingController(text: amountText(d.frais));
    _prixActuel = TextEditingController(text: amountText(d.prixActuel));
    _valorisationEntreprise = TextEditingController(
      text: amountText(d.valorisationEntreprise),
    );
    _exitProduit = TextEditingController(text: amountText(d.exitProduit));
    _note = TextEditingController(text: d.note ?? '');
    _dateInvestissement = d.dateInvestissement;
    _dateValorisation = d.dateValorisation;
    _exitDate = d.exitDate;
  }

  @override
  void dispose() {
    for (final c in [
      _quantite,
      _prixEntree,
      _frais,
      _prixActuel,
      _valorisationEntreprise,
      _exitProduit,
      _note,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate({
    required DateTime? current,
    required String help,
    required void Function(DateTime?) assign,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
      helpText: help,
    );
    if (picked == null) return;
    setState(() => assign(picked));
  }

  String? _nullIfBlank(String v) => v.trim().isEmpty ? null : v.trim();

  StartupDraft _draft() => StartupDraft(
    typeTitre: _nullIfBlank(_typeTitre),
    categorie: _nullIfBlank(_categorie),
    quantite: parseAmount(_quantite.text),
    prixEntree: parseAmount(_prixEntree.text),
    frais: parseAmount(_frais.text),
    dateInvestissement: _dateInvestissement,
    stade: _nullIfBlank(_stade),
    prixActuel: parseAmount(_prixActuel.text),
    dateValorisation: _dateValorisation,
    valorisationEntreprise: parseAmount(_valorisationEntreprise.text),
    statut: _statut,
    exitDate: _statut == 'sorti' ? _exitDate : null,
    exitProduit: parseAmount(_exitProduit.text),
    exitMode: _statut == 'sorti' ? _nullIfBlank(_exitMode) : null,
    note: _note.text,
  );

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await context.read<PortfolioController>().saveStartupDetails(
      assetId: widget.asset.id,
      draft: _draft(),
    );
    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer la fiche startup ?'),
        content: const Text(
          'Les informations de cette startup seront effacées.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await context.read<PortfolioController>().deleteStartupDetails(
      widget.asset.id,
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Startup'),
        actions: [
          if (_hadDetails)
            IconButton(
              tooltip: 'Supprimer la fiche',
              icon: const Icon(Icons.delete_outline),
              onPressed: _saving ? null : _delete,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            const FormSectionTitle(title: 'Catégorie'),
            DropdownButtonFormField<String>(
              initialValue: _categorie,
              decoration: const InputDecoration(
                labelText: 'Portefeuille / catégorie',
              ),
              items: [
                const DropdownMenuItem(value: '', child: Text('Non renseigné')),
                ...startupCategories.map(
                  (c) => DropdownMenuItem(value: c, child: Text(c)),
                ),
                // Une catégorie importée hors liste reste sélectionnable.
                if (_categorie.isNotEmpty &&
                    !startupCategories.contains(_categorie))
                  DropdownMenuItem(
                    value: _categorie,
                    child: Text(_categorie),
                  ),
              ],
              onChanged: (v) => setState(() => _categorie = v ?? ''),
            ),
            const FormSectionTitle(title: 'Investissement'),
            DropdownButtonFormField<String>(
              initialValue: _typeTitre,
              decoration: const InputDecoration(
                labelText: 'Type de titre',
              ),
              items: [
                const DropdownMenuItem(value: '', child: Text('Non renseigné')),
                ...startupInstruments.map(
                  (t) => DropdownMenuItem(
                    value: t,
                    child: Text(startupInstrumentLabel(t)),
                  ),
                ),
              ],
              onChanged: (v) => setState(() => _typeTitre = v ?? ''),
            ),
            const SizedBox(height: 12),
            AmountField(
              controller: _quantite,
              label: 'Quantité (nombre de titres)',
              suffix: 'titres',
            ),
            const SizedBox(height: 12),
            AmountField(
              controller: _prixEntree,
              label: 'Prix d\'entrée unitaire',
              suffix: '€',
            ),
            const SizedBox(height: 12),
            AmountField(controller: _frais, label: 'Frais', suffix: '€'),
            const SizedBox(height: 12),
            DateField(
              label: 'Date d\'investissement',
              date: _dateInvestissement,
              onTap: () => _pickDate(
                current: _dateInvestissement,
                help: 'Date d\'investissement',
                assign: (d) => _dateInvestissement = d,
              ),
              onClear: () => setState(() => _dateInvestissement = null),
            ),
            const FormSectionTitle(title: 'Stade'),
            DropdownButtonFormField<String>(
              initialValue: _stade,
              decoration: const InputDecoration(labelText: 'Stade de maturité'),
              items: [
                const DropdownMenuItem(value: '', child: Text('Non renseigné')),
                ...startupStages.map(
                  (s) => DropdownMenuItem(
                    value: s,
                    child: Text(startupStageLabel(s)),
                  ),
                ),
              ],
              onChanged: (v) => setState(() => _stade = v ?? ''),
            ),
            const FormSectionTitle(title: 'Valorisation (manuelle)'),
            AmountField(
              controller: _prixActuel,
              label: 'Prix actuel unitaire',
              suffix: '€',
              hint: 'Mis à jour à la main',
            ),
            const SizedBox(height: 12),
            DateField(
              label: 'Date de valorisation',
              date: _dateValorisation,
              onTap: () => _pickDate(
                current: _dateValorisation,
                help: 'Date de valorisation',
                assign: (d) => _dateValorisation = d,
              ),
              onClear: () => setState(() => _dateValorisation = null),
            ),
            const SizedBox(height: 12),
            AmountField(
              controller: _valorisationEntreprise,
              label: 'Valorisation de l\'entreprise',
              suffix: '€',
            ),
            const FormSectionTitle(title: 'Statut'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: startupStatuses
                  .map(
                    (s) => ChoiceChip(
                      label: Text(startupStatusLabel(s)),
                      selected: _statut == s,
                      onSelected: (_) => setState(() => _statut = s),
                    ),
                  )
                  .toList(),
            ),
            if (_statut == 'sorti') ...[
              const FormSectionTitle(title: 'Sortie'),
              DateField(
                label: 'Date de sortie',
                date: _exitDate,
                onTap: () => _pickDate(
                  current: _exitDate,
                  help: 'Date de sortie',
                  assign: (d) => _exitDate = d,
                ),
                onClear: () => setState(() => _exitDate = null),
              ),
              const SizedBox(height: 12),
              AmountField(
                controller: _exitProduit,
                label: 'Produit de sortie (encaissé)',
                suffix: '€',
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _exitMode,
                decoration: const InputDecoration(labelText: 'Mode de sortie'),
                items: [
                  const DropdownMenuItem(
                    value: '',
                    child: Text('Non renseigné'),
                  ),
                  ...startupExitModes.map(
                    (m) => DropdownMenuItem(
                      value: m,
                      child: Text(startupExitModeLabel(m)),
                    ),
                  ),
                ],
                onChanged: (v) => setState(() => _exitMode = v ?? ''),
              ),
            ],
            const FormSectionTitle(title: 'Note'),
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
                  : const Text('Enregistrer'),
            ),
            const SizedBox(height: 8),
            Text(
              'Le prix actuel n\'est pas coté : mettez-le à jour après chaque '
              'levée ou opération. Sans prix actuel, la ligne vaut 0 €.',
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialogue d'ajout d'une levée de fonds.
class FundingRoundDialog extends StatefulWidget {
  const FundingRoundDialog({super.key});

  @override
  State<FundingRoundDialog> createState() => _FundingRoundDialogState();
}

class _FundingRoundDialogState extends State<FundingRoundDialog> {
  final _montant = TextEditingController();
  final _postMoney = TextEditingController();
  final _prix = TextEditingController();
  final _note = TextEditingController();
  DateTime? _date;

  @override
  void dispose() {
    _montant.dispose();
    _postMoney.dispose();
    _prix.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nouvelle levée de fonds'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DateField(
              label: 'Date',
              date: _date,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date ?? DateTime.now(),
                  firstDate: DateTime(1950),
                  lastDate: DateTime(2100),
                  helpText: 'Date de la levée',
                );
                if (picked != null) setState(() => _date = picked);
              },
              onClear: () => setState(() => _date = null),
            ),
            const SizedBox(height: 12),
            AmountField(
              controller: _montant,
              label: 'Montant levé',
              suffix: '€',
            ),
            const SizedBox(height: 12),
            AmountField(
              controller: _postMoney,
              label: 'Valorisation post-money',
              suffix: '€',
            ),
            const SizedBox(height: 12),
            AmountField(
              controller: _prix,
              label: 'Prix par action',
              suffix: '€',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _note,
              decoration: const InputDecoration(labelText: 'Note (optionnel)'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(
            context,
            FundingRoundDraft(
              date: _date,
              montantLeve: parseAmount(_montant.text),
              valorisationPostMoney: parseAmount(_postMoney.text),
              prixParAction: parseAmount(_prix.text),
              note: _note.text,
            ),
          ),
          child: const Text('Ajouter'),
        ),
      ],
    );
  }
}
