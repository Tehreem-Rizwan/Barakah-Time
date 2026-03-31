import '../entities/prayer_times.dart';

abstract class PrayerRepository {
  Future<PrayerTimesEntity> getPrayerTimes(double latitude, double longitude);
}
