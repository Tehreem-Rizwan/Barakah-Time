import 'package:barakah_time/main.dart' show silenceLogsInRelease;
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final original = debugPrint;
  tearDown(() => debugPrint = original);

  test('release builds write nothing to the device log', () {
    final printed = <String?>[];
    debugPrint = (String? m, {int? wrapWidth}) => printed.add(m);
    silenceLogsInRelease(release: true);
    debugPrint('Reverse geocoding failed: something');
    expect(printed, isEmpty);
  });

  test('debug builds keep logging', () {
    final printed = <String?>[];
    debugPrint = (String? m, {int? wrapWidth}) => printed.add(m);
    silenceLogsInRelease(release: false);
    debugPrint('still visible');
    expect(printed, ['still visible']);
  });
}
