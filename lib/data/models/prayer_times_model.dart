import 'package:adhan/adhan.dart';
import '../../domain/entities/prayer_times.dart';

class PrayerTimesModel extends PrayerTimesEntity {
  const PrayerTimesModel({
    required super.fajr,
    required super.sunrise,
    required super.dhuhr,
    required super.asr,
    required super.maghrib,
    required super.isha,
    required super.currentPrayerName,
    required super.timeUntilNextPrayer,
  });

  factory PrayerTimesModel.fromAdhan(PrayerTimes adhanTimes, Prayer next) {
    return PrayerTimesModel(
      fajr: adhanTimes.fajr,
      sunrise: adhanTimes.sunrise,
      dhuhr: adhanTimes.dhuhr,
      asr: adhanTimes.asr,
      maghrib: adhanTimes.maghrib,
      isha: adhanTimes.isha,
      currentPrayerName: _getPrayerName(next),
      timeUntilNextPrayer: adhanTimes.timeForPrayer(next)!.difference(DateTime.now()),
    );
  }

  static String _getPrayerName(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr: return 'Fajr';
      case Prayer.sunrise: return 'Sunrise';
      case Prayer.dhuhr: return 'Dhuhr';
      case Prayer.asr: return 'Asr';
      case Prayer.maghrib: return 'Maghrib';
      case Prayer.isha: return 'Isha';
      default: return 'None';
    }
  }
}
