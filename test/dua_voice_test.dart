import 'package:barakah_time/core/constants/daily_ayats.dart';
import 'package:barakah_time/core/services/audio_service.dart';
import 'package:barakah_time/data/repositories/quran_repository.dart';
import 'package:barakah_time/presentation/pages/duas_page.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, String> _v(
  String name,
  String locale, {
  String quality = 'normal',
  bool network = false,
  String features = '',
}) => {
  'name': name,
  'locale': locale,
  'quality': quality,
  'network_required': network ? '1' : '0',
  'features': features,
};

void main() {
  group('pickBestVoice', () {
    test('prefers the most natural installed voice for the language', () {
      final best = AudioService.pickBestVoice([
        _v('en-us-x-iol-local', 'en-US', quality: 'very high'),
        _v('ar-xa-x-ard-local', 'ar-XA', quality: 'normal'),
        _v('ar-xa-x-arc-local', 'ar-XA', quality: 'very high'),
      ], 'ar-SA');
      expect(best, {'name': 'ar-xa-x-arc-local', 'locale': 'ar-XA'});
    });

    test('an installed voice beats a slightly better network-only one', () {
      final best = AudioService.pickBestVoice([
        _v('ar-net', 'ar-XA', quality: 'very high', network: true),
        _v('ar-local', 'ar-XA', quality: 'high'),
      ], 'ar-SA');
      expect(best!['name'], 'ar-local');
    });

    test('uses a network voice when it is the only one', () {
      final best = AudioService.pickBestVoice([
        _v('ar-net', 'ar-XA', quality: 'high', network: true),
      ], 'ar-SA');
      expect(best!['name'], 'ar-net');
    });

    test('skips voices that are not downloaded', () {
      final best = AudioService.pickBestVoice([
        _v('ar-new', 'ar-XA', quality: 'very high', features: 'notInstalled'),
        _v('ar-old', 'ar-XA'),
      ], 'ar-SA');
      expect(best!['name'], 'ar-old');
    });

    test('iOS qualities and underscores; null when nothing matches', () {
      final best = AudioService.pickBestVoice([
        {'name': 'Maged', 'locale': 'ar_SA', 'quality': 'default'},
        {'name': 'Laila', 'locale': 'ar_SA', 'quality': 'enhanced'},
      ], 'ar-SA');
      expect(best!['name'], 'Laila');
      expect(AudioService.pickBestVoice([_v('x', 'en-US')], 'ur-PK'), isNull);
      expect(AudioService.pickBestVoice(const ['junk', 1], 'ar-SA'), isNull);
    });
  });

  test('Ayat al-Kursi plays the real recitation (2:255 = ayah 262)', () {
    final kursi = kDuas.firstWhere((d) => d['key'] == 'dua_ayatul_kursi');
    expect(kursi['ayah'], '262');
    expect(
      QuranRepository.arabicAudioUrl(262),
      'https://cdn.islamic.network/quran/audio/128/ar.alafasy/262.mp3',
    );
    expect(QuranRepository.translationAudioUrl('ur', 262), isNotNull);
    // Other duas are not full ayahs: they stay on text-to-speech.
    expect(kDuas.where((d) => d['ayah'] != null).length, 1);
  });

  test('every daily ayat plays the ayah its reference names', () {
    // Ayahs per surah (standard Hafs count, 6236 in total).
    const counts = [
      7, 286, 200, 176, 120, 165, 206, 75, 129, 109, 123, 111, 43, 52, 99, //
      128, 111, 110, 98, 135, 112, 78, 118, 64, 77, 227, 93, 88, 69, 60, 34,
      30, 73, 54, 45, 83, 182, 88, 75, 85, 54, 53, 89, 59, 37, 35, 38, 29, 18,
      45, 60, 49, 62, 55, 78, 96, 29, 22, 24, 13, 14, 11, 11, 18, 12, 12, 30,
      52, 52, 44, 28, 28, 20, 56, 40, 31, 50, 40, 46, 42, 29, 19, 36, 25, 22,
      17, 19, 26, 30, 20, 15, 21, 11, 8, 8, 19, 5, 8, 8, 11, 11, 8, 3, 9, 5,
      4, 7, 3, 6, 3, 5, 4, 5, 6,
    ];
    expect(counts.length, 114);
    expect(counts.reduce((a, b) => a + b), 6236);
    int global(int surah, int ayah) =>
        counts.take(surah - 1).fold(0, (a, b) => a + b) + ayah;
    expect(global(2, 255), 262); // Ayat al-Kursi

    for (final d in dailyAyats) {
      final m = RegExp(r'\[(\d+):(\d+)\]').firstMatch(d.surah)!;
      final expected = global(int.parse(m[1]!), int.parse(m[2]!));
      expect(d.ayah, expected, reason: d.surah);
    }
  });
}
