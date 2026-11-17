import 'package:adhan/adhan.dart' as adhan;
import 'package:barakah_time/core/services/notification_service.dart';
import 'package:barakah_time/core/utils/calculation_methods.dart';
import 'package:barakah_time/data/datasources/remote/adhan_service.dart';
import 'package:barakah_time/presentation/blocs/settings_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeNotifications extends NotificationService {
  bool granted;
  int cancelled = 0;
  _FakeNotifications(this.granted);

  @override
  Future<bool> arePermissionsGranted() async => granted;
  @override
  Future<bool> requestPermission() async => granted;
  @override
  Future<bool> requestExactAlarmsPermission() async => true;
  @override
  Future<void> cancelAll() async => cancelled++;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('default method by country', () {
    const f = CalculationMethods.defaultForCountry;
    test('mapping', () {
      for (final cc in ['PK', 'IN', 'BD', 'AF', 'pk']) {
        expect(f(cc), 'Karachi', reason: cc);
      }
      expect(f('US'), 'ISNA');
      expect(f('CA'), 'ISNA');
      expect(f('SA'), 'Makkah');
      expect(f('AE'), 'Dubai');
      expect(f('QA'), 'Qatar');
      expect(f('KW'), 'Kuwait');
      expect(f('TR'), 'Turkey');
      expect(f('EG'), 'Egyptian');
      expect(f('IR'), 'Tehran');
      for (final cc in ['SG', 'MY', 'ID']) {
        expect(f(cc), 'Singapore', reason: cc);
      }
      expect(f('GB'), 'MoonsightingCommittee');
      expect(f('DE'), 'MoonsightingCommittee');
      expect(f('NG'), 'MWL');
      expect(f(null), 'MWL');
      expect(f(''), 'MWL');
    });

    test('every method id maps to a distinct adhan method', () {
      final mapped = {
        for (final id in CalculationMethods.ids) AdhanService.methodFor(id),
      };
      expect(mapped.length, CalculationMethods.ids.length);
      expect(
        AdhanService.methodFor('MoonsightingCommittee'),
        adhan.CalculationMethod.moon_sighting_committee,
      );
      expect(
        AdhanService.methodFor('???'),
        adhan.CalculationMethod.muslim_world_league,
      );
      for (final m in CalculationMethods.all) {
        expect(m.l10nKey, startsWith('method_'));
      }
    });
  });

  group('SettingsBloc', () {
    Future<SharedPreferences> prefsWith(Map<String, Object> v) async {
      SharedPreferences.setMockInitialValues(v);
      return SharedPreferences.getInstance();
    }

    test('no saved method -> country default; saved method wins', () async {
      var bloc = SettingsBloc(await prefsWith({}), countryCode: 'TR');
      expect(bloc.state.calculationMethod, 'Turkey');
      await bloc.close();
      bloc = SettingsBloc(
        await prefsWith({'calculation_method': 'Egyptian'}),
        countryCode: 'TR',
      );
      expect(bloc.state.calculationMethod, 'Egyptian');
      await bloc.close();
      // Unknown saved ids fall back to the default.
      bloc = SettingsBloc(
        await prefsWith({'calculation_method': 'Bogus'}),
        countryCode: 'US',
      );
      expect(bloc.state.calculationMethod, 'ISNA');
      await bloc.close();
    });

    test('ToggleAdhanSound persists, default true', () async {
      final prefs = await prefsWith({});
      final bloc = SettingsBloc(prefs, countryCode: 'PK');
      expect(bloc.state.adhanSoundEnabled, isTrue);
      bloc.add(const ToggleAdhanSound(false));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(bloc.state.adhanSoundEnabled, isFalse);
      expect(prefs.getBool('adhan_sound_enabled'), isFalse);
      await bloc.close();
    });

    test(
      'RecheckNotificationPermission turns reminders off if revoked',
      () async {
        final prefs = await prefsWith({'notifications_enabled': true});
        final notifications = _FakeNotifications(true);
        final bloc = SettingsBloc(
          prefs,
          countryCode: 'PK',
          notificationService: notifications,
        );
        bloc.add(const RecheckNotificationPermission());
        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(bloc.state.notificationsEnabled, isTrue);

        notifications.granted = false;
        bloc.add(const RecheckNotificationPermission());
        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(bloc.state.notificationsEnabled, isFalse);
        expect(prefs.getBool('notifications_enabled'), isFalse);
        expect(notifications.cancelled, 1);
        await bloc.close();
      },
    );
  });

  test('time zone picks the region when the phone locale is en_US', () {
    expect(SettingsBloc.countryForUtcOffset(const Duration(hours: 5)), 'PK');
    expect(
      SettingsBloc.countryForUtcOffset(const Duration(hours: 5, minutes: 30)),
      'IN',
    );
    expect(SettingsBloc.countryForUtcOffset(const Duration(hours: -5)), isNull);
    expect(
      SettingsBloc.deviceCountryCode(utcOffset: const Duration(hours: 5)),
      'PK',
    );
  });
}
