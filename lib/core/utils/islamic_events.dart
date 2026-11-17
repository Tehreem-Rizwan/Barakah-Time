import 'package:hijri/hijri_calendar.dart';

/// An Islamic event identified by its Hijri month/day.
class IslamicEventDef {
  /// Localization key for the event name.
  final String key;
  final int hijriMonth;
  final int hijriDay;

  const IslamicEventDef(this.key, this.hijriMonth, this.hijriDay);
}

class UpcomingIslamicEvent {
  final IslamicEventDef def;
  final int hijriYear;
  final DateTime gregorian;
  final int daysRemaining;

  const UpcomingIslamicEvent({
    required this.def,
    required this.hijriYear,
    required this.gregorian,
    required this.daysRemaining,
  });
}

class IslamicEvents {
  IslamicEvents._();

  static const List<IslamicEventDef> all = [
    IslamicEventDef('islamic_new_year', 1, 1),
    IslamicEventDef('ashura', 1, 10),
    IslamicEventDef('mawlid', 3, 12),
    IslamicEventDef('isra_miraj', 7, 27),
    IslamicEventDef('shab_e_barat', 8, 15),
    IslamicEventDef('ramadan_begins', 9, 1),
    IslamicEventDef('laylat_al_qadr', 9, 27),
    IslamicEventDef('eid_ul_fitr', 10, 1),
    IslamicEventDef('hajj_season', 12, 8),
    IslamicEventDef('day_of_arafah', 12, 9),
    IslamicEventDef('eid_ul_adha', 12, 10),
  ];

  /// Returns the next occurrence (today or later) of each event, sorted by
  /// date. Events that fall today are included with `daysRemaining == 0`.
  /// [adjust] shifts the Hijri calendar by local moon sighting (-2..+2).
  static List<UpcomingIslamicEvent> upcoming(DateTime now, {int adjust = 0}) {
    final today = DateTime(now.year, now.month, now.day);
    final hToday = HijriCalendar.fromDate(
      DateTime(today.year, today.month, today.day + adjust),
    );
    final result = <UpcomingIslamicEvent>[];
    for (final def in all) {
      for (var year = hToday.hYear; year <= hToday.hYear + 1; year++) {
        final calc = _toGregorian(year, def.hijriMonth, def.hijriDay);
        if (calc == null) continue;
        final date = DateTime(calc.year, calc.month, calc.day - adjust);
        if (date.isBefore(today)) continue;
        result.add(
          UpcomingIslamicEvent(
            def: def,
            hijriYear: year,
            gregorian: date,
            daysRemaining: _daysBetween(today, date),
          ),
        );
        break;
      }
    }
    result.sort((a, b) => a.gregorian.compareTo(b.gregorian));
    return result;
  }

  static DateTime? _toGregorian(int year, int month, int day) {
    try {
      final g = HijriCalendar().hijriToGregorian(year, month, day);
      return DateTime(g.year, g.month, g.day);
    } catch (_) {
      // Outside the Umm al-Qura table range.
      return null;
    }
  }

  static int _daysBetween(DateTime a, DateTime b) {
    // Use UTC to avoid DST off-by-one errors.
    final ua = DateTime.utc(a.year, a.month, a.day);
    final ub = DateTime.utc(b.year, b.month, b.day);
    return ub.difference(ua).inDays;
  }
}
