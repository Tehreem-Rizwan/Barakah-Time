import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Spacing scale (4-point grid), scaled with flutter_screenutil.
///
/// Horizontal values use `.w`, vertical values use `.h`. Use the `h*` getters
/// for widths/horizontal gaps and the `v*` getters for heights/vertical gaps.
/// The plain getters (`xs`, `sm`, ...) are scaled with `.w` and are a good
/// default for symmetric paddings.
///
/// Requires a `ScreenUtilInit` ancestor (already in `main.dart`).
abstract final class AppSpacing {
  // Raw (unscaled) values, handy for const contexts and theme definitions.
  static const double xsRaw = 4;
  static const double smRaw = 8;
  static const double mdRaw = 12;
  static const double lgRaw = 16;
  static const double xlRaw = 24;
  static const double xxlRaw = 32;

  // Default (width-scaled) values.
  static double get xs => xsRaw.w;
  static double get sm => smRaw.w;
  static double get md => mdRaw.w;
  static double get lg => lgRaw.w;
  static double get xl => xlRaw.w;
  static double get xxl => xxlRaw.w;

  // Vertical (height-scaled) values.
  static double get vXs => xsRaw.h;
  static double get vSm => smRaw.h;
  static double get vMd => mdRaw.h;
  static double get vLg => lgRaw.h;
  static double get vXl => xlRaw.h;
  static double get vXxl => xxlRaw.h;

  /// Horizontal page gutter used across screens (24 logical px).
  static double get pageGutter => xl;

  /// Page padding: 24w horizontal, 16h vertical.
  static EdgeInsetsDirectional get page =>
      EdgeInsetsDirectional.symmetric(horizontal: xl, vertical: vLg);

  /// Horizontal-only page padding (24w).
  static EdgeInsetsDirectional get pageHorizontal =>
      EdgeInsetsDirectional.symmetric(horizontal: xl);

  /// Default inner padding for cards (16).
  static EdgeInsetsDirectional get card =>
      EdgeInsetsDirectional.symmetric(horizontal: lg, vertical: vLg);

  /// Compact inner padding for list rows (16w x 12h).
  static EdgeInsetsDirectional get tile =>
      EdgeInsetsDirectional.symmetric(horizontal: lg, vertical: vMd);

  /// Uniform padding of a raw value, scaled (`.w` horizontal, `.h` vertical).
  static EdgeInsetsDirectional all(double raw) =>
      EdgeInsetsDirectional.symmetric(horizontal: raw.w, vertical: raw.h);

  /// Symmetric padding from raw values, scaled.
  static EdgeInsetsDirectional symmetric({
    double horizontal = 0,
    double vertical = 0,
  }) => EdgeInsetsDirectional.symmetric(
    horizontal: horizontal.w,
    vertical: vertical.h,
  );

  /// Directional padding from raw values, scaled.
  static EdgeInsetsDirectional only({
    double start = 0,
    double top = 0,
    double end = 0,
    double bottom = 0,
  }) => EdgeInsetsDirectional.only(
    start: start.w,
    top: top.h,
    end: end.w,
    bottom: bottom.h,
  );

  // Gap widgets.
  static Widget get gapXs => SizedBox(width: xs, height: vXs);
  static Widget get gapSm => SizedBox(width: sm, height: vSm);
  static Widget get gapMd => SizedBox(width: md, height: vMd);
  static Widget get gapLg => SizedBox(width: lg, height: vLg);
  static Widget get gapXl => SizedBox(width: xl, height: vXl);
  static Widget get gapXxl => SizedBox(width: xxl, height: vXxl);
}

/// Corner radius scale, scaled with `.r`.
abstract final class AppRadius {
  static const double smRaw = 12;
  static const double mdRaw = 16;
  static const double lgRaw = 24;
  static const double pillRaw = 999;

  static double get sm => smRaw.r;
  static double get md => mdRaw.r;
  static double get lg => lgRaw.r;
  static double get pill => pillRaw;

  static BorderRadius get smAll => BorderRadius.circular(sm);
  static BorderRadius get mdAll => BorderRadius.circular(md);
  static BorderRadius get lgAll => BorderRadius.circular(lg);
  static BorderRadius get pillAll => BorderRadius.circular(pill);

  /// Top-only radius for bottom sheets.
  static BorderRadius get sheetTop =>
      BorderRadius.vertical(top: Radius.circular(lg));
}

/// Animation durations and curves.
abstract final class AppDurations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration snackBar = Duration(seconds: 4);

  static const Curve curve = Curves.easeOutCubic;
}

/// Minimum interactive size (Material accessibility guideline).
abstract final class AppSizes {
  static const double minTapTarget = 48;
  static const double buttonHeight = 52;
}
