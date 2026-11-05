/// Correspondance tolérante entre une saisie libre (CSV, libellé français)
/// et les clés snake_case stockées en base.
library;

const Map<String, String> _diacritics = {
  'à': 'a', 'á': 'a', 'â': 'a', 'ä': 'a', 'ã': 'a', 'å': 'a',
  'ç': 'c',
  'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e',
  'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i',
  'ñ': 'n',
  'ò': 'o', 'ó': 'o', 'ô': 'o', 'ö': 'o', 'õ': 'o',
  'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u',
  'ý': 'y', 'ÿ': 'y',
  'œ': 'oe', 'æ': 'ae',
};

/// Mots sans valeur pour la comparaison (« bail meublé » ≈ « meublé »).
const Set<String> _fillerWords = {
  'de', 'du', 'des', 'la', 'le', 'les', 'l', 'd', 'un', 'une', 'en',
  'bail', 'gestion', 'mode', 'type', 'non',
};

/// Minuscules, sans accents, sans ponctuation ni mots de liaison.
String normalizeForMatch(String raw) {
  final tokens = stripAccents(raw)
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .split(' ')
      .where((t) => t.isNotEmpty && !_fillerWords.contains(t));
  return tokens.join();
}

/// Supprime les accents (é -> e, œ -> oe…) sans toucher au reste.
String stripAccents(String raw) {
  final buffer = StringBuffer();
  for (final rune in raw.runes) {
    final ch = String.fromCharCode(rune);
    buffer.write(_diacritics[ch] ?? ch);
  }
  return buffer.toString();
}

/// Retrouve la clé snake_case correspondant à [raw].
///
/// Accepte la clé elle-même, son libellé français ([labelOf]) ou une variante
/// proche (« bail meublé » -> `meuble`, « Gestion directe » -> `direct`).
/// Renvoie `null` si rien ne correspond (ou si [raw] est vide).
String? matchChoice(
  String? raw,
  List<String> keys,
  String Function(String?) labelOf,
) {
  final needle = normalizeForMatch(raw ?? '');
  if (needle.isEmpty) return null;

  for (final key in keys) {
    if (normalizeForMatch(key) == needle) return key;
  }
  for (final key in keys) {
    if (normalizeForMatch(labelOf(key)) == needle) return key;
  }
  for (final key in keys) {
    final k = normalizeForMatch(key);
    if (k.length >= 3 && (needle.contains(k) || k.contains(needle))) {
      return key;
    }
  }
  for (final key in keys) {
    final label = normalizeForMatch(labelOf(key));
    if (label.length >= 3 &&
        (needle.contains(label) || label.contains(needle))) {
      return key;
    }
  }
  return null;
}
