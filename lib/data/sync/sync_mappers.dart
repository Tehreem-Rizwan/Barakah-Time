import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

import '../../domain/entities/saved_verse.dart';
import '../../domain/entities/spiritual_activity.dart';

/// Pure conversions between local entities and Firestore documents.
/// Timestamps are written as [DateTime] (Firestore stores them as
/// Timestamps) and read back from either form.
class SyncMappers {
  SyncMappers._();

  /// 'yyyyMMdd' in local time.
  static String dayKey(DateTime t) =>
      '${t.year.toString().padLeft(4, '0')}'
      '${t.month.toString().padLeft(2, '0')}'
      '${t.day.toString().padLeft(2, '0')}';

  static DateTime? toDate(Object? v) {
    if (v is Timestamp) return v.toDate();
    if (v is DateTime) return v;
    if (v is String) return DateTime.tryParse(v);
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
    return null;
  }

  // ── Activities ────────────────────────────────────────────────────────────
  static Map<String, dynamic> activityToCloud(SpiritualActivity a) => {
    'type': a.type,
    'subType': a.subType,
    'points': a.points.clamp(0, 100),
    'timestamp': a.timestamp,
    'day': dayKey(a.timestamp),
  };

  static SpiritualActivity? activityFromCloud(
    String id,
    Map<String, dynamic> data,
  ) {
    final type = data['type'];
    final points = data['points'];
    final ts = toDate(data['timestamp']);
    if (type is! String || points is! num || ts == null) return null;
    final sub = data['subType'];
    return SpiritualActivity(
      id: id,
      type: type,
      subType: sub is String ? sub : null,
      timestamp: ts,
      points: points.toInt(),
    );
  }

  /// Sum of points (lifetime total).
  static int totalPoints(Iterable<SpiritualActivity> activities) =>
      activities.fold(0, (sum, a) => sum + a.points);

  /// Local activities that are missing from the cloud and should be
  /// uploaded. Prayers already logged in the cloud for the same day (under a
  /// different id) are skipped so they are not counted twice.
  static List<SpiritualActivity> localOnlyActivities(
    Iterable<SpiritualActivity> local,
    Iterable<SpiritualActivity> cloud,
  ) {
    final cloudIds = {for (final a in cloud) a.id};
    final cloudPrayers = {
      for (final a in cloud)
        if (a.type == 'prayer') '${a.subType}_${dayKey(a.timestamp)}',
    };
    return [
      for (final a in local)
        if (!cloudIds.contains(a.id) &&
            !(a.type == 'prayer' &&
                cloudPrayers.contains('${a.subType}_${dayKey(a.timestamp)}')))
          a,
    ];
  }

  // ── Saved verses ──────────────────────────────────────────────────────────
  /// Firestore doc id `<surah>_<ayah>` (local ids are `<surah>:<ayah>`).
  static String savedVerseDocId(int surah, int ayah) => '${surah}_$ayah';

  /// Converts a local id `2:255` to `2_255`; returns null if malformed.
  static String? savedVerseDocIdFromLocalId(String localId) {
    final parts = localId.split(RegExp('[:_]'));
    if (parts.length != 2) return null;
    final s = int.tryParse(parts[0]);
    final a = int.tryParse(parts[1]);
    if (s == null || a == null) return null;
    return savedVerseDocId(s, a);
  }

  static Map<String, dynamic> savedVerseToCloud(SavedVerse v) => {
    'surahNumber': v.surahNumber,
    'ayahNumber': v.ayahNumber,
    'text': v.text,
    'translation': v.translation,
    'surahName': v.surahName,
    'timestamp': v.timestamp,
  };

  static SavedVerse? savedVerseFromCloud(Map<String, dynamic> data) {
    final s = data['surahNumber'];
    final a = data['ayahNumber'];
    final text = data['text'];
    if (s is! num || a is! num || text is! String) return null;
    final translation = data['translation'];
    final name = data['surahName'];
    return SavedVerse(
      id: '${s.toInt()}:${a.toInt()}',
      surahNumber: s.toInt(),
      ayahNumber: a.toInt(),
      text: text,
      translation: translation is String ? translation : null,
      surahName: name is String ? name : '',
      timestamp: toDate(data['timestamp']) ?? DateTime.now(),
    );
  }

  // ── Badges ────────────────────────────────────────────────────────────────
  static Map<String, DateTime> badgesFromCloud(
    Iterable<MapEntry<String, Map<String, dynamic>>> docs,
  ) => {
    for (final d in docs)
      d.key:
          toDate(d.value['earnedAt']) ?? DateTime.fromMillisecondsSinceEpoch(0),
  };

  // ── Tasbeeh ───────────────────────────────────────────────────────────────
  static Map<String, dynamic> tasbeehToCloud(int count, int loggedCount) => {
    'count': count < 0 ? 0 : count,
    'loggedCount': loggedCount.clamp(0, count < 0 ? 0 : count),
  };

  static ({int count, int loggedCount})? tasbeehFromCloud(
    Map<String, dynamic>? data,
  ) {
    if (data == null) return null;
    final c = data['count'];
    final l = data['loggedCount'];
    if (c is! num) return null;
    final count = c.toInt() < 0 ? 0 : c.toInt();
    final logged = (l is num ? l.toInt() : 0).clamp(0, count);
    return (count: count, loggedCount: logged);
  }
}
