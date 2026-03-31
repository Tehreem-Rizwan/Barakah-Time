import 'dart:ui';
import 'package:flutter/material.dart';

class GlassBox extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final double blur;
  final Color? color;
  final Border? border;

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
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(24),
      child: Container(
        width: width,
        height: height,
        padding: padding,
        child: Stack(
          children: [
            // Blur effect
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
              child: Container(),
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: borderRadius ?? BorderRadius.circular(24),
                border: border ?? Border.all(
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
