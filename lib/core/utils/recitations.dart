import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/prayer_times.dart';
import '../localization/app_localizations.dart';
import '../services/notification_service.dart';

/// When a set of recommended recitations is shown.
enum RecitationWindow { night, friday }

/// A surah (or ayah range) recommended for the night or for Friday.
class Recitation {
  const Recitation({
    required this.id,
    required this.surah,
    this.ayah,
    required this.labelKey,
    required this.arabicName,
    this.sunnah = true,
  });

  final String id;
  final int surah;

  /// First ayah to open at (null = start of the surah).
  final int? ayah;

  /// l10n key of the display name.
  final String labelKey;
  final String arabicName;

  /// True when backed by authentic hadith; false for practices that are
  /// common but based on weak narrations (shown as "also commonly read",
  /// without claiming a virtue).
  final bool sunnah;
}

abstract final class Recitations {
  static const ayatKursi = Recitation(
    id: 'ayat_kursi',
    surah: 2,
    ayah: 255,
    labelKey: 'rec_ayat_kursi',
    arabicName: 'آية الكرسي',
  );
  static const baqarahEnd = Recitation(
    id: 'baqarah_end',
    surah: 2,
    ayah: 285,
    labelKey: 'rec_baqarah_end',
    arabicName: 'خواتيم البقرة',
  );
  static const mulk = Recitation(
    id: 'mulk',
    surah: 67,
    labelKey: 'rec_mulk',
    arabicName: 'الملك',
  );

  /// The four Quls, shown together as one row.
  static const quls = [
    Recitation(
      id: 'kafirun',
      surah: 109,
      labelKey: 'rec_quls',
      arabicName: 'الكافرون',
    ),
    Recitation(
      id: 'ikhlas',
      surah: 112,
      labelKey: 'rec_quls',
      arabicName: 'الإخلاص',
    ),
    Recitation(
      id: 'falaq',
      surah: 113,
      labelKey: 'rec_quls',
      arabicName: 'الفلق',
    ),
    Recitation(
      id: 'nas',
      surah: 114,
      labelKey: 'rec_quls',
      arabicName: 'الناس',
    ),
  ];

  /// Common in South Asia; the narrations are weak or unclear, so they are
  /// offered without any claim of virtue.
  static const commonNight = [
    Recitation(
      id: 'waqiah',
      surah: 56,
      labelKey: 'rec_waqiah',
      arabicName: 'الواقعة',
      sunnah: false,
    ),
    Recitation(
      id: 'muzzammil',
      surah: 73,
      labelKey: 'rec_muzzammil',
      arabicName: 'المزمل',
      sunnah: false,
    ),
  ];

  static const kahf = Recitation(
    id: 'kahf',
    surah: 18,
    labelKey: 'rec_kahf',
    arabicName: 'الكهف',
  );

  /// Items that count towards "x of y done" for the night.
  static List<Recitation> get nightSunnah => [
    ayatKursi,
    baqarahEnd,
    mulk,
    ...quls,
  ];

  static List<Recitation> itemsFor(RecitationWindow w) => switch (w) {
    RecitationWindow.night => [...nightSunnah, ...commonNight],
    RecitationWindow.friday => const [kahf],
  };

  /// Fallback hours when prayer times are unknown.
  static const _fallbackNightStart = 21;
  static const _fallbackNightEnd = 4;
  static const _fallbackMaghrib = 18;

  /// Windows active at [now]. Night: from Isha until Fajr. Friday: the
  /// Islamic day, i.e. from Maghrib on Thursday until Maghrib on Friday.
  /// [today] is today's prayer times (null when unknown).
  static List<RecitationWindow> activeWindows(
    DateTime now,
    DailyPrayerTimes? today,
  ) {
    final windows = <RecitationWindow>[];
    DateTime at(int hour) => DateTime(now.year, now.month, now.day, hour);
    final isha = _onDay(now, today?.isha) ?? at(_fallbackNightStart);
    final fajr = _onDay(now, today?.fajr) ?? at(_fallbackNightEnd);
    final maghrib = _onDay(now, today?.maghrib) ?? at(_fallbackMaghrib);
    final weekday = now.weekday;
    final fridayEve = weekday == DateTime.thursday && !now.isBefore(maghrib);
    final friday = weekday == DateTime.friday && now.isBefore(maghrib);
    if (fridayEve || friday) windows.add(RecitationWindow.friday);
    if (!now.isBefore(isha) || now.isBefore(fajr)) {
      windows.add(RecitationWindow.night);
    }
    return windows;
  }

  /// [time]'s clock time on [now]'s date. Prayer times can be from another
  /// day (e.g. the app stayed open past midnight before they refreshed);
  /// the clock time differs by only a minute or two between days, so this
  /// keeps the windows right.
  static DateTime? _onDay(DateTime now, DateTime? time) =>
      time == null
          ? null
          : DateTime(now.year, now.month, now.day, time.hour, time.minute);

  /// Stable key of the window instance [now] belongs to, so ticks survive
  /// midnight: a night is keyed by the evening it started, a Friday by the
  /// Friday's date.
  static String windowKey(
    RecitationWindow w,
    DateTime now,
    DailyPrayerTimes? today,
  ) {
    String fmt(DateTime d) =>
        '${d.year.toString().padLeft(4, '0')}'
        '${d.month.toString().padLeft(2, '0')}'
        '${d.day.toString().padLeft(2, '0')}';
    final day = DateTime(now.year, now.month, now.day);
    switch (w) {
      case RecitationWindow.night:
        final fajr =
            _onDay(now, today?.fajr) ??
            DateTime(now.year, now.month, now.day, _fallbackNightEnd);
        final evening =
            now.isBefore(fajr) ? day.subtract(const Duration(days: 1)) : day;
        return 'night_${fmt(evening)}';
      case RecitationWindow.friday:
        final friday =
            now.weekday == DateTime.thursday
                ? day.add(const Duration(days: 1))
                : day;
        return 'friday_${fmt(friday)}';
    }
  }

  /// Optional reminders: an hour after Isha each night, and Friday morning
  /// (two hours after sunrise) for Surah Al-Kahf.
  static List<ExtraReminder> reminders(
    List<DailyPrayerTimes> days,
    AppLocalizations l10n, {
    required bool night,
    required bool kahf,
  }) => [
    for (final d in days) ...[
      if (night)
        ExtraReminder(
          time: d.isha.add(const Duration(hours: 1)),
          title: l10n.translate('night_reminder_title'),
          body: l10n.translate('night_reminder_body'),
          payload: 'recitation:night',
        ),
      if (kahf && d.date.weekday == DateTime.friday)
        ExtraReminder(
          time: d.sunrise.add(const Duration(hours: 2)),
          title: l10n.translate('kahf_reminder_title'),
          body: l10n.translate('kahf_reminder_body'),
          payload: 'recitation:kahf',
        ),
    ],
  ];
}

/// Which recommended recitations were ticked, per window instance (kept on
/// the phone; only the last few windows are stored).
class RecitationTracker {
  RecitationTracker(this.prefs);

  final SharedPreferences prefs;
  static const key = 'recitations_done';
  static const _keep = 4;

  Map<String, List<String>> _read() {
    try {
      final raw = prefs.getString(key);
      if (raw == null) return {};
      final data = json.decode(raw) as Map<String, dynamic>;
      return {
        for (final e in data.entries)
          if (e.value is List) e.key: List<String>.from(e.value as List),
      };
    } catch (_) {
      return {};
    }
  }

  Set<String> doneIn(String windowKey) => {...?_read()[windowKey]};

  bool isDone(String windowKey, String id) => doneIn(windowKey).contains(id);

  /// Ticks or unticks [ids] in [windowKey]. Returns the new done set.
  Future<Set<String>> setDone(
    String windowKey,
    Iterable<String> ids,
    bool done,
  ) async {
    final data = _read();
    final set = {...?data[windowKey]};
    done ? set.addAll(ids) : set.removeAll(ids);
    data[windowKey] = set.toList()..sort();
    // Drop the oldest windows (by the date at the end of each key).
    final keys =
        data.keys.toList()
          ..sort((a, b) => a.split('_').last.compareTo(b.split('_').last));
    while (keys.length > _keep) {
      data.remove(keys.removeAt(0));
    }
    await prefs.setString(key, json.encode(data));
    return set;
  }
}
