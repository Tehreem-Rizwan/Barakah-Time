import 'package:barakah_time/core/localization/app_localizations.dart';
import 'package:barakah_time/core/services/location_service.dart';
import 'package:barakah_time/core/services/notification_service.dart';
import 'package:barakah_time/injection_container.dart';
import 'package:barakah_time/presentation/blocs/location_bloc.dart';
import 'package:barakah_time/presentation/blocs/settings_bloc.dart';
import 'package:barakah_time/presentation/pages/first_run_prompts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeNotifications implements NotificationService {
  _FakeNotifications({required this.grant, required this.exact});
  final bool grant;
  final bool exact;
  int permissionAsks = 0;
  int exactAsks = 0;
  @override
  Future<bool> requestPermission() async {
    permissionAsks++;
    return grant;
  }

  @override
  Future<bool> canScheduleExactAlarms() async => exact;
  @override
  Future<bool> requestExactAlarmsPermission() async {
    exactAsks++;
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _NoGps implements LocationService {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

Future<(SettingsBloc, BuildContext)> _pump(
  WidgetTester tester,
  _FakeNotifications n,
) async {
  await sl.reset();
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);
  sl.registerSingleton<NotificationService>(n);
  final settings = SettingsBloc(
    prefs,
    countryCode: 'PK',
    notificationService: n,
  );
  final location = LocationBloc(_NoGps())..add(
    UpdateLocationManually(latitude: 33.7, longitude: 73.0, city: 'Islamabad'),
  );
  late BuildContext ctx;
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(390, 844),
      builder:
          (_, __) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: settings),
              BlocProvider.value(value: location),
            ],
            child: MaterialApp(
              localizationsDelegates: const [AppLocalizationsDelegate()],
              home: Builder(
                builder: (c) {
                  ctx = c;
                  return const Scaffold();
                },
              ),
            ),
          ),
    ),
  );
  await tester.pump();
  addTearDown(settings.close);
  addTearDown(location.close);
  return (settings, ctx);
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  final l10n = AppLocalizations(const Locale('en'));

  testWidgets('asks once, enables notifications, explains exact alarms', (
    tester,
  ) async {
    final n = _FakeNotifications(grant: true, exact: false);
    final (settings, ctx) = await _pump(tester, n);

    FirstRunPrompts.run(ctx);
    await tester.pumpAndSettle();
    expect(n.permissionAsks, greaterThanOrEqualTo(1));
    expect(settings.state.notificationsEnabled, isTrue);
    expect(find.text(l10n.exact_alarm_prompt_title), findsOneWidget);

    await tester.tap(find.text(l10n.open_settings));
    await tester.pumpAndSettle();
    expect(n.exactAsks, 1);

    // Never asked again.
    final asks = n.permissionAsks;
    FirstRunPrompts.run(ctx);
    await tester.pumpAndSettle();
    expect(n.permissionAsks, asks);
  });

  testWidgets('declined: stays off and is not asked again', (tester) async {
    final n = _FakeNotifications(grant: false, exact: false);
    final (settings, ctx) = await _pump(tester, n);

    FirstRunPrompts.run(ctx);
    await tester.pumpAndSettle();
    expect(n.permissionAsks, 1);
    expect(settings.state.notificationsEnabled, isFalse);
    expect(find.text(l10n.exact_alarm_prompt_title), findsNothing);

    FirstRunPrompts.run(ctx);
    await tester.pumpAndSettle();
    expect(n.permissionAsks, 1);
  });

  testWidgets('no exact-alarm dialog when already allowed', (tester) async {
    final n = _FakeNotifications(grant: true, exact: true);
    final (settings, ctx) = await _pump(tester, n);
    FirstRunPrompts.run(ctx);
    await tester.pumpAndSettle();
    expect(settings.state.notificationsEnabled, isTrue);
    expect(find.text(l10n.exact_alarm_prompt_title), findsNothing);
    expect(n.exactAsks, 0);
  });
}
