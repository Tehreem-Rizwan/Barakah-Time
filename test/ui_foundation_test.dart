import 'package:barakah_time/core/localization/app_localizations.dart';
import 'package:barakah_time/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

const _locales = [Locale('en'), Locale('ar')];

Widget _app(Widget home, Locale locale) => ScreenUtilInit(
  designSize: const Size(375, 812),
  builder: (_, _) => MaterialApp(
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
    home: home,
  ),
);

Future<void> _pump(WidgetTester tester, Widget home, Locale locale) async {
  tester.view.physicalSize = const Size(1125, 2436);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(_app(home, locale));
  // Avoid pumpAndSettle: spinners/shimmer animate forever.
  await tester.pump(const Duration(milliseconds: 100));
  expect(tester.takeException(), isNull);
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    AppFonts.useGoogleFonts = false;
  });

  group('theme', () {
    test('dark theme uses gold primary with black on-primary', () {
      for (final code in ['en', 'ar', 'fa', 'ur', 'tr']) {
        final theme = AppTheme.dark(Locale(code), useGoogleFonts: false);
        expect(theme.colorScheme.primary, AppColors.secondaryGold);
        expect(theme.colorScheme.onPrimary, AppColors.onGold);
        expect(theme.colorScheme.error, AppColors.error);
        expect(theme.scaffoldBackgroundColor, AppColors.backgroundSlate);
        expect(theme.textTheme.bodyLarge?.color, AppColors.textMain);
      }
      expect(AppTheme.darkTheme.colorScheme.primary, AppColors.secondaryGold);
    });
  });

  for (final locale in _locales) {
    final tag = '[${locale.languageCode}]';

    testWidgets('$tag AppScaffold + SectionHeader + AppCard + GlassBox', (
      tester,
    ) async {
      var taps = 0;
      await _pump(
        tester,
        AppScaffold(
          title: 'Title',
          gradientBackground: true,
          actions: [
            IconButton(
              tooltip: 'Info',
              onPressed: () {},
              icon: const Icon(Icons.info_outline),
            ),
          ],
          body: ListView(
            children: [
              SectionHeader(
                title: 'Section',
                icon: Icons.star,
                actionLabel: 'See all',
                onAction: () {},
              ),
              AppCard(onTap: () => taps++, child: const Text('Card')),
              const AppCard(blur: true, child: Text('Blurred')),
              const GlassBox(child: Text('Glass')),
              const GlassBox(
                shape: BoxShape.circle,
                width: 60,
                height: 60,
                child: SizedBox(),
              ),
            ],
          ),
        ),
        locale,
      );
      await tester.tap(find.text('Card'));
      await tester.pump();
      expect(taps, 1);
      expect(find.text('See all'), findsOneWidget);
    });

    testWidgets('$tag ActionTile shows chevron and destructive variant', (
      tester,
    ) async {
      await _pump(
        tester,
        Scaffold(
          body: Column(
            children: [
              ActionTile(
                icon: Icons.language,
                title: 'Language',
                subtitle: 'English',
                onTap: () {},
              ),
              ActionTile(
                icon: Icons.delete_outline,
                title: 'Delete account',
                destructive: true,
                onTap: () {},
              ),
              const ActionTile(
                icon: Icons.notifications,
                title: 'Notifications',
                trailing: Switch(value: true, onChanged: null),
              ),
            ],
          ),
        ),
        locale,
      );
      expect(find.byIcon(Icons.chevron_right_rounded), findsNWidgets(2));
    });

    testWidgets('$tag StateView variants (incl. inside RefreshIndicator)', (
      tester,
    ) async {
      var retried = 0;
      await _pump(
        tester,
        Scaffold(
          body: RefreshIndicator(
            onRefresh: () async {},
            child: StateView.error(
              message: 'Oops',
              onRetry: () => retried++,
              secondaryLabel: 'Settings',
              onSecondary: () {},
            ),
          ),
        ),
        locale,
      );
      final l10n = AppLocalizations(locale);
      await tester.tap(find.text(l10n.retry));
      await tester.pump();
      expect(retried, 1);

      await _pump(
        tester,
        const Scaffold(body: StateView.loading(message: 'Loading data')),
        locale,
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await _pump(
        tester,
        Scaffold(
          body: StateView.empty(
            icon: Icons.inbox,
            message: 'Nothing here',
            actionLabel: 'Add',
            onAction: () {},
          ),
        ),
        locale,
      );
      expect(find.text('Add'), findsOneWidget);

      // Unbounded height (inside a scroll view) must not throw.
      await _pump(
        tester,
        Scaffold(
          body: ListView(
            children: const [
              StateView.empty(icon: Icons.inbox, message: 'Nothing'),
            ],
          ),
        ),
        locale,
      );
    });

    testWidgets('$tag AppSearchField clear button', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      String? last;
      await _pump(
        tester,
        Scaffold(
          body: AppSearchField(
            controller: controller,
            hint: 'Search',
            onChanged: (v) => last = v,
          ),
        ),
        locale,
      );
      final l10n = AppLocalizations(locale);
      expect(find.byTooltip(l10n.clear_search), findsNothing);
      await tester.enterText(find.byType(TextField), 'abc');
      await tester.pump();
      expect(last, 'abc');
      await tester.tap(find.byTooltip(l10n.clear_search));
      await tester.pump();
      expect(controller.text, isEmpty);
      expect(last, '');
    });

    testWidgets('$tag buttons', (tester) async {
      var pressed = 0;
      await _pump(
        tester,
        Scaffold(
          body: ListView(
            children: [
              PrimaryButton(
                label: 'Primary',
                icon: Icons.check,
                onPressed: () => pressed++,
              ),
              const PrimaryButton(
                label: 'Loading',
                onPressed: null,
                loading: true,
              ),
              SecondaryButton(label: 'Secondary', onPressed: () {}),
              GoogleSignInButton(onPressed: () {}),
              const GoogleSignInButton(onPressed: null, loading: true),
              AppleSignInButton(onPressed: () {}),
            ],
          ),
        ),
        locale,
      );
      await tester.tap(find.text('Primary'));
      await tester.pump();
      expect(pressed, 1);
      final l10n = AppLocalizations(locale);
      expect(find.text(l10n.continue_with_google), findsNWidgets(2));
      expect(find.text(l10n.continue_with_apple), findsOneWidget);
      expect(find.byType(GoogleLogo), findsNWidgets(1));
    });

    testWidgets('$tag AuthTextField password toggle', (tester) async {
      final email = TextEditingController();
      final password = TextEditingController();
      addTearDown(email.dispose);
      addTearDown(password.dispose);
      await _pump(
        tester,
        Scaffold(
          body: Form(
            child: Column(
              children: [
                AuthTextField(
                  controller: email,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  validator: (v) => (v ?? '').isEmpty ? 'Required' : null,
                ),
                AuthTextField(
                  controller: password,
                  label: 'Password',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  autofillHints: const [AutofillHints.password],
                ),
              ],
            ),
          ),
        ),
        locale,
      );
      final l10n = AppLocalizations(locale);
      EditableText editable() => tester.widget<EditableText>(
        find.descendant(
          of: find.byType(AuthTextField).last,
          matching: find.byType(EditableText),
        ),
      );
      expect(editable().obscureText, isTrue);
      await tester.tap(find.byTooltip(l10n.show_password));
      await tester.pump();
      expect(editable().obscureText, isFalse);
      expect(find.byTooltip(l10n.hide_password), findsOneWidget);
    });

    testWidgets('$tag StatTile/StatRow, ArabicText, TranslationText', (
      tester,
    ) async {
      await _pump(
        tester,
        const Scaffold(
          body: Column(
            children: [
              StatRow(
                children: [
                  StatTile(value: '12', label: 'Day streak', icon: Icons.bolt),
                  StatTile(value: '340', label: 'Ayahs read'),
                  StatTile(value: '5/5', label: 'Prayers'),
                ],
              ),
              ArabicText('بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ'),
              TranslationText('In the name of Allah, the Most Gracious.'),
              TranslationText('اردو ترجمہ', isLtr: false),
            ],
          ),
        ),
        locale,
      );
      final arabic = tester.widget<Text>(
        find.descendant(of: find.byType(ArabicText), matching: find.byType(Text)),
      );
      expect(arabic.textDirection, TextDirection.rtl);
      final translation = tester.widget<Text>(
        find.descendant(
          of: find.byType(TranslationText).first,
          matching: find.byType(Text),
        ),
      );
      expect(translation.textDirection, TextDirection.ltr);
    });

    testWidgets('$tag showAppSnackBar all types', (tester) async {
      late BuildContext ctx;
      await _pump(
        tester,
        Scaffold(
          body: Builder(
            builder: (c) {
              ctx = c;
              return const SizedBox.expand();
            },
          ),
        ),
        locale,
      );
      for (final type in SnackType.values) {
        showAppSnackBar(ctx, 'Message ${type.name}', type: type);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 750));
        expect(find.text('Message ${type.name}'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('$tag showConfirmDialog with typed confirmation', (
      tester,
    ) async {
      late BuildContext ctx;
      await _pump(
        tester,
        Scaffold(
          body: Builder(
            builder: (c) {
              ctx = c;
              return const SizedBox.expand();
            },
          ),
        ),
        locale,
      );
      final l10n = AppLocalizations(locale);

      // Simple confirm.
      var future = showConfirmDialog(ctx, title: 'Sure?', message: 'Really?');
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.confirm));
      await tester.pumpAndSettle();
      expect(await future, isTrue);

      // Cancel.
      future = showConfirmDialog(ctx, title: 'Sure?');
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.cancel));
      await tester.pumpAndSettle();
      expect(await future, isFalse);

      // Typed confirmation gate.
      future = showConfirmDialog(
        ctx,
        title: 'Delete account',
        message: 'This cannot be undone.',
        confirmLabel: 'Delete',
        destructive: true,
        requireTypedText: 'DELETE',
      );
      await tester.pumpAndSettle();
      FilledButton confirm() => tester.widget<FilledButton>(
        find.ancestor(of: find.text('Delete'), matching: find.byType(FilledButton)),
      );
      expect(confirm().onPressed, isNull);
      await tester.enterText(find.byType(TextField), 'DEL');
      await tester.pump();
      expect(confirm().onPressed, isNull);
      await tester.enterText(find.byType(TextField), 'DELETE');
      await tester.pump();
      expect(confirm().onPressed, isNotNull);
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(await future, isTrue);
    });

    testWidgets('$tag SkeletonList', (tester) async {
      await _pump(tester, const Scaffold(body: SkeletonList()), locale);
      expect(find.byType(SkeletonBox), findsWidgets);
    });

    testWidgets('$tag tokens resolve', (tester) async {
      await _pump(
        tester,
        Scaffold(
          body: Builder(
            builder: (context) {
              expect(AppSpacing.lg, greaterThan(0));
              expect(AppRadius.lg, greaterThan(0));
              return Padding(
                padding: AppSpacing.page,
                child: Container(
                  decoration: BoxDecoration(borderRadius: AppRadius.mdAll),
                ),
              );
            },
          ),
        ),
        locale,
      );
    });
  }
}
