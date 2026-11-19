import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';

/// Card surface used throughout the app: flat ivory with a hairline border.
///
/// (Formerly a frosted-glass box; the blur was dropped because flat cards
/// read better on the light theme and are cheaper to draw. [blur] and
/// [blurSigma] are accepted for compatibility and ignored.)
///
/// Defaults: radius [AppRadius.lg], [AppColors.glassStroke] border.
/// Pass [color] to tint the card lightly.
class GlassBox extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;

  /// Defaults to `AppRadius.lgAll`. Ignored for [BoxShape.circle].
  final BorderRadius? borderRadius;
  final bool blur;
  final double blurSigma;
  final Color? color;
  final Border? border;
  final BoxShape shape;

  const GlassBox({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.blur = true,
    this.blurSigma = 15,
    this.color,
    this.border,
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    final c = color;
    return Container(
      width: width,
      height: height,
      padding: padding,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        shape: shape,
        borderRadius:
            shape == BoxShape.circle ? null : (borderRadius ?? AppRadius.lgAll),
        border: border ?? Border.all(color: AppColors.glassStroke),
        color:
            c == null
                ? AppColors.cardDark
                : Color.alphaBlend(
                  c.withValues(alpha: 0.08),
                  AppColors.cardDark,
                ),
      ),
      child: child,
    );
  }
}
