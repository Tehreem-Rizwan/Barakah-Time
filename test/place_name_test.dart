// "Unknown location" fixes: OpenStreetMap fallback and remembering the last
// place name found.
import 'package:barakah_time/core/services/location_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _islamabad = (lat: 33.6844, lng: 73.0479);

String _osm({String? city, String? town, String country = 'Pakistan'}) =>
    '{"address":{${city != null ? '"city":"$city",' : ''}'
    '${town != null ? '"town":"$town",' : ''}"country":"$country"}}';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Future<List<Placemark>> failingGeocoder(double a, double b) async =>
      throw Exception('grpc failed');

  test(
    'uses the phone geocoder first and does not call OpenStreetMap',
    () async {
      var osmCalls = 0;
      final service = LocationService(
        prefs: prefs,
        platformGeocoder:
            (a, b) async => [
              Placemark(locality: 'Islamabad', country: 'Pakistan'),
            ],
        client: MockClient((_) async {
          osmCalls++;
          return http.Response(_osm(city: 'X'), 200);
        }),
      );
      final place = await service.getPlace(_islamabad.lat, _islamabad.lng);
      expect(place.city, 'Islamabad');
      expect(place.country, 'Pakistan');
      expect(osmCalls, 0);
    },
  );

  test('falls back to OpenStreetMap with an app User-Agent', () async {
    http.Request? sent;
    final service = LocationService(
      prefs: prefs,
      platformGeocoder: failingGeocoder,
      client: MockClient((request) async {
        sent = request;
        return http.Response(_osm(city: 'Islamabad'), 200);
      }),
    );
    final place = await service.getPlace(_islamabad.lat, _islamabad.lng);
    expect(place.city, 'Islamabad');
    expect(sent!.url.host, LocationService.nominatimHost);
    expect(sent!.url.queryParameters['format'], 'jsonv2');
    expect(sent!.headers['User-Agent'], LocationService.userAgent);
  });

  test('remembers the last name and reuses it nearby when offline', () async {
    final online = LocationService(
      prefs: prefs,
      platformGeocoder:
          (a, b) async => [
            Placemark(locality: 'Islamabad', country: 'Pakistan'),
          ],
    );
    await online.getPlace(_islamabad.lat, _islamabad.lng);

    // Next launch: geocoder and OpenStreetMap both fail.
    final offline = LocationService(
      prefs: prefs,
      platformGeocoder: failingGeocoder,
      client: MockClient((_) async => throw Exception('offline')),
    );
    // ~2 km away: same city.
    final nearby = await offline.getPlace(33.70, 73.06);
    expect(nearby.city, 'Islamabad');

    // Lahore is ~270 km away: never shows the old city.
    final far = LocationService(
      prefs: prefs,
      platformGeocoder: failingGeocoder,
      client: MockClient((_) async => http.Response('', 500)),
    );
    final lahore = await far.getPlace(31.5204, 74.3587);
    expect(lahore.isUnknown, isTrue);
  });

  test('unknown only when every source fails', () async {
    final service = LocationService(
      prefs: prefs,
      platformGeocoder: (a, b) async => const [],
      client: MockClient((_) async => http.Response('{}', 200)),
    );
    expect((await service.getPlace(1, 1)).isUnknown, isTrue);
  });

  test('does not hit OpenStreetMap more than once per second', () async {
    var calls = 0;
    final service = LocationService(
      prefs: prefs,
      platformGeocoder: failingGeocoder,
      client: MockClient((_) async {
        calls++;
        return http.Response('', 503);
      }),
    );
    await service.getPlace(10, 10);
    await service.getPlace(20, 20);
    expect(calls, 1);
  });

  group('parseNominatim', () {
    test('prefers city, then town', () {
      expect(
        LocationService.parseNominatim(_osm(city: 'Karachi'))!.city,
        'Karachi',
      );
      expect(
        LocationService.parseNominatim(_osm(town: 'Murree'))!.city,
        'Murree',
      );
    });

    test('country alone is still useful; junk is null', () {
      expect(LocationService.parseNominatim(_osm())!.country, 'Pakistan');
      expect(LocationService.parseNominatim('not json'), isNull);
      expect(
        LocationService.parseNominatim('{"error":"Unable to geocode"}'),
        isNull,
      );
    });
  });

  test('distanceKm', () {
    expect(
      LocationService.distanceKm(33.6844, 73.0479, 31.5204, 74.3587),
      closeTo(270, 10),
    );
    expect(LocationService.distanceKm(10, 10, 10, 10), 0);
  });
}
