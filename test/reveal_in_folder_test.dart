import 'package:flutter_test/flutter_test.dart';
import 'package:patrimoine/utils/reveal_in_folder.dart';

void main() {
  test('un chemin vide ne lance aucune commande', () async {
    expect(await revealInFolder('   '), isFalse);
  });

  test('le support dépend de la plateforme de bureau', () {
    // Le test tourne sur l'hôte (Linux/macOS/Windows) : le support doit être
    // actif, et l'entrée de menu visible dans l'UI.
    expect(supportsRevealInFolder, isTrue);
  });
}
