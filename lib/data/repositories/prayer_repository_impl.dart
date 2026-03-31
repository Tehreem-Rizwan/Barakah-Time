import '../../domain/entities/prayer_times.dart';
import '../../domain/repositories/prayer_repository.dart';
import '../datasources/remote/adhan_service.dart';

class PrayerRepositoryImpl implements PrayerRepository {
  final AdhanService adhanService;

  PrayerRepositoryImpl(this.adhanService);

  @override
  Future<PrayerTimesEntity> getPrayerTimes(double latitude, double longitude) async {
    return await adhanService.getTimes(latitude, longitude);
  }
}
