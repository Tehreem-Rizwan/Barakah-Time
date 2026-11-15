import 'package:flutter/material.dart';

/// Bottom-navigation tabs of [MainNavigationPage], in display order.
enum MainTab { home, quran, pulse, settings }

/// Exposes tab switching to everything below `MainNavigationPage`.
///
/// Tab destinations (Quran, Pulse, Settings) must never be pushed as new
/// routes — that creates duplicate, stale copies of the tab. Use
/// [MainNavigationScope.openTab] instead: it pops back to the main page and
/// selects the tab.
class MainNavigationScope extends InheritedWidget {
  const MainNavigationScope({
    super.key,
    required this.currentTab,
    required ValueChanged<MainTab> onSwitch,
    required super.child,
  }) : _onSwitch = onSwitch;

  final MainTab currentTab;
  final ValueChanged<MainTab> _onSwitch;

  /// Pops every route above the main page and selects [tab].
  void switchTo(MainTab tab) => _onSwitch(tab);

  /// The nearest scope, or null outside `MainNavigationPage`. Does not
  /// register a dependency (use [of] to rebuild on tab changes).
  static MainNavigationScope? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<MainNavigationScope>();

  /// The nearest scope; rebuilds the caller when the current tab changes.
  static MainNavigationScope of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<MainNavigationScope>();
    assert(scope != null, 'No MainNavigationScope found in context');
    return scope!;
  }

  /// Switches to [tab] when inside the main navigation; otherwise (e.g. a
  /// page shown standalone) pushes [fallback].
  static void openTab(
    BuildContext context,
    MainTab tab, {
    required WidgetBuilder fallback,
  }) {
    final scope = maybeOf(context);
    if (scope != null) {
      scope.switchTo(tab);
    } else {
      Navigator.of(context).push(MaterialPageRoute(builder: fallback));
    }
  }

  @override
  bool updateShouldNotify(MainNavigationScope oldWidget) =>
      oldWidget.currentTab != currentTab;
}
