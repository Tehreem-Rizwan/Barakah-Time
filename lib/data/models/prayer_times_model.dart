import 'package:adhan/adhan.dart';
import '../../domain/entities/prayer_times.dart';

class PrayerTimesModel extends PrayerTimesEntity {
  const PrayerTimesModel({required super.today, required super.tomorrow});

  static DailyPrayerTimes dailyFromAdhan(PrayerTimes t, DateTime date) {
    return DailyPrayerTimes(
      date: DateTime(date.year, date.month, date.day),
      fajr: t.fajr,
      sunrise: t.sunrise,
      dhuhr: t.dhuhr,
      asr: t.asr,
      maghrib: t.maghrib,
      isha: t.isha,
    );
  }
}
