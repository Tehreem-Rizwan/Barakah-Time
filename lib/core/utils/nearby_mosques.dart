import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class NearbyMosque {
  /// Empty when OpenStreetMap has no name for it.
  final String name;
  final String? address;
  final double latitude;
  final double longitude;

  /// Distance from the user in metres.
  final double distanceMeters;

  const NearbyMosque({
    required this.name,
    this.address,
    required this.latitude,
    required this.longitude,
    required this.distanceMeters,
  });
}

class MosqueLookupException implements Exception {
  final String message;
  const MosqueLookupException(this.message);
  @override
  String toString() => message;
}

/// Finds mosques near a coordinate using the OpenStreetMap Overpass API.
/// Falls back to a mirror when the main endpoint is rate limited (429),
/// failing (5xx) or unreachable/timing out.
class NearbyMosquesService {
  static const String endpoint = 'https://overpass-api.de/api/interpreter';
  static const String fallbackEndpoint =
      'https://overpass.kumi.systems/api/interpreter';
  static const List<String> endpoints = [endpoint, fallbackEndpoint];
  static const Duration timeout = Duration(seconds: 25);

  final http.Client _client;

  NearbyMosquesService({http.Client? client})
    : _client = client ?? http.Client();

  /// nodes, ways and relations (`nwr`) with `out center;` so every result
  /// has a coordinate. No result cap: the nearest ones must not be dropped
  /// (results are sorted by distance after parsing).
  static String buildQuery(double lat, double lng, {int radiusMeters = 5000}) {
    final around = 'around:$radiusMeters,$lat,$lng';
    return '[out:json][timeout:20];'
        'nwr["amenity"="place_of_worship"]["religion"="muslim"]($around);'
        'out center;';
  }

  /// Whether a response/error from one endpoint should be retried on the
  /// next one.
  static bool shouldTryNextEndpoint(int? statusCode) =>
      statusCode == null || statusCode == 429 || statusCode >= 500;

  Future<List<NearbyMosque>> fetch(double lat, double lng) async {
    MosqueLookupException? lastError;
    for (final url in endpoints) {
      final http.Response response;
      try {
        response = await _client
            .post(
              Uri.parse(url),
              headers: const {
                'User-Agent': 'BarakahTime/1.0',
                'Content-Type': 'application/x-www-form-urlencoded',
              },
              body: {'data': buildQuery(lat, lng)},
            )
            .timeout(timeout);
      } catch (_) {
        lastError = const MosqueLookupException('network');
        continue; // timeout / unreachable: try the mirror
      }
      if (response.statusCode != 200) {
        lastError = MosqueLookupException('http_${response.statusCode}');
        if (shouldTryNextEndpoint(response.statusCode)) continue;
        throw lastError;
      }
      final body = utf8.decode(response.bodyBytes);
      // Overpass reports server-side timeouts/out-of-memory as HTTP 200
      // with a "remark" and no results: try the mirror instead of showing
      // "no mosques nearby".
      if (isServerError(body)) {
        lastError = const MosqueLookupException('server');
        continue;
      }
      try {
        return parse(body, lat, lng);
      } catch (_) {
        throw const MosqueLookupException('parse');
      }
    }
    throw lastError ?? const MosqueLookupException('network');
  }

  static bool isServerError(String body) {
    try {
      final decoded = json.decode(body);
      final remark = decoded is Map ? decoded['remark'] : null;
      return remark is String &&
          RegExp(
            'runtime error|timed out|out of memory',
            caseSensitive: false,
          ).hasMatch(remark);
    } catch (_) {
      return false;
    }
  }

  /// Parses an Overpass JSON response, computes distances, removes
  /// duplicates (same name within 150 m) and sorts by distance.
  static List<NearbyMosque> parse(
    String body,
    double userLat,
    double userLng, {
    String unnamedLabel = '',
  }) {
    final decoded = json.decode(body) as Map<String, dynamic>;
    final elements = (decoded['elements'] as List?) ?? const [];
    final mosques = <NearbyMosque>[];
    for (final raw in elements) {
      if (raw is! Map) continue;
      final el = raw.cast<String, dynamic>();
      double? lat = (el['lat'] as num?)?.toDouble();
      double? lon = (el['lon'] as num?)?.toDouble();
      final center = el['center'];
      if ((lat == null || lon == null) && center is Map) {
        lat = (center['lat'] as num?)?.toDouble();
        lon = (center['lon'] as num?)?.toDouble();
      }
      if (lat == null || lon == null) continue;
      final tags = (el['tags'] as Map?)?.cast<String, dynamic>() ?? const {};
      final name =
          ((tags['name'] ?? tags['name:en'] ?? tags['name:ar']) as String?)
              ?.trim() ??
          '';
      mosques.add(
        NearbyMosque(
          name: name.isEmpty ? unnamedLabel : name,
          address: _address(tags),
          latitude: lat,
          longitude: lon,
          distanceMeters: Geolocator.distanceBetween(
            userLat,
            userLng,
            lat,
            lon,
          ),
        ),
      );
    }
    mosques.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
    return dedupe(mosques);
  }

  static List<NearbyMosque> dedupe(
    List<NearbyMosque> sorted, {
    double withinMeters = 150,
  }) {
    final result = <NearbyMosque>[];
    for (final m in sorted) {
      final key = m.name.toLowerCase();
      final dup = result.any(
        (r) =>
            r.name.toLowerCase() == key &&
            Geolocator.distanceBetween(
                  r.latitude,
                  r.longitude,
                  m.latitude,
                  m.longitude,
                ) <
                withinMeters,
      );
      if (!dup) result.add(m);
    }
    return result;
  }

  static String? _address(Map<String, dynamic> tags) {
    final parts = <String>[
      if (tags['addr:housenumber'] != null && tags['addr:street'] != null)
        '${tags['addr:housenumber']} ${tags['addr:street']}'
      else if (tags['addr:street'] != null)
        '${tags['addr:street']}',
      if (tags['addr:suburb'] != null) '${tags['addr:suburb']}',
      if (tags['addr:city'] != null) '${tags['addr:city']}',
    ];
    return parts.isEmpty ? null : parts.join(', ');
  }
}
