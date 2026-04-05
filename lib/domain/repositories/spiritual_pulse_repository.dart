import '../entities/spiritual_pulse.dart';
import '../entities/spiritual_activity.dart';

abstract class SpiritualPulseRepository {
  Future<SpiritualPulseEntity> getPulseData();
  Future<void> logActivity(SpiritualActivity activity);
}
