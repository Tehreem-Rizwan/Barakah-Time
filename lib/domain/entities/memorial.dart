import 'package:flutter/foundation.dart';
import 'package:hijri/hijri_calendar.dart';

/// A recitation people can count toward a shared goal for a memorial.
@immutable
class DhikrPreset {
  final String id;
  final String arabic;
  final int defaultGoal;
  const DhikrPreset(this.id, this.arabic, this.defaultGoal);

  /// l10n key of the display name.
  String get nameKey => 'dhikr_$id';

  static const all = [
    DhikrPreset(
      'kareema',
      'لَا إِلٰهَ إِلَّا أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ',
      125000,
    ),
    DhikrPreset(
      'darood',
      'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ',
      10000,
    ),
    DhikrPreset(
      'kalma',
      'لَا إِلٰهَ إِلَّا اللّٰهُ مُحَمَّدٌ رَسُولُ اللّٰهِ',
      70000,
    ),
    DhikrPreset('ikhlas', 'قُلْ هُوَ اللّٰهُ أَحَدٌ', 1000),
    DhikrPreset('yaseen', 'يٰسٓ', 41),
    DhikrPreset('istighfar', 'أَسْتَغْفِرُ اللّٰهَ', 10000),
  ];

  static DhikrPreset? byId(String id) {
    for (final d in all) {
      if (d.id == id) return d;
    }
    return null;
  }
}

/// Who took a para of the current khatam.
@immutable
class ParaClaim {
  final String uid;
  final String name;
  final bool done;
  const ParaClaim({required this.uid, required this.name, required this.done});

  Map<String, dynamic> toMap() => {'uid': uid, 'name': name, 'done': done};

  static ParaClaim? fromMap(Object? m) {
    if (m is! Map) return null;
    final uid = m['uid'];
    if (uid is! String || uid.isEmpty) return null;
    final name = m['name'];
    return ParaClaim(
      uid: uid,
      name: name is String ? name : '',
      done: m['done'] == true,
    );
  }
}

/// A shared Esaal-e-Sawab page for a deceased person
/// (`memorials/{code}` in Firestore).
@immutable
class Memorial {
  static const int paraCount = 30;

  final String id;
  final String ownerUid;
  final String name;
  final String subtitle;
  final DateTime? deathDate;
  final bool showDates;

  /// Dhikr id → target count.
  final Map<String, int> goals;

  /// Dhikr id → recited so far.
  final Map<String, int> counts;

  /// Para number (1..30) → claim, for the khatam in progress.
  final Map<int, ParaClaim> paras;

  /// Completed khatams.
  final int khatams;

  const Memorial({
    required this.id,
    required this.ownerUid,
    required this.name,
    this.subtitle = '',
    this.deathDate,
    this.showDates = true,
    this.goals = const {},
    this.counts = const {},
    this.paras = const {},
    this.khatams = 0,
  });

  int get parasDone => paras.values.where((p) => p.done).length;

  bool isOwner(String? uid) => uid != null && uid == ownerUid;

  static Map<String, int> _ints(Object? raw) => {
    if (raw is Map)
      for (final e in raw.entries)
        if (e.key is String && e.value is num)
          e.key as String: (e.value as num).toInt().clamp(0, 1 << 40),
  };

  factory Memorial.fromMap(String id, Map<String, dynamic> m) {
    final rawParas = m['paras'];
    final paras = <int, ParaClaim>{};
    if (rawParas is Map) {
      rawParas.forEach((k, v) {
        final n = int.tryParse('$k');
        final c = ParaClaim.fromMap(v);
        if (n != null && n >= 1 && n <= paraCount && c != null) paras[n] = c;
      });
    }
    final death = m['deathDate'];
    final khatams = m['khatams'];
    return Memorial(
      id: id,
      ownerUid: m['ownerUid'] is String ? m['ownerUid'] as String : '',
      name: m['name'] is String ? m['name'] as String : '',
      subtitle: m['subtitle'] is String ? m['subtitle'] as String : '',
      deathDate: _calendarDate(death is DateTime ? death : _toDate(death)),
      showDates: m['showDates'] != false,
      goals: _ints(m['goals']),
      counts: _ints(m['counts']),
      paras: paras,
      khatams: khatams is num ? khatams.toInt() : 0,
    );
  }

  /// The death date is saved as 12:00 UTC of the chosen day; read the day
  /// back in UTC so it doesn't shift in time zones beyond ±12 h.
  static DateTime? _calendarDate(DateTime? d) {
    if (d == null) return null;
    final u = d.toUtc();
    return DateTime(u.year, u.month, u.day);
  }

  /// Firestore Timestamp (or anything with `toDate()`) → DateTime.
  static DateTime? _toDate(Object? v) {
    try {
      // ignore: avoid_dynamic_calls
      final d = (v as dynamic)?.toDate();
      return d is DateTime ? d : null;
    } catch (_) {
      return null;
    }
  }
}

/// One line of a memorial's activity feed.
@immutable
class MemorialEntry {
  final String id;
  final String uid;
  final String name;

  /// 'para', 'khatam', 'dhikr', 'deed' or 'join'.
  final String type;

  /// Para number, dhikr id or the deed text, depending on [type].
  final String text;
  final int count;
  final DateTime? createdAt;

  const MemorialEntry({
    required this.id,
    required this.uid,
    required this.name,
    required this.type,
    required this.text,
    this.count = 0,
    this.createdAt,
  });

  factory MemorialEntry.fromMap(String id, Map<String, dynamic> m) =>
      MemorialEntry(
        id: id,
        uid: m['uid'] is String ? m['uid'] as String : '',
        name: m['name'] is String ? m['name'] as String : '',
        type: m['type'] is String ? m['type'] as String : '',
        text: m['text'] is String ? m['text'] as String : '',
        count: m['count'] is num ? (m['count'] as num).toInt() : 0,
        createdAt: Memorial._toDate(m['createdAt']),
      );
}

/// A memorial in the user's own list (`users/{uid}/memorials/{code}`).
@immutable
class MemorialLink {
  final String id;
  final String name;
  final bool owner;
  const MemorialLink({
    required this.id,
    required this.name,
    required this.owner,
  });
}

/// Customary remembrance days after a death.
@immutable
class MemorialDate {
  /// l10n key: memorial_day3, memorial_day10, memorial_day40, memorial_barsi.
  final String key;
  final DateTime date;
  const MemorialDate(this.key, this.date);

  @override
  bool operator ==(Object other) =>
      other is MemorialDate && other.key == key && other.date == date;

  @override
  int get hashCode => Object.hash(key, date);

  /// The 3rd, 10th and 40th day (the day of death is day 1) and the next
  /// yearly anniversary on the Hijri calendar (Barsi) on or after [today].
  static List<MemorialDate> forDeath(DateTime death, DateTime today) {
    final d = DateTime(death.year, death.month, death.day);
    final t = DateTime(today.year, today.month, today.day);
    DateTime plus(int days) => DateTime(d.year, d.month, d.day + days);
    final result = [
      MemorialDate('memorial_day3', plus(2)),
      MemorialDate('memorial_day10', plus(9)),
      MemorialDate('memorial_day40', plus(39)),
    ];
    // The hijri package covers roughly 1937–2076; skip Barsi outside it.
    try {
      final h = HijriCalendar.fromDate(d);
      final cal = HijriCalendar();
      for (var y = h.hYear + 1; y <= 1499; y++) {
        final day = h.hDay.clamp(1, cal.getDaysInMonth(y, h.hMonth));
        final g = cal.hijriToGregorian(y, h.hMonth, day);
        final date = DateTime(g.year, g.month, g.day);
        if (!date.isBefore(t)) {
          result.add(MemorialDate('memorial_barsi', date));
          break;
        }
      }
    } catch (_) {}
    return result;
  }
}
