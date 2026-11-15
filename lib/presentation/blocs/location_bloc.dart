import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../core/services/location_service.dart';

// Events
abstract class LocationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Fetches the GPS location. Only dispatch in automatic-location mode.
class FetchLocation extends LocationEvent {
  final bool forceRefresh;
  FetchLocation({this.forceRefresh = false});
  @override
  List<Object?> get props => [forceRefresh];
}

/// Uses a manually configured location (never touches GPS).
class UpdateLocationManually extends LocationEvent {
  final double latitude;
  final double longitude;
  final String city;

  UpdateLocationManually({
    required this.latitude,
    required this.longitude,
    required this.city,
  });

  @override
  List<Object?> get props => [latitude, longitude, city];
}

// States
abstract class LocationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LocationInitial extends LocationState {}

class LocationLoading extends LocationState {}

class LocationLoaded extends LocationState {
  final double latitude;
  final double longitude;
  final String city;
  final String country;
  final bool isManual;

  LocationLoaded({
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.country,
    this.isManual = false,
  });

  /// "City, Country" (or just the non-empty part). Empty when the place is
  /// unknown — show the localized `unknown_city` text then.
  String get displayName =>
      [city, country].where((s) => s.trim().isNotEmpty).join(', ');

  bool get isPlaceUnknown => displayName.isEmpty;

  @override
  List<Object?> get props => [latitude, longitude, city, country, isManual];
}

class LocationError extends LocationState {
  final String message;
  final LocationFailure failure;
  LocationError(this.message, {this.failure = LocationFailure.unknown});

  @override
  List<Object?> get props => [message, failure];
}

// BLoC
class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final LocationService _locationService;

  /// Incremented per request so a slow GPS fetch can't overwrite a manual
  /// location chosen in the meantime.
  int _request = 0;

  LocationBloc(this._locationService) : super(LocationInitial()) {
    on<FetchLocation>((event, emit) async {
      final request = ++_request;
      emit(LocationLoading());
      try {
        final position = await _locationService.getCurrentPosition(
          forceRefresh: event.forceRefresh,
        );
        final place = await _locationService.getPlace(
          position.latitude,
          position.longitude,
        );
        if (request != _request) return;
        emit(
          LocationLoaded(
            latitude: position.latitude,
            longitude: position.longitude,
            city: place.city,
            country: place.country,
          ),
        );
      } on LocationException catch (e) {
        if (request != _request) return;
        emit(LocationError(e.message, failure: e.failure));
      } catch (e) {
        if (request != _request) return;
        emit(LocationError(e.toString()));
      }
    });

    on<UpdateLocationManually>((event, emit) {
      ++_request;
      emit(
        LocationLoaded(
          latitude: event.latitude,
          longitude: event.longitude,
          city: event.city,
          country: '',
          isManual: true,
        ),
      );
    });
  }
}
