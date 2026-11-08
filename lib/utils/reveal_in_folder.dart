import 'dart:io';

import 'package:path/path.dart' as p;

/// Vrai si la plateforme sait ouvrir l'explorateur de fichiers sur un chemin.
///
/// L'app est desktop-first : Android et iOS n'ont pas d'explorateur de
/// fichiers partagé, l'option correspondante est donc masquée.
bool get supportsRevealInFolder =>
    Platform.isWindows || Platform.isMacOS || Platform.isLinux;

/// Ouvre le dossier contenant [path] dans l'explorateur du système et, quand
/// c'est possible, sélectionne le fichier :
///
///  - Windows : `explorer /select,<chemin>` ;
///  - macOS : `open -R <chemin>` ;
///  - Linux : `xdg-open <dossier parent>`.
///
/// Renvoie `true` si la commande a été lancée sans erreur, `false` sur une
/// plateforme non supportée, si le chemin est vide ou en cas d'échec. La
/// fonction ne lève jamais : les exceptions sont converties en `false` pour
/// que l'appelant puisse afficher un message.
Future<bool> revealInFolder(String path) async {
  final target = path.trim();
  if (target.isEmpty || !supportsRevealInFolder) return false;

  // Si le fichier a disparu entre-temps, on retombe sur le dossier parent,
  // puis sur son parent si celui-ci n'existe plus non plus.
  var fileExists = false;
  try {
    fileExists = await File(target).exists();
  } catch (_) {
    fileExists = false;
  }
  var folder = p.dirname(target);
  if (!fileExists) {
    try {
      if (!await Directory(folder).exists()) folder = p.dirname(folder);
    } catch (_) {
      // On garde le dossier calculé.
    }
  }

  try {
    if (Platform.isWindows) {
      // `explorer` renvoie souvent un code de sortie non nul même en cas de
      // succès : on ne se fie qu'à l'absence d'exception.
      await Process.run('explorer', ['/select,', fileExists ? target : folder]);
      return true;
    }
    if (Platform.isMacOS) {
      final result = await Process.run('open', [
        '-R',
        fileExists ? target : folder,
      ]);
      return result.exitCode == 0;
    }
    // Linux : xdg-open n'a pas d'option « sélectionner », on ouvre le dossier.
    final result = await Process.run('xdg-open', [folder]);
    return result.exitCode == 0;
  } on ProcessException {
    return false;
  } catch (_) {
    return false;
  }
}
