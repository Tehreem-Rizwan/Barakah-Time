import 'package:equatable/equatable.dart';

/// Missed (qaza) prayers still owed and already made up, per prayer.
///
/// Witr is tracked separately because it is wajib in the Hanafi madhab;
/// users of other madhabs can leave it at zero.
class QazaState extends Equatable {
  static const List<String> prayers = [
    'fajr',
    'dhuhr',
    'asr',
    'maghrib',
    'isha',
    'witr',
  ];

  /// Upper bound per prayer (about 150 years), guards against typos.
  static const int maxPerPrayer = 60000;

  final Map<String, int> remaining;
  final Map<String, int> done;

  QazaState({Map<String, int>? remaining, Map<String, int>? done})
    : remaining = _normalize(remaining),
      done = _normalize(done);

  static final QazaState empty = QazaState();

  static Map<String, int> _normalize(Map<String, int>? m) => {
    for (final p in prayers) p: (m?[p] ?? 0).clamp(0, maxPerPrayer),
  };

  int remainingOf(String prayer) => remaining[prayer] ?? 0;
  int doneOf(String prayer) => done[prayer] ?? 0;

  int get totalRemaining => remaining.values.fold(0, (s, v) => s + v);
  int get totalDone => done.values.fold(0, (s, v) => s + v);

  /// True when nothing has ever been entered.
  bool get isEmpty => totalRemaining == 0 && totalDone == 0;

  /// Share of all qaza prayers already made up (0..1).
  double get progress {
    final total = totalRemaining + totalDone;
    return total == 0 ? 0 : totalDone / total;
  }

  /// One [prayer] made up: remaining -1, done +1. No-op at zero remaining.
  QazaState madeUp(String prayer) {
    if (remainingOf(prayer) <= 0) return this;
    return QazaState(
      remaining: {...remaining, prayer: remainingOf(prayer) - 1},
      done: {...done, prayer: doneOf(prayer) + 1},
    );
  }

  /// Reverts one [madeUp] (for undo).
  QazaState undoMadeUp(String prayer) {
    if (doneOf(prayer) <= 0) return this;
    return QazaState(
      remaining: {...remaining, prayer: remainingOf(prayer) + 1},
      done: {...done, prayer: doneOf(prayer) - 1},
    );
  }

  QazaState withRemaining(String prayer, int count) => QazaState(
    remaining: {...remaining, prayer: count},
    done: done,
  );

  /// Adds [days] missed days of every prayer (Witr only if [includeWitr]).
  QazaState addDays(int days, {bool includeWitr = true}) {
    if (days <= 0) return this;
    return QazaState(
      remaining: {
        for (final p in prayers)
          p: remainingOf(p) + (p == 'witr' && !includeWitr ? 0 : days),
      },
      done: done,
    );
  }

  /// Number of days in a period of missed prayers. A year counts as 365 days
  /// (slightly more than a lunar year, so the estimate errs on the safe side).
  static int daysFor({int years = 0, int months = 0, int days = 0}) {
    final total = years * 365 + months * 30 + days;
    return total < 0 ? 0 : total;
  }

  Map<String, dynamic> toJson() => {'remaining': remaining, 'done': done};

  /// Tolerant of missing/invalid fields (cloud or old local data).
  factory QazaState.fromJson(Map<String, dynamic>? json) {
    Map<String, int> read(Object? raw) => {
      if (raw is Map)
        for (final p in prayers)
          if (raw[p] is num) p: (raw[p] as num).toInt(),
    };
    if (json == null) return QazaState();
    return QazaState(
      remaining: read(json['remaining']),
      done: read(json['done']),
    );
  }

  @override
  List<Object?> get props => [remaining, done];
}
