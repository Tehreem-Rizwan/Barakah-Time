import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';

const Color _skeletonBase = AppColors.cardDark;
const Color _skeletonHighlight = Color(0xFFF7F4EA);

/// A single rounded placeholder block. Use inside a [Skeleton] (or any
/// [Shimmer]) to animate.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({super.key, this.width, required this.height, this.radius});

  final double? width;
  final double height;

  /// Defaults to [AppRadius.sm].
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: _skeletonBase,
        borderRadius: BorderRadius.circular(radius ?? AppRadius.sm),
      ),
    );
  }
}

/// Wraps [child] (built from [SkeletonBox]es) in the app's shimmer and
/// announces "Loading…" to screen readers.
class Skeleton extends StatelessWidget {
  const Skeleton({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.l10n.loading,
      liveRegion: true,
      child: ExcludeSemantics(
        child: Shimmer.fromColors(
          baseColor: _skeletonBase,
          highlightColor: _skeletonHighlight,
          child: child,
        ),
      ),
    );
  }
}

/// Shimmering placeholder list mimicking rows of cards (avatar + 2 lines).
/// Drop-in replacement for a list while its data loads.
class SkeletonList extends StatelessWidget {
  const SkeletonList({
    super.key,
    this.itemCount = 6,
    this.itemHeight,
    this.showLeading = true,
    this.padding,
    this.shrinkWrap = false,
  });

  final int itemCount;

  /// Defaults to `72.h`.
  final double? itemHeight;
  final bool showLeading;

  /// Defaults to [AppSpacing.page].
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    final h = itemHeight ?? 72.h;
    return Skeleton(
      child: ListView.separated(
        padding: padding ?? AppSpacing.page,
        shrinkWrap: shrinkWrap,
        physics: shrinkWrap
            ? const NeverScrollableScrollPhysics()
            : const AlwaysScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (_, _) => SizedBox(height: AppSpacing.vMd),
        itemBuilder: (_, _) => Container(
          height: h,
          padding: AppSpacing.tile,
          decoration: BoxDecoration(
            color: AppColors.cardDark.withValues(alpha: 0.5),
            borderRadius: AppRadius.mdAll,
          ),
          child: Row(
            children: [
              if (showLeading) ...[
                SkeletonBox(width: 44.r, height: 44.r, radius: AppRadius.sm),
                SizedBox(width: AppSpacing.md),
              ],
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FractionallySizedBox(
                      widthFactor: 0.6,
                      child: SkeletonBox(height: 12.h, radius: 6.r),
                    ),
                    SizedBox(height: AppSpacing.vSm),
                    FractionallySizedBox(
                      widthFactor: 0.4,
                      child: SkeletonBox(height: 10.h, radius: 5.r),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
