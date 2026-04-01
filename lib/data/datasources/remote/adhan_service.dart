import 'package:adhan/adhan.dart';
import '../../models/prayer_times_model.dart';

class AdhanService {
  Future<PrayerTimesModel> getTimes(double lat, double lng) async {
    final coordinates = Coordinates(lat, lng);
    final params = CalculationMethod.karachi.getParameters();
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
