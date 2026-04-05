import 'package:adhan/adhan.dart';
import '../../models/prayer_times_model.dart';

class AdhanService {
  Future<PrayerTimesModel> getTimes(double lat, double lng, {String method = 'Karachi'}) async {
    final coordinates = Coordinates(lat, lng);
    
    CalculationMethod adhanMethod;
    switch (method) {
      case 'ISNA':
        adhanMethod = CalculationMethod.north_america;
        break;
      case 'MWL':
        adhanMethod = CalculationMethod.muslim_world_league;
        break;
      case 'Makkah':
        adhanMethod = CalculationMethod.umm_al_qura;
        break;
      case 'Dubai':
        adhanMethod = CalculationMethod.dubai;
        break;
      case 'Qatar':
        adhanMethod = CalculationMethod.qatar;
        break;
      case 'Karachi':
      default:
        adhanMethod = CalculationMethod.karachi;
    }

    final params = adhanMethod.getParameters();
    params.madhab = Madhab.hanafi;

    final adhanTimes = PrayerTimes.today(coordinates, params);
    
    // Determine the next prayer
    var next = adhanTimes.nextPrayer();
    
    // If next is none, it means Isha has passed. Get next day's Fajr.
    if (next == Prayer.none) {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final tomorrowTimes = PrayerTimes(
        coordinates,
        DateComponents(tomorrow.year, tomorrow.month, tomorrow.day),
        params,
      );
      return PrayerTimesModel.fromAdhan(tomorrowTimes, Prayer.fajr);
    }
    
    return PrayerTimesModel.fromAdhan(adhanTimes, next);
  }
}
