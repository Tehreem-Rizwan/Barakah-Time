import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../widgets/widgets.dart';
import '../../core/services/notification_service.dart';
import '../../injection_container.dart';
import 'home_page.dart';
import 'main_navigation_scope.dart';
import 'prayer_times_page.dart';
import 'pulse_page.dart';
import 'quran_page.dart';
import 'settings_page.dart';

export 'main_navigation_scope.dart';

/// Prayer-time reloading on settings changes lives in the app-level
/// coordinator (main.dart), so it works no matter which page is visible.
class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  MainTab _tab = MainTab.home;

  /// Tabs are built lazily on first visit, then kept alive in the
  /// IndexedStack so their state and scroll position survive tab switches.
  final Set<MainTab> _visited = {MainTab.home};

  StreamSubscription<String?>? _notificationSub;

  static const Map<MainTab, Widget> _pages = {
    MainTab.home: HomePage(),
    MainTab.quran: QuranPage(),
    MainTab.pulse: PulsePage(),
    MainTab.settings: SettingsPage(),
  };

  @override
  void initState() {
    super.initState();
    if (sl.isRegistered<NotificationService>()) {
      final notifications = sl<NotificationService>();
      _notificationSub = notifications.onNotificationTap.listen(
        _handleNotification,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _handleNotification(notifications.takeLaunchPayload());
      });
    }
  }

  @override
  void dispose() {
    _notificationSub?.cancel();
    super.dispose();
  }

  /// Pops everything above this page (pushed pages, sheets, dialogs).
  void _popToMain() {
    final route = ModalRoute.of(context);
    final navigator = Navigator.of(context);
    if (route == null) {
      navigator.popUntil((r) => r.isFirst);
    } else {
      navigator.popUntil((r) => r == route || r.isFirst);
    }
  }

  void _switchTo(MainTab tab) {
    if (!mounted) return;
    _popToMain();
    if (_tab == tab) return;
    setState(() {
      _tab = tab;
      _visited.add(tab);
    });
  }

  void _handleNotification(String? payload) {
    if (!mounted || !PrayerNotificationPayload.isPrayer(payload)) return;
    _switchTo(MainTab.home);
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const PrayerTimesPage()));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return MainNavigationScope(
      currentTab: _tab,
      onSwitch: _switchTo,
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: IndexedStack(
                index: _tab.index,
                children: [
                  for (final tab in MainTab.values)
                    _visited.contains(tab)
                        ? _pages[tab]!
                        : const SizedBox.shrink(),
                ],
              ),
            ),
            const AudioControlBar(),
          ],
        ),
        bottomNavigationBar: IslamicNavBar(
          selectedIndex: _tab.index,
          onSelected: (i) => _switchTo(MainTab.values[i]),
          items: [
            IslamicNavItem(
              icon: Icons.mosque_outlined,
              selectedIcon: Icons.mosque_rounded,
              label: l10n.home,
            ),
            IslamicNavItem(
              icon: Icons.menu_book_outlined,
              selectedIcon: Icons.menu_book_rounded,
              label: l10n.quran,
            ),
            IslamicNavItem(
              icon: Icons.auto_graph_outlined,
              selectedIcon: Icons.auto_graph_rounded,
              label: l10n.pulse,
            ),
            IslamicNavItem(
              icon: Icons.settings_outlined,
              selectedIcon: Icons.settings_rounded,
              label: l10n.settings,
            ),
          ],
        ),
      ),
    );
  }
}
