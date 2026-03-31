import 'package:adhan/adhan.dart';
import '../../models/prayer_times_model.dart';

class AdhanService {
  Future<PrayerTimesModel> getTimes(double lat, double lng) async {
    final coordinates = Coordinates(lat, lng);
    final params = CalculationMethod.karachi.getParameters();
    params.madhab = Madhab.hanafi;

    final adhanTimes = PrayerTimes.today(coordinates, params);
    
    // Determine the next prayer
    final next = adhanTimes.nextPrayer();
    
    return PrayerTimesModel.fromAdhan(adhanTimes, next);
  }
}
