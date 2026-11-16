import 'package:barakah_time/core/services/entry_route.dart';
import 'package:barakah_time/core/services/user_data_sync_service.dart';
import 'package:barakah_time/core/utils/nearby_mosques.dart';
import 'package:barakah_time/data/datasources/local/settings_prefs.dart';
import 'package:barakah_time/data/repositories/tasbeeh_repository.dart';
import 'package:barakah_time/data/sync/sync_mappers.dart';
import 'package:barakah_time/domain/entities/saved_verse.dart';
import 'package:barakah_time/domain/entities/spiritual_activity.dart';
import 'package:barakah_time/presentation/blocs/settings_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeSync implements UserDataSync {
  @override
  String? currentUid = 'u1';
  final List<Map<String, dynamic>> settings = [];
  final List<(int, int)> tasbeeh = [];

  @override
  void pushSettings(Map<String, dynamic> s) => settings.add(s);
  @override
  void pushTasbeeh(int count, int loggedCount) =>
      tasbeeh.add((count, loggedCount));
  final List<Map<String, dynamic>> qaza = [];
  @override
  void pushQaza(Map<String, dynamic> data) => qaza.add(data);
  @override
  void pushRamadanLog(Map<String, dynamic> log) {}
  @override
  void pushActivity(SpiritualActivity activity, {int? longestStreak}) {}
  @override
  void pushBadges(Map<String, DateTime> badges) {}
  @override
  void pushSavedVerse(SavedVerse verse) {}
  @override
  void deleteSavedVerse(String localId) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('activity mapping', () {
    final a = SpiritualActivity(
      id: 'prayer_fajr_20261115',
      type: 'prayer',
      subType: 'fajr',
      timestamp: DateTime(2026, 11, 15, 5, 30),
      points: 20,
    );

    test('to cloud', () {
      final m = SyncMappers.activityToCloud(a);
      expect(m['type'], 'prayer');
      expect(m['subType'], 'fajr');
      expect(m['points'], 20);
      expect(m['day'], '20261115');
      expect(m['timestamp'], a.timestamp);
    });

    test('points are clamped to the rules range', () {
      final big = SpiritualActivity(
        id: 'x',
        type: 'quran',
        timestamp: DateTime(2026),
        points: 500,
      );
      expect(SyncMappers.activityToCloud(big)['points'], 100);
    });

    test('round trip, Timestamp or DateTime', () {
      final data = {
        ...SyncMappers.activityToCloud(a),
        'timestamp': Timestamp.fromDate(a.timestamp),
      };
      expect(SyncMappers.activityFromCloud(a.id, data), a);
      expect(
        SyncMappers.activityFromCloud(a.id, SyncMappers.activityToCloud(a)),
        a,
      );
      expect(SyncMappers.activityFromCloud('bad', {'type': 'x'}), isNull);
    });

    test('dayKey pads', () {
      expect(SyncMappers.dayKey(DateTime(2026, 1, 5)), '20260105');
    });

    test('local-only activities skip ids and same-day prayers in cloud', () {
      final cloud = [a];
      final local = [
        a, // same id
        SpiritualActivity(
          id: 'legacy_fajr',
          type: 'prayer',
          subType: 'fajr',
          timestamp: DateTime(2026, 11, 15, 6),
          points: 20,
        ), // same prayer same day, different id
        SpiritualActivity(
          id: 'prayer_dhuhr_20261115',
          type: 'prayer',
          subType: 'dhuhr',
          timestamp: DateTime(2026, 11, 15, 13),
          points: 20,
        ),
        SpiritualActivity(
          id: 'dhikr_1',
          type: 'dhikr',
          timestamp: DateTime(2026, 11, 15, 14),
          points: 5,
        ),
      ];
      final pending = SyncMappers.localOnlyActivities(local, cloud);
      expect(pending.map((e) => e.id), ['prayer_dhuhr_20261115', 'dhikr_1']);
      expect(SyncMappers.totalPoints(pending), 25);
    });
  });

  group('saved verse mapping', () {
    final v = SavedVerse(
      id: '2:255',
      surahNumber: 2,
      ayahNumber: 255,
      text: 'ٱللَّهُ لَآ إِلَٰهَ إِلَّا هُوَ',
      translation: 'Allah - there is no deity except Him',
      surahName: 'Al-Baqara',
      timestamp: DateTime(2026, 11, 1),
    );

    test('doc ids', () {
      expect(SyncMappers.savedVerseDocId(2, 255), '2_255');
      expect(SyncMappers.savedVerseDocIdFromLocalId('2:255'), '2_255');
      expect(SyncMappers.savedVerseDocIdFromLocalId('nonsense'), isNull);
    });

    test('round trip keeps the local id format', () {
      final back = SyncMappers.savedVerseFromCloud(
        SyncMappers.savedVerseToCloud(v),
      );
      expect(back, v);
    });
  });

  group('tasbeeh + badges mapping', () {
    test('tasbeeh clamps', () {
      expect(SyncMappers.tasbeehToCloud(10, 50), {
        'count': 10,
        'loggedCount': 10,
      });
      expect(SyncMappers.tasbeehFromCloud({'count': 40, 'loggedCount': 33}), (
        count: 40,
        loggedCount: 33,
      ));
      expect(SyncMappers.tasbeehFromCloud({'count': 'x'}), isNull);
      expect(SyncMappers.tasbeehFromCloud(null), isNull);
    });

    test('badges from cloud', () {
      final at = DateTime(2026, 5, 1);
      expect(
        SyncMappers.badgesFromCloud([
          MapEntry('streak_7', {'earnedAt': Timestamp.fromDate(at)}),
        ]),
        {'streak_7': at},
      );
    });
  });

  group('settings mapping', () {
    test(
      'toCloud only includes saved keys; applyCloud skips notifications',
      () async {
        SharedPreferences.setMockInitialValues({
          'calculation_method': 'MWL',
          'manual_latitude': 51.5,
          'adhan_sound_enabled': false,
        });
        final prefs = await SharedPreferences.getInstance();
        expect(SettingsPrefs.toCloud(prefs), {
          'calculationMethod': 'MWL',
          'manualLatitude': 51.5,
          'adhanSoundEnabled': false,
        });

        await SettingsPrefs.applyCloud(prefs, {
          'calculationMethod': 'Turkey',
          'asrMadhab': 'hanafi',
          'useAutoLocation': false,
          'manualLocation': 'Istanbul',
          'manualLatitude': 41,
          'manualLongitude': 28.9,
          'languageCode': 'tr',
          'quranFontSize': 28,
          'notificationsEnabled': true,
          'adhanSoundEnabled': true,
        });
        final s = SettingsBloc.readFromPrefs(prefs, countryCode: 'PK');
        expect(s.calculationMethod, 'Turkey');
        expect(s.asrMadhab, 'hanafi');
        expect(s.useAutoLocation, isFalse);
        expect(s.manualLocation, 'Istanbul');
        expect(s.manualLatitude, 41.0);
        expect(s.languageCode, 'tr');
        expect(s.quranFontSize, 28.0);
        expect(s.adhanSoundEnabled, isTrue);
        expect(s.notificationsEnabled, isFalse); // per device
      },
    );

    test(
      'SettingsBloc pushes settings once, debounced, when signed in',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final sync = _FakeSync();
        final bloc = SettingsBloc(
          prefs,
          countryCode: 'PK',
          sync: sync,
          syncDebounce: const Duration(milliseconds: 30),
        );
        bloc.add(const UpdateCalculationMethod('MWL'));
        bloc.add(const UpdateMadhab('hanafi'));
        bloc.add(const UpdateLanguage('ur'));
        await Future<void>.delayed(const Duration(milliseconds: 100));
        expect(sync.settings.length, 1);
        expect(sync.settings.single['calculationMethod'], 'MWL');
        expect(sync.settings.single['asrMadhab'], 'hanafi');
        expect(sync.settings.single['languageCode'], 'ur');

        // LoadSettings (e.g. after a cloud pull) does not push back.
        bloc.add(LoadSettings());
        await Future<void>.delayed(const Duration(milliseconds: 100));
        expect(sync.settings.length, 1);

        // Signed out: no push.
        sync.currentUid = null;
        bloc.add(const UpdateLanguage('en'));
        await Future<void>.delayed(const Duration(milliseconds: 100));
        expect(sync.settings.length, 1);
        await bloc.close();
      },
    );
  });

  group('TasbeehRepository', () {
    test('saves to prefs immediately and syncs debounced', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final sync = _FakeSync();
      final repo = TasbeehRepository(
        prefs,
        sync: sync,
        debounce: const Duration(milliseconds: 30),
      );
      expect(repo.load(), TasbeehCounter.zero);
      for (var i = 1; i <= 5; i++) {
        await repo.save(i, 0);
      }
      expect(prefs.getInt('tasbeeh_count'), 5);
      expect(sync.tasbeeh, isEmpty);
      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(sync.tasbeeh, [(5, 0)]);

      await repo.save(33, 40); // logged clamps to count
      repo.flush();
      expect(sync.tasbeeh.last, (33, 33));
      expect(repo.load(), const TasbeehCounter(33, 33));
    });
  });

  group('entry route', () {
    AppEntryRoute r({
      bool ready = true,
      bool signedIn = false,
      bool guest = false,
      bool seen = true,
    }) => decideEntryRoute(
      firebaseReady: ready,
      signedIn: signedIn,
      isGuest: guest,
      hasSeenOnboarding: seen,
    );

    test('decisions', () {
      expect(r(signedIn: true), AppEntryRoute.main);
      expect(r(signedIn: true, seen: false), AppEntryRoute.main);
      expect(r(seen: false), AppEntryRoute.onboarding);
      expect(r(guest: true), AppEntryRoute.main);
      expect(r(), AppEntryRoute.signIn);
      // Firebase failed: never strand the user on a sign-in form.
      expect(r(ready: false), AppEntryRoute.main);
      expect(r(ready: false, signedIn: true), AppEntryRoute.main);
      expect(r(ready: false, seen: false), AppEntryRoute.onboarding);
    });

    test('resolveEntryRoute works without Firebase', () async {
      SharedPreferences.setMockInitialValues({
        'has_seen_onboarding': true,
        'guest_mode': false,
      });
      // AppInitStatus.firebaseReady is false in tests.
      expect(await resolveEntryRoute(), AppEntryRoute.main);
    });
  });

  group('mosque lookup fallback', () {
    const ok =
        '{"elements":[{"type":"node","lat":1.0,"lon":2.0,'
        '"tags":{"name":"Masjid"}}]}';

    test('429 on the main endpoint uses the mirror', () async {
      final hosts = <String>[];
      final service = NearbyMosquesService(
        client: MockClient((req) async {
          hosts.add(req.url.host);
          if (req.url.host == 'overpass-api.de') {
            return http.Response('busy', 429);
          }
          return http.Response(ok, 200);
        }),
      );
      final list = await service.fetch(1.0, 2.0);
      expect(list.single.name, 'Masjid');
      expect(hosts, ['overpass-api.de', 'overpass.kumi.systems']);
    });

    test('400 is not retried', () async {
      var calls = 0;
      final service = NearbyMosquesService(
        client: MockClient((req) async {
          calls++;
          return http.Response('bad', 400);
        }),
      );
      await expectLater(
        service.fetch(1, 2),
        throwsA(isA<MosqueLookupException>()),
      );
      expect(calls, 1);
    });

    test('both failing throws', () async {
      final service = NearbyMosquesService(
        client: MockClient((req) async => throw Exception('down')),
      );
      await expectLater(
        service.fetch(1, 2),
        throwsA(isA<MosqueLookupException>()),
      );
    });
  });
}
