import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/portfolio_controller.dart';
import '../../data/database.dart';
import '../../models/rental.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../widgets/form_widgets.dart';

/// Saisie / modification de la fiche de location d'un bien immobilier.
class RentalFormScreen extends StatefulWidget {
  final Asset asset;
  const RentalFormScreen({super.key, required this.asset});

  @override
  State<RentalFormScreen> createState() => _RentalFormScreenState();
}

class _RentalFormScreenState extends State<RentalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _hadRental = false;

  late String _statut;
  String? _typeBail;
  late final TextEditingController _locataire;
  late final TextEditingController _loyer;
  late final TextEditingController _chargesLocatives;
  late final TextEditingController _depot;
  DateTime? _dateDebut;
  DateTime? _dateFin;
  String? _modeGestion;
  late final TextEditingController _fraisGestion;
  late final TextEditingController _taxeFonciere;
  late final TextEditingController _assurancePno;
  late final TextEditingController _chargesCopro;
  late final TextEditingController _travaux;
  late final TextEditingController _vacance;
  late final TextEditingController _note;
  bool _aUnCredit = false;
  late final TextEditingController _montantCredit;
  late final TextEditingController _tauxCredit;
  late final TextEditingController _mensualite;
  late final TextEditingController _duree;
  late final TextEditingController _capitalRestant;
  late final TextEditingController _assuranceEmprunteur;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final existing = context.read<PortfolioController>().rentalOf(
      widget.asset.id,
    );
    _hadRental = existing != null;
    final d = existing == null
        ? const RentalDraft()
        : RentalDraft.fromRental(existing);
    _statut = rentalStatuses.contains(d.statut) ? d.statut : 'vacant';
    _typeBail = rentalLeaseTypes.contains(d.typeBail) ? d.typeBail : null;
    _locataire = TextEditingController(text: d.locataire ?? '');
    _loyer = TextEditingController(text: amountText(d.loyerHc));
    _chargesLocatives = TextEditingController(
      text: amountText(d.chargesLocatives),
    );
    _depot = TextEditingController(text: amountText(d.depotGarantie));
    _dateDebut = d.dateDebutBail;
    _dateFin = d.dateFinBail;
    _modeGestion = rentalManagementModes.contains(d.modeGestion)
        ? d.modeGestion
        : null;
    _fraisGestion = TextEditingController(text: amountText(d.fraisGestion));
    _taxeFonciere = TextEditingController(text: amountText(d.taxeFonciere));
    _assurancePno = TextEditingController(text: amountText(d.assurancePno));
    _chargesCopro = TextEditingController(
      text: amountText(d.chargesCopropriete),
    );
    _travaux = TextEditingController(text: amountText(d.travauxEntretien));
    _vacance = TextEditingController(text: amountText(d.vacanceLocative));
    _note = TextEditingController(text: d.note ?? '');
    _aUnCredit = d.aUnCredit;
    _montantCredit = TextEditingController(text: amountText(d.montantCredit));
    _tauxCredit = TextEditingController(text: amountText(d.tauxCreditPct));
    _mensualite = TextEditingController(text: amountText(d.mensualiteCredit));
    _duree = TextEditingController(
      text: d.dureeCreditMois == 0 ? '' : '${d.dureeCreditMois}',
    );
    _capitalRestant = TextEditingController(
      text: amountText(d.capitalRestantDu),
    );
    _assuranceEmprunteur = TextEditingController(
      text: amountText(d.assuranceEmprunteur),
    );
  }

  @override
  void dispose() {
    for (final c in [
      _locataire,
      _loyer,
      _chargesLocatives,
      _depot,
      _fraisGestion,
      _taxeFonciere,
      _assurancePno,
      _chargesCopro,
      _travaux,
      _vacance,
      _note,
      _montantCredit,
      _tauxCredit,
      _mensualite,
      _duree,
      _capitalRestant,
      _assuranceEmprunteur,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate({required bool debut}) async {
    final current = debut ? _dateDebut : _dateFin;
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
      helpText: debut ? 'Début du bail' : 'Fin du bail',
    );
    if (picked == null) return;
    setState(() {
      if (debut) {
        _dateDebut = picked;
      } else {
        _dateFin = picked;
      }
    });
  }

  RentalDraft _draft() => RentalDraft(
    statut: _statut,
    typeBail: _typeBail,
    locataire: _locataire.text,
    loyerHc: parseAmount(_loyer.text),
    chargesLocatives: parseAmount(_chargesLocatives.text),
    depotGarantie: parseAmount(_depot.text),
    dateDebutBail: _dateDebut,
    dateFinBail: _dateFin,
    modeGestion: _modeGestion,
    fraisGestion: parseAmount(_fraisGestion.text),
    taxeFonciere: parseAmount(_taxeFonciere.text),
    assurancePno: parseAmount(_assurancePno.text),
    chargesCopropriete: parseAmount(_chargesCopro.text),
    travauxEntretien: parseAmount(_travaux.text),
    vacanceLocative: parseAmount(_vacance.text),
    note: _note.text,
    aUnCredit: _aUnCredit,
    montantCredit: parseAmount(_montantCredit.text),
    tauxCreditPct: parseAmount(_tauxCredit.text),
    mensualiteCredit: parseAmount(_mensualite.text),
    dureeCreditMois: int.tryParse(_duree.text) ?? 0,
    capitalRestantDu: parseAmount(_capitalRestant.text),
    assuranceEmprunteur: parseAmount(_assuranceEmprunteur.text),
  );

  Future<void> _save() async {
    setState(() => _saving = true);
    await context.read<PortfolioController>().saveRental(
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
        title: const Text('Supprimer la location ?'),
        content: const Text(
          'Les informations de location de ce bien seront effacées.',
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
    await context.read<PortfolioController>().deleteRental(widget.asset.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location'),
        actions: [
          if (_hadRental)
            IconButton(
              tooltip: 'Supprimer la location',
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
            const FormSectionTitle(title: 'Bail'),
            Wrap(
              spacing: 8,
              children: rentalStatuses
                  .map(
                    (s) => ChoiceChip(
                      label: Text(rentalStatusLabel(s)),
                      selected: _statut == s,
                      onSelected: (_) => setState(() => _statut = s),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _typeBail,
              decoration: const InputDecoration(labelText: 'Type de bail'),
              items: rentalLeaseTypes
                  .map(
                    (t) => DropdownMenuItem(
                      value: t,
                      child: Text(rentalLeaseTypeLabel(t)),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _typeBail = v),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _locataire,
              decoration: const InputDecoration(labelText: 'Locataire'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _DateField(
                    label: 'Début du bail',
                    date: _dateDebut,
                    onTap: () => _pickDate(debut: true),
                    onClear: () => setState(() => _dateDebut = null),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DateField(
                    label: 'Fin du bail',
                    date: _dateFin,
                    onTap: () => _pickDate(debut: false),
                    onClear: () => setState(() => _dateFin = null),
                  ),
                ),
              ],
            ),
            const FormSectionTitle(title: 'Loyer et dépôt'),
            AmountField(
              controller: _loyer,
              label: 'Loyer hors charges (mensuel)',
              suffix: '€',
            ),
            const SizedBox(height: 12),
            AmountField(
              controller: _chargesLocatives,
              label: 'Charges locatives (mensuelles)',
              suffix: '€',
            ),
            const SizedBox(height: 12),
            AmountField(
              controller: _depot,
              label: 'Dépôt de garantie',
              suffix: '€',
            ),
            const FormSectionTitle(title: 'Gestion'),
            Wrap(
              spacing: 8,
              children: rentalManagementModes
                  .map(
                    (m) => ChoiceChip(
                      label: Text(rentalManagementModeLabel(m)),
                      selected: _modeGestion == m,
                      onSelected: (_) => setState(() => _modeGestion = m),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            AmountField(
              controller: _fraisGestion,
              label: 'Frais de gestion (mensuels)',
              suffix: '€',
            ),
            const FormSectionTitle(title: 'Charges et frais'),
            AmountField(
              controller: _taxeFonciere,
              label: 'Taxe foncière (annuelle)',
              suffix: '€',
            ),
            const SizedBox(height: 12),
            AmountField(
              controller: _assurancePno,
              label: 'Assurance PNO (annuelle)',
              suffix: '€',
            ),
            const SizedBox(height: 12),
            AmountField(
              controller: _chargesCopro,
              label: 'Charges de copropriété (annuelles)',
              suffix: '€',
            ),
            const SizedBox(height: 12),
            AmountField(
              controller: _travaux,
              label: 'Travaux et entretien (annuels)',
              suffix: '€',
            ),
            const SizedBox(height: 12),
            AmountField(
              controller: _vacance,
              label: 'Vacance locative (perte mensuelle)',
              suffix: '€',
            ),
            const FormSectionTitle(title: 'Crédit'),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Un crédit finance ce bien'),
              value: _aUnCredit,
              onChanged: (v) => setState(() => _aUnCredit = v),
            ),
            if (_aUnCredit) ...[
              AmountField(
                controller: _montantCredit,
                label: 'Montant emprunté',
                suffix: '€',
              ),
              const SizedBox(height: 12),
              AmountField(
                controller: _tauxCredit,
                label: 'Taux du crédit',
                suffix: '%',
              ),
              const SizedBox(height: 12),
              AmountField(
                controller: _mensualite,
                label: 'Mensualité (hors assurance)',
                suffix: '€',
              ),
              const SizedBox(height: 12),
              AmountField(
                controller: _duree,
                label: 'Durée restante',
                suffix: 'mois',
                integer: true,
              ),
              const SizedBox(height: 12),
              AmountField(
                controller: _capitalRestant,
                label: 'Capital restant dû',
                suffix: '€',
              ),
              const SizedBox(height: 12),
              AmountField(
                controller: _assuranceEmprunteur,
                label: 'Assurance emprunteur (mensuelle)',
                suffix: '€',
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
              'Rendement brut = loyer annuel hors charges / valeur du bien. '
              'Cashflow = loyer − charges − mensualité de crédit.',
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: date == null
              ? const Icon(Icons.calendar_today_outlined, size: 18)
              : IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: onClear,
                ),
        ),
        child: Text(
          date == null ? '—' : formatDate(date!),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
