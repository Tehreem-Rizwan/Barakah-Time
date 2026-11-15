import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
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

  LocationService({this.prefs});

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

  Future<PlaceInfo> getPlace(double latitude, double longitude) async {
    final key =
        '${latitude.toStringAsFixed(3)},${longitude.toStringAsFixed(3)}';
    final cached = _placeCache[key];
    if (cached != null) return cached;
    try {
      final placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      ).timeout(geocodeTimeout);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        String? pick(List<String?> xs) => xs.firstWhere(
          (x) => x != null && x.trim().isNotEmpty,
          orElse: () => null,
        );
        final info = PlaceInfo(
          pick([p.locality, p.subAdministrativeArea, p.administrativeArea]) ??
              '',
          pick([p.country]) ?? '',
        );
        _placeCache[key] = info;
        return info;
      }
    } catch (e) {
      debugPrint('Reverse geocoding failed: $e');
    }
    return PlaceInfo.unknown;
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
