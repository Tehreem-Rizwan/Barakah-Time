import 'package:barakah_time/core/localization/app_localizations.dart';
import 'package:barakah_time/presentation/pages/names_all_page.dart';
import 'package:barakah_time/presentation/pages/zakat_calculator_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => ScreenUtilInit(
  designSize: const Size(375, 812),
  builder:
      (_, __) => MaterialApp(
        localizationsDelegates: const [
          AppLocalizationsDelegate(),
          DefaultMaterialLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
        home: child,
      ),
);

void main() {
  testWidgets('zakat: invalid input shows error, below nisab message', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 4000);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_wrap(const ZakatCalculatorPage()));
    await tester.pumpAndSettle();
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '-5');
    await tester.tap(find.text('Calculate Zakat'));
    await tester.pump();
    expect(find.text('Enter a valid positive number'), findsOneWidget);

    await tester.enterText(fields.at(0), '50,000');
    await tester.enterText(fields.at(5), '1000'); // silver price/gram
    await tester.tap(find.text('Calculate Zakat'));
    await tester.pump();
    expect(find.text('Enter a valid positive number'), findsNothing);
    expect(find.textContaining('Below nisab'), findsOneWidget);
  });

  testWidgets('names: filtered card keeps the real number', (tester) async {
    await tester.pumpWidget(_wrap(const NamesOfAllahPage()));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'As-Sabur');
    await tester.pump();
    expect(find.text('99'), findsOneWidget);
    expect(find.text('1'), findsNothing);
  });
}
