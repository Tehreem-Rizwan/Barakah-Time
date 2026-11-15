import 'dart:async';
import 'dart:convert';
import 'package:barakah_time/core/services/app_init_status.dart';
import 'package:barakah_time/core/utils/arabic_text.dart';
import 'package:barakah_time/domain/entities/ayah.dart';
import 'package:barakah_time/domain/entities/surah.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

/// Thrown by [QuranRepository]. [message] is safe to log; the UI shows its
/// own localized text.
class QuranLoadException implements Exception {
  final String message;
  const QuranLoadException(this.message);
  @override
  String toString() => message;
}

/// Key/value store for raw API payloads (JSON strings).
abstract class QuranCache {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
}

/// Hive-backed cache (box `quran_cache`). Not user data: kept on sign-out.
/// Failures (e.g. Hive not initialised in tests) degrade to "no cache".
class HiveQuranCache implements QuranCache {
  static const boxName = 'quran_cache';

  Future<Box<String>?> _box() async {
    if (!AppInitStatus.hiveReady) return null;
    try {
      return await Hive.openBox<String>(boxName);
    } catch (e) {
      debugPrint('Quran cache unavailable: $e');
      return null;
    }
  }

  @override
  Future<String?> read(String key) async {
    try {
      return (await _box())?.get(key);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> write(String key, String value) async {
    try {
      await (await _box())?.put(key, value);
    } catch (_) {}
  }
}

class QuranRepository {
  final String baseUrl = 'https://api.alquran.cloud/v1';
  static const Duration requestTimeout = Duration(seconds: 20);

  static const String arabicEdition = 'quran-uthmani';
  static const String audioEdition = 'ar.alafasy';
  static const String defaultTranslationEdition = 'en.asad';

  /// alquran.cloud translation edition for an app language.
  /// ar uses the Tafsir al-Muyassar (simplified Arabic explanation).
  static String translationEditionFor(String languageCode) {
    switch (languageCode) {
      case 'ur':
        return 'ur.jalandhry';
      case 'tr':
        return 'tr.diyanet';
      case 'fa':
        return 'fa.makarem';
      case 'ar':
        return 'ar.muyassar';
      case 'en':
      default:
        return defaultTranslationEdition;
    }
  }

  final http.Client _client;
  final QuranCache _cache;

  QuranRepository({http.Client? client, QuranCache? cache})
    : _client = client ?? http.Client(),
      _cache = cache ?? HiveQuranCache();

  Future<Map<String, dynamic>> _getJson(String path) async {
    final http.Response response;
    try {
      response = await _client
          .get(Uri.parse('$baseUrl$path'))
          .timeout(requestTimeout);
    } on TimeoutException {
      throw const QuranLoadException('Request timed out');
    } catch (e) {
      throw QuranLoadException('Network error: $e');
    }
    if (response.statusCode != 200) {
      throw QuranLoadException('Server returned ${response.statusCode}');
    }
    try {
      // Always decode as UTF-8 (the server may omit the charset).
      final decoded = json.decode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, dynamic> || decoded['data'] == null) {
        throw const FormatException('missing data');
      }
      return decoded;
    } catch (_) {
      throw const QuranLoadException('Invalid response from server');
    }
  }

  // ── Surah list ──────────────────────────────────────────────────────────────
  static const _surahListKey = 'surah_list';

  /// Cached list first (refreshed in the background); [forceRefresh] goes
  /// to the network and falls back to the cache on failure.
  Future<List<Surah>> getSurahs({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = await _cachedSurahs();
      if (cached != null) {
        unawaited(_fetchSurahs().then((_) {}, onError: (_) {}));
        return cached;
      }
    }
    try {
      return await _fetchSurahs();
    } on QuranLoadException {
      final cached = await _cachedSurahs();
      if (cached != null) return cached;
      rethrow;
    }
  }

  Future<List<Surah>> _fetchSurahs() async {
    final data = await _getJson('/surah');
    final List<Surah> surahs;
    try {
      final List<dynamic> surahsJson = data['data'];
      surahs = surahsJson.map((json) => Surah.fromJson(json)).toList();
    } catch (_) {
      throw const QuranLoadException('Invalid surah list');
    }
    await _cache.write(_surahListKey, json.encode(data['data']));
    return surahs;
  }

  Future<List<Surah>?> _cachedSurahs() async {
    final raw = await _cache.read(_surahListKey);
    if (raw == null) return null;
    try {
      final list = json.decode(raw) as List;
      final surahs =
          list.map((j) => Surah.fromJson(j as Map<String, dynamic>)).toList();
      return surahs.isEmpty ? null : surahs;
    } catch (_) {
      return null;
    }
  }

  // ── Surah detail ────────────────────────────────────────────────────────────
  static String _ayahsKey(int surah, String edition) =>
      'ayahs_${surah}_$edition';

  /// Arabic text + [translationEdition] (see [translationEditionFor]) +
  /// audio. Each edition is cached separately, so a surah opened once works
  /// offline. [forceRefresh] bypasses the cache.
  Future<List<Ayah>> getSurahWithTranslation(
    int number, {
    String translationEdition = defaultTranslationEdition,
    bool forceRefresh = false,
  }) async {
    final editions = [arabicEdition, translationEdition, audioEdition];
    final lists = await Future.wait(
      editions.map((e) => _editionAyahs(number, e, forceRefresh)),
    );
    final arAyahs = lists[0];
    final trAyahs = lists[1];
    final audioAyahs = lists[2];
    if (arAyahs.isEmpty ||
        arAyahs.length != trAyahs.length ||
        arAyahs.length != audioAyahs.length) {
      throw const QuranLoadException('Surah data is incomplete');
    }
    final combined = combineAyahs(number, arAyahs, trAyahs, audioAyahs);
    // Cache only consistent data.
    for (var i = 0; i < editions.length; i++) {
      await _cache.write(_ayahsKey(number, editions[i]), json.encode(lists[i]));
    }
    return combined;
  }

  Future<List> _editionAyahs(int surah, String edition, bool force) async {
    if (!force) {
      final cached = await _cachedAyahs(surah, edition);
      if (cached != null) return cached;
    }
    try {
      final response = await _getJson('/surah/$surah/$edition');
      try {
        return response['data']['ayahs'] as List;
      } catch (_) {
        throw const QuranLoadException('Invalid surah data');
      }
    } on QuranLoadException {
      if (force) {
        final cached = await _cachedAyahs(surah, edition);
        if (cached != null) return cached;
      }
      rethrow;
    }
  }

  Future<List?> _cachedAyahs(int surah, String edition) async {
    final raw = await _cache.read(_ayahsKey(surah, edition));
    if (raw == null) return null;
    try {
      final list = json.decode(raw) as List;
      return list.isEmpty ? null : list;
    } catch (_) {
      return null;
    }
  }

  /// Merges the three editions into one list. Public for testing.
  static List<Ayah> combineAyahs(
    int surahNumber,
    List arAyahs,
    List translationAyahs,
    List audioAyahs,
  ) {
    return List.generate(arAyahs.length, (i) {
      var ayah = Ayah.fromJson(arAyahs[i]);
      if (i == 0 && ArabicText.surahHasBismillahPrefix(surahNumber)) {
        ayah = ayah.copyWith(text: ArabicText.stripBismillah(ayah.text));
      }
      final audio = audioAyahs[i];
      return ayah.copyWith(
        translation: translationAyahs[i]['text'],
        audio: audio['audio'],
        audioSecondary:
            audio['audioSecondary'] != null
                ? List<String>.from(audio['audioSecondary'])
                : null,
      );
    });
  }
}
