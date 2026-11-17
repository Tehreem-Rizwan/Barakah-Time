import 'package:barakah_time/data/repositories/quran_repository.dart';
import 'package:barakah_time/presentation/blocs/quran_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('human-voice translation audio per language', () {
    expect(
      QuranRepository.translationAudioUrl('ur', 2),
      'https://cdn.islamic.network/quran/audio/64/ur.khan/2.mp3',
    );
    expect(QuranRepository.translationAudioUrl('en', 262), contains('en.walk/262.mp3'));
    expect(QuranRepository.translationAudioUrl('ar', 2), isNull); // TTS
    expect(QuranRepository.translationAudioUrl('ur', 0), isNull);
  });

  test('chosen translation language overrides the app language', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final bloc = QuranBloc(QuranRepository(), prefs: prefs);

    bloc.add(ChangeQuranLanguage('en'));
    await Future<void>.delayed(Duration.zero);
    expect(bloc.translationLanguage, 'en');

    bloc.add(SetTranslationLanguage('ur'));
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(bloc.translationEdition, QuranRepository.translationEditionFor('ur'));

    // App language changes don't override the user's choice.
    bloc.add(ChangeQuranLanguage('tr'));
    await Future<void>.delayed(Duration.zero);
    expect(bloc.translationLanguage, 'ur');

    // "Same as app" follows the app again.
    bloc.add(SetTranslationLanguage(null));
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(bloc.translationLanguage, 'tr');
    await bloc.close();
  });
}
