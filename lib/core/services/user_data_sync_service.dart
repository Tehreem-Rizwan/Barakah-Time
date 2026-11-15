import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/local/local_store.dart';
import '../../data/datasources/local/settings_prefs.dart';
import '../../data/sync/sync_mappers.dart';
import '../../domain/entities/saved_verse.dart';
import '../../domain/entities/spiritual_activity.dart';
import 'app_init_status.dart';
import 'firebase_service.dart';

/// Cloud write operations used by repositories. All methods are
/// fire-and-forget: they return immediately, do nothing when nobody is
/// signed in, and log (never throw) errors. Firestore's offline persistence
/// queues writes made while offline.
abstract class UserDataSync {
  /// Uid of the signed-in user, or null (guest / signed out).
  String? get currentUid;

  void pushActivity(SpiritualActivity activity, {int? longestStreak});
  void pushSavedVerse(SavedVerse verse);

  /// [localId] is the local verse id (`<surah>:<ayah>`).
  void deleteSavedVerse(String localId);
  void pushBadges(Map<String, DateTime> badges);
  void pushSettings(Map<String, dynamic> settings);
  void pushTasbeeh(int count, int loggedCount);
}

/// Everything stored for a user in Firestore.
class CloudUserData {
  final Map<String, dynamic>? profile;
  final List<SpiritualActivity> activities;
  final List<SavedVerse> savedVerses;
  final Map<String, DateTime> badges;
  final Map<String, dynamic>? settings;
  final ({int count, int loggedCount})? tasbeeh;

  const CloudUserData({
    this.profile,
    this.activities = const [],
    this.savedVerses = const [],
    this.badges = const {},
    this.settings,
    this.tasbeeh,
  });

  int get totalPoints {
    final v = profile?['totalPoints'];
    return v is num ? v.toInt() : SyncMappers.totalPoints(activities);
  }
}

/// Firestore schema (all owner-only, see `firestore.rules`):
///
/// * `users/{uid}`: profile + `totalPoints` (increment), `longestStreak`,
///   `lastActiveDay` ('yyyyMMdd')
/// * `users/{uid}/activities/{activityId}`: type, subType, points,
///   timestamp, day, createdAt — immutable (the rules reject updates, so a
///   batch re-writing an existing activity fails as a whole and its
///   `totalPoints` increment is never applied twice)
/// * `users/{uid}/saved_verses/{surah_ayah}`
/// * `users/{uid}/badges/{badgeId}`: earnedAt
/// * `users/{uid}/settings/app`
/// * `users/{uid}/state/tasbeeh`: count, loggedCount, updatedAt
class UserDataSyncService implements UserDataSync {
  final SharedPreferences prefs;
  final FirebaseService firebaseService;

  UserDataSyncService(this.prefs, this.firebaseService);

  static const _subcollections = [
    'activities',
    'saved_verses',
    'badges',
    'settings',
    'state',
  ];

  final Map<String, Future<bool>> _syncInFlight = {};

  bool get _available => AppInitStatus.firebaseReady;

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _user(String uid) =>
      _db.collection('users').doc(uid);

  @override
  String? get currentUid =>
      _available ? firebaseService.currentUser?.uid : null;

  void _run(String label, Future<void> Function() body) {
    if (!_available) return;
    unawaited(
      Future.sync(body).catchError((Object e, StackTrace st) {
        debugPrint('UserDataSync.$label failed: $e');
      }),
    );
  }

  // ── Pushes ────────────────────────────────────────────────────────────────
  @override
  void pushActivity(SpiritualActivity activity, {int? longestStreak}) {
    final uid = currentUid;
    if (uid == null) return;
    _run('pushActivity', () async {
      final ref = _user(uid).collection('activities').doc(activity.id);
      try {
        // Cheap duplicate check (server, or cache when offline).
        final existing = await ref.get().timeout(const Duration(seconds: 8));
        if (existing.exists) return;
      } catch (_) {
        // Offline/unknown: the security rules still prevent double counting.
      }
      final batch = _db.batch();
      batch.set(ref, {
        ...SyncMappers.activityToCloud(activity),
        'createdAt': FieldValue.serverTimestamp(),
      });
      batch.set(_user(uid), {
        'totalPoints': FieldValue.increment(activity.points.clamp(0, 100)),
        'lastActiveDay': SyncMappers.dayKey(activity.timestamp),
        if (longestStreak != null) 'longestStreak': longestStreak,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      await batch.commit();
    });
  }

  @override
  void pushSavedVerse(SavedVerse verse) {
    final uid = currentUid;
    if (uid == null) return;
    _run('pushSavedVerse', () async {
      await _user(uid)
          .collection('saved_verses')
          .doc(SyncMappers.savedVerseDocId(verse.surahNumber, verse.ayahNumber))
          .set(SyncMappers.savedVerseToCloud(verse));
    });
  }

  @override
  void deleteSavedVerse(String localId) {
    final uid = currentUid;
    final docId = SyncMappers.savedVerseDocIdFromLocalId(localId);
    if (uid == null || docId == null) return;
    _run('deleteSavedVerse', () async {
      await _user(uid).collection('saved_verses').doc(docId).delete();
    });
  }

  @override
  void pushBadges(Map<String, DateTime> badges) {
    final uid = currentUid;
    if (uid == null || badges.isEmpty) return;
    _run('pushBadges', () async {
      final batch = _db.batch();
      badges.forEach((id, earnedAt) {
        batch.set(_user(uid).collection('badges').doc(id), {
          'earnedAt': earnedAt,
        });
      });
      await batch.commit();
    });
  }

  @override
  void pushSettings(Map<String, dynamic> settings) {
    final uid = currentUid;
    if (uid == null || settings.isEmpty) return;
    _run('pushSettings', () async {
      await _user(uid).collection('settings').doc('app').set({
        ...settings,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  @override
  void pushTasbeeh(int count, int loggedCount) {
    final uid = currentUid;
    if (uid == null) return;
    _run('pushTasbeeh', () async {
      await _user(uid).collection('state').doc('tasbeeh').set({
        ...SyncMappers.tasbeehToCloud(count, loggedCount),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  // ── Pull ──────────────────────────────────────────────────────────────────
  /// Reads everything for [uid] from the server (not the cache, so an
  /// offline device never mistakes "nothing cached" for "no cloud data").
  Future<CloudUserData> pullAll(String uid) async {
    if (!_available) throw StateError('Firebase unavailable');
    const server = GetOptions(source: Source.server);
    final user = _user(uid);
    final results = await Future.wait<Object>([
      user.get(server),
      user.collection('activities').get(server),
      user.collection('saved_verses').get(server),
      user.collection('badges').get(server),
      user.collection('settings').doc('app').get(server),
      user.collection('state').doc('tasbeeh').get(server),
    ]);
    final profile = results[0] as DocumentSnapshot<Map<String, dynamic>>;
    final activities = results[1] as QuerySnapshot<Map<String, dynamic>>;
    final verses = results[2] as QuerySnapshot<Map<String, dynamic>>;
    final badges = results[3] as QuerySnapshot<Map<String, dynamic>>;
    final settings = results[4] as DocumentSnapshot<Map<String, dynamic>>;
    final tasbeeh = results[5] as DocumentSnapshot<Map<String, dynamic>>;
    return CloudUserData(
      profile: profile.data(),
      activities: [
        for (final d in activities.docs)
          if (SyncMappers.activityFromCloud(d.id, d.data()) case final a?) a,
      ],
      savedVerses: [
        for (final d in verses.docs)
          if (SyncMappers.savedVerseFromCloud(d.data()) case final v?) v,
      ],
      badges: SyncMappers.badgesFromCloud(
        badges.docs.map((d) => MapEntry(d.id, d.data())),
      ),
      settings: settings.data(),
      tasbeeh: SyncMappers.tasbeehFromCloud(tasbeeh.data()),
    );
  }

  /// Run after every sign-in (and on app start when already signed in):
  /// 1. pulls all cloud data,
  /// 2. once per uid on this device (`migrated_<uid>`), uploads local
  ///    guest/legacy data missing from the cloud,
  /// 3. writes cloud data into Hive/prefs (offline cache).
  ///
  /// Returns true when local data was refreshed (the app should then reload
  /// pulse data and settings). Returns false (and changes nothing) when
  /// offline or Firebase is unavailable; it is retried on the next call.
  Future<bool> syncOnSignIn(String uid) {
    final existing = _syncInFlight[uid];
    if (existing != null) return existing;
    final f = _syncOnSignIn(uid).whenComplete(() => _syncInFlight.remove(uid));
    _syncInFlight[uid] = f;
    return f;
  }

  Future<bool> _syncOnSignIn(String uid) async {
    if (!_available || currentUid != uid) return false;
    final CloudUserData cloud;
    try {
      cloud = await pullAll(uid).timeout(const Duration(seconds: 25));
    } catch (e) {
      debugPrint('UserDataSync.pullAll failed: $e');
      return false;
    }

    final activityBox = await Hive.openBox<SpiritualActivity>(
      LocalBoxes.activities,
    );
    final verseBox = await Hive.openBox<SavedVerse>(LocalBoxes.savedVerses);
    final metaBox = await Hive.openBox(LocalBoxes.pulseMeta);
    final localBadges = readLocalBadges(metaBox);

    // 1. One-time upload of local (guest / pre-sync) data.
    if (!(prefs.getBool(UserPrefsKeys.migrated(uid)) ?? false)) {
      try {
        await _uploadLocal(
          uid,
          cloud: cloud,
          localActivities: activityBox.values.toList(),
          localVerses: verseBox.values.toList(),
          localBadges: localBadges,
        );
        await prefs.setBool(UserPrefsKeys.migrated(uid), true);
      } catch (e) {
        debugPrint('UserDataSync migration failed (will retry): $e');
      }
    }

    // 2. Cloud → local cache.
    await activityBox.putAll({for (final a in cloud.activities) a.id: a});
    await verseBox.putAll({for (final v in cloud.savedVerses) v.id: v});
    final mergedBadges = {...localBadges};
    cloud.badges.forEach((id, at) {
      final mine = mergedBadges[id];
      if (mine == null || at.isBefore(mine)) mergedBadges[id] = at;
    });
    await writeLocalBadges(metaBox, mergedBadges);

    if (cloud.settings != null) {
      await SettingsPrefs.applyCloud(prefs, cloud.settings!);
    }
    final t = cloud.tasbeeh;
    if (t != null) {
      await prefs.setInt(UserPrefsKeys.tasbeehCount, t.count);
      await prefs.setInt(UserPrefsKeys.tasbeehLoggedCount, t.loggedCount);
    }
    return true;
  }

  Future<void> _uploadLocal(
    String uid, {
    required CloudUserData cloud,
    required List<SpiritualActivity> localActivities,
    required List<SavedVerse> localVerses,
    required Map<String, DateTime> localBadges,
  }) async {
    final user = _user(uid);
    final writes = <Future<void>>[];

    // Activities: chunks of 400 (+1 user-doc increment per batch).
    final pending = SyncMappers.localOnlyActivities(
      localActivities,
      cloud.activities,
    );
    for (var i = 0; i < pending.length; i += 400) {
      final chunk = pending.skip(i).take(400).toList();
      final batch = _db.batch();
      for (final a in chunk) {
        batch.set(user.collection('activities').doc(a.id), {
          ...SyncMappers.activityToCloud(a),
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      final latest = chunk
          .map((a) => a.timestamp)
          .reduce((x, y) => x.isAfter(y) ? x : y);
      batch.set(user, {
        'totalPoints': FieldValue.increment(
          chunk.fold<int>(0, (s, a) => s + a.points.clamp(0, 100)),
        ),
        'lastActiveDay': SyncMappers.dayKey(latest),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      writes.add(batch.commit());
    }

    final cloudVerseIds = {for (final v in cloud.savedVerses) v.id};
    final verses = localVerses.where((v) => !cloudVerseIds.contains(v.id));
    final badges = {
      for (final e in localBadges.entries)
        if (!cloud.badges.containsKey(e.key)) e.key: e.value,
    };
    if (verses.isNotEmpty || badges.isNotEmpty) {
      final batch = _db.batch();
      for (final v in verses.take(250)) {
        batch.set(
          user
              .collection('saved_verses')
              .doc(SyncMappers.savedVerseDocId(v.surahNumber, v.ayahNumber)),
          SyncMappers.savedVerseToCloud(v),
        );
      }
      badges.forEach((id, at) {
        batch.set(user.collection('badges').doc(id), {'earnedAt': at});
      });
      writes.add(batch.commit());
    }

    if (cloud.settings == null) {
      final settings = SettingsPrefs.toCloud(prefs);
      if (settings.isNotEmpty) {
        writes.add(
          user.collection('settings').doc('app').set({
            ...settings,
            'updatedAt': FieldValue.serverTimestamp(),
          }),
        );
      }
    }
    if (cloud.tasbeeh == null) {
      final count = prefs.getInt(UserPrefsKeys.tasbeehCount) ?? 0;
      if (count > 0) {
        writes.add(
          user.collection('state').doc('tasbeeh').set({
            ...SyncMappers.tasbeehToCloud(
              count,
              prefs.getInt(UserPrefsKeys.tasbeehLoggedCount) ?? 0,
            ),
            'updatedAt': FieldValue.serverTimestamp(),
          }),
        );
      }
    }
    await Future.wait(writes).timeout(const Duration(seconds: 30));
  }

  // ── Local badge store ─────────────────────────────────────────────────────
  static Map<String, DateTime> readLocalBadges(Box metaBox) {
    final raw = metaBox.get(LocalBoxes.badgesKey);
    if (raw is! Map) return {};
    final result = <String, DateTime>{};
    raw.forEach((k, v) {
      final at = v is String ? DateTime.tryParse(v) : null;
      if (k is String && at != null) result[k] = at;
    });
    return result;
  }

  static Future<void> writeLocalBadges(
    Box metaBox,
    Map<String, DateTime> badges,
  ) => metaBox.put(LocalBoxes.badgesKey, {
    for (final e in badges.entries) e.key: e.value.toIso8601String(),
  });

  // ── Deletion / wipe ───────────────────────────────────────────────────────
  /// Deletes all Firestore data of [uid] (subcollections in batches of
  /// ≤500, then the user document). Must run while still signed in.
  Future<void> deleteAllUserData(String uid) async {
    if (!_available) throw StateError('Firebase unavailable');
    final user = _user(uid);
    for (final name in _subcollections) {
      final col = user.collection(name);
      while (true) {
        final snap = await col
            .limit(500)
            .get(const GetOptions(source: Source.server));
        if (snap.docs.isEmpty) break;
        final batch = _db.batch();
        for (final d in snap.docs) {
          batch.delete(d.reference);
        }
        await batch.commit();
        if (snap.docs.length < 500) break;
      }
    }
    await user.delete();
  }

  /// Removes all per-user local data (Hive boxes and prefs, incl. tasbeeh
  /// and migration flags). Settings are device preferences and are kept.
  Future<void> wipeLocalUserData() => wipeLocal(prefs);

  static Future<void> wipeLocal(SharedPreferences prefs) async {
    for (final key in [
      ...UserPrefsKeys.all,
      ...prefs.getKeys().where(
        (k) => k.startsWith(UserPrefsKeys.migratedPrefix),
      ),
    ]) {
      try {
        await prefs.remove(key);
      } catch (_) {}
    }
    for (final box in LocalBoxes.all) {
      try {
        // Deleting (rather than opening + clearing) avoids opening the box
        // with the wrong type; repositories re-open it lazily.
        await Hive.deleteBoxFromDisk(box);
      } catch (_) {}
    }
  }
}
