import 'dart:convert';

import 'package:barakah_time/core/localization/app_localizations.dart';
import 'package:barakah_time/core/services/home_widget_service.dart';
import 'package:barakah_time/domain/entities/prayer_times.dart';
import 'package:flutter/material.dart' show Locale;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

DailyPrayerTimes _day(int d) {
  DateTime at(int h) => DateTime(2026, 11, d, h);
  return DailyPrayerTimes(
    date: DateTime(2026, 11, d),
    fajr: at(5),
    sunrise: at(6),
    dhuhr: at(12),
    asr: at(15),
    maghrib: at(17),
    isha: at(19),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('encodes five times per day plus localized labels', () {
    final json =
        jsonDecode(
              HomeWidgetService.encode([
                _day(16),
                _day(17),
              ], AppLocalizations(const Locale('en'))),
            )
            as Map<String, dynamic>;
    final days = json['days'] as List;
    expect(days, hasLength(2));
    expect(days[0], hasLength(5)); // sunrise is not included
    expect(days[0][0], DateTime(2026, 11, 16, 5).millisecondsSinceEpoch);
    expect(days[1][4], DateTime(2026, 11, 17, 19).millisecondsSinceEpoch);
    final labels = json['labels'] as Map;
    expect(labels['fajr'], 'Fajr');
    expect(labels['next'], isNotEmpty);
    expect(labels['empty'], isNot('widget_empty'));
  });

  test('sends data over the channel on Android, never throws', () async {
    const channel = MethodChannel('test/home_widget');
    MethodCall? call;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (c) async {
          call = c;
          throw PlatformException(code: 'boom');
        });
    await HomeWidgetService(
      channel: channel,
      supported: true,
    ).update([_day(16)], AppLocalizations(const Locale('ur')));
    expect(call?.method, 'update');
    expect((call!.arguments as Map)['data'], contains('"days"'));

    call = null;
    await HomeWidgetService(
      channel: channel,
      supported: false,
    ).update([_day(16)], AppLocalizations(const Locale('en')));
    expect(call, isNull);
  });
}
