import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';

/// Frosted-glass surface used throughout the app.
///
/// Defaults: radius [AppRadius.lg] (24.r), [AppColors.glassStroke] border,
/// white 10%→5% gradient fill. Pass [color] to tint the gradient.
class GlassBox extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;

  /// Defaults to `AppRadius.lgAll` (24.r). Ignored for [BoxShape.circle].
  final BorderRadius? borderRadius;

  /// When false, no BackdropFilter is used and a cheap translucent fill is
  /// drawn instead. Use `blur: false` for items in long scrolling lists.
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
    final effectiveBorderRadius =
        shape == BoxShape.circle
            ? null
            : (borderRadius ?? AppRadius.lgAll);

    final decoration = BoxDecoration(
      shape: shape,
      borderRadius: effectiveBorderRadius,
      border:
          border ??
          Border.all(color: AppColors.glassStroke, width: 1.5),
      gradient: LinearGradient(
        begin: AlignmentDirectional.topStart,
        end: AlignmentDirectional.bottomEnd,
        colors: color == null
            ? const [AppColors.glassFill, AppColors.glassBase]
            : [
                color!.withValues(alpha: 0.1),
                color!.withValues(alpha: 0.05),
              ],
      ),
    );

    if (!blur) {
      return Container(
        width: width,
        height: height,
        padding: padding,
        clipBehavior: Clip.antiAlias,
        decoration: decoration,
        child: child,
      );
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        shape: shape,
        borderRadius: effectiveBorderRadius,
      ),
      child: ClipPath(
        clipper: _GlassClipper(
          shape: shape,
          borderRadius: effectiveBorderRadius,
        ),
        child: Stack(
          children: [
            // Blur effect
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
                child: const ColoredBox(color: Colors.transparent),
              ),
            ),
            // Gradient overlay with child
            Container(padding: padding, decoration: decoration, child: child),
          ],
        ),
      ),
    );
  }
}

class _GlassClipper extends CustomClipper<Path> {
  final BoxShape shape;
  final BorderRadius? borderRadius;

  _GlassClipper({required this.shape, this.borderRadius});

  @override
  Path getClip(Size size) {
    final path = Path();
    if (shape == BoxShape.circle) {
      final center = Offset(size.width / 2, size.height / 2);
      final radius = math.min(size.width / 2, size.height / 2);
      path.addOval(Rect.fromCircle(center: center, radius: radius));
    } else {
      path.addRRect(
        (borderRadius ?? BorderRadius.zero).toRRect(
          Rect.fromLTWH(0, 0, size.width, size.height),
        ),
      );
    }
    return path;
  }

  @override
  bool shouldReclip(covariant _GlassClipper oldClipper) =>
      oldClipper.shape != shape || oldClipper.borderRadius != borderRadius;
}
