/// Helpers for searching and cleaning Arabic text.
class ArabicText {
  ArabicText._();

  // Harakat, tanween, shadda, sukun, Quranic annotation marks, superscript
  // alef, tatweel and byte-order marks.
  static final RegExp _diacritics = RegExp(
    '[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED\u0640\uFEFF\u200C\u200D\u200F]',
  );

  /// Removes diacritics and normalizes letter variants so that text typed
  /// without harakat matches fully vocalised text.
  static String normalize(String input) {
    return input
        .replaceAll(_diacritics, '')
        .replaceAll(RegExp('[\u0622\u0623\u0625\u0671\u0672\u0673]'), '\u0627')
        .replaceAll('ى', 'ي') // alef maqsura -> ya
        .replaceAll('ة', 'ه') // ta marbuta -> ha
        .replaceAll('ؤ', 'و')
        .replaceAll('ئ', 'ي')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static const List<String> _bismillahWords = [
    'بسم',
    'الله',
    'الرحمن',
    'الرحيم',
  ];

  /// The quran-uthmani edition prefixes ayah 1 of every surah (except
  /// Al-Fatiha, where it *is* ayah 1, and At-Tawbah, which has none) with the
  /// Bismillah. Returns [text] with that prefix removed, or unchanged when
  /// the first four words are not the Bismillah.
  static String stripBismillah(String text) {
    final words = RegExp(r'\S+').allMatches(text).take(4).toList();
    if (words.length < 4) return text;
    for (var i = 0; i < 4; i++) {
      if (normalize(words[i].group(0)!) != _bismillahWords[i]) return text;
    }
    final rest = text.substring(words[3].end).trim();
    return rest.isEmpty ? text : rest;
  }

  /// Whether ayah 1 of [surahNumber] carries a Bismillah prefix to strip.
  static bool surahHasBismillahPrefix(int surahNumber) =>
      surahNumber != 1 && surahNumber != 9;
}
