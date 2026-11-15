import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import 'glass_box.dart';

/// Tappable glass card: [GlassBox] + [Material] + [InkWell], with the ripple
/// clipped to the card's rounded corners.
///
/// [blur] defaults to `false` (cheap translucent fill), which is what you
/// want for list items; enable it for hero cards over imagery/gradients.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding,
    this.blur = false,
    this.borderRadius,
    this.color,
    this.border,
    this.width,
    this.height,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Inner padding; defaults to [AppSpacing.card] (16).
  final EdgeInsetsGeometry? padding;
  final bool blur;

  /// Defaults to [AppRadius.lgAll] (24.r).
  final BorderRadius? borderRadius;

  /// Tint for the glass gradient (see [GlassBox.color]).
  final Color? color;
  final Border? border;
  final double? width;
  final double? height;

  /// Optional accessibility label for the whole card when tappable.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppRadius.lgAll;
    final content = Padding(padding: padding ?? AppSpacing.card, child: child);
    final interactive = onTap != null || onLongPress != null;

    Widget card = GlassBox(
      blur: blur,
      borderRadius: radius,
      color: color,
      border: border,
      width: width,
      height: height,
      child: interactive
          ? Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: onTap,
                onLongPress: onLongPress,
                borderRadius: radius,
                splashColor: AppColors.secondaryGold.withValues(alpha: 0.12),
                highlightColor: AppColors.glassBase,
                child: content,
              ),
            )
          : content,
    );

    if (semanticLabel != null) {
      card = Semantics(
        label: semanticLabel,
        button: interactive,
        container: true,
        child: card,
      );
    }
    return card;
  }
}
