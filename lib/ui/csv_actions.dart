import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/portfolio_controller.dart';
import '../data/csv_import.dart';

/// Ouvre le sélecteur de fichier CSV, détecte son type (immobilier ou
/// startups) puis l'importe. Utilisé par la barre supérieure (bouton global)
/// et par le menu de l'écran des actifs.
Future<void> importCsvFromPicker(BuildContext context) async {
  final controller = context.read<PortfolioController>();
  PlatformFile? picked;
  try {
    picked = await FilePicker.pickFile(
      dialogTitle: 'Choisir un fichier CSV',
      type: FileType.custom,
      allowedExtensions: const ['csv'],
    );
  } catch (e) {
    if (context.mounted) _snack(context, 'Sélection impossible : $e');
    return;
  }
  if (picked == null) return;

  final String content;
  try {
    final bytes = await picked.readAsBytes();
    content = utf8.decode(bytes, allowMalformed: true);
  } catch (e) {
    if (context.mounted) _snack(context, 'Lecture impossible : $e');
    return;
  }
  if (!context.mounted) return;

  final type = detectCsvAssetType(content);
  if (type == null) {
    _snack(
      context,
      'Colonnes non reconnues : utilisez un modèle CSV de l\'application.',
    );
    return;
  }

  final CsvImportResult result;
  try {
    result = await controller.importCsv(csv: content, type: type);
  } catch (e) {
    if (context.mounted) _snack(context, 'Import impossible : $e');
    return;
  }
  if (!context.mounted) return;

  final parts = <String>[
    result.imported == 1 ? '1 actif importé' : '${result.imported} actifs importés',
  ];
  if (result.updated > 0) {
    parts.add(result.updated == 1 ? '1 mis à jour' : '${result.updated} mis à jour');
  }
  if (result.skipped > 0) {
    parts.add(result.skipped == 1 ? '1 ligne ignorée' : '${result.skipped} lignes ignorées');
  }
  _snack(context, parts.join(' · '));
}

void _snack(BuildContext context, String message) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
