import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/services/user_data_sync_service.dart';
import '../datasources/local/local_store.dart';

/// Tasbeeh counter state. [loggedCount] is the part of [count] already
/// logged to Spiritual Pulse.
class TasbeehCounter {
  final int count;
  final int loggedCount;
  const TasbeehCounter(this.count, this.loggedCount);

  static const zero = TasbeehCounter(0, 0);

  @override
  bool operator ==(Object other) =>
      other is TasbeehCounter &&
      other.count == count &&
      other.loggedCount == loggedCount;

  @override
  int get hashCode => Object.hash(count, loggedCount);
}

/// Persists the tasbeeh counter in SharedPreferences (instant, offline) and
/// syncs it to Firestore (`users/{uid}/state/tasbeeh`), debounced so rapid
/// taps produce a single write.
class TasbeehRepository {
  final SharedPreferences prefs;
  final UserDataSync? sync;
  final Duration debounce;

  Timer? _timer;
  TasbeehCounter? _pending;

  TasbeehRepository(
    this.prefs, {
    this.sync,
    this.debounce = const Duration(seconds: 2),
  });

  TasbeehCounter load() {
    final count = prefs.getInt(UserPrefsKeys.tasbeehCount) ?? 0;
    final logged = (prefs.getInt(UserPrefsKeys.tasbeehLoggedCount) ?? 0).clamp(
      0,
      count < 0 ? 0 : count,
    );
    return TasbeehCounter(count < 0 ? 0 : count, logged);
  }

  Future<void> save(int count, int loggedCount) async {
    final c = count < 0 ? 0 : count;
    final l = loggedCount.clamp(0, c);
    await prefs.setInt(UserPrefsKeys.tasbeehCount, c);
    await prefs.setInt(UserPrefsKeys.tasbeehLoggedCount, l);
    if (sync == null) return;
    _pending = TasbeehCounter(c, l);
    _timer?.cancel();
    _timer = Timer(debounce, flush);
  }

  /// Sends a pending cloud write now (e.g. when leaving the page).
  void flush() {
    _timer?.cancel();
    _timer = null;
    final p = _pending;
    _pending = null;
    if (p != null) sync?.pushTasbeeh(p.count, p.loggedCount);
  }
}
