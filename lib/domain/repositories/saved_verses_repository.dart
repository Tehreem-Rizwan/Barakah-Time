import '../entities/saved_verse.dart';

abstract class SavedVersesRepository {
  Future<List<SavedVerse>> getSavedVerses();
  Future<void> saveVerse(SavedVerse verse);
  Future<void> deleteVerse(String id);
  Future<bool> isVerseSaved(String id);
}
