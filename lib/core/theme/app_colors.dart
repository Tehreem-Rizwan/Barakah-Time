import 'package:flutter/material.dart';

/// Brand palette. All values are `const`.
///
/// Contrast notes (on [backgroundSlate]):
/// - [secondaryGold] 7.3:1 — safe for text, icons and as the primary color.
/// - [textMain] 17:1, [textSecondary] 7.0:1.
/// - [textTertiary] 5.1:1 on slate but only 4.2:1 on [cardDark] — use for
///   hints, captions on slate, or large text (>= 18sp) on cards.
/// - [error] 4.9:1, [success] 7.0:1, [warning] 8.3:1.
/// - [primaryEmerald] 1.8:1 — decorative only (gradients, fills), never for
///   text or indicators on slate.
/// - On gold (and on [error]/[success]/[warning] fills), use [onGold]
///   (black, 8.6:1 on gold), never white (2.5:1).
abstract final class AppColors {
  // Primary palette
  static const Color primaryEmerald = Color(0xFF004D40);
  static const Color emeraldDeep = Color(0xFF00382E);
  static const Color secondaryGold = Color(0xFFC5A059);

  /// Foreground for content placed on [secondaryGold].
  static const Color onGold = Color(0xFF000000);

  // Neutral palette
  static const Color backgroundSlate = Color(0xFF0F172A);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color textMain = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);

  /// Low-emphasis text; large text / hints only.
  static const Color textTertiary = Color(0xFF7C8AA0);

  // Status
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFF43F5E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF38BDF8);

  // Accents (legacy names, kept for existing callers)
  static const Color accentRose = Color(0xFFE11D48);
  static const Color accentGreen = Color(0xFF10B981);

  // Glassmorphism
  /// Base translucent fill (white @ 5%).
  static const Color glassBase = Color(0x0DFFFFFF);

  /// Slightly stronger glass fill (white @ 10%), top of the glass gradient
  /// and the fill for inputs.
  static const Color glassFill = Color(0x1AFFFFFF);

  /// Hairline border for glass surfaces (white @ 10%).
  static const Color glassStroke = Color(0x1AFFFFFF);

  /// Stronger stroke / divider (white @ 20%).
  static const Color glassStrokeStrong = Color(0x33FFFFFF);

  /// Emerald → slate background gradient used on Home and hero screens.
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: [emeraldDeep, backgroundSlate],
  );
}
