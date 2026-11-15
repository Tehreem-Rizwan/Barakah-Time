import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_init_status.dart';

/// Profile pictures are stored in the `images` bucket under
/// `profile_pics/<uid>/<timestamp>.<ext>`.
///
/// Requests are authorised with the user's Firebase ID token (Supabase
/// third-party auth, see `supabase/README.md`); Storage RLS policies in
/// `supabase/storage_policies.sql` only allow writes inside the user's own
/// `profile_pics/<uid>/` folder.
class SupabaseService {
  static const String _bucket = 'images';
  static const String _profileFolder = 'profile_pics';

  /// Resolved lazily: `Supabase.instance` throws if initialisation failed.
  SupabaseClient get _client {
    if (!AppInitStatus.supabaseReady) {
      throw StateError('Supabase is not initialised');
    }
    return Supabase.instance.client;
  }

  bool get isAvailable => AppInitStatus.supabaseReady;

  /// Uploads [filePath] as the profile picture for [uid] and returns its
  /// public URL.
  Future<String> uploadProfileImage({
    required String uid,
    required String filePath,
  }) async {
    final file = File(filePath);
    final ext = _extensionOf(filePath);
    final path =
        '$_profileFolder/$uid/${DateTime.now().millisecondsSinceEpoch}.$ext';

    try {
      await _client.storage
          .from(_bucket)
          .upload(
            path,
            file,
            fileOptions: FileOptions(
              contentType: _contentTypeFor(ext),
              upsert: true,
            ),
          );
      return _client.storage.from(_bucket).getPublicUrl(path);
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Best-effort removal of a previous profile picture. Only deletes objects
  /// that live under this user's own folder in our bucket.
  Future<void> deletePreviousProfileImage({
    required String uid,
    required String? previousUrl,
  }) async {
    final path = storagePathFromPublicUrl(previousUrl);
    if (path == null || !path.startsWith('$_profileFolder/$uid/')) return;
    try {
      await _client.storage.from(_bucket).remove([path]);
    } catch (_) {
      // Ignore: stale files are harmless.
    }
  }

  /// Deletes every object in `profile_pics/<uid>/` (account deletion).
  /// Best-effort: failures are logged, not thrown.
  Future<void> deleteAllUserImages(String uid) async {
    if (!isAvailable || uid.isEmpty) return;
    final folder = '$_profileFolder/$uid';
    try {
      final storage = _client.storage.from(_bucket);
      // Bounded: if RLS silently refuses the delete we must not loop forever.
      for (var page = 0; page < 20; page++) {
        final files = await storage.list(
          path: folder,
          searchOptions: const SearchOptions(limit: 100),
        );
        final paths = [
          for (final f in files)
            if (f.name.isNotEmpty && f.id != null) '$folder/${f.name}',
        ];
        if (paths.isEmpty) break;
        await storage.remove(paths);
        if (files.length < 100) break;
      }
    } catch (e) {
      debugPrint('Deleting profile images failed: $e');
    }
  }

  /// Extracts the object path from a Supabase public URL of our bucket.
  static String? storagePathFromPublicUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    const marker = '/storage/v1/object/public/$_bucket/';
    final index = url.indexOf(marker);
    if (index < 0) return null;
    var path = url.substring(index + marker.length);
    final q = path.indexOf('?');
    if (q >= 0) path = path.substring(0, q);
    return Uri.decodeComponent(path);
  }

  static String _extensionOf(String filePath) {
    final name = filePath.split(Platform.pathSeparator).last.split('/').last;
    final dot = name.lastIndexOf('.');
    if (dot < 0 || dot == name.length - 1) return 'jpg';
    final ext = name.substring(dot + 1).toLowerCase();
    return ext == 'jpeg' ? 'jpg' : ext;
  }

  static String _contentTypeFor(String ext) {
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'heic':
        return 'image/heic';
      case 'heif':
        return 'image/heif';
      case 'jpg':
      default:
        return 'image/jpeg';
    }
  }
}
