import '../../domain/entities/prayer_times.dart';
import '../../domain/repositories/prayer_repository.dart';
import '../datasources/remote/adhan_service.dart';

class PrayerRepositoryImpl implements PrayerRepository {
  final AdhanService adhanService;

  PrayerRepositoryImpl(this.adhanService);

  @override
  Future<PrayerTimesEntity> getPrayerTimes(
    double latitude,
    double longitude, {
    String method = 'Karachi',
    String? madhab,
    Map<String, int> offsets = const {},
  }) {
    return adhanService.getTimes(
      latitude,
      longitude,
      method: method,
      madhab: madhab,
      offsets: offsets,
    );
  }
}
