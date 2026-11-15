import 'package:hive/hive.dart';
import '../../core/services/user_data_sync_service.dart';
import '../../domain/entities/saved_verse.dart';
import '../../domain/repositories/saved_verses_repository.dart';
import '../datasources/local/local_store.dart';

/// Hive-backed; mirrors saves/un-saves to Firestore when signed in.
class SavedVersesRepositoryImpl implements SavedVersesRepository {
  static const String _boxName = LocalBoxes.savedVerses;

  final UserDataSync? sync;

  SavedVersesRepositoryImpl({this.sync});

  @override
  Future<List<SavedVerse>> getSavedVerses() async {
    final box = await Hive.openBox<SavedVerse>(_boxName);
    return box.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  @override
  Future<void> saveVerse(SavedVerse verse) async {
    final box = await Hive.openBox<SavedVerse>(_boxName);
    await box.put(verse.id, verse);
    sync?.pushSavedVerse(verse);
  }

  @override
  Future<void> deleteVerse(String id) async {
    final box = await Hive.openBox<SavedVerse>(_boxName);
    await box.delete(id);
    sync?.deleteSavedVerse(id);
  }

  @override
  Future<bool> isVerseSaved(String id) async {
    final box = await Hive.openBox<SavedVerse>(_boxName);
    return box.containsKey(id);
  }
}
