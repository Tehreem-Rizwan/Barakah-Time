import 'dart:convert';
import 'package:barakah_time/domain/entities/ayah.dart';
import 'package:barakah_time/domain/entities/surah.dart';
import 'package:http/http.dart' as http;

class QuranRepository {
  final String baseUrl = 'https://api.alquran.cloud/v1';

  Future<List<Surah>> getSurahs() async {
    final response = await http.get(Uri.parse('$baseUrl/surah'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> surahsJson = data['data'];
      return surahsJson.map((json) => Surah.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load surahs');
    }
  }

  Future<List<Ayah>> getSurahWithTranslation(int number) async {
    final arResponse = await http.get(
      Uri.parse('$baseUrl/surah/$number/quran-uthmani'),
    );
    final enResponse = await http.get(
      Uri.parse('$baseUrl/surah/$number/en.asad'),
    );

    if (arResponse.statusCode == 200 && enResponse.statusCode == 200) {
      final arAyahs = json.decode(arResponse.body)['data']['ayahs'] as List;
      final enAyahs = json.decode(enResponse.body)['data']['ayahs'] as List;

      return List.generate(arAyahs.length, (i) {
        final ayah = Ayah.fromJson(arAyahs[i]);
        return ayah.copyWith(translation: enAyahs[i]['text']);
      });
    }
    throw Exception('Failed to load surah translation');
  }
}
