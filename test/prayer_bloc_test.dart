import 'package:barakah_time/core/services/location_service.dart';
import 'package:barakah_time/data/datasources/remote/adhan_service.dart';
import 'package:barakah_time/data/repositories/prayer_repository_impl.dart';
import 'package:barakah_time/presentation/blocs/prayer_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

class _FakeLocation implements LocationService {
  int calls = 0;
  LocationException? error;
  @override
  Future<Position> getCurrentPosition({bool forceRefresh = false}) async {
    calls++;
    if (error != null) throw error!;
    return Position(
      latitude: 21.42,
      longitude: 39.82,
      timestamp: DateTime.now(),
      accuracy: 1,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  const manual = PrayerConfig(
    method: 'MWL',
    madhab: 'shafi',
    useAutoLocation: false,
    manualLatitude: 51.5,
    manualLongitude: -0.12,
  );

  test('manual mode uses manual coords and never requests GPS', () async {
    final loc = _FakeLocation();
    final bloc = PrayerBloc(PrayerRepositoryImpl(AdhanService()), loc);
    bloc.add(LoadPrayerTimes(manual));
    await Future<void>.delayed(const Duration(milliseconds: 20));
    final s = bloc.state as PrayerLoaded;
    expect(s.latitude, 51.5);
    expect(loc.calls, 0);
    await bloc.close();
  });

  test('auto mode surfaces typed location failures', () async {
    final loc =
        _FakeLocation()
          ..error = const LocationException(LocationFailure.deniedForever, 'x');
    final bloc = PrayerBloc(PrayerRepositoryImpl(AdhanService()), loc);
    bloc.add(
      LoadPrayerTimes(
        const PrayerConfig(
          method: 'MWL',
          madhab: 'shafi',
          useAutoLocation: true,
          manualLatitude: 0,
          manualLongitude: 0,
        ),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(
      (bloc.state as PrayerError).locationFailure,
      LocationFailure.deniedForever,
    );
    await bloc.close();
  });
}
