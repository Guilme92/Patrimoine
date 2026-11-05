import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';

import '../../controllers/portfolio_controller.dart';
import '../../data/database.dart';
import '../../domain/portfolio.dart';
import '../../domain/rental.dart';
import '../../domain/startup.dart';
import '../../models/asset_type.dart';
import '../../models/rental.dart';
import '../../models/startup.dart';
import '../../theme/app_theme.dart';
import '../../theme/palette.dart';
import '../../utils/format.dart';
import '../widgets/form_widgets.dart';
import '../widgets/info_hint.dart';
import 'add_position_screen.dart';
import 'edit_asset_screen.dart';
import 'rental_form_screen.dart';
import 'startup_form_screen.dart';

class AssetDetailScreen extends StatelessWidget {
  final Asset asset;
  const AssetDetailScreen({super.key, required this.asset});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PortfolioController>();
    final current = controller.assetById(asset.id);
    if (current == null) {
      return Scaffold(
        appBar: AppBar(title: Text(asset.name)),
        body: const Center(child: Text('Cet actif a été supprimé.')),
      );
    }
    final positions = controller.positionsOf(current.id);
    final type = assetTypeFrom(current.type);
    final startup = controller.startupOf(current.id);
    final rounds = controller.fundingRoundsOf(current.id);
    final value = assetValue(
      asset: current,
      positions: positions,
      prices: controller.prices,
      startup: startup,
    );
    final rental = controller.rentalOf(current.id);
    final documents = controller.documentsOf(current.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(current.name),
        actions: [
          IconButton(
            tooltip: 'Supprimer',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, current.name),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _HeaderCard(
            asset: current,
            value: value,
            type: type,
            hint: startup != null
                ? 'Quantité × prix actuel (ou produit de sortie après une sortie)'
                : positions.isNotEmpty
                ? 'Somme des quantités × dernier prix connu'
                : 'Valeur saisie manuellement pour cet actif',
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditAssetScreen(asset: current),
                    ),
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Modifier'),
                ),
              ),
            ],
          ),
          if (type == AssetType.realEstate) ...[
            const SizedBox(height: 24),
            SectionHeader(
              title: 'Location',
              action: TextButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RentalFormScreen(asset: current),
                  ),
                ),
                icon: Icon(
                  rental == null ? Icons.add : Icons.edit_outlined,
                  size: 18,
                ),
                label: Text(rental == null ? 'Renseigner' : 'Modifier'),
              ),
            ),
            _RentalCard(rental: rental, assetValue: value),
          ],
          if (type == AssetType.startup) ...[
            const SizedBox(height: 24),
            SectionHeader(
              title: 'Startup',
              action: TextButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StartupDetailsFormScreen(asset: current),
                  ),
                ),
                icon: Icon(
                  startup == null ? Icons.add : Icons.edit_outlined,
                  size: 18,
                ),
                label: Text(startup == null ? 'Renseigner' : 'Modifier'),
              ),
            ),
            _StartupCard(startup: startup),
            const SizedBox(height: 20),
            SectionHeader(
              title: 'Levées de fonds',
              action: TextButton.icon(
                onPressed: startup == null
                    ? null
                    : () => _addFundingRound(context, current),
                icon: const Icon(Icons.add),
                label: const Text('Ajouter'),
              ),
            ),
            if (startup == null)
              Container(
                decoration: cardDecoration(),
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Renseignez d\'abord la fiche startup pour suivre ses '
                  'levées de fonds.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              )
            else if (rounds.isEmpty)
              Container(
                decoration: cardDecoration(),
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Aucune levée enregistrée.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              )
            else
              ...rounds.map(
                (r) => _FundingRoundTile(
                  round: r,
                  onDelete: () => _confirmDeleteRound(context, r),
                ),
              ),
          ],
          if (supportsPositions(type)) ...[
            const SizedBox(height: 24),
            SectionHeader(
              title: 'Positions',
              action: TextButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddPositionScreen(asset: current),
                  ),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Ajouter'),
              ),
            ),
            if (positions.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Aucune position. Ajoutez vos titres ou cryptos.'),
              )
            else
              ...positions.map(
                (p) => _PositionTile(
                  position: p,
                  price: controller.prices[p.symbol],
                ),
              ),
          ],
          const SizedBox(height: 24),
          SectionHeader(
            title: 'Documents',
            action: TextButton.icon(
              onPressed: () => _addDocument(context, current),
              icon: const Icon(Icons.upload_file_outlined),
              label: const Text('Ajouter'),
            ),
          ),
          if (documents.isEmpty)
            Container(
              decoration: cardDecoration(),
              padding: const EdgeInsets.all(16),
              child: Text(
                'Aucun document. Ajoutez un bail, une facture, un relevé…',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            )
          else
            ...documents.map(
              (d) => _DocumentTile(
                document: d,
                onOpen: () => _openDocument(context, d),
                onDelete: () => _confirmDeleteDocument(context, d),
              ),
            ),
          if (current.note != null && current.note!.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('Note', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(current.note!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String name) async {
    final controller = context.read<PortfolioController>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer ?'),
        content: Text(
          'Supprimer « $name » ainsi que ses positions, sa location '
          'et ses documents ?',
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
    if (ok == true) {
      await controller.deleteAsset(asset.id);
      if (context.mounted) Navigator.pop(context);
    }
  }

  Future<void> _addDocument(BuildContext context, Asset asset) async {
    final controller = context.read<PortfolioController>();
    PlatformFile? picked;
    try {
      picked = await FilePicker.pickFile(dialogTitle: 'Choisir un document');
    } catch (e) {
      if (context.mounted) _snack(context, 'Sélection impossible : $e');
      return;
    }
    if (picked == null) return;
    final sourcePath = picked.path;
    if (sourcePath == null) {
      if (context.mounted) {
        _snack(context, 'Ce fichier n\'est pas accessible sur l\'appareil.');
      }
      return;
    }
    if (!context.mounted) return;

    final defaultLabel = p.basenameWithoutExtension(picked.name);
    final label = await showDialog<String>(
      context: context,
      builder: (_) => _DocumentLabelDialog(
        fileName: picked!.name,
        initialLabel: defaultLabel,
      ),
    );
    if (label == null || !context.mounted) return;

    try {
      await controller.attachDocument(
        assetId: asset.id,
        file: File(sourcePath),
        label: label,
      );
      if (context.mounted) _snack(context, 'Document ajouté.');
    } catch (e) {
      if (context.mounted) _snack(context, 'Échec de l\'ajout : $e');
    }
  }

  Future<void> _openDocument(BuildContext context, AssetDocument doc) async {
    final exists = await File(doc.filePath).exists();
    if (!exists) {
      if (context.mounted) {
        _snack(context, 'Fichier introuvable sur le disque.');
      }
      return;
    }
    final result = await OpenFile.open(doc.filePath);
    if (result.type != ResultType.done && context.mounted) {
      _snack(context, 'Ouverture impossible : ${result.message}');
    }
  }

  Future<void> _confirmDeleteDocument(
    BuildContext context,
    AssetDocument doc,
  ) async {
    final controller = context.read<PortfolioController>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer le document ?'),
        content: Text('« ${doc.label} » sera retiré et son fichier supprimé.'),
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
    if (ok != true) return;
    await controller.removeDocument(doc);
    if (context.mounted) _snack(context, 'Document supprimé.');
  }

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _addFundingRound(BuildContext context, Asset asset) async {
    final controller = context.read<PortfolioController>();
    final draft = await showDialog<FundingRoundDraft>(
      context: context,
      builder: (_) => const FundingRoundDialog(),
    );
    if (draft == null || !context.mounted) return;
    await controller.addFundingRound(assetId: asset.id, draft: draft);
    if (context.mounted) _snack(context, 'Levée de fonds ajoutée.');
  }

  Future<void> _confirmDeleteRound(
    BuildContext context,
    FundingRound round,
  ) async {
    final controller = context.read<PortfolioController>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer la levée ?'),
        content: const Text('Cette levée sera retirée de la fiche startup.'),
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
    if (ok != true) return;
    await controller.deleteFundingRound(round.id);
    if (context.mounted) _snack(context, 'Levée supprimée.');
  }
}

class _HeaderCard extends StatelessWidget {
  final Asset asset;
  final double value;
  final AssetType type;
  final String hint;
  const _HeaderCard({
    required this.asset,
    required this.value,
    required this.type,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: cardDecoration(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(assetTypeIcon(type), color: assetTypeColors[type]),
              const SizedBox(width: 8),
              Text(
                assetTypeLabel(type),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Flexible(
                child: Text(
                  formatEuro(value),
                  style: Theme.of(context).textTheme.headlineMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              InfoHint(hint),
            ],
          ),
          if (asset.institution != null) ...[
            const SizedBox(height: 4),
            Text(
              asset.institution!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

class _RentalCard extends StatelessWidget {
  final Rental? rental;
  final double assetValue;

  const _RentalCard({required this.rental, required this.assetValue});

  @override
  Widget build(BuildContext context) {
    final r = rental;
    if (r == null) {
      return Container(
        decoration: cardDecoration(),
        padding: const EdgeInsets.all(16),
        child: Text(
          'Renseignez le bail, le loyer et les charges pour suivre le '
          'rendement et le cashflow de ce bien.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }

    final cashflow = monthlyCashflow(r);
    final cashflowColor = cashflow >= 0
        ? AppColors.positive
        : AppColors.negative;
    final rented = r.statut == 'loue';
    final bail = _bailPeriod(r);

    return Container(
      decoration: cardDecoration(),
      child: Material(
        type: MaterialType.transparency,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color:
                          (rented
                                  ? AppColors.positive
                                  : AppColors.textSecondary)
                              .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      rentalStatusLabel(r.statut),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: rented
                            ? AppColors.positive
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      rentalLeaseTypeLabel(r.typeBail),
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _Metric(
                      label: 'Rendement brut',
                      hint: 'Loyer annuel hors charges ÷ valeur du bien',
                      value: formatShare(grossYieldPct(r, assetValue)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _Metric(
                      label: 'Cashflow / mois',
                      hint: 'Loyer − charges du propriétaire − mensualité '
                          'de crédit',
                      value: formatSignedEuro(cashflow),
                      color: cashflowColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: _Metric(
                      label: 'Rendement net',
                      hint: '(Loyer annuel − charges annuelles) ÷ valeur '
                          'du bien',
                      value: formatShare(netYieldPct(r, assetValue)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _Metric(
                      label: 'Loyer HC / mois',
                      hint: 'Loyer hors charges saisi dans le bail',
                      value: formatEuro(r.loyerHc),
                    ),
                  ),
                ],
              ),
              const Divider(height: 28, color: AppColors.divider),
              if (r.locataire != null && r.locataire!.isNotEmpty)
                InfoRow(label: 'Locataire', value: r.locataire!),
              if (bail != null) InfoRow(label: 'Bail', value: bail),
              InfoRow(
                label: 'Gestion',
                value: r.modeGestion == null
                    ? 'Non renseignée'
                    : rentalManagementModeLabel(r.modeGestion),
              ),
              InfoRow(
                label: 'Charges locatives',
                value: '${formatEuro(r.chargesLocatives)} / mois',
              ),
              InfoRow(
                label: 'Dépôt de garantie',
                value: _money(r.depotGarantie),
              ),
              InfoRow(
                label: 'Charges et frais du propriétaire',
                value: '${formatEuro(monthlyOwnerCharges(r))} / mois',
              ),
              if (r.aUnCredit)
                InfoRow(
                  label: 'Mensualité de crédit',
                  value: '${formatEuro(monthlyLoanPayment(r))} / mois',
                ),
              Theme(
                data: Theme.of(context)
                    .copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: const EdgeInsets.only(bottom: 4),
                  iconColor: AppColors.textSecondary,
                  collapsedIconColor: AppColors.textSecondary,
                  title: Text(
                    'Détail des charges et du crédit',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  children: [
                    InfoRow(
                      label: 'Taxe foncière (annuelle)',
                      value: _money(r.taxeFonciere),
                    ),
                    InfoRow(
                      label: 'Assurance PNO (annuelle)',
                      value: _money(r.assurancePno),
                    ),
                    InfoRow(
                      label: 'Charges de copropriété (annuelles)',
                      value: _money(r.chargesCopropriete),
                    ),
                    InfoRow(
                      label: 'Travaux et entretien (annuels)',
                      value: _money(r.travauxEntretien),
                    ),
                    InfoRow(
                      label: 'Frais de gestion (mensuels)',
                      value: _money(r.fraisGestion),
                    ),
                    InfoRow(
                      label: 'Vacance locative (mensuelle)',
                      value: _money(r.vacanceLocative),
                    ),
                    if (r.aUnCredit) ...[
                      const Divider(height: 20, color: AppColors.divider),
                      InfoRow(
                        label: 'Montant emprunté',
                        value: _money(r.montantCredit),
                      ),
                      InfoRow(
                        label: 'Taux du crédit',
                        value: r.tauxCreditPct > 0
                            ? '${r.tauxCreditPct.toStringAsFixed(2)} %'
                            : '—',
                      ),
                      InfoRow(
                        label: 'Mensualité hors assurance',
                        value: _money(r.mensualiteCredit),
                      ),
                      InfoRow(
                        label: 'Assurance emprunteur (mensuelle)',
                        value: _money(r.assuranceEmprunteur),
                      ),
                      InfoRow(
                        label: 'Durée restante',
                        value: r.dureeCreditMois > 0
                            ? '${r.dureeCreditMois} mois'
                            : '—',
                      ),
                      InfoRow(
                        label: 'Capital restant dû',
                        value: _money(r.capitalRestantDu),
                      ),
                    ],
                  ],
                ),
              ),
              if (r.note != null && r.note!.isNotEmpty) ...[
                const Divider(height: 24, color: AppColors.divider),
                Text(r.note!, style: Theme.of(context).textTheme.bodySmall),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _money(double v) => v > 0 ? formatEuro(v) : '—';

  String? _bailPeriod(Rental r) {
    final start = r.dateDebutBail;
    final end = r.dateFinBail;
    if (start == null && end == null) return null;
    if (start != null && end != null) {
      return '${formatDate(start)} → ${formatDate(end)}';
    }
    if (start != null) return 'Depuis le ${formatDate(start)}';
    return 'Jusqu\'au ${formatDate(end!)}';
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final String? hint;
  final Color? color;
  const _Metric({
    required this.label,
    required this.value,
    this.hint,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (hint != null) InfoHint(hint!, size: 13),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  final AssetDocument document;
  final VoidCallback onOpen;
  final VoidCallback onDelete;
  const _DocumentTile({
    required this.document,
    required this.onOpen,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onOpen,
      child: Container(
        decoration: cardDecoration(),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _iconFor(document.fileName),
                size: 20,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    document.label,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${document.fileName} · ${formatDate(document.createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'Actions',
              onSelected: (v) {
                if (v == 'open') onOpen();
                if (v == 'delete') onDelete();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'open',
                  child: ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.open_in_new),
                    title: Text('Ouvrir'),
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.delete_outline),
                    title: Text('Supprimer'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(String fileName) {
    final ext = p.extension(fileName).toLowerCase();
    switch (ext) {
      case '.pdf':
        return Icons.picture_as_pdf_outlined;
      case '.jpg':
      case '.jpeg':
      case '.png':
      case '.heic':
        return Icons.image_outlined;
      case '.doc':
      case '.docx':
      case '.odt':
        return Icons.description_outlined;
      case '.xls':
      case '.xlsx':
      case '.csv':
        return Icons.table_chart_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }
}

class _DocumentLabelDialog extends StatefulWidget {
  final String fileName;
  final String initialLabel;
  const _DocumentLabelDialog({
    required this.fileName,
    required this.initialLabel,
  });

  @override
  State<_DocumentLabelDialog> createState() => _DocumentLabelDialogState();
}

class _DocumentLabelDialogState extends State<_DocumentLabelDialog> {
  late final TextEditingController _label = TextEditingController(
    text: widget.initialLabel,
  );

  @override
  void dispose() {
    _label.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ajouter un document'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.fileName,
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _label,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Libellé'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: () {
            final label = _label.text.trim();
            Navigator.pop(context, label.isEmpty ? widget.initialLabel : label);
          },
          child: const Text('Ajouter'),
        ),
      ],
    );
  }
}

class _PositionTile extends StatelessWidget {
  final Position position;
  final double? price;
  const _PositionTile({required this.position, this.price});

  @override
  Widget build(BuildContext context) {
    final p = price ?? position.unitCost;
    final pnl = positionPnl(position, p);
    final pnlPct = positionPnlPct(position, p);
    final positive = pnl >= 0;
    final color = positive ? AppColors.positive : AppColors.negative;
    return Container(
      decoration: cardDecoration(),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  position.name,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${_fmtQty(position.quantity)} × ${formatEuro(position.unitCost, cents: true)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatEuro(positionValue(position, p)),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${formatSignedEuro(pnl)} (${formatPct(pnlPct)})',
                    style: TextStyle(color: color, fontSize: 12),
                  ),
                  const InfoHint('Quantité × (prix − PRU)', size: 12),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _fmtQty(double q) {
    final s = q.toStringAsFixed(6);
    return s.replaceFirst(RegExp(r'\.?0+$'), '');
  }
}

/// Fiche startup + indicateurs (KPIs) calculés.
class _StartupCard extends StatelessWidget {
  final StartupDetail? startup;
  const _StartupCard({required this.startup});

  @override
  Widget build(BuildContext context) {
    final s = startup;
    if (s == null) {
      return Container(
        decoration: cardDecoration(),
        padding: const EdgeInsets.all(16),
        child: Text(
          'Renseignez l\'instrument, la quantité, le prix d\'entrée puis le prix '
          'actuel (saisi à la main) pour suivre la valorisation, la plus-value, '
          'le multiple et le TRI de cette startup.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }

    final invested = investedCapital(s);
    final value = lineValue(s);
    final gain = unrealizedGain(s);
    final gainPct = unrealizedGainPct(s);
    final exited = s.statut == 'sorti';
    final gainColor = gain >= 0 ? AppColors.positive : AppColors.negative;
    final statusColor = switch (s.statut) {
      'sorti' => AppColors.primary,
      'radie' => AppColors.negative,
      _ => AppColors.textSecondary,
    };

    return Container(
      decoration: cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  startupStatusLabel(s.statut),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  startupInstrumentLabel(s.typeTitre),
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _Metric(
                  label: 'Capital investi',
                  hint: 'Quantité × prix d\'entrée + frais',
                  value: formatEuro(invested),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Metric(
                  label: 'Valorisation',
                  hint: 'Quantité × prix actuel (ou produit de sortie '
                      'si sortie)',
                  value: formatEuro(value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _Metric(
                  label: exited ? 'Plus-value réalisée' : 'PV latente',
                  hint: exited
                      ? 'Produit de sortie − capital investi'
                      : 'Valorisation − capital investi',
                  value: exited
                      ? formatSignedEuro(realizedGain(s))
                      : '${formatSignedEuro(gain)} (${formatPct(gainPct)})',
                  color: gainColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Metric(
                  label: 'Multiple (MOIC)',
                  hint: 'Valorisation ÷ capital investi '
                      '(1× = capital remboursé)',
                  value: '${moic(s).toStringAsFixed(2)}×',
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _Metric(
                  label: 'TRI annualisé',
                  hint: 'Rendement annualisé : '
                      '(Valorisation ÷ capital investi)^(1/années) − 1',
                  value: formatPct(triAnnualizedPct(s)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Metric(
                  label: 'Stade',
                  value: startupStageLabel(s.stade),
                ),
              ),
            ],
          ),
          const Divider(height: 28, color: AppColors.divider),
          InfoRow(label: 'Quantité', value: _qty(s.quantite)),
          InfoRow(
            label: 'Prix d\'entrée',
            value: formatEuro(s.prixEntree, cents: true),
          ),
          InfoRow(label: 'Frais', value: formatEuro(s.frais, cents: true)),
          if (s.dateInvestissement != null)
            InfoRow(
              label: 'Date d\'investissement',
              value: formatDate(s.dateInvestissement!),
            ),
          InfoRow(
            label: 'Prix actuel (manuel)',
            value: formatEuro(s.prixActuel, cents: true),
          ),
          if (s.dateValorisation != null)
            InfoRow(
              label: 'Date de valorisation',
              value: formatDate(s.dateValorisation!),
            ),
          if (s.valorisationEntreprise > 0)
            InfoRow(
              label: 'Valorisation de l\'entreprise',
              value: formatEuro(s.valorisationEntreprise),
            ),
          if (exited) ...[
            InfoRow(
              label: 'Mode de sortie',
              value: startupExitModeLabel(s.exitMode),
            ),
            if (s.exitDate != null)
              InfoRow(
                label: 'Date de sortie',
                value: formatDate(s.exitDate!),
              ),
            InfoRow(
              label: 'Produit de sortie',
              value: formatEuro(s.exitProduit),
            ),
          ],
          if (s.note != null && s.note!.isNotEmpty) ...[
            const Divider(height: 24, color: AppColors.divider),
            Text(s.note!, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }

  String _qty(double q) {
    final txt = q.toStringAsFixed(6);
    return txt.replaceFirst(RegExp(r'\.?0+$'), '');
  }
}

/// Une levée de fonds de la startup.
class _FundingRoundTile extends StatelessWidget {
  final FundingRound round;
  final VoidCallback onDelete;
  const _FundingRoundTile({required this.round, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: cardDecoration(),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 6, 6, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  round.date == null
                      ? 'Levée non datée'
                      : 'Levée du ${formatDate(round.date!)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                tooltip: 'Supprimer',
                icon: const Icon(Icons.delete_outline, size: 20),
                onPressed: onDelete,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Column(
              children: [
                InfoRow(
                  label: 'Montant levé',
                  value: formatEuro(round.montantLeve),
                ),
                InfoRow(
                  label: 'Valorisation post-money',
                  value: round.valorisationPostMoney > 0
                      ? formatEuro(round.valorisationPostMoney)
                      : '—',
                ),
                InfoRow(
                  label: 'Prix par action',
                  value: round.prixParAction > 0
                      ? formatEuro(round.prixParAction, cents: true)
                      : '—',
                ),
                if (round.note != null && round.note!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      round.note!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
