import '../entities/prayer_times.dart';

abstract class PrayerRepository {
  /// [madhab] is 'shafi' or 'hanafi'; null uses the method's default.
  Future<PrayerTimesEntity> getPrayerTimes(
    double latitude,
    double longitude, {
    String method,
    String? madhab,
  });
}
