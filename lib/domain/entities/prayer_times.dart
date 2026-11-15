import 'package:equatable/equatable.dart';

/// Asr juristic method values persisted in settings.
class AsrMadhab {
  static const String shafi = 'shafi';
  static const String hanafi = 'hanafi';

  /// Sensible default per calculation method: the Karachi (University of
  /// Islamic Sciences) method is used mostly in Hanafi regions.
  static String defaultFor(String method) =>
      method == 'Karachi' ? hanafi : shafi;
}

/// The five obligatory prayers (sunrise is not a prayer and is never used as
/// a countdown target).
enum PrayerName { fajr, dhuhr, asr, maghrib, isha }

extension PrayerNameX on PrayerName {
  /// Stable lowercase key, also used as the l10n key and pulse `subType`.
  String get key => name;

  /// English display name (kept for backwards compatibility).
  String get englishName => name[0].toUpperCase() + name.substring(1);
}

/// Prayer (and sunrise) times for a single calendar day.
class DailyPrayerTimes extends Equatable {
  /// Local calendar date (midnight) these times belong to.
  final DateTime date;
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;

  const DailyPrayerTimes({
    required this.date,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  DateTime timeOf(PrayerName prayer) {
    switch (prayer) {
      case PrayerName.fajr:
        return fajr;
      case PrayerName.dhuhr:
        return dhuhr;
      case PrayerName.asr:
        return asr;
      case PrayerName.maghrib:
        return maghrib;
      case PrayerName.isha:
        return isha;
    }
  }

  @override
  List<Object?> get props => [date, fajr, sunrise, dhuhr, asr, maghrib, isha];
}

/// Result of computing the upcoming prayer at a given instant.
class NextPrayer extends Equatable {
  final PrayerName prayer;
  final DateTime time;

  /// True when the next prayer is tomorrow's Fajr (i.e. today's Isha passed).
  final bool isTomorrow;

  const NextPrayer({
    required this.prayer,
    required this.time,
    required this.isTomorrow,
  });

  Duration timeUntil(DateTime now) {
    final d = time.difference(now);
    return d.isNegative ? Duration.zero : d;
  }

  @override
  List<Object?> get props => [prayer, time, isTomorrow];
}

class PrayerTimesEntity extends Equatable {
  /// Today's times – what the table shows.
  final DailyPrayerTimes today;

  /// Tomorrow's times – used for the after-Isha countdown and notifications.
  final DailyPrayerTimes tomorrow;

  const PrayerTimesEntity({required this.today, required this.tomorrow});

  DateTime get date => today.date;
  DateTime get fajr => today.fajr;
  DateTime get sunrise => today.sunrise;
  DateTime get dhuhr => today.dhuhr;
  DateTime get asr => today.asr;
  DateTime get maghrib => today.maghrib;
  DateTime get isha => today.isha;

  /// The next obligatory prayer after [now]. Sunrise is skipped; after Isha
  /// this is tomorrow's Fajr.
  NextPrayer nextPrayerAt(DateTime now) {
    for (final p in PrayerName.values) {
      final t = today.timeOf(p);
      if (t.isAfter(now)) {
        return NextPrayer(prayer: p, time: t, isTomorrow: false);
      }
    }
    return NextPrayer(
      prayer: PrayerName.fajr,
      time: tomorrow.fajr,
      isTomorrow: true,
    );
  }

  /// The prayer whose time window contains [now], or null (before Fajr,
  /// and between sunrise and Dhuhr).
  PrayerName? currentPrayerAt(DateTime now) {
    if (now.isBefore(today.fajr)) return null;
    if (!now.isBefore(today.sunrise) && now.isBefore(today.dhuhr)) return null;
    PrayerName? current;
    for (final p in PrayerName.values) {
      if (!today.timeOf(p).isAfter(now)) current = p;
    }
    return current;
  }

  /// Whether the time for [prayer] has begun today.
  bool hasStarted(PrayerName prayer, DateTime now) =>
      !today.timeOf(prayer).isAfter(now);

  @override
  List<Object?> get props => [today, tomorrow];
}

/// Formats a countdown as HH:MM:SS. Negative durations are shown as 00:00:00.
String formatCountdown(Duration duration) {
  final d = duration.isNegative ? Duration.zero : duration;
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.inHours)}:${two(d.inMinutes.remainder(60))}:'
      '${two(d.inSeconds.remainder(60))}';
}
