import 'package:flutter/material.dart';

/// Brand palette: "Islamic art" — pale stone surfaces, ivory cards,
/// deep turquoise (tile) ink and brass details, as in mosque tilework.
/// All values are `const`.
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
  // Primary palette
  /// Tile turquoise for large fills (header band, gradients).
  static const Color primaryEmerald = Color(0xFF0E5A66);
  static const Color emeraldDeep = Color(0xFF0A4650);

  /// Main accent (turquoise). Name kept from the old gold palette.
  static const Color secondaryGold = Color(0xFF0E5A66);

  /// Foreground for content placed on [secondaryGold] and status fills.
  static const Color onGold = Color(0xFFFFFFFF);

  /// Brass ornament colour: arch borders, dividers, pattern lines.
  static const Color brass = Color(0xFFC9A45C);

  /// Darker brass, readable as small text on ivory.
  static const Color brassDeep = Color(0xFF7E5F24);

  /// Ivory text/ornaments placed on the turquoise header band.
  static const Color ivoryOnTeal = Color(0xFFF5EAD0);

  // Neutral palette
  static const Color backgroundSlate = Color(0xFFEEF2EF);

  /// Card surface (ivory). Name kept from the old dark palette.
  static const Color cardDark = Color(0xFFFFFDF6);
  static const Color textMain = Color(0xFF16302F);
  static const Color textSecondary = Color(0xFF4A5F5D);

  /// Low-emphasis text; hints and captions.
  static const Color textTertiary = Color(0xFF66787A);

  // Status (dark enough for text on light surfaces)
  static const Color success = Color(0xFF1F7A4D);
  static const Color error = Color(0xFFB3261E);
  static const Color warning = Color(0xFF8F5400);
  static const Color info = Color(0xFF1F6FA8);

  // Accents (legacy names, kept for existing callers)
  static const Color accentRose = Color(0xFFB3261E);
  static const Color accentGreen = Color(0xFF1F7A4D);

  // Surface tints (names kept from the old glass style; no blur anymore)
  /// Faint turquoise tint (4%).
  static const Color glassBase = Color(0x0A0E5A66);

  /// Input fills, progress tracks, chip backgrounds (8% turquoise).
  static const Color glassFill = Color(0x140E5A66);

  /// Hairline border for cards (ink @ 10%).
  static const Color glassStroke = Color(0x1A16302F);

  /// Stronger stroke / divider (ink @ 20%).
  static const Color glassStrokeStrong = Color(0x3316302F);

  /// Soft stone gradient behind Home and hero screens.
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: [Color(0xFFF3F6F3), Color(0xFFE9EEEA)],
  );
}
