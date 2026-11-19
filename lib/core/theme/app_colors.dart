import 'package:flutter/material.dart';

/// Brand palette: "Islamic art" — pale stone surfaces, ivory cards,
/// deep turquoise (tile) ink and brass details, as in mosque tilework.
/// Surface/text/accent colours switch with [AppColors.isDark] (set by the
/// app root from the user's theme choice); brand ornaments stay `const`.
///
/// Historical names are kept so every screen picks the palette up:
/// [secondaryGold] is now the main accent (turquoise), [cardDark] the ivory
/// card, [backgroundSlate] the stone background.
///
/// Contrast notes (on [cardDark] ivory / [backgroundSlate] stone):
/// - [secondaryGold] (turquoise) 7.5:1 / 6.9:1 — text, icons, primary.
/// - [textMain] 13:1, [textSecondary] 6.3:1, [textTertiary] 4.6:1.
/// - [error] 6.4:1, [success] 5.5:1, [warning] 5.6:1, [info] 5.4:1.
/// - [brass] 2.3:1 — decorative only (borders, ornaments), never text.
///   For small gold text use [brassDeep] (4.8:1).
/// - On turquoise and status fills use [onGold] (white).
abstract final class AppColors {
  /// True while the dark palette is active. Set only by the app root
  /// (see `ThemeSync`), which then rebuilds the widget tree.
  static bool isDark = false;

  static Color _pick(Color light, Color dark) => isDark ? dark : light;

  // Primary palette
  /// Tile turquoise for large fills (header band, gradients).
  static const Color primaryEmerald = Color(0xFF0E5A66);
  /// Same in both palettes so the splash matches the system splash.
  static const Color emeraldDeep = Color(0xFF0A4650);

  /// Main accent (turquoise). Name kept from the old gold palette.
  static Color get secondaryGold =>
      _pick(const Color(0xFF0E5A66), const Color(0xFF62C3CE));

  /// Foreground for content placed on [secondaryGold] and status fills.
  static Color get onGold =>
      _pick(const Color(0xFFFFFFFF), const Color(0xFF04282E));

  /// Brass ornament colour: arch borders, dividers, pattern lines.
  static const Color brass = Color(0xFFC9A45C);

  /// Darker brass, readable as small text on cards.
  static Color get brassDeep =>
      _pick(const Color(0xFF7E5F24), const Color(0xFFD9B872));

  /// Ivory text/ornaments placed on the turquoise header band.
  static const Color ivoryOnTeal = Color(0xFFF5EAD0);

  /// Icons/text on a [secondaryGold] fill (nav pill, earned badge):
  /// ivory in light, deep teal in dark (where the accent is light).
  static Color get onAccentFill => isDark ? onGold : ivoryOnTeal;

  // Neutral palette
  static Color get backgroundSlate =>
      _pick(const Color(0xFFEEF2EF), const Color(0xFF0C1B1D));

  /// Card surface. Name kept from the old dark palette.
  static Color get cardDark =>
      _pick(const Color(0xFFFFFDF6), const Color(0xFF15282B));
  static Color get textMain =>
      _pick(const Color(0xFF16302F), const Color(0xFFEDE7D6));
  static Color get textSecondary =>
      _pick(const Color(0xFF4A5F5D), const Color(0xFFB2C0BC));

  /// Low-emphasis text; hints and captions.
  static Color get textTertiary =>
      _pick(const Color(0xFF66787A), const Color(0xFF8C9C99));

  // Status (readable as text on the current surfaces)
  static Color get success =>
      _pick(const Color(0xFF1F7A4D), const Color(0xFF6FCF9A));
  static Color get error =>
      _pick(const Color(0xFFB3261E), const Color(0xFFF2B8B5));
  static Color get warning =>
      _pick(const Color(0xFF8F5400), const Color(0xFFF0B866));
  static Color get info =>
      _pick(const Color(0xFF1F6FA8), const Color(0xFF8CC4EE));

  // Status colours that read on dark surfaces (snackbar is dark ink).
  static const Color successOnDark = Color(0xFF8FD9B0);
  static const Color errorOnDark = Color(0xFFF2B8B5);
  static const Color infoOnDark = Color(0xFF8FD3DC);

  // Accents (legacy names, kept for existing callers)
  static Color get accentRose => error;
  static Color get accentGreen => success;

  // Surface tints (names kept from the old glass style; no blur anymore)
  /// Faint accent tint (4%).
  static Color get glassBase => secondaryGold.withValues(alpha: 0.04);

  /// Input fills, progress tracks, chip backgrounds (8% accent).
  static Color get glassFill =>
      secondaryGold.withValues(alpha: isDark ? 0.12 : 0.08);

  /// Hairline border for cards.
  static Color get glassStroke =>
      textMain.withValues(alpha: isDark ? 0.12 : 0.10);

  /// Stronger stroke / divider.
  static Color get glassStrokeStrong =>
      textMain.withValues(alpha: isDark ? 0.24 : 0.20);

  /// Soft gradient behind Home and hero screens.
  static LinearGradient get backgroundGradient => LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors:
        isDark
            ? const [Color(0xFF0F2023), Color(0xFF0A1719)]
            : const [Color(0xFFF3F6F3), Color(0xFFE9EEEA)],
  );
}
