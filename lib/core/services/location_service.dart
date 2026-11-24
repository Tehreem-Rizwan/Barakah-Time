import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Why a location could not be obtained.
enum LocationFailure {
  serviceDisabled,
  denied,
  deniedForever,
  timeout,
  unknown,
}

class LocationException implements Exception {
  final LocationFailure failure;
  final String message;
  const LocationException(this.failure, this.message);

  @override
  String toString() => message;
}

/// Resolved place name for a coordinate. [city]/[country] are empty when
/// unknown — the UI shows a localized "Unknown location" (`unknown_city`).
class PlaceInfo {
  final String city;
  final String country;
  const PlaceInfo(this.city, this.country);

  static const unknown = PlaceInfo('', '');

  bool get isUnknown => city.isEmpty && country.isEmpty;
}

/// Single entry point for GPS access. Permission requests and position
/// lookups are de-duplicated: concurrent callers share one in-flight Future,
/// so the OS permission dialog is only ever shown once at a time.
class LocationService {
  static const Duration positionTimeout = Duration(seconds: 15);
  static const Duration geocodeTimeout = Duration(seconds: 10);
  static const Duration _cacheTtl = Duration(minutes: 5);

  Future<void>? _permissionInFlight;
  Future<Position>? _positionInFlight;
  Position? _lastPosition;
  DateTime? _lastPositionAt;
  final Map<String, PlaceInfo> _placeCache = {};

  /// Persists the last GPS fix so a cold start without a fresh fix (GPS
  /// timeout, airplane mode) can still compute prayer times.
  final SharedPreferences? prefs;
  static const kLastLat = 'last_gps_latitude';
  static const kLastLng = 'last_gps_longitude';
  static const kLastAt = 'last_gps_at';

  /// Last place name found, with the coordinates it belongs to, so the city
  /// still shows when the geocoder fails or there is no internet.
  static const kPlaceCity = 'last_place_city';
  static const kPlaceCountry = 'last_place_country';
  static const kPlaceLat = 'last_place_latitude';
  static const kPlaceLng = 'last_place_longitude';

  /// A saved place name is reused within this distance.
  static const double savedPlaceRadiusKm = 10;

  /// OpenStreetMap reverse geocoding, used when the phone's own geocoder
  /// fails (common on phones without Google services). Free, no key; the
  /// usage policy asks for an app-identifying User-Agent and at most one
  /// request per second.
  static const nominatimHost = 'nominatim.openstreetmap.org';
  static const userAgent =
      'BarakahTime/1.0 (Android; com.tehreem.barakah_time)';

  /// Phone geocoder; overridable in tests.
  final Future<List<Placemark>> Function(double lat, double lng)
  _platformGeocoder;
  final http.Client? _client;
  DateTime? _lastNominatimAt;

  LocationService({
    this.prefs,
    http.Client? client,
    Future<List<Placemark>> Function(double lat, double lng)? platformGeocoder,
  }) : _client = client,
       _platformGeocoder = platformGeocoder ?? placemarkFromCoordinates;

  /// Last persisted GPS coordinates, if any.
  ({double latitude, double longitude})? get savedCoordinates {
    final lat = prefs?.getDouble(kLastLat);
    final lng = prefs?.getDouble(kLastLng);
    if (lat == null || lng == null) return null;
    return (latitude: lat, longitude: lng);
  }

  void _persist(Position p) {
    final store = prefs;
    if (store == null) return;
    store.setDouble(kLastLat, p.latitude);
    store.setDouble(kLastLng, p.longitude);
    store.setInt(kLastAt, p.timestamp.millisecondsSinceEpoch);
  }

  Position? _savedPosition() {
    final c = savedCoordinates;
    if (c == null) return null;
    final at = prefs?.getInt(kLastAt);
    return Position(
      latitude: c.latitude,
      longitude: c.longitude,
      timestamp:
          at != null ? DateTime.fromMillisecondsSinceEpoch(at) : DateTime.now(),
      accuracy: 0,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );
  }

  /// Ensures location services are on and permission is granted, requesting
  /// it if needed. Throws [LocationException] otherwise.
  Future<void> ensurePermission() {
    final existing = _permissionInFlight;
    if (existing != null) return existing;
    final f = _ensurePermission();
    _permissionInFlight = f;
    _clearWhenDone(f, () => _permissionInFlight = null);
    return f;
  }

  Future<void> _ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationException(
        LocationFailure.serviceDisabled,
        'Location services are disabled.',
      );
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw const LocationException(
        LocationFailure.denied,
        'Location permission was denied.',
      );
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(
        LocationFailure.deniedForever,
        'Location permission is permanently denied.',
      );
    }
  }

  /// Current position. Results are cached briefly and concurrent callers
  /// share a single request. Times out after [positionTimeout] and falls back
  /// to the last known position.
  Future<Position> getCurrentPosition({bool forceRefresh = false}) {
    final cached = _lastPosition;
    final at = _lastPositionAt;
    if (!forceRefresh &&
        cached != null &&
        at != null &&
        DateTime.now().difference(at) < _cacheTtl) {
      return Future.value(cached);
    }
    final existing = _positionInFlight;
    if (existing != null) return existing;
    final f = _fetchPosition();
    _positionInFlight = f;
    _clearWhenDone(f, () => _positionInFlight = null);
    return f;
  }

  Future<Position> _fetchPosition() async {
    await ensurePermission();
    Position? position;
    try {
      position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: positionTimeout,
        ),
      ).timeout(positionTimeout + const Duration(seconds: 2));
    } on LocationServiceDisabledException {
      throw const LocationException(
        LocationFailure.serviceDisabled,
        'Location services are disabled.',
      );
    } catch (e) {
      debugPrint('getCurrentPosition failed: $e');
      position = await _lastKnown() ?? _savedPosition();
      if (position == null) {
        throw LocationException(
          e is TimeoutException
              ? LocationFailure.timeout
              : LocationFailure.unknown,
          e is TimeoutException
              ? 'Timed out while getting your location.'
              : 'Could not get your location.',
        );
      }
    }
    _lastPosition = position;
    _lastPositionAt = DateTime.now();
    _persist(position);
    return position;
  }

  Future<Position?> _lastKnown() async {
    try {
      return await Geolocator.getLastKnownPosition().timeout(
        const Duration(seconds: 3),
      );
    } catch (_) {
      return null; // Not supported on web, or no cached fix.
    }
  }

  /// City and country for coordinates. Tries the phone's geocoder, then
  /// OpenStreetMap, then the last name found nearby. Never throws; returns
  /// [PlaceInfo.unknown] only when all three fail.
  Future<PlaceInfo> getPlace(double latitude, double longitude) async {
    final key =
        '${latitude.toStringAsFixed(3)},${longitude.toStringAsFixed(3)}';
    final cached = _placeCache[key];
    if (cached != null) return cached;
    final found =
        await _fromPlatform(latitude, longitude) ??
        await _fromNominatim(latitude, longitude);
    if (found != null && !found.isUnknown) {
      _placeCache[key] = found;
      _savePlace(found, latitude, longitude);
      return found;
    }
    return savedPlaceNear(latitude, longitude) ?? PlaceInfo.unknown;
  }

  Future<PlaceInfo?> _fromPlatform(double latitude, double longitude) async {
    try {
      final placemarks = await _platformGeocoder(
        latitude,
        longitude,
      ).timeout(geocodeTimeout);
      if (placemarks.isEmpty) return null;
      final p = placemarks.first;
      String? pick(List<String?> xs) => xs.firstWhere(
        (x) => x != null && x.trim().isNotEmpty,
        orElse: () => null,
      );
      final info = PlaceInfo(
        pick([p.locality, p.subAdministrativeArea, p.administrativeArea]) ?? '',
        pick([p.country]) ?? '',
      );
      return info.isUnknown ? null : info;
    } catch (e) {
      debugPrint('Reverse geocoding failed: $e');
      return null;
    }
  }

  Future<PlaceInfo?> _fromNominatim(double latitude, double longitude) async {
    // Respect the one-request-per-second limit.
    final last = _lastNominatimAt;
    final now = DateTime.now();
    if (last != null && now.difference(last) < const Duration(seconds: 2)) {
      return null;
    }
    _lastNominatimAt = now;
    String lang;
    try {
      lang = PlatformDispatcher.instance.locale.languageCode;
    } catch (_) {
      lang = 'en';
    }
    final uri = Uri.https(nominatimHost, '/reverse', {
      'format': 'jsonv2',
      'lat': latitude.toStringAsFixed(5),
      'lon': longitude.toStringAsFixed(5),
      'zoom': '10',
      'accept-language': lang,
    });
    final client = _client ?? http.Client();
    try {
      final response = await client
          .get(uri, headers: {'User-Agent': userAgent})
          .timeout(geocodeTimeout);
      if (response.statusCode != 200) return null;
      return parseNominatim(response.body);
    } catch (e) {
      debugPrint('OpenStreetMap reverse geocoding failed: $e');
      return null;
    } finally {
      if (_client == null) client.close();
    }
  }

  /// City/country from a Nominatim `jsonv2` reverse response (public for
  /// tests). Null when nothing usable is in it.
  @visibleForTesting
  static PlaceInfo? parseNominatim(String body) {
    try {
      final data = json.decode(body);
      if (data is! Map) return null;
      final address = data['address'];
      if (address is! Map) return null;
      String? pick(List<String> keys) {
        for (final k in keys) {
          final v = address[k];
          if (v is String && v.trim().isNotEmpty) return v.trim();
        }
        return null;
      }

      final info = PlaceInfo(
        pick(['city', 'town', 'village', 'municipality', 'county', 'state']) ??
            '',
        pick(['country']) ?? '',
      );
      return info.isUnknown ? null : info;
    } catch (_) {
      return null;
    }
  }

  void _savePlace(PlaceInfo place, double latitude, double longitude) {
    final store = prefs;
    if (store == null) return;
    store.setString(kPlaceCity, place.city);
    store.setString(kPlaceCountry, place.country);
    store.setDouble(kPlaceLat, latitude);
    store.setDouble(kPlaceLng, longitude);
  }

  /// The last place name found, if it was within [savedPlaceRadiusKm].
  PlaceInfo? savedPlaceNear(double latitude, double longitude) {
    final store = prefs;
    if (store == null) return null;
    final lat = store.getDouble(kPlaceLat);
    final lng = store.getDouble(kPlaceLng);
    if (lat == null || lng == null) return null;
    if (distanceKm(lat, lng, latitude, longitude) > savedPlaceRadiusKm) {
      return null;
    }
    final info = PlaceInfo(
      store.getString(kPlaceCity) ?? '',
      store.getString(kPlaceCountry) ?? '',
    );
    return info.isUnknown ? null : info;
  }

  /// Great-circle distance in kilometres.
  static double distanceKm(double lat1, double lng1, double lat2, double lng2) {
    const r = 6371.0;
    double rad(double d) => d * math.pi / 180;
    final dLat = rad(lat2 - lat1);
    final dLng = rad(lng2 - lng1);
    final a =
        math.pow(math.sin(dLat / 2), 2) +
        math.cos(rad(lat1)) *
            math.cos(rad(lat2)) *
            math.pow(math.sin(dLng / 2), 2);
    return 2 * r * math.asin(math.sqrt(a.toDouble()));
  }

  Future<String> getCityFromPosition(Position position) async =>
      (await getPlace(position.latitude, position.longitude)).city;

  Future<String> getCountryFromPosition(Position position) async =>
      (await getPlace(position.latitude, position.longitude)).country;

  /// Forward-geocodes a free-text place. Returns null when not found.
  Future<({double latitude, double longitude})?> geocode(String query) async {
    final q = query.trim();
    if (q.isEmpty) return null;
    try {
      final results = await locationFromAddress(q).timeout(geocodeTimeout);
      if (results.isEmpty) return null;
      return (
        latitude: results.first.latitude,
        longitude: results.first.longitude,
      );
    } catch (e) {
      debugPrint('Geocoding "$q" failed: $e');
      return null;
    }
  }

  Future<bool> openAppSettings() => Geolocator.openAppSettings();

  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();

  static void _clearWhenDone(Future<void> f, void Function() clear) {
    f.then<void>((_) {}, onError: (_) {}).whenComplete(clear);
  }
}
