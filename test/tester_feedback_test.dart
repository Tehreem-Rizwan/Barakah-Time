// Fixes from closed-testing feedback: optional sign-in, Qibla accuracy and
// refresh, offline Quran audio.
import 'dart:async';
import 'dart:io';

import 'package:barakah_time/core/services/audio_cache.dart';
import 'package:barakah_time/core/services/geomagnetic_service.dart';
import 'package:barakah_time/core/services/location_service.dart';
import 'package:barakah_time/core/services/notification_service.dart';
import 'package:barakah_time/domain/entities/prayer_times.dart';
import 'package:barakah_time/data/datasources/remote/adhan_service.dart';
import 'package:barakah_time/presentation/pages/support_actions.dart';
import 'package:flutter/foundation.dart';
import 'package:barakah_time/presentation/blocs/location_bloc.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

class _FakeLocation implements LocationService {
  double lat = 31.52;
  LocationException? error;

  @override
  Future<Position> getCurrentPosition({bool forceRefresh = false}) async {
    if (error != null) throw error!;
    return Position(
      latitude: lat,
      longitude: 74.35,
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
  Future<PlaceInfo> getPlace(double l, double g) async =>
      const PlaceInfo('Lahore', 'Pakistan');

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HeadingFilter', () {
    test('first reading passes through', () {
      expect(HeadingFilter().add(120), closeTo(120, 1e-9));
    });

    test('smooths towards new readings', () {
      final f = HeadingFilter(smoothing: 0.5);
      f.add(0);
      final v = f.add(90);
      expect(v, greaterThan(0));
      expect(v, lessThan(90));
    });

    test('wraps around north instead of swinging the long way', () {
      final f = HeadingFilter(smoothing: 0.5);
      f.add(350);
      final v = f.add(10);
      // Halfway between 350° and 10° is 0°, not 180°.
      expect(v < 5 || v > 355, isTrue, reason: 'got $v');
    });

    test('reset starts fresh', () {
      final f = HeadingFilter(smoothing: 0.1)..add(0);
      f.reset();
      expect(f.add(200), closeTo(200, 1e-9));
    });
  });

  group('GeomagneticService', () {
    const channel = MethodChannel('test/geomagnetic');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    tearDown(() => messenger.setMockMethodCallHandler(channel, null));

    test('returns the platform declination and caches it', () async {
      var calls = 0;
      Map<Object?, Object?>? args;
      messenger.setMockMethodCallHandler(channel, (call) async {
        calls++;
        args = call.arguments as Map<Object?, Object?>;
        return call.method == 'declination' ? 2.4 : null;
      });
      final s = GeomagneticService(channel: channel, needsCorrection: true);
      expect(await s.declination(31.52, 74.35), 2.4);
      expect(await s.declination(31.53, 74.31), 2.4);
      expect(calls, 1);
      expect(args?['latitude'], 31.52);
    });

    test(
      'no correction when the platform already reports true north',
      () async {
        final s = GeomagneticService(channel: channel, needsCorrection: false);
        expect(await s.declination(31.5, 74.3), 0);
      },
    );

    test('falls back to 0 when the channel fails', () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        throw PlatformException(code: 'x');
      });
      final s = GeomagneticService(channel: channel, needsCorrection: true);
      expect(await s.declination(31.5, 74.3), 0);
    });
  });

  group('LocationBloc silent refresh', () {
    test('keeps showing the loaded location (no loading state)', () async {
      final loc = _FakeLocation();
      final bloc = LocationBloc(loc);
      addTearDown(bloc.close);
      bloc.add(FetchLocation());
      await bloc.stream.firstWhere((s) => s is LocationLoaded);

      final states = <LocationState>[];
      final sub = bloc.stream.listen(states.add);
      loc.lat = 31.60;
      final done = Completer<bool>();
      bloc.add(
        FetchLocation(forceRefresh: true, silent: true, completer: done),
      );
      expect(await done.future, isTrue);
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(states.whereType<LocationLoading>(), isEmpty);
      expect((bloc.state as LocationLoaded).latitude, 31.60);
    });

    test('completes even when the location did not change', () async {
      final bloc = LocationBloc(_FakeLocation());
      addTearDown(bloc.close);
      bloc.add(FetchLocation());
      await bloc.stream.firstWhere((s) => s is LocationLoaded);
      final done = Completer<bool>();
      bloc.add(FetchLocation(silent: true, completer: done));
      expect(await done.future.timeout(const Duration(seconds: 2)), isTrue);
    });

    test('a failed silent refresh keeps the previous location', () async {
      final loc = _FakeLocation();
      final bloc = LocationBloc(loc);
      addTearDown(bloc.close);
      bloc.add(FetchLocation());
      await bloc.stream.firstWhere((s) => s is LocationLoaded);

      loc.error = const LocationException(
        LocationFailure.serviceDisabled,
        'off',
      );
      final done = Completer<bool>();
      bloc.add(
        FetchLocation(forceRefresh: true, silent: true, completer: done),
      );
      expect(await done.future, isFalse);
      expect(bloc.state, isA<LocationLoaded>());
    });
  });

  group('AudioCache', () {
    late Directory tmp;
    setUp(() => tmp = Directory.systemTemp.createTempSync('audio_cache'));
    tearDown(() => tmp.deleteSync(recursive: true));

    test('file names are stable and filesystem safe', () {
      expect(
        AudioCache.fileNameFor(
          'https://cdn.islamic.network/quran/audio/128/ar.alafasy/1.mp3',
        ),
        'audio_128_ar.alafasy_1.mp3',
      );
      expect(
        AudioCache.fileNameFor(
          'https://cdn.islamic.network/quran/audio/64/ur.khan/262.mp3',
        ),
        'audio_64_ur.khan_262.mp3',
      );
    });

    test('allSaved reflects what is on disk', () async {
      final cache = AudioCache(baseDir: () async => tmp);
      const a = 'https://cdn.islamic.network/quran/audio/128/ar.alafasy/1.mp3';
      const b = 'https://cdn.islamic.network/quran/audio/128/ar.alafasy/2.mp3';
      expect(await cache.allSaved([a, b]), isFalse);
      await (await cache.fileFor(a)).writeAsString('x');
      expect(await cache.allSaved([a]), isTrue);
      expect(await cache.allSaved([a, b]), isFalse);
    });

    test('trim removes the oldest recitations beyond the limit', () async {
      final now = DateTime.now();
      File make(String name, int bytes, int minutesAgo) {
        final f = File('${tmp.path}/$name')
          ..writeAsBytesSync(List.filled(bytes, 0));
        final t = now.subtract(Duration(minutes: minutesAgo));
        f.setLastModifiedSync(t);
        f.setLastAccessedSync(t);
        return f;
      }

      final oldest = make('a.mp3', 100, 30);
      final oldestMime = File('${oldest.path}.mime')
        ..writeAsStringSync('audio/mpeg');
      final middle = make('b.mp3', 100, 20);
      final newest = make('c.mp3', 100, 10);

      await AudioCache.trimDirectory(tmp, 200);

      expect(oldest.existsSync(), isFalse);
      expect(oldestMime.existsSync(), isFalse);
      expect(middle.existsSync(), isTrue);
      expect(newest.existsSync(), isTrue);
    });

    test(
      'trim keeps side files of saved recitations, drops stale partials',
      () async {
        final saved = File('${tmp.path}/a.mp3')..writeAsStringSync('x');
        final mime = File('${saved.path}.mime')
          ..writeAsStringSync('audio/mpeg');
        final stale = File('${tmp.path}/b.mp3.part')..writeAsStringSync('x');
        stale.setLastModifiedSync(
          DateTime.now().subtract(const Duration(days: 2)),
        );
        final fresh = File('${tmp.path}/c.mp3.part')..writeAsStringSync('x');

        await AudioCache.trimDirectory(tmp, 1 << 20);

        expect(saved.existsSync(), isTrue);
        expect(mime.existsSync(), isTrue);
        expect(stale.existsSync(), isFalse);
        expect(fresh.existsSync(), isTrue, reason: 'may still be downloading');
      },
    );
  });

  group('notification horizon', () {
    tearDown(() => debugDefaultTargetPlatformOverride = null);

    test('Android schedules a month, iOS stays within its 64 limit', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      expect(NotificationService.scheduleDays, 30);
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      expect(NotificationService.scheduleDays, NotificationService.daysAhead);
      expect(NotificationService.scheduleDays * 5, lessThanOrEqualTo(64));
    });

    test('30 days of prayers get unique ids inside the prayers group', () {
      final now = DateTime(2026, 11, 20, 0, 1);
      final days = AdhanService().timesForDays(31.52, 74.35, now, 30);
      final schedule = NotificationService.computeSchedule(days, now);
      final ids = schedule.map((s) => s.id).toList();
      expect(ids.toSet().length, ids.length);
      expect(ids.every((id) => id >= 0 && id < ReminderGroups.size), isTrue);
      expect(schedule.length, 150);
    });
  });

  group('no duplicate prayer notifications', () {
    test(
      'the same prayer time keeps its id when scheduled from another day',
      () {
        final days = AdhanService().timesForDays(
          31.52,
          74.35,
          DateTime(2026, 11, 25),
          30,
        );
        final fromToday = NotificationService.computeSchedule(
          days,
          DateTime(2026, 11, 25, 0, 1),
        );
        // A reschedule starting tomorrow (e.g. after midnight).
        final fromTomorrow = NotificationService.computeSchedule(
          days.sublist(1),
          DateTime(2026, 11, 26, 0, 1),
        );
        final byTime = {for (final s in fromToday) s.time: s.id};
        for (final s in fromTomorrow) {
          expect(byTime[s.time], s.id, reason: '${s.prayer} ${s.time}');
        }
      },
    );

    test('ids are unique for 100 days and stay in the prayers group', () {
      final ids = <int>{};
      for (var d = 0; d < 100; d++) {
        for (final p in PrayerName.values) {
          final id = NotificationService.prayerNotificationId(
            DateTime(2026, 11, 25).add(Duration(days: d)),
            p,
          );
          expect(id, inInclusiveRange(0, ReminderGroups.size - 1));
          expect(ids.add(id), isTrue);
        }
      }
    });
  });

  group('feedback email', () {
    test('goes to the support address with readable encoding', () {
      final uri = feedbackEmailUri(version: '1.0.1', os: 'android 14');
      expect(uri.scheme, 'mailto');
      final text = uri.toString();
      expect(text, contains('Barakah%20Time%20feedback%20(v1.0.1)'));
      expect(text, isNot(contains('+')));
      expect(Uri.decodeComponent(text), contains('App version: 1.0.1'));
      expect(Uri.decodeComponent(text), contains('Device: android 14'));
    });

    test('works without version or device info', () {
      final uri = feedbackEmailUri();
      expect(Uri.decodeComponent(uri.toString()), isNot(contains('null')));
    });
  });
}
