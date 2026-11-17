import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_fonts.dart';
import 'app_tokens.dart';

/// App-wide light "Islamic art" theme (stone, ivory, turquoise, brass).
///
/// Use `AppTheme.dark(Locale(languageCode))` so Arabic-script locales get a
/// font with the right glyphs. [darkTheme] is kept for backward
/// compatibility and equals `dark(const Locale('en'))`.
///
/// Theme values are intentionally unscaled (no ScreenUtil) so the theme can
/// be built anywhere, including tests.
abstract final class AppTheme {
  /// Status bar over light pages: transparent, dark icons; the gesture /
  /// navigation bar matches the ivory tab bar.
  static const SystemUiOverlayStyle overlayOnLight = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.cardDark,
    systemNavigationBarIconBrightness: Brightness.dark,
    systemNavigationBarDividerColor: Colors.transparent,
  );

  /// Status bar over the turquoise header band (Home, Pulse): light icons.
  static const SystemUiOverlayStyle overlayOnBand = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: AppColors.cardDark,
    systemNavigationBarIconBrightness: Brightness.dark,
    systemNavigationBarDividerColor: Colors.transparent,
  );

  static ThemeData get darkTheme => dark(const Locale('en'));

  static const ColorScheme colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.secondaryGold,
    onPrimary: AppColors.onGold,
    primaryContainer: Color(0xFFD5EBEE),
    onPrimaryContainer: Color(0xFF06323A),
    secondary: AppColors.success,
    onSecondary: AppColors.onGold,
    secondaryContainer: Color(0xFFF1E5C8),
    onSecondaryContainer: Color(0xFF3D2E0E),
    tertiary: AppColors.info,
    onTertiary: AppColors.onGold,
    error: AppColors.error,
    onError: AppColors.onGold,
    errorContainer: Color(0xFFF9DEDC),
    onErrorContainer: Color(0xFF410E0B),
    surface: AppColors.backgroundSlate,
    onSurface: AppColors.textMain,
    onSurfaceVariant: AppColors.textSecondary,
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF7F8F4),
    surfaceContainer: Color(0xFFF3F5F1),
    surfaceContainerHigh: AppColors.cardDark,
    surfaceContainerHighest: Color(0xFFE6ECE8),
    outline: Color(0xFF7C8C8B),
    outlineVariant: AppColors.glassStrokeStrong,
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: AppColors.textMain,
    onInverseSurface: AppColors.backgroundSlate,
    inversePrimary: Color(0xFF8FD3DC),
    surfaceTint: Colors.transparent,
  );

  /// Base type scale (sizes/weights) before font family and color.
  static const TextTheme _typeScale = TextTheme(
    displayLarge: TextStyle(fontSize: 48, fontWeight: FontWeight.w700, height: 1.15),
    displayMedium: TextStyle(fontSize: 40, fontWeight: FontWeight.w700, height: 1.15),
    displaySmall: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, height: 1.2),
    headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, height: 1.25),
    headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, height: 1.25),
    headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, height: 1.3),
    titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, height: 1.3),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.35),
    titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1.4),
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5),
    bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1.45),
    labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, height: 1.3),
    labelMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, height: 1.3),
    labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, height: 1.3, letterSpacing: 0.4),
  );

  /// Builds the text theme for [locale] (colors + font family applied).
  static TextTheme textTheme(Locale locale) {
    final colored = _typeScale
        .apply(
          bodyColor: AppColors.textMain,
          displayColor: AppColors.textMain,
        )
        .copyWith(
          bodyMedium: _typeScale.bodyMedium!.copyWith(color: AppColors.textSecondary),
          bodySmall: _typeScale.bodySmall!.copyWith(color: AppColors.textSecondary),
          labelSmall: _typeScale.labelSmall!.copyWith(color: AppColors.textSecondary),
        );
    return AppFonts.textTheme(colored, locale);
  }

  /// The app's dark theme for [locale].
  ///
  /// Pass `useGoogleFonts: false` to skip Google Fonts (e.g. in tests);
  /// defaults to [AppFonts.useGoogleFonts].
  static ThemeData dark(Locale locale, {bool? useGoogleFonts}) {
    final previous = AppFonts.useGoogleFonts;
    if (useGoogleFonts != null) AppFonts.useGoogleFonts = useGoogleFonts;
    try {
      return _build(locale);
    } finally {
      AppFonts.useGoogleFonts = previous;
    }
  }

  static ThemeData _build(Locale locale) {
    const cs = colorScheme;
    final text = textTheme(locale);

    final mdShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.mdRaw),
    );
    final lgShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.lgRaw),
    );
    const minButtonSize = Size(64, AppSizes.buttonHeight);
    const buttonPadding = EdgeInsets.symmetric(horizontal: 24, vertical: 14);
    final buttonText = text.labelLarge!.copyWith(fontWeight: FontWeight.w700);

    OutlineInputBorder inputBorder(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.mdRaw),
          borderSide: BorderSide(color: color, width: width),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: cs,
      primaryColor: AppColors.secondaryGold,
      scaffoldBackgroundColor: AppColors.backgroundSlate,
      canvasColor: AppColors.backgroundSlate,
      cardColor: AppColors.cardDark,
      dividerColor: AppColors.glassStroke,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      textTheme: text,
      primaryTextTheme: text,
      iconTheme: const IconThemeData(color: AppColors.textMain, size: 24),
      primaryIconTheme: const IconThemeData(color: AppColors.secondaryGold),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.secondaryGold,
        selectionColor: AppColors.secondaryGold.withValues(alpha: 0.35),
        selectionHandleColor: AppColors.secondaryGold,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
        },
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        foregroundColor: AppColors.textMain,
        iconTheme: const IconThemeData(color: AppColors.secondaryGold),
        actionsIconTheme: const IconThemeData(color: AppColors.secondaryGold),
        titleTextStyle: text.titleLarge,
        systemOverlayStyle: AppTheme.overlayOnLight,
      ),

      cardTheme: CardThemeData(
        color: AppColors.cardDark,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: lgShape,
        clipBehavior: Clip.antiAlias,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondaryGold,
          foregroundColor: AppColors.onGold,
          disabledBackgroundColor: AppColors.secondaryGold.withValues(alpha: 0.35),
          disabledForegroundColor: AppColors.onGold.withValues(alpha: 0.55),
          elevation: 0,
          minimumSize: minButtonSize,
          padding: buttonPadding,
          shape: mdShape,
          textStyle: buttonText,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.secondaryGold,
          foregroundColor: AppColors.onGold,
          disabledBackgroundColor: AppColors.secondaryGold.withValues(alpha: 0.35),
          disabledForegroundColor: AppColors.onGold.withValues(alpha: 0.55),
          minimumSize: minButtonSize,
          padding: buttonPadding,
          shape: mdShape,
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.secondaryGold,
          disabledForegroundColor: AppColors.textTertiary,
          minimumSize: minButtonSize,
          padding: buttonPadding,
          shape: mdShape,
          side: BorderSide(
            color: AppColors.secondaryGold.withValues(alpha: 0.6),
          ),
          textStyle: buttonText,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.secondaryGold,
          disabledForegroundColor: AppColors.textTertiary,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          shape: mdShape,
          textStyle: text.labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.secondaryGold,
          disabledForegroundColor: AppColors.textTertiary,
          minimumSize: const Size(48, 48),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.secondaryGold,
        foregroundColor: AppColors.onGold,
        elevation: 2,
        shape: mdShape,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
          textStyle: WidgetStatePropertyAll(text.labelMedium),
          shape: WidgetStatePropertyAll(mdShape),
          side: const WidgetStatePropertyAll(
            BorderSide(color: AppColors.glassStrokeStrong),
          ),
          backgroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
                ? AppColors.secondaryGold
                : AppColors.glassBase,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
                ? AppColors.onGold
                : AppColors.textMain,
          ),
          iconColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
                ? AppColors.onGold
                : AppColors.textMain,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.glassFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        labelStyle: text.bodyMedium!.copyWith(color: AppColors.textSecondary),
        floatingLabelStyle: WidgetStateTextStyle.resolveWith(
          (s) => text.bodyMedium!.copyWith(
            color: s.contains(WidgetState.error)
                ? AppColors.error
                : s.contains(WidgetState.focused)
                ? AppColors.secondaryGold
                : AppColors.textSecondary,
          ),
        ),
        hintStyle: text.bodyMedium!.copyWith(color: AppColors.textTertiary),
        helperStyle: text.bodySmall,
        errorStyle: text.bodySmall!.copyWith(color: AppColors.error),
        prefixIconColor: WidgetStateColor.resolveWith(
          (s) => s.contains(WidgetState.error)
              ? AppColors.error
              : AppColors.secondaryGold,
        ),
        suffixIconColor: AppColors.textSecondary,
        border: inputBorder(AppColors.glassStroke),
        enabledBorder: inputBorder(AppColors.glassStroke),
        disabledBorder: inputBorder(AppColors.glassBase),
        focusedBorder: inputBorder(AppColors.secondaryGold, 1.5),
        errorBorder: inputBorder(AppColors.error),
        focusedErrorBorder: inputBorder(AppColors.error, 1.5),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.cardDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lgRaw),
          side: const BorderSide(color: AppColors.brass),
        ),
        titleTextStyle: text.titleLarge,
        contentTextStyle: text.bodyMedium,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.cardDark,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: AppColors.cardDark,
        showDragHandle: true,
        dragHandleColor: AppColors.glassStrokeStrong,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.lgRaw),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textMain,
        contentTextStyle: text.bodyMedium!.copyWith(color: AppColors.cardDark),
        actionTextColor: AppColors.brass,
        closeIconColor: AppColors.textSecondary,
        elevation: 4,
        insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.mdRaw),
          side: const BorderSide(color: AppColors.glassStroke),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.glassStrokeStrong),
        ),
        textStyle: text.bodySmall!.copyWith(color: AppColors.textMain),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.disabled)
              ? AppColors.textTertiary
              : s.contains(WidgetState.selected)
              ? AppColors.onGold
              : AppColors.textSecondary,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.secondaryGold
              : AppColors.glassFill,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? Colors.transparent
              : AppColors.textTertiary,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.secondaryGold
              : Colors.transparent,
        ),
        checkColor: const WidgetStatePropertyAll(AppColors.onGold),
        side: const BorderSide(color: AppColors.textSecondary, width: 1.5),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.secondaryGold
              : AppColors.textSecondary,
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.secondaryGold,
        inactiveTrackColor: AppColors.glassStrokeStrong,
        thumbColor: AppColors.secondaryGold,
        overlayColor: AppColors.secondaryGold.withValues(alpha: 0.16),
        valueIndicatorColor: AppColors.secondaryGold,
        valueIndicatorTextStyle: text.labelMedium!.copyWith(
          color: AppColors.onGold,
        ),
        activeTickMarkColor: AppColors.onGold.withValues(alpha: 0.4),
        inactiveTickMarkColor: AppColors.textSecondary,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.secondaryGold,
        linearTrackColor: AppColors.glassStroke,
        circularTrackColor: Colors.transparent,
        refreshBackgroundColor: AppColors.cardDark,
      ),

      listTileTheme: ListTileThemeData(
        iconColor: AppColors.secondaryGold,
        textColor: AppColors.textMain,
        titleTextStyle: text.titleSmall,
        subtitleTextStyle: text.bodySmall,
        minVerticalPadding: 12,
        minTileHeight: 56,
        contentPadding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
        shape: mdShape,
        selectedColor: AppColors.secondaryGold,
        selectedTileColor: AppColors.glassFill,
      ),
      expansionTileTheme: const ExpansionTileThemeData(
        iconColor: AppColors.secondaryGold,
        collapsedIconColor: AppColors.textSecondary,
        textColor: AppColors.textMain,
        collapsedTextColor: AppColors.textMain,
        shape: Border(),
        collapsedShape: Border(),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.glassBase,
        selectedColor: AppColors.secondaryGold,
        disabledColor: AppColors.glassBase,
        checkmarkColor: AppColors.onGold,
        labelStyle: text.labelMedium!.copyWith(color: AppColors.textMain),
        secondaryLabelStyle: text.labelMedium!.copyWith(color: AppColors.onGold),
        side: const BorderSide(color: AppColors.glassStroke),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pillRaw),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        iconTheme: const IconThemeData(color: AppColors.secondaryGold, size: 18),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.glassStroke,
        thickness: 1,
        space: 1,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.secondaryGold,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.secondaryGold,
        dividerColor: AppColors.glassStroke,
        labelStyle: text.labelLarge,
        unselectedLabelStyle: text.labelLarge!.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardDark,
        selectedItemColor: AppColors.secondaryGold,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: text.labelSmall!.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: text.labelSmall,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showUnselectedLabels: true,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.cardDark,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.secondaryGold.withValues(alpha: 0.14),
        elevation: 0,
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(
            color: s.contains(WidgetState.selected)
                ? AppColors.secondaryGold
                : AppColors.textSecondary,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => text.labelSmall!.copyWith(
            color: s.contains(WidgetState.selected)
                ? AppColors.secondaryGold
                : AppColors.textSecondary,
            fontWeight: s.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w500,
          ),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.cardDark,
        surfaceTintColor: Colors.transparent,
        textStyle: text.bodyMedium!.copyWith(color: AppColors.textMain),
        shape: mdShape,
      ),
    );
  }
}
