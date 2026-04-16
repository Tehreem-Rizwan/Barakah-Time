import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<String> uploadImage(String filePath) async {
    final file = File(filePath);
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final path = 'images/$fileName';

    try {
      await _client.storage.from('images').upload(path, file);
      
      final String publicUrl = _client.storage.from('images').getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload image to Supabase: $e');
    }
  }

  Future<void> deleteImage(String path) async {
    try {
      await _client.storage.from('images').remove([path]);
    } catch (e) {
      throw Exception('Failed to delete image from Supabase: $e');
    }
  }
}
