import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';

/// Shared label/spinner row used by every button below.
class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    required this.loading,
    required this.spinnerColor,
    this.icon,
    this.leading,
  });

  final String label;
  final bool loading;
  final Color spinnerColor;
  final IconData? icon;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final lead = loading
        ? SizedBox(
            width: 20.r,
            height: 20.r,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: spinnerColor,
            ),
          )
        : leading ?? (icon != null ? Icon(icon, size: 20.sp) : null);
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (lead != null) ...[lead, SizedBox(width: AppSpacing.sm)],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

Widget _sized(bool expand, Widget child) =>
    expand ? SizedBox(width: double.infinity, child: child) : child;

/// Gold filled call-to-action (black text on gold). While [loading] the
/// button is disabled and shows a spinner; screen readers still hear
/// [label].
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;

  /// Stretch to the full available width.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    return _sized(
      expand,
      FilledButton(
        onPressed: loading ? null : onPressed,
        style: FilledButton.styleFrom(
          minimumSize: Size(64, AppSizes.buttonHeight.h),
        ),
        child: _ButtonContent(
          label: label,
          loading: loading,
          icon: icon,
          spinnerColor: AppColors.onGold,
        ),
      ),
    );
  }
}

/// Outlined gold button for secondary actions.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    return _sized(
      expand,
      OutlinedButton(
        onPressed: loading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: Size(64, AppSizes.buttonHeight.h),
        ),
        child: _ButtonContent(
          label: label,
          loading: loading,
          icon: icon,
          spinnerColor: AppColors.secondaryGold,
        ),
      ),
    );
  }
}

/// "Continue with Google" button following Google's dark-theme branding
/// (dark fill, grey stroke, multicolor G). [label] defaults to the
/// localized `continue_with_google`.
class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.label,
    this.loading = false,
  });

  final VoidCallback? onPressed;
  final String? label;
  final bool loading;

  // Google's light-theme button colours (brand guidelines).
  static const Color _fill = Color(0xFFFFFFFF);
  static const Color _stroke = Color(0xFF747775);
  static const Color _text = Color(0xFF1F1F1F);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: loading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: _fill,
          foregroundColor: _text,
          disabledBackgroundColor: _fill,
          disabledForegroundColor: _text.withValues(alpha: 0.6),
          side: const BorderSide(color: _stroke),
          minimumSize: Size(64, AppSizes.buttonHeight.h),
        ),
        child: _ButtonContent(
          label: label ?? context.l10n.continue_with_google,
          loading: loading,
          spinnerColor: _text,
          leading: ExcludeSemantics(child: GoogleLogo(size: 20.r)),
        ),
      ),
    );
  }
}

/// "Continue with Apple" button (black fill, white text, Apple glyph — the
/// style Apple asks for on light backgrounds).
/// [label] defaults to the localized `continue_with_apple`.
class AppleSignInButton extends StatelessWidget {
  const AppleSignInButton({
    super.key,
    required this.onPressed,
    this.label,
    this.loading = false,
  });

  final VoidCallback? onPressed;
  final String? label;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.black.withValues(alpha: 0.6),
          disabledForegroundColor: Colors.white70,
          minimumSize: Size(64, AppSizes.buttonHeight.h),
        ),
        child: _ButtonContent(
          label: label ?? context.l10n.continue_with_apple,
          loading: loading,
          spinnerColor: Colors.white,
          leading: Icon(Icons.apple, size: 22.sp),
        ),
      ),
    );
  }
}

/// The multicolor Google "G", painted (no asset required).
class GoogleLogo extends StatelessWidget {
  const GoogleLogo({super.key, this.size = 20});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _GoogleGPainter());
  }
}

class _GoogleGPainter extends CustomPainter {
  static const _blue = Color(0xFF4285F4);
  static const _green = Color(0xFF34A853);
  static const _yellow = Color(0xFFFBBC05);
  static const _red = Color(0xFFEA4335);

  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width, size.height);
    final stroke = s * 0.2;
    final center = Offset(size.width / 2, size.height / 2);
    final r = (s - stroke) / 2;
    final rect = Rect.fromCircle(center: center, radius: r);
    double deg(double d) => d * math.pi / 180;

    Paint arc(Color c) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt
      ..isAntiAlias = true;

    // Angles: 0° = 3 o'clock, positive = clockwise. The G's opening is
    // the gap between 315° (-45°) and 0°, closed by the blue crossbar.
    canvas.drawArc(rect, deg(0), deg(45), false, arc(_blue));
    canvas.drawArc(rect, deg(45), deg(90), false, arc(_green));
    canvas.drawArc(rect, deg(135), deg(80), false, arc(_yellow));
    canvas.drawArc(rect, deg(215), deg(100), false, arc(_red));

    final bar = Paint()
      ..color = _blue
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawRect(
      Rect.fromLTRB(
        center.dx - stroke * 0.05,
        center.dy - stroke / 2,
        center.dx + r + stroke / 2,
        center.dy + stroke / 2,
      ),
      bar,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
