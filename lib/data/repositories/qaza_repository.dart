import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/services/user_data_sync_service.dart';
import '../../domain/entities/qaza_state.dart';
import '../datasources/local/local_store.dart';

/// Stores the qaza tracker in SharedPreferences (instant, offline) and syncs
/// it to Firestore (`users/{uid}/state/qaza`), debounced so quick taps make
/// a single write.
class QazaRepository {
  final SharedPreferences prefs;
  final UserDataSync? sync;
  final Duration debounce;

  Timer? _timer;
  QazaState? _pending;

  QazaRepository(
    this.prefs, {
    this.sync,
    this.debounce = const Duration(seconds: 2),
  });

  QazaState load() {
    final raw = prefs.getString(UserPrefsKeys.qaza);
    if (raw == null) return QazaState.empty;
    try {
      final json = jsonDecode(raw);
      return QazaState.fromJson(json is Map<String, dynamic> ? json : null);
    } catch (_) {
      return QazaState.empty;
    }
  }

  Future<void> save(QazaState state) async {
    await prefs.setString(UserPrefsKeys.qaza, jsonEncode(state.toJson()));
    await prefs.setInt(
      UserPrefsKeys.qazaUpdatedAt,
      DateTime.now().millisecondsSinceEpoch,
    );
    if (sync == null) return;
    _pending = state;
    _timer?.cancel();
    _timer = Timer(debounce, flush);
  }

  /// Sends a pending cloud write now (e.g. when leaving the page).
  void flush() {
    _timer?.cancel();
    _timer = null;
    final p = _pending;
    _pending = null;
    if (p != null) sync?.pushQaza(p.toJson());
  }
}
