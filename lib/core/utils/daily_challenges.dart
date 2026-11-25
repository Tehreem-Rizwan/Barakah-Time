import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/spiritual_activity.dart';

enum ChallengeKind { prayers, quran, dhikr }

class ChallengeStatus {
  const ChallengeStatus(this.kind, this.progress, this.goal);

  final ChallengeKind kind;
  final int progress;
  final int goal;

  bool get done => progress >= goal;
}

/// Three daily challenges, completed automatically from what the app
/// already tracks (no extra tapping): all five prayers marked, any Quran
/// reading logged, and a tasbeeh round (dhikr is logged from 33 counts).
abstract final class DailyChallenges {
  static const _prayers = {'fajr', 'dhuhr', 'asr', 'maghrib', 'isha'};

  static List<ChallengeStatus> evaluate(List<SpiritualActivity> today) {
    final prayed =
        today
            .where((a) => a.type == 'prayer' && _prayers.contains(a.subType))
            .map((a) => a.subType)
            .toSet()
            .length;
    final quran = today.any((a) => a.type == 'quran');
    final dhikr = today.any((a) => a.type == 'dhikr');
    return [
      ChallengeStatus(ChallengeKind.prayers, prayed, _prayers.length),
      ChallengeStatus(ChallengeKind.quran, quran ? 1 : 0, 1),
      ChallengeStatus(ChallengeKind.dhikr, dhikr ? 1 : 0, 1),
    ];
  }

  static bool allDone(List<ChallengeStatus> s) => s.every((c) => c.done);
}

/// Days on which every challenge was completed ("perfect days"), kept on the
/// phone for the weekly count.
class PerfectDays {
  PerfectDays(this.prefs);

  final SharedPreferences prefs;
  static const key = 'challenge_perfect_days';
  static const _keep = 60;

  static String dayKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}'
      '${d.month.toString().padLeft(2, '0')}'
      '${d.day.toString().padLeft(2, '0')}';

  Set<String> _read() {
    try {
      final raw = prefs.getString(key);
      if (raw == null) return {};
      return Set<String>.from(json.decode(raw) as List);
    } catch (_) {
      return {};
    }
  }

  bool contains(DateTime day) => _read().contains(dayKey(day));

  /// Records [day] as perfect (idempotent).
  Future<void> mark(DateTime day) async {
    final days = _read();
    if (!days.add(dayKey(day))) return;
    final sorted = days.toList()..sort();
    final kept =
        sorted.length > _keep ? sorted.sublist(sorted.length - _keep) : sorted;
    await prefs.setString(key, json.encode(kept));
  }

  /// Perfect days in the 7 days ending on [today].
  int inLastWeek(DateTime today) {
    final days = _read();
    final base = DateTime(today.year, today.month, today.day);
    var n = 0;
    for (var i = 0; i < 7; i++) {
      if (days.contains(dayKey(base.subtract(Duration(days: i))))) n++;
    }
    return n;
  }
}
