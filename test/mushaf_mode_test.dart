import 'package:barakah_time/core/services/audio_service.dart';
import 'package:barakah_time/data/datasources/local/settings_prefs.dart';
import 'package:barakah_time/domain/entities/ayah.dart';
import 'package:barakah_time/presentation/blocs/settings_bloc.dart';
import 'package:barakah_time/presentation/pages/mushaf_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Ayah _ayah(int n, {required int page, int juz = 1}) => Ayah(
  number: n,
  text: 'آية $n',
  numberInSurah: n,
  juz: juz,
  manzil: 1,
  page: page,
  ruku: 1,
  hizbQuarter: 1,
);

void main() {
  group('ayah markers', () {
    test('Arabic-Indic digits', () {
      expect(arabicDigits(0), '٠');
      expect(arabicDigits(7), '٧');
      expect(arabicDigits(286), '٢٨٦');
    });

    test('marker encloses the number and sticks to the ayah', () {
      expect(ayahMarker(12), ' ﴿١٢﴾');
    });
  });

  group('groupAyahsByPage', () {
    test('splits at mushaf page changes', () {
      final ayahs = [
        _ayah(1, page: 2),
        _ayah(2, page: 2),
        _ayah(3, page: 3),
        _ayah(4, page: 3),
        _ayah(5, page: 3),
        _ayah(6, page: 4, juz: 2),
      ];
      final pages = groupAyahsByPage(ayahs);
      expect(pages.map((p) => p.page), [2, 3, 4]);
      expect(pages.map((p) => (p.start, p.end)), [(0, 2), (2, 5), (5, 6)]);
      expect(pages.last.juz, 2);
      expect(pages[1].contains(4), isTrue);
      expect(pages[1].contains(5), isFalse);
    });

    test('a short surah fits on one page; empty gives no pages', () {
      expect(groupAyahsByPage([_ayah(1, page: 604)]).single.page, 604);
      expect(groupAyahsByPage(const []), isEmpty);
    });
  });

  group('playingAyahIndex', () {
    const playing = AudioStatus(mediaId: 'surah_2', isPlaying: true);

    test('whole-surah playback maps the player index directly', () {
      expect(playingAyahIndex(playing, 4, 2), 4);
    });

    test('"play from here" adds the starting ayah', () {
      const from = AudioStatus(mediaId: 'surah_2_from_10', isPlaying: true);
      expect(playingAyahIndex(from, 3, 2), 13);
    });

    test('ignores other surahs, translation playback and idle', () {
      expect(playingAyahIndex(playing, 1, 3), isNull);
      const tr = AudioStatus(mediaId: 'surah_2_tr', isPlaying: true);
      expect(playingAyahIndex(tr, 1, 2), isNull);
      expect(playingAyahIndex(AudioStatus.idle, 1, 2), isNull);
      expect(playingAyahIndex(playing, null, 2), isNull);
    });

    test('a paused recitation stays highlighted', () {
      const paused = AudioStatus(mediaId: 'surah_2', isPaused: true);
      expect(playingAyahIndex(paused, 2, 2), 2);
    });
  });

  group('Quran reading mode setting', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('defaults to translation and persists mushaf', () async {
      final prefs = await SharedPreferences.getInstance();
      final bloc = SettingsBloc(prefs, countryCode: 'PK');
      addTearDown(bloc.close);
      expect(bloc.state.quranMode, 'translation');

      bloc.add(const UpdateQuranMode('mushaf'));
      await bloc.stream.firstWhere((s) => s.quranMode == 'mushaf');
      expect(prefs.getString(SettingsPrefs.quranMode), 'mushaf');

      final reloaded = SettingsBloc(prefs, countryCode: 'PK');
      addTearDown(reloaded.close);
      expect(reloaded.state.quranMode, 'mushaf');
    });

    test('rejects unknown modes', () async {
      final prefs = await SharedPreferences.getInstance();
      final bloc = SettingsBloc(prefs, countryCode: 'PK');
      addTearDown(bloc.close);
      bloc.add(const UpdateQuranMode('pages'));
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.quranMode, 'translation');
      expect(prefs.getString(SettingsPrefs.quranMode), isNull);
    });

    test('syncs through the cloud settings document', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(SettingsPrefs.quranMode, 'mushaf');
      expect(SettingsPrefs.toCloud(prefs)['quranMode'], 'mushaf');

      SharedPreferences.setMockInitialValues({});
      final other = await SharedPreferences.getInstance();
      await SettingsPrefs.applyCloud(other, {'quranMode': 'mushaf'});
      expect(other.getString(SettingsPrefs.quranMode), 'mushaf');
      await SettingsPrefs.applyCloud(other, {'quranMode': 'bogus'});
      expect(other.getString(SettingsPrefs.quranMode), 'mushaf');
    });
  });

  group('Quran font setting', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('defaults to Amiri, persists, rejects unknown, syncs', () async {
      final prefs = await SharedPreferences.getInstance();
      final bloc = SettingsBloc(prefs, countryCode: 'PK');
      addTearDown(bloc.close);
      expect(bloc.state.quranFont, 'amiri');

      bloc.add(const UpdateQuranFont('scheherazadeNew'));
      await bloc.stream.firstWhere((s) => s.quranFont == 'scheherazadeNew');
      expect(prefs.getString(SettingsPrefs.quranFont), 'scheherazadeNew');

      bloc.add(const UpdateQuranFont('comic'));
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.quranFont, 'scheherazadeNew');

      expect(SettingsPrefs.toCloud(prefs)['quranFont'], 'scheherazadeNew');
      SharedPreferences.setMockInitialValues({});
      final other = await SharedPreferences.getInstance();
      await SettingsPrefs.applyCloud(other, {'quranFont': 'amiriQuran'});
      expect(other.getString(SettingsPrefs.quranFont), 'amiriQuran');
    });
  });
}
