import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';

import 'audio_cache.dart';

/// Snapshot of what the app is currently playing.
///
/// UI should derive play/pause icons from this (via [AudioService.statusStream]
/// or [AudioService.status]) instead of comparing `currentMediaId` alone,
/// so icons stay correct for both recorded audio and text-to-speech and reset
/// when playback finishes.
@immutable
class AudioStatus {
  final String? mediaId;
  final String? title;
  final String? artist;

  /// True while sound is actually being produced.
  final bool isPlaying;

  /// True when playback of [mediaId] is paused and can be resumed.
  final bool isPaused;

  /// True when the current media is text-to-speech (no seek bar).
  final bool isTts;

  const AudioStatus({
    this.mediaId,
    this.title,
    this.artist,
    this.isPlaying = false,
    this.isPaused = false,
    this.isTts = false,
  });

  static const idle = AudioStatus();

  bool get isActive => mediaId != null && (isPlaying || isPaused);

  /// Whether [id] is the item currently producing sound.
  bool isPlayingMedia(String? id) => id != null && mediaId == id && isPlaying;

  @override
  bool operator ==(Object other) =>
      other is AudioStatus &&
      other.mediaId == mediaId &&
      other.title == title &&
      other.artist == artist &&
      other.isPlaying == isPlaying &&
      other.isPaused == isPaused &&
      other.isTts == isTts;

  @override
  int get hashCode =>
      Object.hash(mediaId, title, artist, isPlaying, isPaused, isTts);
}

class AudioService {
  final AudioPlayer _player = AudioPlayer();

  /// Saves recitations while they stream so they replay offline.
  final AudioCache? _cache;
  final FlutterTts _tts = FlutterTts();

  final StreamController<AudioStatus> _statusController =
      StreamController<AudioStatus>.broadcast();
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();

  AudioStatus _status = AudioStatus.idle;

  /// Remaining TTS segments (e.g. Arabic then translation) and the one
  /// currently being spoken, so TTS can be paused and resumed.
  final List<_TtsSegment> _ttsQueue = [];
  _TtsSegment? _currentSegment;

  /// Increments on every new playback request so stale async callbacks
  /// (e.g. a TTS completion from a previous item) are ignored.
  int _session = 0;

  AudioService({AudioCache? cache, bool saveForOffline = true})
    : _cache = saveForOffline && AudioCache.supported
          ? (cache ?? AudioCache())
          : null {
    unawaited(_cache?.trim());
    _configureSession();
    _initTts();
    _player.playerStateStream.listen(_onPlayerState);
    // just_audio 0.10 reports mid-playback failures (e.g. network lost)
    // only here; without this the bar stalls silently.
    _player.errorStream.listen((e) {
      debugPrint('Audio playback error: ${e.code} ${e.message}');
      _errorController.add('audio_error_play');
      stop();
    });
  }

  /// Declares the app as a long-form audio player (Quran recitation): plays
  /// with the silent switch on and, with `UIBackgroundModes: audio` in
  /// Info.plist, continues when the screen locks. Pauses when headphones
  /// are unplugged.
  Future<void> _configureSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
      session.becomingNoisyEventStream.listen((_) {
        pause();
      });
    } catch (e) {
      debugPrint('Audio session configuration failed: $e');
    }
  }

  Future<void> _initTts() async {
    try {
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      await _tts.awaitSpeakCompletion(false);
    } catch (e) {
      debugPrint('TTS init failed: $e');
    }
    _tts.setCompletionHandler(_onTtsSegmentDone);
    _tts.setCancelHandler(() {});
    _tts.setErrorHandler((msg) {
      _errorController.add('audio_error_speech');
      _setStatus(AudioStatus.idle);
    });
  }

  // ---------------------------------------------------------------------------
  // Public state
  // ---------------------------------------------------------------------------

  AudioPlayer get player => _player;

  AudioStatus get status => _status;

  /// Emits the current status immediately, then every change.
  Stream<AudioStatus> get statusStream async* {
    yield _status;
    yield* _statusController.stream;
  }

  /// Error l10n keys ('audio_error_play', 'audio_error_speech'); translate
  /// with `l10n.translate(key)` before showing.
  Stream<String> get errorStream => _errorController.stream;

  String? get currentMediaId => _status.mediaId;
  String? get currentTitle => _status.title;
  String? get currentArtist => _status.artist;

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<Duration> get positionStream => _player.positionStream;

  /// Playback speed for recorded audio (recitation and translation). The
  /// pitch is kept, so the reciter's voice sounds natural. Text-to-speech
  /// has its own rate and is not affected.
  double get speed => _player.speed;

  Future<void> setSpeed(double speed) async {
    try {
      await _player.setSpeed(speed);
    } catch (e) {
      debugPrint('Setting playback speed failed: $e');
    }
  }

  /// Index of the playlist item playing (see [playList]), or null.
  Stream<int?> get currentIndexStream => _player.currentIndexStream;
  int? get currentIndex => _player.currentIndex;

  /// Kept for backwards compatibility: emits whether *anything* is playing.
  Stream<bool> get isPlayingStream =>
      statusStream.map((s) => s.isPlaying).distinct();

  bool isCurrentlyPlaying(String? mediaId) => _status.isPlayingMedia(mediaId);

  // ---------------------------------------------------------------------------
  // Recorded audio
  // ---------------------------------------------------------------------------

  /// Plays a single URL. Tapping the same [mediaId] again toggles pause/resume.
  Future<void> playUrl(
    String url, {
    String? title,
    String? artist,
    String? mediaId,
  }) {
    return _playSources(
      [url],
      title: title ?? 'Quran Recitation',
      artist: artist ?? 'Mishary Rashid Alafasy',
      mediaId: mediaId ?? url,
    );
  }

  /// Plays a list of URLs back to back. Same toggle behaviour as [playUrl].
  Future<void> playList(
    List<String> urls, {
    String? title,
    String? artist,
    String? mediaId,
  }) {
    return _playSources(
      urls,
      title: title ?? 'Surah Recitation',
      artist: artist ?? 'Mishary Rashid Alafasy',
      mediaId: mediaId ?? urls.join('|'),
    );
  }

  Future<void> _playSources(
    List<String> urls, {
    required String title,
    required String artist,
    required String mediaId,
  }) async {
    if (urls.isEmpty) return;

    // Toggle behaviour for the same item.
    if (_status.mediaId == mediaId && !_status.isTts) {
      if (_status.isPlaying) {
        await pause();
        return;
      }
      if (_status.isPaused) {
        await resume();
        return;
      }
    }

    final session = ++_session;
    await _stopTts();
    _setStatus(
      AudioStatus(
        mediaId: mediaId,
        title: title,
        artist: artist,
        isPlaying: true,
      ),
    );

    try {
      final sources = await Future.wait(urls.map(_sourceFor));
      if (session != _session) return;
      if (sources.length == 1) {
        await _player.setAudioSource(sources.first);
      } else {
        await _player.setAudioSources(sources);
      }
      if (session != _session) return;
      // play() completes when playback stops; don't await it.
      unawaited(_player.play());
    } catch (e) {
      debugPrint('Error playing audio: $e');
      if (session != _session) return;
      _errorController.add('audio_error_play');
      await _player.stop();
      _setStatus(AudioStatus.idle);
    }
  }

  /// Plays a saved copy when there is one (works offline); otherwise streams
  /// and saves the file at the same time, so it's offline next time.
  Future<AudioSource> _sourceFor(String url) async {
    final uri = Uri.parse(url);
    final cache = _cache;
    if (cache == null || !(uri.isScheme('https') || uri.isScheme('http'))) {
      return AudioSource.uri(uri);
    }
    try {
      final file = await cache.fileFor(url);
      if (await file.exists()) return AudioSource.file(file.path);
      // Experimental in just_audio, but stable in practice; the version is
      // pinned in pubspec.lock and covered by the playback tests.
      // ignore: experimental_member_use
      return LockCachingAudioSource(uri, cacheFile: file);
    } catch (e) {
      debugPrint('Audio cache unavailable: $e');
      return AudioSource.uri(uri);
    }
  }

  void _onPlayerState(PlayerState state) {
    if (_status.isTts || _status.mediaId == null) return;

    if (state.processingState == ProcessingState.completed) {
      // Finished: reset everything so icons go back to "play" and the
      // control bar hides.
      unawaited(stop());
      return;
    }

    final playing =
        state.playing && state.processingState != ProcessingState.idle;
    if (playing != _status.isPlaying) {
      _setStatus(
        AudioStatus(
          mediaId: _status.mediaId,
          title: _status.title,
          artist: _status.artist,
          isPlaying: playing,
          isPaused: !playing && state.processingState != ProcessingState.idle,
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Text to speech
  // ---------------------------------------------------------------------------

  /// Speaks [text]. [languageCode] is the language the *text* is written in
  /// (not the UI language). Tapping the same [mediaId] again stops it.
  Future<void> playTts(
    String text, {
    String? title,
    String? mediaId,
    String languageCode = 'en',
  }) {
    return _startTts(
      [_TtsSegment(text, _ttsLocale(languageCode))],
      title: title ?? 'Translation',
      mediaId: mediaId ?? text,
    );
  }

  /// Speaks the Arabic text, then the translation.
  ///
  /// [translationLang] is the language the *translation text* is written in.
  /// The app's dua/ayah translations are English, so this defaults to 'en'.
  Future<void> playArabicThenTranslation(
    String arabicText,
    String translationText, {
    String? title,
    String? mediaId,
    String translationLang = 'en',
  }) {
    return _startTts(
      [
        _TtsSegment(arabicText, 'ar-SA'),
        _TtsSegment(translationText, _ttsLocale(translationLang)),
      ],
      title: title ?? 'Dua Recitation',
      mediaId: mediaId ?? arabicText,
    );
  }

  Future<void> _startTts(
    List<_TtsSegment> segments, {
    required String title,
    required String mediaId,
  }) async {
    // Toggle: same item playing -> stop, paused -> resume.
    if (_status.mediaId == mediaId && _status.isTts) {
      if (_status.isPlaying) {
        await stop();
        return;
      }
      if (_status.isPaused) {
        await resume();
        return;
      }
    }

    ++_session;
    await _player.stop();
    await _stopTts();

    _ttsQueue
      ..clear()
      ..addAll(segments.where((s) => s.text.trim().isNotEmpty));
    _setStatus(
      AudioStatus(
        mediaId: mediaId,
        title: title,
        artist: 'AI Voice',
        isPlaying: true,
        isTts: true,
      ),
    );
    await _speakNext();
  }

  Future<void> _speakNext() async {
    if (_ttsQueue.isEmpty) {
      _currentSegment = null;
      _setStatus(AudioStatus.idle);
      return;
    }
    final session = _session;
    final segment = _ttsQueue.removeAt(0);
    _currentSegment = segment;
    try {
      // Without a voice for this language the phone would read the text
      // with another language's voice (e.g. Urdu read as English).
      final available = await _isVoiceAvailable(segment.locale);
      if (session != _session) return;
      if (!available) {
        _errorController.add('audio_error_voice_missing');
        _ttsQueue.clear();
        _currentSegment = null;
        _setStatus(AudioStatus.idle);
        return;
      }
      await _tts.setLanguage(segment.locale);
      if (session != _session) return;
      final result = await _tts.speak(segment.text);
      if (result == 0) {
        throw Exception('speak returned 0');
      }
    } catch (e) {
      debugPrint('TTS error: $e');
      if (session != _session) return;
      _errorController.add('audio_error_speech');
      _ttsQueue.clear();
      _currentSegment = null;
      _setStatus(AudioStatus.idle);
    }
  }

  void _onTtsSegmentDone() {
    if (!_status.isTts || !_status.isPlaying) return;
    unawaited(_speakNext());
  }

  Future<void> _stopTts() async {
    _ttsQueue.clear();
    _currentSegment = null;
    try {
      await _tts.stop();
    } catch (_) {}
  }

  Future<bool> _isVoiceAvailable(String locale) async {
    try {
      final r = await _tts.isLanguageAvailable(locale);
      return r != false && r != 0;
    } catch (_) {
      return true; // unknown: try speaking anyway
    }
  }

  String _ttsLocale(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return 'ar-SA';
      case 'ur':
        return 'ur-PK';
      case 'fa':
        return 'fa-IR';
      case 'tr':
        return 'tr-TR';
      default:
        return 'en-US';
    }
  }

  // ---------------------------------------------------------------------------
  // Transport controls
  // ---------------------------------------------------------------------------

  Future<void> pause() async {
    if (!_status.isPlaying) return;
    if (_status.isTts) {
      // TTS can't reliably pause mid-sentence on all platforms; stop and
      // remember the current segment so resume() repeats it.
      final current = _currentSegment;
      ++_session;
      try {
        await _tts.stop();
      } catch (_) {}
      if (current != null) _ttsQueue.insert(0, current);
      _currentSegment = null;
      _setStatus(
        AudioStatus(
          mediaId: _status.mediaId,
          title: _status.title,
          artist: _status.artist,
          isPaused: true,
          isTts: true,
        ),
      );
    } else {
      await _player.pause();
    }
  }

  Future<void> resume() async {
    if (!_status.isPaused) return;
    if (_status.isTts) {
      ++_session;
      _setStatus(
        AudioStatus(
          mediaId: _status.mediaId,
          title: _status.title,
          artist: _status.artist,
          isPlaying: true,
          isTts: true,
        ),
      );
      await _speakNext();
    } else {
      if (_player.processingState == ProcessingState.completed) {
        await _player.seek(Duration.zero, index: 0);
      }
      unawaited(_player.play());
    }
  }

  Future<void> stop() async {
    ++_session;
    _setStatus(AudioStatus.idle);
    await _stopTts();
    try {
      await _player.stop();
    } catch (_) {}
  }

  Future<void> seek(Duration position) async {
    if (_status.isTts) return;
    await _player.seek(position);
  }

  void _setStatus(AudioStatus status) {
    if (status == _status) return;
    _status = status;
    _statusController.add(status);
  }

  void dispose() {
    _player.dispose();
    _tts.stop();
    _statusController.close();
    _errorController.close();
  }
}

class _TtsSegment {
  final String text;
  final String locale;
  const _TtsSegment(this.text, this.locale);
}
