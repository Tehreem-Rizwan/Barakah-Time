import '../../domain/entities/spiritual_pulse.dart';

abstract class SpiritualPulseRepository {
  Future<SpiritualPulseEntity> getPulseData();
}

class MockSpiritualPulseRepository implements SpiritualPulseRepository {
  @override
  Future<SpiritualPulseEntity> getPulseData() async {
    // Mocking real-world consistency data
    return const SpiritualPulseEntity(
      dailyPoints: [40, 70, 90, 100, 20, 0, 0], // Last 7 days
      currentStreak: 4,
      motivationalMessage: "Your spiritual momentum is growing! Keep it up.",
    );
  }
}
