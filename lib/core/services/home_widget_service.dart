import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/prayer_times.dart';
import '../localization/app_localizations.dart';

/// Sends prayer times to the Android home-screen widget
/// (`PrayerWidgetProvider.kt`). The widget keeps the data, so it shows the
/// next prayer and a live countdown even while the app is closed.
class HomeWidgetService {
  HomeWidgetService({MethodChannel? channel, bool? supported})
    : _channel = channel ?? const MethodChannel('barakah_time/home_widget'),
      _supported =
          supported ??
          (!kIsWeb && defaultTargetPlatform == TargetPlatform.android);

  final MethodChannel _channel;
  final bool _supported;

  /// Days of times sent to the widget, so it keeps working for a week
  /// without the app being opened.
  static const int daysAhead = 7;

  /// Pure: the JSON the widget reads. Times are epoch milliseconds, five per
  /// day in [PrayerName] order.
  static String encode(
    List<DailyPrayerTimes> days,
    AppLocalizations l10n,
  ) => jsonEncode({
    'labels': {
      'next': l10n.next_prayer,
      'empty': l10n.translate('widget_empty'),
      for (final p in PrayerName.values) p.key: l10n.translate(p.key),
    },
    'days': [
      for (final d in days)
        [for (final p in PrayerName.values) d.timeOf(p).millisecondsSinceEpoch],
    ],
  });

  Future<void> update(
    List<DailyPrayerTimes> days,
    AppLocalizations l10n,
  ) async {
    if (!_supported) return;
    try {
      await _channel.invokeMethod('update', {'data': encode(days, l10n)});
    } catch (e) {
      debugPrint('Home widget update failed: $e');
    }
  }
}
