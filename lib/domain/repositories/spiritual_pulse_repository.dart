import '../entities/spiritual_pulse.dart';
import '../entities/spiritual_activity.dart';

abstract class SpiritualPulseRepository {
  Future<SpiritualPulseEntity> getPulseData();

  /// Stores [activity]. Returns false (no-op) when an activity with the same
  /// `id` already exists, or a prayer of the same subType was already logged
  /// that day.
  Future<bool> logActivity(SpiritualActivity activity);

  /// All activities whose timestamp falls on the calendar day of [day].
  Future<List<SpiritualActivity>> getActivitiesOn(DateTime day);
}
