import 'package:barakah_time/presentation/blocs/prayer_bloc.dart';
import 'package:barakah_time/presentation/blocs/settings_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<SharedPreferences> prefsWith(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    return SharedPreferences.getInstance();
  }

  test('initial state comes from saved prefs (no startup race)', () async {
    final prefs = await prefsWith({
      'calculation_method': 'MWL',
      'use_auto_location': false,
      'manual_location': 'London',
      'manual_latitude': 51.5,
      'manual_longitude': -0.12,
    });
    final bloc = SettingsBloc(prefs);
    final config = PrayerConfig.fromSettings(bloc.state);
    expect(config.method, 'MWL');
    expect(config.madhab, 'shafi');
    expect(config.useAutoLocation, isFalse);
    expect(config.manualLatitude, 51.5);
    await bloc.close();
  });

  test('madhab defaults by method and can be overridden', () async {
    final prefs = await prefsWith({});
    final bloc = SettingsBloc(prefs, countryCode: 'PK');
    expect(bloc.state.calculationMethod, 'Karachi'); // PK default
    expect(bloc.state.asrMadhab, 'hanafi'); // Karachi default
    bloc.add(const UpdateCalculationMethod('ISNA'));
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.asrMadhab, 'shafi');
    bloc.add(const UpdateMadhab('hanafi'));
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.asrMadhab, 'hanafi');
    expect(prefs.getString('asr_madhab'), 'hanafi');
    await bloc.close();
  });

  test(
    'UpdateManualLocation geocodes and persists; failure sets error',
    () async {
      final prefs = await prefsWith({});
      final bloc = SettingsBloc(
        prefs,
        geocoder:
            (q) async =>
                q == 'Istanbul' ? (latitude: 41.0, longitude: 28.9) : null,
      );
      bloc.add(const UpdateManualLocation('Nowhereville'));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(bloc.state.locationError, isNotNull);
      expect(bloc.state.manualLocation, SettingsState.defaultManualLocation);

      // Same failure twice still produces a fresh error emission.
      final errors = <String?>[];
      final sub = bloc.stream.listen((s) => errors.add(s.locationError));
      bloc.add(const UpdateManualLocation('Nowhereville'));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(errors.length, 2);
      expect(errors.first, isNull);
      expect(errors.last, isNotNull);
      await sub.cancel();

      bloc.add(const UpdateManualLocation('Istanbul'));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(bloc.state.locationError, isNull);
      expect(bloc.state.manualLatitude, 41.0);
      expect(prefs.getDouble('manual_longitude'), 28.9);
      expect(SettingsBloc.readFromPrefs(prefs).manualLocation, 'Istanbul');
      await bloc.close();
    },
  );

  test('ToggleNotifications without permission reverts to false', () async {
    final prefs = await prefsWith({});
    final bloc = SettingsBloc(prefs); // no NotificationService => denied
    final seen = <bool>[];
    final sub = bloc.stream.listen((s) => seen.add(s.notificationsEnabled));
    bloc.add(const ToggleNotifications(true));
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(seen, [true, false]);
    expect(prefs.getBool('notifications_enabled'), isFalse);
    await sub.cancel();
    await bloc.close();
  });
}
