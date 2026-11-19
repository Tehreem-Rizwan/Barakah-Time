import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../core/services/location_service.dart';
import '../../domain/entities/prayer_times.dart';
import '../../domain/repositories/prayer_repository.dart';
import 'settings_bloc.dart';

/// Everything that determines which prayer times are shown. Always derive it
/// from [SettingsState] so there is a single source of truth.
class PrayerConfig extends Equatable {
  final String method;
  final String madhab;
  final bool useAutoLocation;
  final double manualLatitude;
  final double manualLongitude;

  /// Per-prayer minute offsets (see [SettingsState.prayerOffsets]).
  final Map<String, int> offsets;

  const PrayerConfig({
    required this.method,
    required this.madhab,
    required this.useAutoLocation,
    required this.manualLatitude,
    required this.manualLongitude,
    this.offsets = const {},
  });

  factory PrayerConfig.fromSettings(SettingsState s) => PrayerConfig(
    method: s.calculationMethod,
    madhab: s.asrMadhab,
    useAutoLocation: s.useAutoLocation,
    manualLatitude: s.manualLatitude,
    manualLongitude: s.manualLongitude,
    offsets: s.prayerOffsets,
  );

  @override
  List<Object?> get props => [
    method,
    madhab,
    useAutoLocation,
    manualLatitude,
    manualLongitude,
    offsets,
  ];
}

// Events
abstract class PrayerEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Loads prayer times for [config]. In auto mode the GPS position is used
/// (shared/cached via [LocationService]); in manual mode GPS is never touched.
class LoadPrayerTimes extends PrayerEvent {
  final PrayerConfig config;
  final bool forceLocationRefresh;
  LoadPrayerTimes(this.config, {this.forceLocationRefresh = false});
  @override
  List<Object?> get props => [config, forceLocationRefresh];
}

/// Recomputes times for the last config and coordinates (e.g. at midnight)
/// without showing a loading state or requesting GPS again.
class RefreshPrayerTimes extends PrayerEvent {}

// States
abstract class PrayerState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PrayerInitial extends PrayerState {}

class PrayerLoading extends PrayerState {}

class PrayerLoaded extends PrayerState {
  final PrayerTimesEntity prayerTimes;
  final double latitude;
  final double longitude;
  PrayerLoaded(
    this.prayerTimes, {
    required this.latitude,
    required this.longitude,
  });
  @override
  List<Object?> get props => [prayerTimes, latitude, longitude];
}

class PrayerError extends PrayerState {
  final String message;

  /// Set when the failure was about GPS/permissions.
  final LocationFailure? locationFailure;
  PrayerError(this.message, {this.locationFailure});
  @override
  List<Object?> get props => [message, locationFailure];
}

// BLoC
class PrayerBloc extends Bloc<PrayerEvent, PrayerState> {
  final PrayerRepository repository;
  final LocationService locationService;
  final DateTime Function() _clock;

  PrayerConfig? _config;
  double? _lat;
  double? _lng;
  int _request = 0;
  Timer? _midnightTimer;

  PrayerBloc(
    this.repository,
    this.locationService, {
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now,
       super(PrayerInitial()) {
    on<LoadPrayerTimes>(_onLoad);
    on<RefreshPrayerTimes>(_onRefresh);
  }

  PrayerConfig? get config => _config;

  Future<void> _onLoad(LoadPrayerTimes event, Emitter<PrayerState> emit) async {
    final request = ++_request;
    _config = event.config;
    emit(PrayerLoading());
    try {
      double lat, lng;
      if (event.config.useAutoLocation) {
        final position = await locationService.getCurrentPosition(
          forceRefresh: event.forceLocationRefresh,
        );
        lat = position.latitude;
        lng = position.longitude;
      } else {
        lat = event.config.manualLatitude;
        lng = event.config.manualLongitude;
      }
      final times = await repository.getPrayerTimes(
        lat,
        lng,
        method: event.config.method,
        madhab: event.config.madhab,
        offsets: event.config.offsets,
      );
      if (request != _request) return; // superseded by a newer load
      _lat = lat;
      _lng = lng;
      emit(PrayerLoaded(times, latitude: lat, longitude: lng));
      _scheduleMidnightRefresh();
    } on LocationException catch (e) {
      if (request != _request) return;
      emit(PrayerError(e.message, locationFailure: e.failure));
    } catch (e) {
      if (request != _request) return;
      emit(PrayerError(e.toString()));
    }
  }

  Future<void> _onRefresh(
    RefreshPrayerTimes event,
    Emitter<PrayerState> emit,
  ) async {
    final config = _config;
    if (config == null) return;
    final lat = _lat, lng = _lng;
    final current = state;
    // Resuming after the permission dialog (or with a load still running)
    // must not ask again: a denied permission is retried only via Retry.
    if (current is PrayerLoading ||
        (current is PrayerError && current.locationFailure != null)) {
      return;
    }
    if (lat == null || lng == null || current is! PrayerLoaded) {
      add(LoadPrayerTimes(config));
      return;
    }
    final now = _clock();
    final today = DateTime(now.year, now.month, now.day);
    if (current.prayerTimes.date == today) return; // already up to date
    final request = ++_request;
    try {
      final times = await repository.getPrayerTimes(
        lat,
        lng,
        method: config.method,
        madhab: config.madhab,
        offsets: config.offsets,
      );
      if (request != _request) return;
      emit(PrayerLoaded(times, latitude: lat, longitude: lng));
      _scheduleMidnightRefresh();
    } catch (_) {
      // Keep showing the previous data; the next tick will retry.
    }
  }

  void _scheduleMidnightRefresh() {
    _midnightTimer?.cancel();
    final now = _clock();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    _midnightTimer = Timer(
      nextMidnight.difference(now) + const Duration(seconds: 1),
      () {
        if (!isClosed) add(RefreshPrayerTimes());
      },
    );
  }

  @override
  Future<void> close() {
    _midnightTimer?.cancel();
    return super.close();
  }
}
