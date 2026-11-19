import 'dart:convert';

import 'package:barakah_time/core/utils/arabic_text.dart';
import 'package:barakah_time/data/repositories/quran_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

Map<String, dynamic> _ayah(int n, String text, {String? audio}) => {
  'number': n,
  'text': text,
  'numberInSurah': n,
  'juz': 1,
  'manzil': 1,
  'page': 1,
  'ruku': 1,
  'hizbQuarter': 1,
  if (audio != null) 'audio': audio,
};

void main() {
  group('ArabicText', () {
    test('normalize removes harakat and unifies alef', () {
      expect(ArabicText.normalize('بِسْمِ ٱللَّهِ'), 'بسم الله');
      expect(ArabicText.normalize('أَسْتَغْفِرُ'), 'استغفر');
    });

    test('strips uthmani bismillah prefix (with BOM)', () {
      const text = '\uFEFFبِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ الٓمٓ';
      expect(ArabicText.stripBismillah(text), 'الٓمٓ');
    });

    test('keeps text without bismillah', () {
      const text = 'ذَٰلِكَ ٱلْكِتَٰبُ لَا رَيْبَ ۛ فِيهِ';
      expect(ArabicText.stripBismillah(text), text);
    });

    test('surahs 1 and 9 are not stripped', () {
      expect(ArabicText.surahHasBismillahPrefix(1), isFalse);
      expect(ArabicText.surahHasBismillahPrefix(9), isFalse);
      expect(ArabicText.surahHasBismillahPrefix(2), isTrue);
    });
  });

  group('QuranRepository', () {
    String body(List<Map<String, dynamic>> ayahs) => json.encode({
      'data': {'ayahs': ayahs},
    });

    test('combines editions and strips bismillah', () async {
      final client = MockClient((req) async {
        final path = req.url.path;
        if (path.endsWith('quran-uthmani')) {
          return http.Response.bytes(
            utf8.encode(
              body([
                _ayah(1, 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ الٓمٓ'),
                _ayah(2, 'ذَٰلِكَ'),
              ]),
            ),
            200,
          );
        }
        if (path.endsWith('en.sahih')) {
          return http.Response(
            body([_ayah(1, 'Alif. Lam. Mim.'), _ayah(2, 'This')]),
            200,
          );
        }
        return http.Response(
          body([_ayah(1, '', audio: 'a1.mp3'), _ayah(2, '', audio: 'a2.mp3')]),
          200,
        );
      });
      final repo = QuranRepository(client: client);
      final ayahs = await repo.getSurahWithTranslation(2);
      expect(ayahs.length, 2);
      expect(ayahs.first.text, 'الٓمٓ');
      expect(ayahs.first.translation, 'Alif. Lam. Mim.');
      expect(ayahs[1].audio, 'a2.mp3');
    });

    test(
      'mismatched lengths throw QuranLoadException, not RangeError',
      () async {
        final client = MockClient((req) async {
          if (req.url.path.endsWith('en.sahih')) {
            return http.Response(body([_ayah(1, 'x')]), 200);
          }
          return http.Response(body([_ayah(1, 'x'), _ayah(2, 'y')]), 200);
        });
        final repo = QuranRepository(client: client);
        expect(
          repo.getSurahWithTranslation(2),
          throwsA(isA<QuranLoadException>()),
        );
      },
    );

    test('non-200 throws QuranLoadException', () async {
      final repo = QuranRepository(
        client: MockClient((_) async => http.Response('oops', 500)),
      );
      expect(repo.getSurahs(), throwsA(isA<QuranLoadException>()));
    });
  });
}
