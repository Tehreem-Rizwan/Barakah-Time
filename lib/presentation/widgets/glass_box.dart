import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GlassBox extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final double blur;
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
    this.blur = 15,
    this.color,
    this.border,
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius =
        shape == BoxShape.circle
            ? null
            : (borderRadius ?? BorderRadius.circular(24));

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
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
              child: Container(
                decoration: const BoxDecoration(color: Colors.transparent),
              ),
            ),
            // Gradient overlay with child
            Container(
              padding: padding,
              decoration: BoxDecoration(
                shape: shape,
                borderRadius: effectiveBorderRadius,
                border:
                    border ??
                    Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1.5,
                    ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    (color ?? Colors.white).withOpacity(0.1),
                    (color ?? Colors.white).withOpacity(0.05),
                  ],
                ),
              ),
              child: child,
            ),
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
        (borderRadius ?? BorderRadius.circular(24.r)).toRRect(
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
