import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/memorial.dart';

/// The person acting (signed-in user).
typedef MemorialActor = ({String uid, String name});

/// A memorial action failed. [code]: 'not_found', 'para_taken',
/// 'not_allowed', 'offline' or 'unknown'.
class MemorialException implements Exception {
  final String code;
  const MemorialException(this.code);
  @override
  String toString() => 'MemorialException($code)';
}

/// Shared Esaal-e-Sawab pages in Firestore. Anyone signed in who has the
/// code can open and contribute (see `firestore.rules`); codes are random
/// and documents can't be listed, so pages stay private to those invited.
class MemorialRepository {
  MemorialRepository({FirebaseFirestore Function()? db, Random? random})
    : _dbFn = db ?? (() => FirebaseFirestore.instance),
      _random = random ?? Random.secure();

  final FirebaseFirestore Function() _dbFn;
  final Random _random;

  FirebaseFirestore get _db => _dbFn();
  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('memorials');
  CollectionReference<Map<String, dynamic>> _index(String uid) =>
      _db.collection('users').doc(uid).collection('memorials');

  static const codeLength = 8;
  // No 0/O/1/I to avoid misreading.
  static const _alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  String newCode() => List.generate(
    codeLength,
    (_) => _alphabet[_random.nextInt(_alphabet.length)],
  ).join();

  /// Uppercases and strips spaces/dashes; null if it can't be a code.
  static String? normalizeCode(String input) {
    final c = input.toUpperCase().replaceAll(RegExp(r'[\s-]'), '');
    if (c.length != codeLength) return null;
    for (final ch in c.split('')) {
      if (!_alphabet.contains(ch)) return null;
    }
    return c;
  }

  Stream<Memorial?> watch(String id) => _col
      .doc(id)
      .snapshots()
      .map((s) => s.exists ? Memorial.fromMap(s.id, s.data()!) : null);

  Stream<List<MemorialEntry>> watchEntries(String id, {int limit = 40}) =>
      _col
          .doc(id)
          .collection('entries')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .snapshots()
          .map(
            (q) => [
              for (final d in q.docs) MemorialEntry.fromMap(d.id, d.data()),
            ],
          );

  Stream<List<MemorialLink>> watchMine(String uid) => _index(uid)
      .orderBy('joinedAt', descending: true)
      .snapshots()
      .map(
        (q) => [
          for (final d in q.docs)
            MemorialLink(
              id: d.id,
              name: d.data()['name'] is String ? d.data()['name'] : '',
              owner: d.data()['owner'] == true,
            ),
        ],
      );

  Future<String> create(
    MemorialActor me, {
    required String name,
    String subtitle = '',
    DateTime? deathDate,
    bool showDates = true,
    Map<String, int> goals = const {},
  }) async {
    for (var attempt = 0; attempt < 5; attempt++) {
      final code = newCode();
      final ref = _col.doc(code);
      final created = await _db.runTransaction<bool>((tx) async {
        if ((await tx.get(ref)).exists) return false;
        tx.set(ref, {
          'ownerUid': me.uid,
          'name': name.trim(),
          'subtitle': subtitle.trim(),
          'deathDate':
              deathDate == null
                  ? null
                  : Timestamp.fromDate(
                    DateTime.utc(deathDate.year, deathDate.month, deathDate.day, 12),
                  ),
          'showDates': showDates,
          'goals': goals,
          'counts': <String, int>{},
          'paras': <String, dynamic>{},
          'khatams': 0,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        return true;
      });
      if (!created) continue;
      await _index(me.uid).doc(code).set({
        'name': name.trim(),
        'owner': true,
        'joinedAt': FieldValue.serverTimestamp(),
      });
      return code;
    }
    throw const MemorialException('unknown');
  }

  /// Adds the memorial with [code] to the user's list. Returns its id.
  Future<String> join(MemorialActor me, String code) async {
    final c = normalizeCode(code);
    if (c == null) throw const MemorialException('not_found');
    final snap = await _col.doc(c).get();
    if (!snap.exists) throw const MemorialException('not_found');
    final m = Memorial.fromMap(c, snap.data()!);
    await _index(me.uid).doc(c).set({
      'name': m.name,
      'owner': m.isOwner(me.uid),
      'joinedAt': FieldValue.serverTimestamp(),
    });
    return c;
  }

  /// Removes it from the user's list (the page itself stays).
  Future<void> leave(MemorialActor me, String id) =>
      _index(me.uid).doc(id).delete();

  /// Owner only: deletes the page, its feed and the owner's list entry.
  Future<void> delete(MemorialActor me, String id) async {
    final ref = _col.doc(id);
    while (true) {
      final q = await ref.collection('entries').limit(400).get();
      if (q.docs.isEmpty) break;
      final batch = _db.batch();
      for (final d in q.docs) {
        batch.delete(d.reference);
      }
      await batch.commit();
      if (q.docs.length < 400) break;
    }
    await ref.delete();
    await _index(me.uid).doc(id).delete();
  }

  Map<String, dynamic> _entry(
    MemorialActor me,
    String type,
    String text, [
    int count = 0,
  ]) => {
    'uid': me.uid,
    'name': me.name,
    'type': type,
    'text': text,
    'count': count,
    'createdAt': FieldValue.serverTimestamp(),
  };

  Future<void> claimPara(MemorialActor me, String id, int para) async {
    final ref = _col.doc(id);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) throw const MemorialException('not_found');
      final m = Memorial.fromMap(id, snap.data()!);
      if (m.paras.containsKey(para)) {
        throw const MemorialException('para_taken');
      }
      tx.update(ref, {
        'paras.$para':
            ParaClaim(uid: me.uid, name: me.name, done: false).toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  /// Gives a para back (own claim, or any unfinished claim for the owner).
  Future<void> releasePara(MemorialActor me, String id, int para) async {
    final ref = _col.doc(id);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) throw const MemorialException('not_found');
      final m = Memorial.fromMap(id, snap.data()!);
      final c = m.paras[para];
      if (c == null) return;
      if (c.done || (c.uid != me.uid && !m.isOwner(me.uid))) {
        throw const MemorialException('not_allowed');
      }
      tx.update(ref, {
        'paras.$para': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  /// Marks the user's para as read. When all 30 are read the khatam is
  /// counted and a new one starts. Returns true if a khatam was completed.
  Future<bool> completePara(MemorialActor me, String id, int para) async {
    final ref = _col.doc(id);
    final entries = ref.collection('entries');
    return _db.runTransaction<bool>((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) throw const MemorialException('not_found');
      final m = Memorial.fromMap(id, snap.data()!);
      final c = m.paras[para];
      if (c == null || c.uid != me.uid) {
        throw const MemorialException('not_allowed');
      }
      if (c.done) return false;
      tx.set(entries.doc(), _entry(me, 'para', '$para'));
      final finished = m.parasDone + 1 >= Memorial.paraCount;
      if (finished) {
        tx.update(ref, {
          'paras': <String, dynamic>{},
          'khatams': m.khatams + 1,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        tx.set(entries.doc(), _entry(me, 'khatam', '${m.khatams + 1}'));
      } else {
        tx.update(ref, {
          'paras.$para': ParaClaim(uid: c.uid, name: c.name, done: true).toMap(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      return finished;
    });
  }

  Future<void> addDhikr(
    MemorialActor me,
    String id,
    String dhikrId,
    int count,
  ) async {
    if (count <= 0) return;
    final ref = _col.doc(id);
    final batch =
        _db.batch()
          ..update(ref, {
            'counts.$dhikrId': FieldValue.increment(count),
            'updatedAt': FieldValue.serverTimestamp(),
          })
          ..set(
            ref.collection('entries').doc(),
            _entry(me, 'dhikr', dhikrId, count),
          );
    await batch.commit();
  }

  Future<void> addDeed(MemorialActor me, String id, String text) async {
    final t = text.trim();
    if (t.isEmpty) return;
    await _col
        .doc(id)
        .collection('entries')
        .add(_entry(me, 'deed', t.length > 500 ? t.substring(0, 500) : t));
  }

  /// On someone else's page: deletes the user's feed entries (which show
  /// their name) and gives back paras they took but hadn't finished.
  /// Finished paras stay, as they're part of the completed khatam count.
  Future<void> _removeMyTraces(
    MemorialActor me,
    String id,
    Map<String, dynamic> data,
  ) async {
    final ref = _col.doc(id);
    while (true) {
      final q =
          await ref
              .collection('entries')
              .where('uid', isEqualTo: me.uid)
              .limit(400)
              .get();
      if (q.docs.isEmpty) break;
      final batch = _db.batch();
      for (final e in q.docs) {
        batch.delete(e.reference);
      }
      await batch.commit();
      if (q.docs.length < 400) break;
    }
    final m = Memorial.fromMap(id, data);
    for (final e in m.paras.entries) {
      if (e.value.uid == me.uid && !e.value.done) {
        try {
          await releasePara(me, id, e.key);
        } catch (_) {}
      }
    }
  }

  /// Account deletion: deletes memorials the user owns, removes the user's
  /// entries and unfinished paras from pages they joined, and their list.
  Future<void> deleteAllFor(MemorialActor me) async {
    final mine = await _index(me.uid).get();
    for (final d in mine.docs) {
      try {
        final snap = await _col.doc(d.id).get();
        if (snap.exists && snap.data()?['ownerUid'] == me.uid) {
          await delete(me, d.id);
        } else {
          if (snap.exists) await _removeMyTraces(me, d.id, snap.data()!);
          await d.reference.delete();
        }
      } catch (_) {
        // Best effort; the index is removed with the user document.
      }
    }
  }
}
