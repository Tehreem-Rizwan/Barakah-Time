import 'dart:convert';

import 'package:barakah_time/core/utils/islamic_events.dart';
import 'package:barakah_time/core/utils/nearby_mosques.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hijri/hijri_calendar.dart';

void main() {
  group('IslamicEvents.upcoming', () {
    test('returns future events sorted ascending with day counts', () {
      final now = DateTime(2026, 11, 14);
      final events = IslamicEvents.upcoming(now);
      expect(events.length, IslamicEvents.all.length);
      for (var i = 1; i < events.length; i++) {
        expect(events[i].gregorian.isBefore(events[i - 1].gregorian), isFalse);
      }
      for (final e in events) {
        expect(e.gregorian.isBefore(DateTime(2026, 11, 14)), isFalse);
        expect(e.daysRemaining, greaterThanOrEqualTo(0));
        final h = HijriCalendar.fromDate(e.gregorian);
        expect(h.hMonth, e.def.hijriMonth);
        expect(h.hDay, e.def.hijriDay);
      }
    });

    test('event falling today has 0 days remaining', () {
      final g = HijriCalendar().hijriToGregorian(1448, 9, 1);
      final events = IslamicEvents.upcoming(g);
      final ramadan = events.firstWhere((e) => e.def.key == 'ramadan_begins');
      expect(ramadan.daysRemaining, 0);
    });
  });

  group('NearbyMosquesService.parse', () {
    test('reads nodes and way centers, sorts and dedupes', () {
      final body = json.encode({
        'elements': [
          {
            'type': 'node',
            'lat': 33.70,
            'lon': 73.05,
            'tags': {'name': 'Far Mosque'},
          },
          {
            'type': 'way',
            'center': {'lat': 33.6901, 'lon': 73.0501},
            'tags': {'name': 'Near Masjid', 'addr:street': 'Main Rd'},
          },
          {
            'type': 'node',
            'lat': 33.6902,
            'lon': 73.0502,
            'tags': {'name': 'Near Masjid'},
          },
          {
            'type': 'node',
            'tags': {'name': 'No coords'},
          },
          {'type': 'node', 'lat': 33.695, 'lon': 73.05},
        ],
      });
      final list = NearbyMosquesService.parse(body, 33.69, 73.05);
      expect(list.map((m) => m.name).toList(), [
        'Near Masjid',
        '',
        'Far Mosque',
      ]);
      expect(list.first.address, 'Main Rd');
      expect(list.first.distanceMeters, lessThan(50));
    });

    test('query contains coordinates and radius', () {
      final q = NearbyMosquesService.buildQuery(1.5, 2.5);
      expect(q, contains('around:5000,1.5,2.5'));
      expect(q, contains('nwr['));
      expect(q, contains('out center;'));
    });
  });
}
