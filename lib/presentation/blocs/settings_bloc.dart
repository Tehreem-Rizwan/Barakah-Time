import 'dart:async';
import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/user_data_sync_service.dart';
import '../../core/utils/calculation_methods.dart';
import '../../data/datasources/local/settings_prefs.dart';
import '../../domain/entities/prayer_times.dart';

typedef Geocoder =
    Future<({double latitude, double longitude})?> Function(String query);

// Events
abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {}

class ToggleLocationMode extends SettingsEvent {
  final bool useAuto;
  const ToggleLocationMode(this.useAuto);
  @override
  List<Object?> get props => [useAuto];
}

/// Geocodes [location] and, on success, stores it with its coordinates.
/// On failure, [SettingsState.locationError] is set and the previous manual
/// location is kept.
/// With [switchToManual], manual mode is turned on only after the lookup
/// succeeds, so a failed lookup never leaves stale coordinates in use.
class UpdateManualLocation extends SettingsEvent {
  final String location;
  final bool switchToManual;
  const UpdateManualLocation(this.location, {this.switchToManual = false});
  @override
  List<Object?> get props => [location, switchToManual];
}

class UpdateCalculationMethod extends SettingsEvent {
  final String method;
  const UpdateCalculationMethod(this.method);
  @override
  List<Object?> get props => [method];
}

/// [madhab] is 'shafi' or 'hanafi' (see [AsrMadhab]).
class UpdateMadhab extends SettingsEvent {
  final String madhab;
  const UpdateMadhab(this.madhab);
  @override
  List<Object?> get props => [madhab];
}

class ToggleNotifications extends SettingsEvent {
  final bool enabled;
  const ToggleNotifications(this.enabled);
  @override
  List<Object?> get props => [enabled];
}

/// Plays the adhan (instead of the default sound) for prayer reminders.
class ToggleAdhanSound extends SettingsEvent {
  final bool enabled;
  const ToggleAdhanSound(this.enabled);
  @override
  List<Object?> get props => [enabled];
}

/// Dispatch on app resume: turns reminders off if the OS permission was
/// revoked in system settings.
class RecheckNotificationPermission extends SettingsEvent {
  const RecheckNotificationPermission();
}

class UpdateQuranFontSize extends SettingsEvent {
  final double fontSize;
  const UpdateQuranFontSize(this.fontSize);
  @override
  List<Object?> get props => [fontSize];
}

class UpdateLanguage extends SettingsEvent {
  final String languageCode;
  const UpdateLanguage(this.languageCode);
  @override
  List<Object?> get props => [languageCode];
}

// State
class SettingsState extends Equatable {
  static const String defaultManualLocation = 'Karachi, Pakistan';
  static const double defaultManualLatitude = 24.8607;
  static const double defaultManualLongitude = 67.0011;

  final String calculationMethod;
  final double quranFontSize;
  final bool useAutoLocation;
  final String manualLocation;
  final double manualLatitude;
  final double manualLongitude;
  final String languageCode;
  final bool notificationsEnabled;

  /// Prayer reminders play the adhan (true) or the default sound.
  final bool adhanSoundEnabled;

  /// Asr madhab explicitly chosen by the user, or null to use the method's
  /// default. Read [asrMadhab] for the effective value.
  final String? customAsrMadhab;

  /// Set when the manual city could not be geocoded; cleared on success.
  final String? locationError;

  const SettingsState({
    this.calculationMethod = CalculationMethods.karachi,
    this.quranFontSize = 24.0,
    this.useAutoLocation = true,
    this.manualLocation = defaultManualLocation,
    this.manualLatitude = defaultManualLatitude,
    this.manualLongitude = defaultManualLongitude,
    this.languageCode = 'en',
    this.notificationsEnabled = false,
    this.adhanSoundEnabled = true,
    this.customAsrMadhab,
    this.locationError,
  });

  /// Effective Asr madhab: 'shafi' or 'hanafi'.
  String get asrMadhab =>
      customAsrMadhab ?? AsrMadhab.defaultFor(calculationMethod);

  SettingsState copyWith({
    String? calculationMethod,
    double? quranFontSize,
    bool? useAutoLocation,
    String? manualLocation,
    double? manualLatitude,
    double? manualLongitude,
    String? languageCode,
    bool? notificationsEnabled,
    bool? adhanSoundEnabled,
    String? customAsrMadhab,
    String? locationError,
    bool clearLocationError = false,
  }) {
    return SettingsState(
      calculationMethod: calculationMethod ?? this.calculationMethod,
      quranFontSize: quranFontSize ?? this.quranFontSize,
      useAutoLocation: useAutoLocation ?? this.useAutoLocation,
      manualLocation: manualLocation ?? this.manualLocation,
      manualLatitude: manualLatitude ?? this.manualLatitude,
      manualLongitude: manualLongitude ?? this.manualLongitude,
      languageCode: languageCode ?? this.languageCode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      adhanSoundEnabled: adhanSoundEnabled ?? this.adhanSoundEnabled,
      customAsrMadhab: customAsrMadhab ?? this.customAsrMadhab,
      locationError:
          clearLocationError ? null : (locationError ?? this.locationError),
    );
  }

  @override
  List<Object?> get props => [
    calculationMethod,
    quranFontSize,
    useAutoLocation,
    manualLocation,
    manualLatitude,
    manualLongitude,
    languageCode,
    notificationsEnabled,
    adhanSoundEnabled,
    customAsrMadhab,
    locationError,
  ];
}

// BLoC
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SharedPreferences prefs;
  final NotificationService? notificationService;
  final Geocoder? geocoder;

  /// Pushes settings to Firestore (debounced) when signed in.
  final UserDataSync? sync;
  final Duration syncDebounce;

  /// Region used to pick a default calculation method when none is saved;
  /// null = the device locale's country.
  final String? countryCode;

  Timer? _syncTimer;

  static const _kMethod = SettingsPrefs.method;
  static const _kFontSize = SettingsPrefs.fontSize;
  static const _kUseAuto = SettingsPrefs.useAuto;
  static const _kManualLocation = SettingsPrefs.manualLocation;
  static const _kManualLat = SettingsPrefs.manualLat;
  static const _kManualLng = SettingsPrefs.manualLng;
  static const _kLanguage = SettingsPrefs.language;
  static const _kNotifications = SettingsPrefs.notifications;
  static const _kMadhab = SettingsPrefs.madhab;
  static const _kAdhanSound = SettingsPrefs.adhanSound;

  /// The initial state is read synchronously from [prefs] so that anything
  /// created at startup (e.g. prayer times) already sees saved settings.
  SettingsBloc(
    this.prefs, {
    this.notificationService,
    this.geocoder,
    this.sync,
    this.countryCode,
    this.syncDebounce = const Duration(seconds: 1),
  }) : super(readFromPrefs(prefs, countryCode: countryCode)) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateCalculationMethod>(_onUpdateCalculationMethod);
    on<UpdateMadhab>(_onUpdateMadhab);
    on<UpdateQuranFontSize>(_onUpdateQuranFontSize);
    on<ToggleLocationMode>(_onToggleLocationMode);
    on<UpdateManualLocation>(_onUpdateManualLocation);
    on<UpdateLanguage>(_onUpdateLanguage);
    on<ToggleNotifications>(_onToggleNotifications);
    on<ToggleAdhanSound>(_onToggleAdhanSound);
    on<RecheckNotificationPermission>(_onRecheckPermission);
  }

  /// Device region (e.g. 'PK'), or null.
  static String? deviceCountryCode({Duration? utcOffset}) {
    // Many phones in South Asia use "English (United States)", so the
    // locale alone would pick the North American method. The time zone is
    // a better hint for these regions.
    final fromZone = countryForUtcOffset(
      utcOffset ?? DateTime.now().timeZoneOffset,
    );
    if (fromZone != null) return fromZone;
    try {
      return PlatformDispatcher.instance.locale.countryCode;
    } catch (_) {
      return null;
    }
  }

  /// Country implied by a UTC offset where that is unambiguous enough to
  /// pick a calculation method: +5:00 Pakistan, +5:30 India, +6:00
  /// Bangladesh, +4:30 Afghanistan (all use the Karachi method).
  static String? countryForUtcOffset(Duration offset) => switch (offset
      .inMinutes) {
    300 => 'PK',
    330 => 'IN',
    360 => 'BD',
    270 => 'AF',
    _ => null,
  };

  /// Calculation method when the user hasn't chosen one.
  static String defaultMethodFor(String? countryCode) =>
      CalculationMethods.defaultForCountry(countryCode ?? deviceCountryCode());

  static SettingsState readFromPrefs(
    SharedPreferences prefs, {
    String? countryCode,
  }) {
    final madhab = prefs.getString(_kMadhab);
    final savedMethod = prefs.getString(_kMethod);
    return SettingsState(
      calculationMethod:
          CalculationMethods.isKnown(savedMethod)
              ? savedMethod!
              : defaultMethodFor(countryCode),
      quranFontSize: prefs.getDouble(_kFontSize) ?? 24.0,
      useAutoLocation: prefs.getBool(_kUseAuto) ?? true,
      manualLocation:
          prefs.getString(_kManualLocation) ??
          SettingsState.defaultManualLocation,
      manualLatitude:
          prefs.getDouble(_kManualLat) ?? SettingsState.defaultManualLatitude,
      manualLongitude:
          prefs.getDouble(_kManualLng) ?? SettingsState.defaultManualLongitude,
      languageCode: prefs.getString(_kLanguage) ?? 'en',
      notificationsEnabled: prefs.getBool(_kNotifications) ?? false,
      adhanSoundEnabled: prefs.getBool(_kAdhanSound) ?? true,
      customAsrMadhab:
          (madhab == AsrMadhab.hanafi || madhab == AsrMadhab.shafi)
              ? madhab
              : null,
    );
  }

  /// Schedules a debounced push of all persisted settings to the cloud.
  void _scheduleCloudPush() {
    final s = sync;
    if (s == null || s.currentUid == null) return;
    _syncTimer?.cancel();
    _syncTimer = Timer(syncDebounce, () {
      s.pushSettings(SettingsPrefs.toCloud(prefs));
    });
  }

  @override
  void onChange(Change<SettingsState> change) {
    super.onChange(change);
    // Each user change is persisted to prefs around its emit; one debounced
    // push sends the persisted values. Re-reading prefs (LoadSettings, e.g.
    // right after a cloud pull) must not push back, hence the flag.
    if (_pushOnChange) _scheduleCloudPush();
  }

  /// False while LoadSettings emits.
  bool _pushOnChange = true;

  @override
  Future<void> close() {
    _syncTimer?.cancel();
    return super.close();
  }

  void _onLoadSettings(LoadSettings event, Emitter<SettingsState> emit) {
    _pushOnChange = false;
    emit(
      readFromPrefs(
        prefs,
        countryCode: countryCode,
      ).copyWith(locationError: state.locationError),
    );
    _pushOnChange = true;
    // Older versions stored a manual city without coordinates: geocode it.
    final storedCity = prefs.getString(_kManualLocation);
    if (storedCity != null &&
        storedCity != SettingsState.defaultManualLocation &&
        prefs.getDouble(_kManualLat) == null) {
      add(UpdateManualLocation(storedCity));
    }
  }

  Future<void> _onUpdateCalculationMethod(
    UpdateCalculationMethod event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(calculationMethod: event.method));
    await prefs.setString(_kMethod, event.method);
  }

  Future<void> _onUpdateMadhab(
    UpdateMadhab event,
    Emitter<SettingsState> emit,
  ) async {
    final m = event.madhab.toLowerCase();
    if (m != AsrMadhab.hanafi && m != AsrMadhab.shafi) return;
    emit(state.copyWith(customAsrMadhab: m));
    await prefs.setString(_kMadhab, m);
  }

  Future<void> _onUpdateQuranFontSize(
    UpdateQuranFontSize event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(quranFontSize: event.fontSize));
    await prefs.setDouble(_kFontSize, event.fontSize);
  }

  Future<void> _onToggleLocationMode(
    ToggleLocationMode event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(useAutoLocation: event.useAuto));
    await prefs.setBool(_kUseAuto, event.useAuto);
  }

  Future<void> _onUpdateManualLocation(
    UpdateManualLocation event,
    Emitter<SettingsState> emit,
  ) async {
    final city = event.location.trim();
    final l10n = AppLocalizations(Locale(state.languageCode));
    String notFound() =>
        l10n.translate('location_not_found').replaceAll('{city}', city);

    // Clear any previous error first so a repeated failure is a new state
    // change that listeners can react to.
    if (state.locationError != null) {
      emit(state.copyWith(clearLocationError: true));
    }
    if (city.isEmpty || geocoder == null) {
      emit(state.copyWith(locationError: notFound()));
      return;
    }
    final result = await geocoder!(city);
    if (result == null) {
      emit(state.copyWith(locationError: notFound()));
      return;
    }
    emit(
      state.copyWith(
        manualLocation: city,
        manualLatitude: result.latitude,
        manualLongitude: result.longitude,
        useAutoLocation: event.switchToManual ? false : null,
        clearLocationError: true,
      ),
    );
    await prefs.setString(_kManualLocation, city);
    await prefs.setDouble(_kManualLat, result.latitude);
    await prefs.setDouble(_kManualLng, result.longitude);
    if (event.switchToManual) await prefs.setBool(_kUseAuto, false);
  }

  Future<void> _onUpdateLanguage(
    UpdateLanguage event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(languageCode: event.languageCode));
    await prefs.setString(_kLanguage, event.languageCode);
  }

  Future<void> _onToggleNotifications(
    ToggleNotifications event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(notificationsEnabled: event.enabled));
    if (!event.enabled) {
      await prefs.setBool(_kNotifications, false);
      await notificationService?.cancelAll();
      return;
    }
    final granted = await notificationService?.requestPermission() ?? false;
    if (!granted) {
      emit(state.copyWith(notificationsEnabled: false));
      await prefs.setBool(_kNotifications, false);
      return;
    }
    await prefs.setBool(_kNotifications, true);
    // Android 12+: ask for exact alarms (opens a system screen when not yet
    // allowed). Reminders still work, inexactly, if the user declines.
    await notificationService?.requestExactAlarmsPermission();
  }

  Future<void> _onToggleAdhanSound(
    ToggleAdhanSound event,
    Emitter<SettingsState> emit,
  ) async {
    await prefs.setBool(_kAdhanSound, event.enabled);
    emit(state.copyWith(adhanSoundEnabled: event.enabled));
  }

  Future<void> _onRecheckPermission(
    RecheckNotificationPermission event,
    Emitter<SettingsState> emit,
  ) async {
    final service = notificationService;
    if (!state.notificationsEnabled || service == null) return;
    if (await service.arePermissionsGranted()) return;
    await prefs.setBool(_kNotifications, false);
    emit(state.copyWith(notificationsEnabled: false));
    await service.cancelAll();
  }
}
