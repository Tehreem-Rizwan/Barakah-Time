import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Where recitations are saved while they stream, so anything listened to
/// once plays again without internet. No download button: saving happens
/// automatically, and the oldest files are removed past [maxBytes].
class AudioCache {
  AudioCache({Future<Directory> Function()? baseDir, this.maxBytes = 600 << 20})
    : _baseDir = baseDir ?? getApplicationSupportDirectory;

  final Future<Directory> Function() _baseDir;

  /// Upper bound for saved audio (default 600 MB).
  final int maxBytes;

  Future<Directory>? _dir;

  /// Saving needs a file system (not available on web).
  static bool get supported => !kIsWeb;

  Future<Directory> directory() => _dir ??= _create();

  Future<Directory> _create() async {
    final dir = Directory('${(await _baseDir()).path}/quran_audio');
    await dir.create(recursive: true);
    return dir;
  }

  /// Stable file name for [url], e.g.
  /// `https://cdn.islamic.network/quran/audio/128/ar.alafasy/1.mp3`
  /// → `audio_128_ar.alafasy_1.mp3`.
  static String fileNameFor(String url) {
    final uri = Uri.parse(url);
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    final start = segments.indexOf('audio');
    final parts = start >= 0 ? segments.sublist(start) : segments;
    final name = parts.join('_').replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    return name.isEmpty ? 'audio_${url.hashCode.abs()}.mp3' : name;
  }

  Future<File> fileFor(String url) async =>
      File('${(await directory()).path}/${fileNameFor(url)}');

  /// Whether every URL is already saved on the phone.
  Future<bool> allSaved(List<String> urls) async {
    if (!supported) return false;
    try {
      for (final url in urls) {
        if (!await (await fileFor(url)).exists()) return false;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Deletes the least recently used files until the total is within
  /// [maxBytes]. Unfinished downloads (*.part etc.) older than a day are
  /// removed too. Never throws.
  Future<void> trim() async {
    if (!supported) return;
    try {
      await trimDirectory(await directory(), maxBytes);
    } catch (e) {
      debugPrint('Audio cache trim failed: $e');
    }
  }

  /// Pure trimming logic (public for tests).
  @visibleForTesting
  static Future<void> trimDirectory(Directory dir, int maxBytes) async {
    if (!await dir.exists()) return;
    final files = <File, FileStat>{};
    final others = <File, FileStat>{};
    final staleBefore = DateTime.now().subtract(const Duration(days: 1));
    await for (final entity in dir.list()) {
      if (entity is! File) continue;
      final stat = await entity.stat();
      (entity.path.endsWith('.mp3') ? files : others)[entity] = stat;
    }
    // Side files just_audio writes next to a recitation: `<name>.part` while
    // downloading and `<name>.mime`. Remove them once their recitation is
    // gone, and drop downloads interrupted more than a day ago.
    final saved = files.keys.map((f) => f.path).toSet();
    for (final entry in others.entries) {
      final path = entry.key.path;
      final owner = path.substring(0, path.lastIndexOf('.'));
      final orphan = path.endsWith('.mime') && !saved.contains(owner);
      final stalePart =
          path.endsWith('.part') && entry.value.modified.isBefore(staleBefore);
      if (orphan || stalePart) await entry.key.delete();
    }
    var total = files.values.fold<int>(0, (sum, s) => sum + s.size);
    if (total <= maxBytes) return;
    final oldestFirst =
        files.entries.toList()..sort(
          (a, b) => _lastUse(a.value).compareTo(_lastUse(b.value)),
        );
    for (final entry in oldestFirst) {
      if (total <= maxBytes) break;
      total -= entry.value.size;
      await entry.key.delete();
      final mime = File('${entry.key.path}.mime');
      if (await mime.exists()) await mime.delete();
    }
  }

  static DateTime _lastUse(FileStat s) =>
      s.accessed.isAfter(s.modified) ? s.accessed : s.modified;
}
