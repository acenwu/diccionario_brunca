/// Search-time text normalization.
///
/// Both the stored text (when the seed is loaded) and the user's query go
/// through [foldForSearch], so they are always compared in the same form.
/// Folding is lossy on purpose and is used ONLY for matching: what the user
/// sees is always the original, exactly-transcribed text.
///
/// What it does:
///  - lowercases (SQLite's LIKE only ignores case for ASCII, so "Á" would
///    not match "á" without this);
///  - drops accents and tone marks: á → a, ü → u, ñ → n, and any combining
///    mark in U+0300–U+036F (this also turns n + U+0308, i.e. Boruca n̈, into n);
///  - maps ᵛ (U+1D5B, the Boruca glottal stop) to a plain v, so a phone
///    keyboard query "abuv" finds "abuᵛ";
///  - collapses runs of whitespace.
const Map<String, String> _foldMap = {
  'à': 'a', 'á': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a',
  'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e',
  'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i',
  'ò': 'o', 'ó': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o',
  'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u',
  'ñ': 'n',
  '\u1D5B': 'v', // ᵛ MODIFIER LETTER SMALL V (glottal stop)
  '\u2019': "'", // ’ typographic apostrophe
};

final RegExp _combiningMarks = RegExp(r'[\u0300-\u036F]');
final RegExp _whitespace = RegExp(r'\s+');

String foldForSearch(String input) {
  final lowered = input.toLowerCase();
  final buffer = StringBuffer();
  for (final rune in lowered.runes) {
    final ch = String.fromCharCode(rune);
    buffer.write(_foldMap[ch] ?? ch);
  }
  return buffer
      .toString()
      .replaceAll(_combiningMarks, '')
      .replaceAll(_whitespace, ' ')
      .trim();
}
