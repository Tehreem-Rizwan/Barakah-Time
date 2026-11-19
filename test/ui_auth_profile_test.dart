import 'package:barakah_time/core/localization/app_localizations.dart';
import 'package:barakah_time/core/services/app_init_status.dart';
import 'package:barakah_time/core/services/firebase_service.dart';
import 'package:barakah_time/core/services/supabase_service.dart';
import 'package:barakah_time/core/utils/calculation_methods.dart';
import 'package:barakah_time/presentation/blocs/auth_bloc.dart';
import 'package:barakah_time/presentation/blocs/settings_bloc.dart';
import 'package:barakah_time/presentation/pages/auth/sign_in_page.dart';
import 'package:barakah_time/presentation/pages/auth/sign_up_page.dart';
import 'package:barakah_time/presentation/pages/onboarding_page.dart';
import 'package:barakah_time/presentation/pages/settings_page.dart';
import 'package:barakah_time/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:barakah_time/core/services/entry_route.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _locales = [Locale('en'), Locale('ar')];

Widget _app(
  Widget home,
  Locale locale, {
  AuthBloc? authBloc,
  SettingsBloc? settingsBloc,
  double textScale = 1.0,
}) {
  Widget app = ScreenUtilInit(
    designSize: const Size(375, 812),
    builder:
        (_, _) => MaterialApp(
          theme: AppTheme.dark(locale, useGoogleFonts: false),
          locale: locale,
          supportedLocales: const [
            Locale('en'),
            Locale('ar'),
            Locale('fa'),
            Locale('ur'),
            Locale('tr'),
          ],
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder:
              (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(textScale)),
                child: child!,
              ),
          home: home,
        ),
  );
  if (authBloc != null || settingsBloc != null) {
    app = MultiBlocProvider(
      providers: [
        if (authBloc != null) BlocProvider<AuthBloc>.value(value: authBloc),
        if (settingsBloc != null)
          BlocProvider<SettingsBloc>.value(value: settingsBloc),
      ],
      child: app,
    );
  }
  return app;
}

Future<void> _pump(
  WidgetTester tester,
  Widget app, {
  Size size = const Size(1125, 2436),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(app);
  // Avoid pumpAndSettle: spinners animate forever.
  await tester.pump(const Duration(milliseconds: 100));
  expect(tester.takeException(), isNull);
}

Future<AuthBloc> _authBloc() async {
  final prefs = await SharedPreferences.getInstance();
  return AuthBloc(
    prefs,
    SupabaseService(idTokenProvider: () async => null),
    FirebaseService(),
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    AppFonts.useGoogleFonts = false;
    PackageInfo.setMockInitialValues(
      appName: 'Barakah Time',
      packageName: 'com.tehreem.barakah_time',
      version: '1.2.3',
      buildNumber: '45',
      buildSignature: '',
    );
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    // Enables the auth form (Firebase itself is never touched by these
    // tests: validation fails before any request is made).
    AppInitStatus.firebaseReady = true;
  });

  tearDown(AppInitStatus.reset);

  group('onboarding', () {
    for (final locale in _locales) {
      testWidgets('renders localized pages (${locale.languageCode})', (
        tester,
      ) async {
        final l10n = AppLocalizations(locale);
        await _pump(tester, _app(const OnboardingPage(), locale));

        expect(find.text(l10n.onboarding_pulse_title), findsOneWidget);
        expect(find.text(l10n.onboarding_pulse_desc), findsOneWidget);
        expect(find.text(l10n.onboarding_next), findsOneWidget);
        expect(find.text(l10n.skip), findsOneWidget);
        expect(find.text('NEXT'), findsNothing);

        final ctx = tester.element(find.byType(OnboardingPage));
        expect(
          Directionality.of(ctx),
          locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        );

        await tester.tap(find.text(l10n.onboarding_next));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        expect(find.text(l10n.onboarding_prayer_title), findsOneWidget);

        await tester.tap(find.text(l10n.onboarding_next));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        expect(find.text(l10n.onboarding_inspiration_title), findsOneWidget);

        await tester.tap(find.text(l10n.onboarding_next));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        expect(
          find.text(l10n.translate('onboarding_privacy_title')),
          findsOneWidget,
        );
        expect(find.text(l10n.onboarding_get_started), findsOneWidget);
        expect(find.text(l10n.skip), findsNothing);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('no overflow in small landscape at text scale 1.3', (
      tester,
    ) async {
      await _pump(
        tester,
        _app(const OnboardingPage(), const Locale('ar'), textScale: 1.3),
        size: const Size(1920, 1080), // 640x360 logical
      );
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('onboarding opens the app directly, without sign-in', (
    tester,
  ) async {
    final l10n = AppLocalizations(const Locale('en'));
    final bloc = await _authBloc();
    addTearDown(bloc.close);
    await _pump(
      tester,
      _app(
        OnboardingPage(nextPage: (_) => const Scaffold(body: Text('HOME'))),
        const Locale('en'),
        authBloc: bloc,
      ),
    );
    // Skip finishes onboarding just like "Get started" on the last page.
    await tester.tap(find.text(l10n.skip));
    await tester.pumpAndSettle();

    expect(find.text('HOME'), findsOneWidget);
    expect(find.byType(SignInPage), findsNothing);
    expect(bloc.state, isA<GuestMode>());
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool(EntryPrefsKeys.hasSeenOnboarding), isTrue);
    expect(prefs.getBool(EntryPrefsKeys.guestMode), isTrue);
  });

  group('sign in', () {
    for (final locale in _locales) {
      testWidgets('validates the form (${locale.languageCode})', (
        tester,
      ) async {
        final l10n = AppLocalizations(locale);
        final bloc = await _authBloc();
        addTearDown(bloc.close);
        await _pump(tester, _app(const SignInPage(), locale, authBloc: bloc));

        // All strings are localized.
        expect(find.text(l10n.auth_welcome_back), findsOneWidget);
        expect(find.text(l10n.auth_sign_in_subtitle), findsOneWidget);
        expect(find.text(l10n.auth_email_address), findsOneWidget);
        expect(find.text(l10n.auth_password), findsOneWidget);
        expect(find.text(l10n.continue_with_google), findsOneWidget);
        expect(find.text(l10n.continue_as_guest), findsOneWidget);
        expect(find.byType(GoogleSignInButton), findsOneWidget);
        expect(find.byType(AppleSignInButton), findsNothing);
        expect(find.text('SIGN IN'), findsNothing);

        // Submitting an empty form shows both errors.
        await tester.ensureVisible(find.byType(PrimaryButton));
        await tester.tap(find.byType(PrimaryButton));
        await tester.pump();
        expect(find.text(l10n.email_required), findsOneWidget);
        expect(find.text(l10n.password_required), findsOneWidget);

        // Invalid email.
        await tester.enterText(
          find.byType(TextFormField).first,
          'not-an-email',
        );
        await tester.pump();
        expect(find.text(l10n.invalid_email), findsOneWidget);

        // Password visibility toggle.
        expect(find.byTooltip(l10n.show_password), findsOneWidget);
        await tester.tap(find.byTooltip(l10n.show_password));
        await tester.pump();
        expect(find.byTooltip(l10n.hide_password), findsOneWidget);

        // Still on the sign-in page (no request was made).
        expect(bloc.state, isA<AuthInitial>());
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('disables the form when sign-in is unavailable', (
      tester,
    ) async {
      AppInitStatus.firebaseReady = false;
      const locale = Locale('en');
      final l10n = AppLocalizations(locale);
      final bloc = await _authBloc();
      addTearDown(bloc.close);
      await _pump(tester, _app(const SignInPage(), locale, authBloc: bloc));

      expect(find.text(l10n.auth_unavailable_notice), findsOneWidget);
      final button = tester.widget<PrimaryButton>(find.byType(PrimaryButton));
      expect(button.onPressed, isNull);
      expect(find.text(l10n.continue_as_guest), findsOneWidget);
    });

    testWidgets('fits a small screen at text scale 1.3 (ar)', (tester) async {
      final bloc = await _authBloc();
      addTearDown(bloc.close);
      await _pump(
        tester,
        _app(
          const SignInPage(),
          const Locale('ar'),
          authBloc: bloc,
          textScale: 1.3,
        ),
        size: const Size(960, 1704), // 320x568 logical
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('sign up', () {
    for (final locale in _locales) {
      testWidgets('validates the form (${locale.languageCode})', (
        tester,
      ) async {
        final l10n = AppLocalizations(locale);
        final bloc = await _authBloc();
        addTearDown(bloc.close);
        await _pump(tester, _app(const SignUpPage(), locale, authBloc: bloc));

        expect(find.text(l10n.auth_create_account), findsOneWidget);
        expect(find.text(l10n.auth_full_name), findsOneWidget);
        expect(find.text('REGISTER'), findsNothing);

        final fields = find.byType(TextFormField);
        await tester.enterText(fields.at(2), 'secret1');
        await tester.enterText(fields.at(3), 'secret2');
        await tester.ensureVisible(find.byType(PrimaryButton));
        await tester.tap(find.byType(PrimaryButton));
        await tester.pump();
        expect(find.text(l10n.name_required), findsOneWidget);
        expect(find.text(l10n.email_required), findsOneWidget);
        expect(find.text(l10n.passwords_do_not_match), findsOneWidget);
        expect(bloc.state, isA<AuthInitial>());
      });
    }
  });

  group('settings', () {
    for (final locale in _locales) {
      testWidgets('renders grouped settings for a guest '
          '(${locale.languageCode})', (tester) async {
        final l10n = AppLocalizations(locale);
        final prefs = await SharedPreferences.getInstance();
        final auth = await _authBloc();
        final settings = SettingsBloc(prefs, countryCode: 'PK');
        addTearDown(auth.close);
        addTearDown(settings.close);
        await _pump(
          tester,
          _app(
            const SettingsPage(),
            locale,
            authBloc: auth,
            settingsBloc: settings,
          ),
        );

        expect(find.text(l10n.sign_in_to_sync), findsOneWidget);
        expect(find.text(l10n.settings_prayer), findsOneWidget);
        expect(find.text(l10n.adhan_sound), findsOneWidget);
        final karachi = l10n.translate(
          CalculationMethods.byId(CalculationMethods.karachi)!.l10nKey,
        );
        expect(find.text(karachi), findsOneWidget);

        // Method picker lists every method with a check on the current one.
        await tester.tap(find.text(l10n.calculation_method));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        final dialog = find.byType(AlertDialog);
        expect(
          find.descendant(of: dialog, matching: find.text(karachi)),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: dialog,
            matching: find.byIcon(Icons.check_rounded),
          ),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      });
    }
  });
}
