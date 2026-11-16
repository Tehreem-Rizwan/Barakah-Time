import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants/app_config.dart';

/// Profile pictures live in the Supabase `images` bucket under
/// `profile_pics/<firebase uid>/`.
///
/// The app never writes to storage directly. It sends the photo to the free
/// `profile-photo` Supabase Edge Function together with the user's Firebase
/// ID token; the function verifies the token and stores the file with the
/// server-only service-role key. So users can only change their own photo,
/// and no paid Firebase plan is needed. See supabase/README.md.
class SupabaseService {
  SupabaseService({
    required Future<String?> Function() idTokenProvider,
    http.Client? client,
    String functionUrl = AppConfig.profilePhotoFunctionUrl,
    String anonKey = AppConfig.supabaseAnonKey,
  }) : _idTokenProvider = idTokenProvider,
       _client = client ?? http.Client(),
       _functionUrl = Uri.parse(functionUrl),
       _anonKey = anonKey;

  final Future<String?> Function() _idTokenProvider;
  final http.Client _client;
  final Uri _functionUrl;
  final String _anonKey;

  static const Duration _timeout = Duration(seconds: 30);
  static const int maxBytes = 5 * 1024 * 1024;

  bool get isAvailable => true;

  Future<Map<String, String>> _headers({String? contentType}) async {
    final token = await _idTokenProvider();
    if (token == null || token.isEmpty) {
      throw Exception('Not signed in');
    }
    return {
      'Authorization': 'Bearer $token',
      'apikey': _anonKey,
      if (contentType != null) 'Content-Type': contentType,
    };
  }

  /// Uploads [filePath] as the profile picture for the signed-in user and
  /// returns its public URL. The function deletes the user's older photos.
  Future<String> uploadProfileImage({
    required String uid,
    required String filePath,
  }) async {
    final bytes = await File(filePath).readAsBytes();
    if (bytes.length > maxBytes) {
      throw Exception('Image is larger than 5 MB');
    }
    final response = await _client
        .post(
          _functionUrl,
          headers: await _headers(
            contentType: contentTypeFor(extensionOf(filePath)),
          ),
          body: bytes,
        )
        .timeout(_timeout);
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to upload image (${response.statusCode}): ${response.body}',
      );
    }
    final url = (jsonDecode(response.body) as Map<String, dynamic>)['url'];
    if (url is! String || url.isEmpty) {
      throw Exception('Failed to upload image: no URL returned');
    }
    return url;
  }

  /// Older photos are removed by the Edge Function on every upload, so
  /// nothing is left to do here. Kept so callers don't need to change.
  Future<void> deletePreviousProfileImage({
    required String uid,
    required String? previousUrl,
  }) async {}

  /// Deletes all of the user's photos (account deletion). Best-effort.
  Future<void> deleteAllUserImages(String uid) async {
    if (uid.isEmpty) return;
    try {
      final response = await _client
          .delete(_functionUrl, headers: await _headers())
          .timeout(_timeout);
      if (response.statusCode != 200) {
        debugPrint(
          'Deleting profile images failed (${response.statusCode}): '
          '${response.body}',
        );
      }
    } catch (e) {
      debugPrint('Deleting profile images failed: $e');
    }
  }

  static String extensionOf(String filePath) {
    final name = filePath.split(Platform.pathSeparator).last.split('/').last;
    final dot = name.lastIndexOf('.');
    if (dot < 0 || dot == name.length - 1) return 'jpg';
    final ext = name.substring(dot + 1).toLowerCase();
    return ext == 'jpeg' ? 'jpg' : ext;
  }

  static String contentTypeFor(String ext) {
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
