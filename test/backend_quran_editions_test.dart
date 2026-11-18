import 'dart:convert';

import 'package:barakah_time/data/repositories/quran_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class _MemCache implements QuranCache {
  final Map<String, String> store = {};
  @override
  Future<String?> read(String key) async => store[key];
  @override
  Future<void> write(String key, String value) async => store[key] = value;
}

Map<String, dynamic> _ayah(int n, String text, {String? audio}) => {
  'number': n,
  'numberInSurah': n,
  'text': text,
  'juz': 1,
  'manzil': 1,
  'page': 1,
  'ruku': 1,
  'hizbQuarter': 1,
  if (audio != null) 'audio': audio,
};

String _body(List<Map<String, dynamic>> ayahs) => json.encode({
  'data': {'ayahs': ayahs},
});

void main() {
  test('translation edition per language', () {
    const f = QuranRepository.translationEditionFor;
    expect(f('en'), 'en.sahih');
    expect(f('ur'), 'ur.jalandhry');
    expect(f('tr'), 'tr.vakfi');
    expect(f('fa'), 'fa.fooladvand');
    expect(f('ar'), 'ar.muyassar');
    expect(f('xx'), 'en.sahih');
  });

  group('caching', () {
    late List<String> requested;
    late bool online;
    late QuranRepository repo;
    late _MemCache cache;

    setUp(() {
      requested = [];
      online = true;
      cache = _MemCache();
      final client = MockClient((req) async {
        requested.add(req.url.path);
        if (!online) throw Exception('offline');
        final path = req.url.path;
        if (path.endsWith('/surah')) {
          return http.Response.bytes(
            utf8.encode(
              json.encode({
                'data': [
                  {
                    'number': 1,
                    'name': 'الفاتحة',
                    'englishName': 'Al-Faatiha',
                    'englishNameTranslation': 'The Opening',
                    'numberOfAyahs': 7,
                    'revelationType': 'Meccan',
                  },
                ],
              }),
            ),
            200,
          );
        }
        if (path.endsWith('ur.jalandhry')) {
          return http.Response.bytes(
            utf8.encode(_body([_ayah(1, 'اردو'), _ayah(2, 'دو')])),
            200,
          );
        }
        return http.Response.bytes(
          utf8.encode(
            _body([_ayah(1, 'x', audio: 'a1'), _ayah(2, 'y', audio: 'a2')]),
          ),
          200,
        );
      });
      repo = QuranRepository(client: client, cache: cache);
    });

    test('uses the requested translation edition', () async {
      final ayahs = await repo.getSurahWithTranslation(
        9,
        translationEdition: 'ur.jalandhry',
      );
      expect(ayahs.first.translation, 'اردو');
      expect(requested.any((p) => p.endsWith('/surah/9/ur.jalandhry')), isTrue);
    });

    test('surah detail is served from cache when offline', () async {
      await repo.getSurahWithTranslation(9, translationEdition: 'ur.jalandhry');
      online = false;
      requested.clear();
      final again = await repo.getSurahWithTranslation(
        9,
        translationEdition: 'ur.jalandhry',
      );
      expect(again.length, 2);
      expect(requested, isEmpty); // cache first, no network
    });

    test('forceRefresh falls back to cache when offline', () async {
      await repo.getSurahWithTranslation(9);
      online = false;
      final ayahs = await repo.getSurahWithTranslation(9, forceRefresh: true);
      expect(ayahs.length, 2);
    });

    test('surah list: cache first, then offline still works', () async {
      final first = await repo.getSurahs();
      expect(first.single.englishName, 'Al-Faatiha');
      online = false;
      final cached = await repo.getSurahs();
      expect(cached.single.number, 1);
      final forced = await repo.getSurahs(forceRefresh: true);
      expect(forced.single.number, 1);
    });

    test('nothing cached + offline throws QuranLoadException', () async {
      online = false;
      expect(repo.getSurahs(), throwsA(isA<QuranLoadException>()));
    });
  });
}
