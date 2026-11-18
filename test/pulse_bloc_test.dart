import 'package:barakah_time/domain/entities/saved_verse.dart';
import 'package:barakah_time/domain/entities/spiritual_activity.dart';
import 'package:barakah_time/domain/entities/spiritual_pulse.dart';
import 'package:barakah_time/domain/repositories/saved_verses_repository.dart';
import 'package:barakah_time/domain/repositories/spiritual_pulse_repository.dart';
import 'package:barakah_time/presentation/blocs/pulse_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fake with a deliberately slow check-then-write to expose races.
class _FakePulseRepo implements SpiritualPulseRepository {
  final List<SpiritualActivity> stored = [];
  bool failReads = false;

  @override
  Future<bool> logActivity(SpiritualActivity activity) async {
    final exists = stored.any((a) => a.id == activity.id);
    await Future<void>.delayed(const Duration(milliseconds: 5));
    if (exists) return false;
    stored.add(activity);
    return true;
  }

  @override
  Future<SpiritualPulseEntity> getPulseData() async {
    if (failReads) throw Exception('boom');
    return SpiritualPulseEntity(
      dailyPoints: const [0, 0, 0, 0, 0, 0, 0],
      currentStreak: stored.length,
      recentActivities: List.of(stored),
      badges: const [],
    );
  }

  @override
  Future<List<SpiritualActivity>> getActivitiesOn(DateTime day) async =>
      List.of(stored);
}

class _FakeSaved implements SavedVersesRepository {
  @override
  Future<void> deleteVerse(String id) async {}
  @override
  Future<List<SavedVerse>> getSavedVerses() async => const [];
  @override
  Future<bool> isVerseSaved(String id) async => false;
  @override
  Future<void> saveVerse(SavedVerse verse) async {}
}

void main() {
  SpiritualActivity act(String id) => SpiritualActivity(
    id: id,
    type: 'quran',
    timestamp: DateTime(2026, 11, 14, 10),
    points: 10,
  );

  test(
    'LogActivity with an existing id is a no-op, even when spammed',
    () async {
      final repo = _FakePulseRepo();
      final bloc = PulseBloc(
        repository: repo,
        savedVersesRepository: _FakeSaved(),
      );
      final results = <bool>[];
      for (var i = 0; i < 3; i++) {
        bloc.add(LogActivity(act('surah_1_20261114'), onResult: results.add));
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(repo.stored.length, 1);
      expect(results, [true, false, false]);
      await bloc.close();
    },
  );

  test(
    'reload does not emit PulseLoading once loaded; errors keep data',
    () async {
      final repo = _FakePulseRepo();
      final bloc = PulseBloc(
        repository: repo,
        savedVersesRepository: _FakeSaved(),
      );
      final states = <PulseState>[];
      final sub = bloc.stream.listen(states.add);
      bloc.add(LoadPulseData());
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(bloc.state, isA<PulseLoaded>());
      states.clear();

      bloc.add(LogActivity(act('a')));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(states.whereType<PulseLoading>(), isEmpty);

      repo.failReads = true;
      bloc.add(LoadPulseData());
      await Future<void>.delayed(const Duration(milliseconds: 20));
      final s = bloc.state;
      expect(s, isA<PulseLoaded>());
      expect((s as PulseLoaded).error, isNotNull);
      expect(s.pulse.recentActivities.length, 1);
      await sub.cancel();
      await bloc.close();
    },
  );
}
