import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/entities/prayer_times.dart';
import '../localization/app_localizations.dart';

/// One prayer reminder to schedule.
@immutable
class ScheduledPrayer {
  /// Notification id: `dayIndex * 10 + prayer.index` (0..69).
  final int id;
  final PrayerName prayer;
  final DateTime time;
  final int dayIndex;

  const ScheduledPrayer({
    required this.id,
    required this.prayer,
    required this.time,
    required this.dayIndex,
  });

  @override
  bool operator ==(Object other) =>
      other is ScheduledPrayer &&
      other.id == id &&
      other.prayer == prayer &&
      other.time == time;

  @override
  int get hashCode => Object.hash(id, prayer, time);
}

/// A non-prayer reminder (Ramadan sehri/iftar, memorial dates).
@immutable
class ExtraReminder {
  final DateTime time;
  final String title;
  final String body;
  final String? payload;

  const ExtraReminder({
    required this.time,
    required this.title,
    required this.body,
    this.payload,
  });
}

/// Notification id ranges, so each group can be replaced on its own.
/// Prayers use 0..69 (see [ScheduledPrayer.id]).
abstract final class ReminderGroups {
  static const int size = 1000;
  static const int prayers = 0;
  static const int ramadan = 1000;
  static const int memorials = 2000;
}

/// Payload of prayer notifications: `prayer:<key>` (e.g. `prayer:fajr`).
/// Tapping one should open the Prayer tab.
class PrayerNotificationPayload {
  PrayerNotificationPayload._();
  static const prefix = 'prayer:';
  static String of(PrayerName p) => '$prefix${p.key}';
  static bool isPrayer(String? payload) =>
      payload != null && payload.startsWith(prefix);
}

/// Schedules local prayer-time notifications (the five prayers, not
/// sunrise) for the next [NotificationService.daysAhead] days.
///
/// * Android: exact alarms when the user granted "Alarms & reminders",
///   otherwise inexact (may fire a few minutes late). The adhan sound is a
///   channel property, so there are two channels (adhan / default sound).
/// * iOS: `adhan.caf` (a 29 s excerpt; iOS caps notification sounds at 30 s)
///   bundled in Runner. macOS uses the default sound.
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  Future<void>? _initFuture;
  Future<void> _scheduleChain = Future.value();

  /// Bumped by [cancelAll]; queued or running schedule jobs from before a
  /// cancel stop instead of re-adding reminders the user just turned off.
  int _cancelGeneration = 0;

  static const int daysAhead = 7;

  /// Days of reminders actually scheduled. Android allows many pending
  /// alarms, so a month keeps the adhan coming even if the app isn't opened
  /// for weeks (30 days x 5 prayers + Ramadan reminders stays far below
  /// Android's 500-alarm limit; ids are dayIndex * 10 + prayer, so up to
  /// 99 days fit the prayers group). iOS allows only 64 pending
  /// notifications in total, so it keeps [daysAhead].
  static int get scheduleDays =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android
          ? 30
          : daysAhead;

  /// v3: the adhan follows the phone's ring/silent mode (notification
  /// audio). v2 used the alarm stream, which played even on silent.
  static const String adhanChannelId = 'prayer_adhan_v3';
  static const List<String> _oldAdhanChannelIds = ['prayer_adhan_v2'];
  static const String defaultChannelId = 'prayer_default_v2';
  static const String _legacyChannelId = 'prayer_times';
  static const String _smallIcon = 'ic_stat_notification';
  static const String _iosAdhanSound = 'adhan.caf';

  final StreamController<String?> _tapController =
      StreamController<String?>.broadcast();
  String? _launchPayload;

  /// Payloads of tapped notifications while the app is running. When
  /// [PrayerNotificationPayload.isPrayer] is true, open the Prayer tab.
  Stream<String?> get onNotificationTap => _tapController.stream;

  /// Payload of the notification that launched the app (cold start), once.
  /// Call after the first frame; returns null afterwards.
  String? takeLaunchPayload() {
    final p = _launchPayload;
    _launchPayload = null;
    return p;
  }

  bool get _supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

  Future<void> init() => _initFuture ??= _init();

  Future<void> _init() async {
    if (!_supported) return;
    try {
      tzdata.initializeTimeZones();
      try {
        final info = await FlutterTimezone.getLocalTimezone().timeout(
          const Duration(seconds: 5),
        );
        tz.setLocalLocation(tz.getLocation(info.identifier));
      } catch (e) {
        debugPrint('Could not resolve local timezone, using UTC: $e');
      }

      const darwin = DarwinInitializationSettings(
        // Permission is requested explicitly when the user enables reminders.
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings(_smallIcon),
          iOS: darwin,
          macOS: darwin,
        ),
        onDidReceiveNotificationResponse:
            (response) => _tapController.add(response.payload),
      );
      _initialized = true;

      try {
        final launch = await _plugin.getNotificationAppLaunchDetails();
        if (launch?.didNotificationLaunchApp ?? false) {
          _launchPayload = launch?.notificationResponse?.payload;
        }
      } catch (_) {}

      final android = _android;
      if (android != null) {
        await android.createNotificationChannel(
          const AndroidNotificationChannel(
            adhanChannelId,
            'Prayer times (adhan)',
            description: 'Plays the adhan when each prayer time begins',
            importance: Importance.high,
            sound: RawResourceAndroidNotificationSound('adhan'),
            audioAttributesUsage: AudioAttributesUsage.notification,
          ),
        );
        await android.createNotificationChannel(
          const AndroidNotificationChannel(
            defaultChannelId,
            'Prayer times',
            description: 'Reminders when each prayer time begins',
            importance: Importance.high,
          ),
        );
        try {
          await android.deleteNotificationChannel(channelId: _legacyChannelId);
          for (final id in _oldAdhanChannelIds) {
            await android.deleteNotificationChannel(channelId: id);
          }
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('Notification init failed: $e');
    }
  }

  /// Asks the OS for permission to post notifications. Returns true if
  /// granted (or not required on this platform).
  Future<bool> requestPermission() async {
    await init();
    if (!_initialized) return false;
    try {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          final android = _android;
          final granted = await android?.requestNotificationsPermission();
          return granted ?? await android?.areNotificationsEnabled() ?? false;
        case TargetPlatform.iOS:
          return await _plugin
                  .resolvePlatformSpecificImplementation<
                    IOSFlutterLocalNotificationsPlugin
                  >()
                  ?.requestPermissions(alert: true, badge: true, sound: true) ??
              false;
        case TargetPlatform.macOS:
          return await _plugin
                  .resolvePlatformSpecificImplementation<
                    MacOSFlutterLocalNotificationsPlugin
                  >()
                  ?.requestPermissions(alert: true, badge: true, sound: true) ??
              false;
        default:
          return false;
      }
    } catch (e) {
      debugPrint('Notification permission request failed: $e');
      return false;
    }
  }

  /// Whether notifications are currently allowed (no prompt). Use on app
  /// resume to detect a permission revoked in system settings.
  Future<bool> arePermissionsGranted() async {
    await init();
    if (!_initialized) return false;
    try {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          return await _android?.areNotificationsEnabled() ?? false;
        case TargetPlatform.iOS:
          final o =
              await _plugin
                  .resolvePlatformSpecificImplementation<
                    IOSFlutterLocalNotificationsPlugin
                  >()
                  ?.checkPermissions();
          return o?.isEnabled ?? false;
        case TargetPlatform.macOS:
          final o =
              await _plugin
                  .resolvePlatformSpecificImplementation<
                    MacOSFlutterLocalNotificationsPlugin
                  >()
                  ?.checkPermissions();
          return o?.isEnabled ?? false;
        default:
          return false;
      }
    } catch (_) {
      // Unknown: don't turn the user's setting off because of a plugin error.
      return true;
    }
  }

  /// Android 12+: whether exact alarms may be scheduled. Always true
  /// elsewhere.
  Future<bool> canScheduleExactAlarms() async {
    if (defaultTargetPlatform != TargetPlatform.android) return true;
    await init();
    try {
      return await _android?.canScheduleExactNotifications() ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Android 12+: opens the "Alarms & reminders" screen if exact alarms
  /// are not yet allowed. Returns whether they are allowed afterwards.
  Future<bool> requestExactAlarmsPermission() async {
    if (defaultTargetPlatform != TargetPlatform.android) return true;
    if (await canScheduleExactAlarms()) return true;
    try {
      return await _android?.requestExactAlarmsPermission() ?? false;
    } catch (e) {
      debugPrint('Exact alarm permission request failed: $e');
      return false;
    }
  }

  /// Pure: reminders for [days] (consecutive days, as computed by
  /// `AdhanService.timesForDays`), skipping times not after [now].
  static List<ScheduledPrayer> computeSchedule(
    List<DailyPrayerTimes> days,
    DateTime now,
  ) => [
    for (var d = 0; d < days.length; d++)
      for (final prayer in PrayerName.values)
        if (days[d].timeOf(prayer).isAfter(now))
          ScheduledPrayer(
            id: d * 10 + prayer.index,
            prayer: prayer,
            time: days[d].timeOf(prayer),
            dayIndex: d,
          ),
  ];

  /// Replaces all scheduled reminders with [days] (see [computeSchedule]).
  /// Calls are serialised so overlapping reschedules can't interleave.
  Future<void> schedulePrayerNotifications(
    List<DailyPrayerTimes> days, {
    String languageCode = 'en',
    bool adhanSound = true,
    DateTime? now,
  }) {
    final gen = _cancelGeneration;
    final run = _scheduleChain.then(
      (_) =>
          _schedule(days, languageCode, adhanSound, now ?? DateTime.now(), gen),
    );
    _scheduleChain = run.catchError((_) {});
    return _scheduleChain;
  }

  Future<void> _schedule(
    List<DailyPrayerTimes> days,
    String languageCode,
    bool adhanSound,
    DateTime now,
    int gen,
  ) async {
    await init();
    if (!_initialized || gen != _cancelGeneration) return;
    try {
      await _cancelGroup(ReminderGroups.prayers);
      final l10n = AppLocalizations(Locale(languageCode));
      final exact = await canScheduleExactAlarms();
      final details = NotificationDetails(
        android: AndroidNotificationDetails(
          adhanSound ? adhanChannelId : defaultChannelId,
          adhanSound ? 'Prayer times (adhan)' : 'Prayer times',
          icon: _smallIcon,
          importance: Importance.high,
          priority: Priority.high,
          category: AndroidNotificationCategory.reminder,
          sound:
              adhanSound
                  ? const RawResourceAndroidNotificationSound('adhan')
                  : null,
          audioAttributesUsage: AudioAttributesUsage.notification,
        ),
        iOS: DarwinNotificationDetails(
          presentSound: true,
          sound: adhanSound ? _iosAdhanSound : null,
        ),
        macOS: const DarwinNotificationDetails(presentSound: true),
      );
      for (final item in computeSchedule(days, now)) {
        if (gen != _cancelGeneration) return;
        final name = l10n.translate(item.prayer.key);
        await _plugin.zonedSchedule(
          id: item.id,
          scheduledDate: tz.TZDateTime.from(item.time, tz.local),
          notificationDetails: details,
          androidScheduleMode:
              exact
                  ? AndroidScheduleMode.exactAllowWhileIdle
                  : AndroidScheduleMode.inexactAllowWhileIdle,
          title: l10n
              .translate('prayer_notification_title')
              .replaceAll('{prayer}', name),
          body: l10n
              .translate('prayer_notification_body')
              .replaceAll('{prayer}', name),
          payload: PrayerNotificationPayload.of(item.prayer),
        );
      }
    } catch (e) {
      debugPrint('Scheduling prayer notifications failed: $e');
    }
  }

  /// Cancels pending notifications whose id is in [base]'s group.
  Future<void> _cancelGroup(int base) async {
    final pending = await _plugin.pendingNotificationRequests();
    for (final p in pending) {
      if (p.id >= base && p.id < base + ReminderGroups.size) {
        await _plugin.cancel(id: p.id);
      }
    }
  }

  /// Replaces the reminders of group [base] (see [ReminderGroups]) with
  /// [items] (at most [ReminderGroups.size]; past times are skipped).
  /// Serialised with prayer scheduling.
  Future<void> scheduleGroup(
    int base,
    List<ExtraReminder> items, {
    DateTime? now,
  }) {
    final gen = _cancelGeneration;
    final run = _scheduleChain.then(
      (_) => _scheduleGroup(base, items, now ?? DateTime.now(), gen),
    );
    _scheduleChain = run.catchError((_) {});
    return _scheduleChain;
  }

  Future<void> _scheduleGroup(
    int base,
    List<ExtraReminder> items,
    DateTime now,
    int gen,
  ) async {
    await init();
    if (!_initialized || gen != _cancelGeneration) return;
    try {
      await _cancelGroup(base);
      final exact = await canScheduleExactAlarms();
      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          defaultChannelId,
          'Prayer times',
          icon: _smallIcon,
          importance: Importance.high,
          priority: Priority.high,
          category: AndroidNotificationCategory.reminder,
        ),
        iOS: DarwinNotificationDetails(presentSound: true),
        macOS: DarwinNotificationDetails(presentSound: true),
      );
      final future =
          items.where((r) => r.time.isAfter(now)).toList()
            ..sort((a, b) => a.time.compareTo(b.time));
      for (var i = 0; i < future.length && i < ReminderGroups.size; i++) {
        if (gen != _cancelGeneration) return;
        final r = future[i];
        await _plugin.zonedSchedule(
          id: base + i,
          scheduledDate: tz.TZDateTime.from(r.time, tz.local),
          notificationDetails: details,
          androidScheduleMode:
              exact
                  ? AndroidScheduleMode.exactAllowWhileIdle
                  : AndroidScheduleMode.inexactAllowWhileIdle,
          title: r.title,
          body: r.body,
          payload: r.payload,
        );
      }
    } catch (e) {
      debugPrint('Scheduling reminders ($base) failed: $e');
    }
  }

  /// Cancels everything, including schedule jobs still queued or running.
  Future<void> cancelAll() {
    _cancelGeneration++;
    final run = _scheduleChain.then((_) async {
      await init();
      if (!_initialized) return;
      try {
        await _plugin.cancelAll();
      } catch (e) {
        debugPrint('Cancelling notifications failed: $e');
      }
    });
    _scheduleChain = run.catchError((_) {});
    return _scheduleChain;
  }
}
