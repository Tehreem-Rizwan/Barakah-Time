import 'package:barakah_time/data/datasources/local/settings_prefs.dart';
import 'package:barakah_time/data/datasources/remote/adhan_service.dart';
import 'package:barakah_time/presentation/blocs/prayer_bloc.dart';
import 'package:barakah_time/presentation/blocs/settings_bloc.dart';
import 'package:barakah_time/presentation/widgets/theme_sync.dart';
import 'package:flutter/widgets.dart' show Brightness;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('offsets shift only the chosen prayers', () {
    final service = AdhanService();
    final day = DateTime(2026, 11, 18);
    final base = service.timesForDate(24.86, 67.0, day);
    final shifted = service.timesForDate(
      24.86,
      67.0,
      day,
      offsets: const {'fajr': 3, 'isha': -5},
    );
    expect(shifted.fajr.difference(base.fajr).inMinutes, 3);
    expect(shifted.isha.difference(base.isha).inMinutes, -5);
    expect(shifted.dhuhr, base.dhuhr);
    expect(shifted.maghrib, base.maghrib);
  });

  test('cleanOffsets clamps, drops zeros and unknown keys', () {
    expect(
      SettingsPrefs.cleanOffsets({'fajr': 99, 'asr': 0, 'x': 4, 'isha': -2.4}),
      {'fajr': 30, 'isha': -2},
    );
    expect(SettingsPrefs.cleanOffsets('bad'), isEmpty);
  });

  test(
    'bloc persists offsets, config picks them up, cloud round-trips',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final bloc = SettingsBloc(prefs, countryCode: 'PK');
      bloc.add(const UpdatePrayerOffset('maghrib', 2));
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.prayerOffsets, {'maghrib': 2});
      expect(PrayerConfig.fromSettings(bloc.state).offsets, {'maghrib': 2});
      expect(SettingsBloc.readFromPrefs(prefs).prayerOffsets, {'maghrib': 2});
      expect(SettingsPrefs.toCloud(prefs)['prayerOffsets'], {'maghrib': 2});

      bloc.add(const UpdatePrayerOffset('nope', 5));
      bloc.add(const ResetPrayerOffsets());
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.prayerOffsets, isEmpty);

      await SettingsPrefs.applyCloud(prefs, {
        'prayerOffsets': {'fajr': -4},
      });
      expect(SettingsPrefs.readOffsets(prefs), {'fajr': -4});
      await bloc.close();
    },
  );

  test('theme mode persists and resolves', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final bloc = SettingsBloc(prefs, countryCode: 'PK');
    expect(bloc.state.themeMode, 'system');
    bloc.add(const UpdateThemeMode('dark'));
    bloc.add(const UpdateThemeMode('bogus'));
    await Future<void>.delayed(Duration.zero);
    expect(SettingsBloc.readFromPrefs(prefs).themeMode, 'dark');
    expect(SettingsPrefs.toCloud(prefs)['themeMode'], 'dark');
    expect(ThemeSync.resolveDark('system', Brightness.dark), isTrue);
    expect(ThemeSync.resolveDark('light', Brightness.dark), isFalse);
    expect(ThemeSync.resolveDark('dark', Brightness.light), isTrue);
    await bloc.close();
  });
}
