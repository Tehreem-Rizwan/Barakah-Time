import 'package:barakah_time/core/localization/app_localizations.dart';
import 'package:barakah_time/core/services/audio_service.dart';
import 'package:barakah_time/data/datasources/local/settings_prefs.dart';
import 'package:barakah_time/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:barakah_time/presentation/blocs/settings_bloc.dart';
import 'package:barakah_time/presentation/widgets/audio_control_bar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeAudio implements AudioService {
  _FakeAudio(this.status);
  @override
  final AudioStatus status;
  double current = 1.0;
  @override
  double get speed => current;
  @override
  Future<void> setSpeed(double s) async => current = s;
  @override
  Stream<AudioStatus> get statusStream => Stream.value(status);
  @override
  Stream<String> get errorStream => const Stream.empty();
  @override
  Stream<Duration> get positionStream => const Stream.empty();
  @override
  Stream<Duration?> get durationStream => const Stream.empty();
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

Future<SettingsBloc> _pumpBar(WidgetTester tester, _FakeAudio audio) async {
  await sl.reset();
  sl.registerSingleton<AudioService>(audio);
  final prefs = await SharedPreferences.getInstance();
  final bloc = SettingsBloc(prefs, countryCode: 'PK');
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(390, 844),
      builder:
          (_, __) => BlocProvider.value(
            value: bloc,
            child: const MaterialApp(
              localizationsDelegates: [AppLocalizationsDelegate()],
              home: Scaffold(bottomNavigationBar: AudioControlBar()),
            ),
          ),
    ),
  );
  await tester.pump();
  return bloc;
}

void main() {
  testWidgets('control bar changes the recitation speed', (tester) async {
    final audio = _FakeAudio(
      const AudioStatus(
        mediaId: 'surah_1',
        title: 'Al-Fatiha',
        isPlaying: true,
      ),
    );
    final bloc = await _pumpBar(tester, audio);
    addTearDown(bloc.close);
    expect(find.text('1×'), findsOneWidget);

    await tester.tap(find.text('1×'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('0.75×').last);
    await tester.pumpAndSettle();

    expect(audio.current, 0.75);
    expect(find.text('0.75×'), findsOneWidget);
    expect(bloc.state.audioSpeed, 0.75);
  });

  testWidgets('no speed button for text-to-speech', (tester) async {
    final audio = _FakeAudio(
      const AudioStatus(mediaId: 'tts', isPlaying: true, isTts: true),
    );
    final bloc = await _pumpBar(tester, audio);
    addTearDown(bloc.close);
    expect(find.text('1×'), findsNothing);
  });

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('offered speeds stop at 2x', () {
    expect(SettingsPrefs.audioSpeeds, [0.5, 0.75, 1.0, 1.25, 1.5, 2.0]);
    expect(SettingsPrefs.audioSpeeds.reduce((a, b) => a > b ? a : b), 2.0);
  });

  test('labels', () {
    expect(SettingsPrefs.audioSpeeds.map(speedLabel), [
      '0.5×',
      '0.75×',
      '1×',
      '1.25×',
      '1.5×',
      '2×',
    ]);
  });

  test('validSpeed accepts only offered speeds', () {
    expect(SettingsPrefs.validSpeed(1), 1.0);
    expect(SettingsPrefs.validSpeed(0.75), 0.75);
    expect(SettingsPrefs.validSpeed(3.0), isNull);
    expect(SettingsPrefs.validSpeed(2.5), isNull);
    expect(SettingsPrefs.validSpeed('2'), isNull);
    expect(SettingsPrefs.validSpeed(null), isNull);
  });

  test('defaults to normal speed and persists the choice', () async {
    final prefs = await SharedPreferences.getInstance();
    final bloc = SettingsBloc(prefs, countryCode: 'PK');
    addTearDown(bloc.close);
    expect(bloc.state.audioSpeed, 1.0);

    bloc.add(const UpdateAudioSpeed(0.75));
    await bloc.stream.firstWhere((s) => s.audioSpeed == 0.75);
    expect(prefs.getDouble(SettingsPrefs.audioSpeed), 0.75);

    final reloaded = SettingsBloc(prefs, countryCode: 'PK');
    addTearDown(reloaded.close);
    expect(reloaded.state.audioSpeed, 0.75);
  });

  test('ignores speeds above the cap', () async {
    final prefs = await SharedPreferences.getInstance();
    final bloc = SettingsBloc(prefs, countryCode: 'PK');
    addTearDown(bloc.close);
    bloc.add(const UpdateAudioSpeed(3.0));
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.audioSpeed, 1.0);
    expect(prefs.getDouble(SettingsPrefs.audioSpeed), isNull);
  });

  test('a corrupted saved value falls back to 1x', () async {
    SharedPreferences.setMockInitialValues({SettingsPrefs.audioSpeed: 9.0});
    final prefs = await SharedPreferences.getInstance();
    final bloc = SettingsBloc(prefs, countryCode: 'PK');
    addTearDown(bloc.close);
    expect(bloc.state.audioSpeed, 1.0);
  });

  test('syncs through the cloud settings document', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(SettingsPrefs.audioSpeed, 1.5);
    expect(SettingsPrefs.toCloud(prefs)['audioSpeed'], 1.5);

    SharedPreferences.setMockInitialValues({});
    final other = await SharedPreferences.getInstance();
    await SettingsPrefs.applyCloud(other, {'audioSpeed': 1.5});
    expect(other.getDouble(SettingsPrefs.audioSpeed), 1.5);
    await SettingsPrefs.applyCloud(other, {'audioSpeed': 3});
    expect(other.getDouble(SettingsPrefs.audioSpeed), 1.5);
  });
}
