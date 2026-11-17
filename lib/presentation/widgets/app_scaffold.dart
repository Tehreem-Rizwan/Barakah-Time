import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Standard page scaffold.
///
/// - Shows an [AppBar] (styled by the theme) when [title], [titleWidget] or
///   [actions] is provided. The back button is automatic (shown when the
///   route can pop) unless [showBack] is set explicitly.
/// - [gradientBackground] paints the emerald→slate Home gradient behind the
///   whole page (including the app bar).
/// - The body is wrapped in a [SafeArea]; the top inset is skipped when an
///   app bar is present (it already handles it) and the bottom inset is
///   skipped when a [bottomBar] is present.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.bottomBar,
    this.floatingActionButton,
    this.gradientBackground = false,
    this.showBack,
    this.safeAreaBottom = true,
    this.safeAreaTop = true,
    this.resizeToAvoidBottomInset,
  });

  final Widget body;
  final String? title;

  /// Custom title widget; takes precedence over [title].
  final Widget? titleWidget;
  final List<Widget>? actions;

  /// Custom leading widget; overrides the automatic back button.
  final Widget? leading;

  /// Shown as [Scaffold.bottomNavigationBar] (e.g. `AudioControlBar`).
  final Widget? bottomBar;
  final Widget? floatingActionButton;
  final bool gradientBackground;

  /// `null` = automatic (back button when the route can pop).
  final bool? showBack;

  /// Apply the bottom safe-area inset to the body (ignored with [bottomBar]).
  final bool safeAreaBottom;

  /// Apply the top safe-area inset (without an app bar). Set false when the
  /// page paints its own band under the status bar (Home).
  final bool safeAreaTop;
  final bool? resizeToAvoidBottomInset;

  bool get _hasAppBar => title != null || titleWidget != null || actions != null;

  @override
  Widget build(BuildContext context) {
    final appBar = _hasAppBar
        ? AppBar(
            title: titleWidget ??
                (title == null
                    ? null
                    : Text(title!, maxLines: 1, overflow: TextOverflow.ellipsis)),
            leading: leading,
            automaticallyImplyLeading: showBack ?? true,
            actions: actions,
          )
        : null;

    final scaffold = Scaffold(
      backgroundColor: gradientBackground ? Colors.transparent : null,
      appBar: appBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomBar,
      body: SafeArea(
        top: appBar == null && safeAreaTop,
        bottom: bottomBar == null && safeAreaBottom,
        child: body,
      ),
    );

    if (!gradientBackground) return scaffold;
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.backgroundSlate,
        gradient: AppColors.backgroundGradient,
      ),
      child: scaffold,
    );
  }
}
