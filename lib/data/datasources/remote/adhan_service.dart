import 'package:adhan/adhan.dart';
import '../../../core/utils/calculation_methods.dart';
import '../../../domain/entities/prayer_times.dart';
import '../../models/prayer_times_model.dart';

class AdhanService {
  /// Maps a persisted method id ([CalculationMethods]) to adhan's enum.
  /// Unknown ids fall back to Muslim World League.
  static CalculationMethod methodFor(String method) {
    switch (method) {
      case CalculationMethods.karachi:
        return CalculationMethod.karachi;
      case CalculationMethods.isna:
        return CalculationMethod.north_america;
      case CalculationMethods.mwl:
        return CalculationMethod.muslim_world_league;
      case CalculationMethods.ummAlQura:
        return CalculationMethod.umm_al_qura;
      case CalculationMethods.dubai:
        return CalculationMethod.dubai;
      case CalculationMethods.qatar:
        return CalculationMethod.qatar;
      case CalculationMethods.kuwait:
        return CalculationMethod.kuwait;
      case CalculationMethods.egyptian:
        return CalculationMethod.egyptian;
      case CalculationMethods.turkey:
        return CalculationMethod.turkey;
      case CalculationMethods.tehran:
        return CalculationMethod.tehran;
      case CalculationMethods.singapore:
        return CalculationMethod.singapore;
      case CalculationMethods.moonsighting:
        return CalculationMethod.moon_sighting_committee;
      default:
        return CalculationMethod.muslim_world_league;
    }
  }

  static CalculationParameters _params(String method, String? madhab) {
    final params = methodFor(method).getParameters();
    final effectiveMadhab = madhab ?? AsrMadhab.defaultFor(method);
    params.madhab =
        effectiveMadhab == AsrMadhab.hanafi ? Madhab.hanafi : Madhab.shafi;
    return params;
  }

  /// Prayer times for the calendar day of [date] (synchronous, pure).
  DailyPrayerTimes timesForDate(
    double lat,
    double lng,
    DateTime date, {
    String method = CalculationMethods.karachi,
    String? madhab,
  }) {
    final day = DateTime(date.year, date.month, date.day);
    final t = PrayerTimes(
      Coordinates(lat, lng),
      DateComponents(day.year, day.month, day.day),
      _params(method, madhab),
    );
    return PrayerTimesModel.dailyFromAdhan(t, day);
  }

  /// [days] consecutive days starting with [from]'s calendar day.
  List<DailyPrayerTimes> timesForDays(
    double lat,
    double lng,
    DateTime from,
    int days, {
    String method = CalculationMethods.karachi,
    String? madhab,
  }) => [
    for (var i = 0; i < days; i++)
      timesForDate(
        lat,
        lng,
        // Calendar-day arithmetic (DST safe).
        DateTime(from.year, from.month, from.day + i),
        method: method,
        madhab: madhab,
      ),
  ];

  /// Computes today's (relative to [now]) and tomorrow's prayer times.
  Future<PrayerTimesModel> getTimes(
    double lat,
    double lng, {
    String method = CalculationMethods.karachi,
    String? madhab,
    DateTime? now,
  }) async {
    final days = timesForDays(
      lat,
      lng,
      now ?? DateTime.now(),
      2,
      method: method,
      madhab: madhab,
    );
    return PrayerTimesModel(today: days[0], tomorrow: days[1]);
  }
}
