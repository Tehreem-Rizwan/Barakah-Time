import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/local/local_store.dart';
import '../../domain/entities/memorial.dart';
import '../localization/app_localizations.dart';
import 'notification_service.dart';

/// Local reminders for a memorial's remembrance days (3rd, 10th, 40th day,
/// Barsi). Opt-in per memorial on this device.
class MemorialReminderService {
  MemorialReminderService(this.prefs);

  final SharedPreferences prefs;

  /// Reminders fire at this hour on the day.
  static const int hour = 9;

  Map<String, dynamic> _load() {
    final raw = prefs.getString(UserPrefsKeys.memorialReminders);
    if (raw == null) return {};
    try {
      final j = jsonDecode(raw);
      return j is Map<String, dynamic> ? j : {};
    } catch (_) {
      return {};
    }
  }

  bool isEnabled(String memorialId) => _load().containsKey(memorialId);

  Future<void> setEnabled(Memorial m, bool enabled) async {
    final all = _load();
    if (enabled && m.deathDate != null) {
      all[m.id] = {'name': m.name, 'death': m.deathDate!.toIso8601String()};
    } else {
      all.remove(m.id);
    }
    await prefs.setString(UserPrefsKeys.memorialReminders, jsonEncode(all));
  }

  /// Pure: reminders for [entries] (id → name + death date) after [now].
  static List<ExtraReminder> build(
    Map<String, dynamic> entries,
    AppLocalizations l10n,
    DateTime now,
  ) {
    final result = <ExtraReminder>[];
    for (final e in entries.values) {
      if (e is! Map) continue;
      final name = e['name'] is String ? e['name'] as String : '';
      final death = DateTime.tryParse('${e['death']}');
      if (death == null) continue;
      for (final d in MemorialDate.forDeath(death.toLocal(), now)) {
        final at = DateTime(d.date.year, d.date.month, d.date.day, hour);
        if (!at.isAfter(now)) continue;
        result.add(
          ExtraReminder(
            time: at,
            title: l10n
                .translate('memorial_reminder_title')
                .replaceAll('{day}', l10n.translate(d.key))
                .replaceAll('{name}', name),
            body: l10n
                .translate('memorial_reminder_body')
                .replaceAll('{name}', name),
            payload: 'memorial',
          ),
        );
      }
    }
    return result;
  }

  Future<void> reschedule(
    NotificationService notifications,
    String languageCode,
  ) => notifications.scheduleGroup(
    ReminderGroups.memorials,
    build(_load(), AppLocalizations(Locale(languageCode)), DateTime.now()),
  );
}
