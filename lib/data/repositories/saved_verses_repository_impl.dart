import 'package:hive/hive.dart';
import '../../domain/entities/saved_verse.dart';
import '../../domain/repositories/saved_verses_repository.dart';

class SavedVersesRepositoryImpl implements SavedVersesRepository {
  static const String _boxName = 'saved_verses';

  @override
  Future<List<SavedVerse>> getSavedVerses() async {
    final box = await Hive.openBox<SavedVerse>(_boxName);
    return box.values.toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  @override
  Future<void> saveVerse(SavedVerse verse) async {
    final box = await Hive.openBox<SavedVerse>(_boxName);
    await box.put(verse.id, verse);
  }

  @override
  Future<void> deleteVerse(String id) async {
    final box = await Hive.openBox<SavedVerse>(_boxName);
    await box.delete(id);
  }

  @override
  Future<bool> isVerseSaved(String id) async {
    final box = await Hive.openBox<SavedVerse>(_boxName);
    return box.containsKey(id);
  }
}
