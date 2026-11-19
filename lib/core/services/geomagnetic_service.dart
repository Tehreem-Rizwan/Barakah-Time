import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Magnetic declination (degrees, east positive) for the Qibla compass.
///
/// Android's compass reports a heading from *magnetic* north, while the
/// Qibla bearing is measured from *true* north. Android's own
/// `GeomagneticField` (World Magnetic Model) supplies the difference through
/// a method channel. iOS already reports a true heading, so this is 0 there.
class GeomagneticService {
  GeomagneticService({MethodChannel? channel, bool? needsCorrection})
    : _channel = channel ?? const MethodChannel('barakah_time/geomagnetic'),
      _needsCorrection =
          needsCorrection ??
          (!kIsWeb && defaultTargetPlatform == TargetPlatform.android);

  final MethodChannel _channel;
  final bool _needsCorrection;
  final Map<String, double> _cache = {};

  /// Never throws: falls back to 0 (no correction).
  Future<double> declination(double latitude, double longitude) async {
    if (!_needsCorrection) return 0;
    // Declination changes slowly over distance; ~10 km buckets are plenty.
    final key =
        '${latitude.toStringAsFixed(1)},${longitude.toStringAsFixed(1)}';
    final cached = _cache[key];
    if (cached != null) return cached;
    try {
      final value = await _channel.invokeMethod<double>('declination', {
        'latitude': latitude,
        'longitude': longitude,
      });
      final result = (value == null || !value.isFinite) ? 0.0 : value;
      return _cache[key] = result;
    } catch (_) {
      return 0;
    }
  }
}

/// Low-pass filter for compass headings so the needle moves smoothly instead
/// of jittering. Averages on the unit circle, so 359° → 1° doesn't swing the
/// long way round.
class HeadingFilter {
  HeadingFilter({this.smoothing = 0.25})
    : assert(smoothing > 0 && smoothing <= 1);

  /// Weight of each new reading (1 = no smoothing).
  final double smoothing;
  double? _sin;
  double? _cos;

  /// Adds a reading and returns the smoothed heading in [0, 360).
  double add(double degrees) {
    final rad = degrees * math.pi / 180;
    final s = math.sin(rad);
    final c = math.cos(rad);
    if (_sin == null || _cos == null) {
      _sin = s;
      _cos = c;
    } else {
      _sin = _sin! + smoothing * (s - _sin!);
      _cos = _cos! + smoothing * (c - _cos!);
    }
    final deg = math.atan2(_sin!, _cos!) * 180 / math.pi;
    return (deg + 360) % 360;
  }

  void reset() {
    _sin = null;
    _cos = null;
  }
}
