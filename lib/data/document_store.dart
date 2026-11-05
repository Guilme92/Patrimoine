import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Stockage local des pièces jointes : chaque fichier est copié dans
/// `<documents>/documents/<assetId>/<fileName>`.
class DocumentStore {
  const DocumentStore();

  Future<Directory> _assetDir(int assetId) async {
    final root = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(root.path, 'documents', '$assetId'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Copie [source] dans le dossier du bien et renvoie le fichier créé.
  /// En cas de collision de nom, un suffixe `_1`, `_2`… est ajouté.
  Future<File> copyIn({
    required int assetId,
    required File source,
    String? fileName,
  }) async {
    final dir = await _assetDir(assetId);
    final raw = (fileName == null || fileName.trim().isEmpty)
        ? p.basename(source.path)
        : p.basename(fileName.trim());
    final ext = p.extension(raw);
    final stem = p.basenameWithoutExtension(raw);

    var target = File(p.join(dir.path, raw));
    var i = 1;
    while (await target.exists()) {
      target = File(p.join(dir.path, '${stem}_$i$ext'));
      i++;
    }
    return source.copy(target.path);
  }

  /// Supprime le fichier s'il existe encore (sans lever d'erreur).
  Future<void> deleteFile(String path) async {
    try {
      final f = File(path);
      if (await f.exists()) await f.delete();
    } catch (_) {
      // Un fichier déjà absent ou verrouillé ne doit pas bloquer la suppression
      // de la ligne en base.
    }
  }
}
