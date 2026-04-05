import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class UpdateManualLocation extends SettingsEvent {
  final String location;
  const UpdateManualLocation(this.location);
  @override
  List<Object?> get props => [location];
}

class UpdateCalculationMethod extends SettingsEvent {
  final String method;
  const UpdateCalculationMethod(this.method);
  @override
  List<Object?> get props => [method];
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
  final String calculationMethod;
  final double quranFontSize;
  final bool useAutoLocation;
  final String manualLocation;
  final double manualLatitude;
  final double manualLongitude;
  final String languageCode;

  const SettingsState({
    this.calculationMethod = 'Karachi',
    this.quranFontSize = 24.0,
    this.useAutoLocation = true,
    this.manualLocation = 'Karachi, Pakistan',
    this.manualLatitude = 24.8607,
    this.manualLongitude = 67.0011,
    this.languageCode = 'en',
  });

  SettingsState copyWith({
    String? calculationMethod,
    double? quranFontSize,
    bool? useAutoLocation,
    String? manualLocation,
    double? manualLatitude,
    double? manualLongitude,
    String? languageCode,
  }) {
    return SettingsState(
      calculationMethod: calculationMethod ?? this.calculationMethod,
      quranFontSize: quranFontSize ?? this.quranFontSize,
      useAutoLocation: useAutoLocation ?? this.useAutoLocation,
      manualLocation: manualLocation ?? this.manualLocation,
      manualLatitude: manualLatitude ?? this.manualLatitude,
      manualLongitude: manualLongitude ?? this.manualLongitude,
      languageCode: languageCode ?? this.languageCode,
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
  ];
}

// BLoC
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SharedPreferences prefs;

  SettingsBloc(this.prefs) : super(const SettingsState()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateCalculationMethod>(_onUpdateCalculationMethod);
    on<UpdateQuranFontSize>(_onUpdateQuranFontSize);
    on<ToggleLocationMode>(_onToggleLocationMode);
    on<UpdateManualLocation>(_onUpdateManualLocation);
    on<UpdateLanguage>(_onUpdateLanguage);
  }

  void _onLoadSettings(LoadSettings event, Emitter<SettingsState> emit) {
    final method = prefs.getString('calculation_method') ?? 'Karachi';
    final fontSize = prefs.getDouble('quran_font_size') ?? 24.0;
    final useAuto = prefs.getBool('use_auto_location') ?? true;
    final manualLoc = prefs.getString('manual_location') ?? 'Karachi, Pakistan';
    final language = prefs.getString('language_code') ?? 'en';
    
    emit(SettingsState(
      calculationMethod: method,
      quranFontSize: fontSize,
      useAutoLocation: useAuto,
      manualLocation: manualLoc,
      languageCode: language,
    ));
  }

  Future<void> _onUpdateCalculationMethod(UpdateCalculationMethod event, Emitter<SettingsState> emit) async {
    await prefs.setString('calculation_method', event.method);
    emit(state.copyWith(calculationMethod: event.method));
  }

  Future<void> _onUpdateQuranFontSize(UpdateQuranFontSize event, Emitter<SettingsState> emit) async {
    await prefs.setDouble('quran_font_size', event.fontSize);
    emit(state.copyWith(quranFontSize: event.fontSize));
  }

  Future<void> _onToggleLocationMode(ToggleLocationMode event, Emitter<SettingsState> emit) async {
    await prefs.setBool('use_auto_location', event.useAuto);
    emit(state.copyWith(useAutoLocation: event.useAuto));
  }

  Future<void> _onUpdateManualLocation(UpdateManualLocation event, Emitter<SettingsState> emit) async {
    await prefs.setString('manual_location', event.location);
    // For demo purposes, we'll keep the default Karachi coords or just update the string.
    // In a real app, this would involve geocoding.
    emit(state.copyWith(manualLocation: event.location));
  }

  Future<void> _onUpdateLanguage(UpdateLanguage event, Emitter<SettingsState> emit) async {
    await prefs.setString('language_code', event.languageCode);
    emit(state.copyWith(languageCode: event.languageCode));
  }
}
