import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central font switchboard.
///
/// Set [useGoogleFonts] to `false` in widget tests (together with
/// `GoogleFonts.config.allowRuntimeFetching = false`) so no network fetch is
/// attempted; the platform default font is used instead.
abstract final class AppFonts {
  static bool useGoogleFonts = true;

  /// Whether [locale] needs an Arabic-script UI font.
  static bool isArabicScript(Locale locale) =>
      const {'ar', 'fa', 'ur'}.contains(locale.languageCode);

  /// Latin UI font (Outfit).
  static TextStyle outfit([TextStyle? style]) =>
      useGoogleFonts
          ? GoogleFonts.outfit(textStyle: style)
          : (style ?? const TextStyle());

  /// Quranic / Arabic display font (Amiri).
  static TextStyle amiri([TextStyle? style]) =>
      useGoogleFonts
          ? GoogleFonts.amiri(textStyle: style)
          : (style ?? const TextStyle());

  /// Quran / Arabic text in the font the user chose (see
  /// `SettingsPrefs.quranFonts`). Unknown values use Amiri.
  static TextStyle quran(String font, [TextStyle? style]) {
    if (!useGoogleFonts) return style ?? const TextStyle();
    return switch (font) {
      'amiriQuran' => GoogleFonts.amiriQuran(textStyle: style),
      'scheherazadeNew' => GoogleFonts.scheherazadeNew(textStyle: style),
      'notoNaskhArabic' => GoogleFonts.notoNaskhArabic(textStyle: style),
      _ => GoogleFonts.amiri(textStyle: style),
    };
  }

  /// Display names for the Quran font picker (font names aren't translated).
  static const quranFontNames = {
    'amiri': 'Amiri',
    'amiriQuran': 'Amiri Quran',
    'scheherazadeNew': 'Scheherazade',
    'notoNaskhArabic': 'Noto Naskh',
  };

  /// Applies the locale-appropriate UI font family to [base].
  ///
  /// - ar / fa → Noto Naskh Arabic (Latin falls back to Outfit)
  /// - ur → Noto Nastaliq Urdu (Latin falls back to Outfit)
  /// - everything else → Outfit
  static TextTheme textTheme(TextTheme base, Locale locale) {
    if (!useGoogleFonts) return base;
    final latinFamily = GoogleFonts.outfit().fontFamily;
    final fallback = latinFamily == null ? null : <String>[latinFamily];
    switch (locale.languageCode) {
      case 'ar':
      case 'fa':
        return GoogleFonts.notoNaskhArabicTextTheme(
          base,
        ).apply(fontFamilyFallback: fallback);
      case 'ur':
        return GoogleFonts.notoNastaliqUrduTextTheme(
          base,
        ).apply(fontFamilyFallback: fallback);
      default:
        return GoogleFonts.outfitTextTheme(base);
    }
  }
}
