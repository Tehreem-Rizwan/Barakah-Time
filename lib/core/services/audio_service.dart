import 'package:just_audio/just_audio.dart';
import 'package:flutter_tts/flutter_tts.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();
  final FlutterTts _tts = FlutterTts();
  
  String? currentTitle;
  String? currentArtist;
  String? currentMediaId;
  bool _isTtsActive = false;

  AudioService() {
    _initTts();
  }

  void _initTts() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  AudioPlayer get player => _player;

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<bool> get isPlayingStream => _player.playingStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<Duration> get positionStream => _player.positionStream;

  bool isCurrentlyPlaying(String? mediaId) {
    return currentMediaId == mediaId && _player.playing;
  }

  Future<void> playUrl(String url, {String? title, String? artist, String? mediaId}) async {
    if (isCurrentlyPlaying(mediaId)) {
      await _player.pause();
      return;
    }

    _isTtsActive = false;
    currentMediaId = mediaId;
    currentTitle = title ?? "Quran Recitation";
    currentArtist = artist ?? "Mishary Rashid Alafasy";
    await _tts.stop();
    try {
      await _player.setAudioSource(AudioSource.uri(Uri.parse(url)));
      await _player.play();
    } catch (e) {
      print("Error playing audio: $e");
    }
  }

  Future<void> playList(List<String> urls, {String? title, String? artist, String? mediaId}) async {
    if (isCurrentlyPlaying(mediaId)) {
      await _player.pause();
      return;
    }

    _isTtsActive = false;
    currentMediaId = mediaId;
    currentTitle = title ?? "Surah Recitation";
    currentArtist = artist ?? "Mishary Rashid Alafasy";
    await _tts.stop();
    try {
      final playlist = ConcatenatingAudioSource(
        children: urls.map((url) => AudioSource.uri(Uri.parse(url))).toList(),
      );
      await _player.setAudioSource(playlist);
      await _player.play();
    } catch (e) {
      print("Error playing playlist: $e");
    }
  }

  Future<void> playTts(String text, {String? title, String? mediaId, String languageCode = 'en'}) async {
    if (currentMediaId == mediaId && _isTtsActive) {
      await _tts.stop();
      _isTtsActive = false;
      return;
    }

    await _player.stop();
    _isTtsActive = true;
    currentMediaId = mediaId;
    currentTitle = title ?? "Translation";
    currentArtist = "AI Voice";
    
    await _tts.setLanguage(languageCode == 'ar' ? 'ar-SA' : 'en-US');
    await _tts.speak(text);
  }

  Future<void> playArabicThenTranslation(String arabicText, String translationText, {String? title, String? mediaId, String translationLang = 'en'}) async {
    await _player.stop();
    await _tts.stop();
    _isTtsActive = true;
    currentMediaId = mediaId;
    currentTitle = title ?? "Dua Recitation";
    currentArtist = "AI Voice";

    // Play Arabic
    await _tts.setLanguage('ar-SA');
    await _tts.speak(arabicText);
    
    // We need a way to wait for Arabic to finish before playing translation.
    // FlutterTts has a completion handler.
    _tts.setCompletionHandler(() async {
      if (_isTtsActive && currentMediaId == mediaId) {
        await _tts.setLanguage(translationLang == 'ar' ? 'ar-SA' : 'en-US');
        await _tts.speak(translationText);
        _tts.setCompletionHandler(null);
      }
    });
  }

  Future<void> pause() async {
    if (_isTtsActive) {
      await _tts.stop();
    } else {
      await _player.pause();
    }
  }

  Future<void> resume() async {
    if (!_isTtsActive) {
      await _player.play();
    }
  }

  Future<void> stop() async {
    await _player.stop();
    await _tts.stop();
    _isTtsActive = false;
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  void dispose() {
    _player.dispose();
  }
}
