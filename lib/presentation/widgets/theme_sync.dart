import 'package:flutter/widgets.dart';

import '../../core/theme/app_colors.dart';

/// Keeps [AppColors.isDark] in step with the user's theme choice and the
/// phone's light/dark setting, and rebuilds the whole tree when it flips
/// (many widgets read [AppColors] directly rather than through `Theme`).
///
/// [mode] is 'system', 'light' or 'dark'.
class ThemeSync extends StatefulWidget {
  const ThemeSync({super.key, required this.mode, required this.builder});

  final String mode;
  final WidgetBuilder builder;

  /// Whether [mode] resolves to dark for the given platform brightness.
  static bool resolveDark(String mode, Brightness platform) => switch (mode) {
    'dark' => true,
    'light' => false,
    _ => platform == Brightness.dark,
  };

  @override
  State<ThemeSync> createState() => _ThemeSyncState();
}

class _ThemeSyncState extends State<ThemeSync> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _apply(rebuild: false);
  }

  @override
  void didUpdateWidget(ThemeSync oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mode != widget.mode) _apply();
  }

  @override
  void didChangePlatformBrightness() {
    if (widget.mode == 'system') setState(_apply);
  }

  void _apply({bool rebuild = true}) {
    final dark = ThemeSync.resolveDark(
      widget.mode,
      WidgetsBinding.instance.platformDispatcher.platformBrightness,
    );
    if (dark == AppColors.isDark) return;
    AppColors.isDark = dark;
    if (!rebuild || !mounted) return;
    // Mark every descendant dirty so widgets that captured colours
    // (including ones whose inputs didn't change) repaint with the new
    // palette. State is kept; nothing is remounted.
    void markAll(Element e) {
      e.markNeedsBuild();
      e.visitChildren(markAll);
    }

    (context as Element).visitChildren(markAll);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context);
}
