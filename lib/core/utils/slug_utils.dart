const _diacritics = 'áàäâãéèëêíìïîóòöôõúùüûñç';
const _plain = 'aaaaaeeeeiiiiooooouuuunc';

/// Convierte un nombre a id estable, ej. "Héctor Díaz" → "hector-diaz".
String slugify(String input) {
  final lower = input.trim().toLowerCase();
  final buffer = StringBuffer();
  for (final rune in lower.runes) {
    final char = String.fromCharCode(rune);
    final idx = _diacritics.indexOf(char);
    if (idx >= 0) {
      buffer.write(_plain[idx]);
    } else if (RegExp(r'[a-z0-9]').hasMatch(char)) {
      buffer.write(char);
    } else {
      buffer.write(' ');
    }
  }
  final slug = buffer.toString().trim().replaceAll(RegExp(r'\s+'), '-');
  return slug.isEmpty ? 'persona' : slug;
}

/// Garantiza unicidad frente a [existing] agregando sufijos -2, -3, …
String uniqueSlug(String base, Iterable<String> existing) {
  final taken = existing.toSet();
  if (!taken.contains(base)) return base;
  var i = 2;
  while (taken.contains('$base-$i')) {
    i++;
  }
  return '$base-$i';
}
