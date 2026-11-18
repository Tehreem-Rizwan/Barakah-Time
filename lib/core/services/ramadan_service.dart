import '../utils/date_labels.dart';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/local/local_store.dart';
import '../../domain/entities/prayer_times.dart';
import '../localization/app_localizations.dart';
import 'notification_service.dart';
import 'user_data_sync_service.dart';

enum FastStatus { none, fasted, missed }

/// One Ramadan day in the fasting log.
@immutable
class FastDay {
  final FastStatus status;
  final bool taraweeh;
  const FastDay({this.status = FastStatus.none, this.taraweeh = false});

  static const empty = FastDay();
  bool get isEmpty => status == FastStatus.none && !taraweeh;

  Map<String, dynamic> toJson() => {'s': status.index, 't': taraweeh};

  factory FastDay.fromJson(Object? json) {
    if (json is! Map) return empty;
    final s = json['s'];
    return FastDay(
      status:
          s is int && s >= 0 && s < FastStatus.values.length
              ? FastStatus.values[s]
              : FastStatus.none,
      taraweeh: json['t'] == true,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is FastDay && other.status == status && other.taraweeh == taraweeh;

  @override
  int get hashCode => Object.hash(status, taraweeh);
}

/// Where we are relative to Ramadan.
@immutable
class RamadanInfo {
  /// Hijri year of the current (or next) Ramadan.
  final int year;
  final bool isRamadan;

  /// 1-based day of Ramadan when [isRamadan].
  final int day;

  /// Days until 1 Ramadan when not [isRamadan].
  final int daysUntil;

  /// Number of days in that Ramadan (29 or 30).
  final int length;

  /// Gregorian date of 1 Ramadan.
  final DateTime start;

  const RamadanInfo({
    required this.year,
    required this.isRamadan,
    required this.day,
    required this.daysUntil,
    required this.length,
    required this.start,
  });
}

/// Ramadan helpers: moon-sighting adjustment, the fasting log and sehri /
/// iftar reminders. Everything is stored on the device.
class RamadanService {
  RamadanService(this.prefs, {this.sync});

  final SharedPreferences prefs;
  final UserDataSync? sync;

  static const _adjustKey = 'ramadan_hijri_adjust';
  static const _remindersKey = 'ramadan_reminders';

  /// Minutes before Fajr for the sehri reminder.
  static const int sehriReminderMinutes = 30;

  /// Local moon sighting can differ from the calculated calendar by a day
  /// or two; the user can shift the Hijri date (-2..+2 days).
  int get hijriAdjust => (prefs.getInt(_adjustKey) ?? 0).clamp(-2, 2);
  Future<void> setHijriAdjust(int days) =>
      prefs.setInt(_adjustKey, days.clamp(-2, 2));

  bool get remindersEnabled => prefs.getBool(_remindersKey) ?? true;
  Future<void> setRemindersEnabled(bool v) => prefs.setBool(_remindersKey, v);

  HijriCalendar hijriOf(DateTime date) => hijriFor(date, hijriAdjust);

  static HijriCalendar hijriFor(DateTime date, int adjust) =>
      HijriCalendar.fromDate(
        DateTime(date.year, date.month, date.day + adjust),
      );

  RamadanInfo info(DateTime now) => infoFor(now, hijriAdjust);

  /// Pure: Ramadan status on [now]'s day with a Hijri [adjust]ment.
  static RamadanInfo infoFor(DateTime now, int adjust) {
    final today = DateTime(now.year, now.month, now.day);
    final h = hijriFor(today, adjust);
    final cal = HijriCalendar();
    if (h.hMonth == 9) {
      return RamadanInfo(
        year: h.hYear,
        isRamadan: true,
        day: h.hDay,
        daysUntil: 0,
        length: cal.getDaysInMonth(h.hYear, 9),
        start: DateTime(today.year, today.month, today.day - (h.hDay - 1)),
      );
    }
    final year = h.hMonth < 9 ? h.hYear : h.hYear + 1;
    final g = cal.hijriToGregorian(year, 9, 1);
    // Undo the adjustment: the user's 1 Ramadan is `adjust` days earlier.
    final start = DateTime(g.year, g.month, g.day - adjust);
    return RamadanInfo(
      year: year,
      isRamadan: false,
      day: 0,
      daysUntil:
          DateTime.utc(
            start.year,
            start.month,
            start.day,
          ).difference(DateTime.utc(today.year, today.month, today.day)).inDays,
      length: cal.getDaysInMonth(year, 9),
      start: start,
    );
  }

  /// Hijri year whose Ramadan the fasting log shows: the current one, or
  /// the most recent one before the next starts.
  int logYear(DateTime now) {
    final h = hijriOf(now);
    return h.hMonth >= 9 ? h.hYear : h.hYear - 1;
  }

  Map<String, dynamic> _all() {
    final raw = prefs.getString(UserPrefsKeys.ramadanLog);
    if (raw == null) return {};
    try {
      final j = jsonDecode(raw);
      return j is Map<String, dynamic> ? j : {};
    } catch (_) {
      return {};
    }
  }

  /// Day (1..30) → entry for Ramadan of [year].
  Map<int, FastDay> loadLog(int year) {
    final y = _all()['$year'];
    if (y is! Map) return {};
    return {
      for (final e in y.entries)
        if (int.tryParse('${e.key}') case final d? when d >= 1 && d <= 30)
          d: FastDay.fromJson(e.value),
    };
  }

  Future<void> saveDay(int year, int day, FastDay value) async {
    final all = _all();
    final y = Map<String, dynamic>.from(
      all['$year'] is Map ? all['$year'] as Map : const {},
    );
    if (value.isEmpty) {
      y.remove('$day');
    } else {
      y['$day'] = value.toJson();
    }
    all['$year'] = y;
    await prefs.setString(UserPrefsKeys.ramadanLog, jsonEncode(all));
    await prefs.setInt(
      UserPrefsKeys.ramadanUpdatedAt,
      DateTime.now().millisecondsSinceEpoch,
    );
    sync?.pushRamadanLog(all);
  }

  /// Pure: sehri (30 min before Fajr) and iftar (Maghrib) reminders for the
  /// days in [days] that fall in Ramadan.
  static List<ExtraReminder> buildReminders(
    List<DailyPrayerTimes> days,
    AppLocalizations l10n, {
    int adjust = 0,
  }) {
    final code = l10n.locale.languageCode;
    String time(DateTime t) {
      try {
        return ltrTime(DateFormat.jm(code).format(t));
      } catch (_) {
        return ltrTime(DateFormat.jm().format(t));
      }
    }

    return [
      for (final d in days)
        if (hijriFor(d.date, adjust).hMonth == 9) ...[
          ExtraReminder(
            time: d.fajr.subtract(
              const Duration(minutes: sehriReminderMinutes),
            ),
            title: l10n.translate('ramadan_sehri_reminder_title'),
            body: l10n
                .translate('ramadan_sehri_reminder_body')
                .replaceAll('{time}', time(d.fajr)),
            payload: 'ramadan',
          ),
          ExtraReminder(
            time: d.maghrib,
            title: l10n.translate('ramadan_iftar_reminder_title'),
            body: l10n.translate('ramadan_iftar_reminder_body'),
            payload: 'ramadan',
          ),
        ],
    ];
  }

  /// Replaces scheduled sehri/iftar reminders (none when disabled).
  Future<void> reschedule(
    NotificationService notifications,
    List<DailyPrayerTimes> days,
    String languageCode,
  ) => notifications.scheduleGroup(
    ReminderGroups.ramadan,
    remindersEnabled
        ? buildReminders(
          days,
          AppLocalizations(Locale(languageCode)),
          adjust: hijriAdjust,
        )
        : const [],
  );
}
