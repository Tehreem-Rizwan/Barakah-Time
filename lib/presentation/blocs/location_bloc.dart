import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/services/location_service.dart';

// Events
abstract class LocationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchLocation extends LocationEvent {}

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

  LocationLoaded({
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.country,
  });

  @override
  List<Object?> get props => [latitude, longitude, city, country];
}

class LocationError extends LocationState {
  final String message;
  LocationError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final LocationService _locationService;

  LocationBloc(this._locationService) : super(LocationInitial()) {
    on<FetchLocation>((event, emit) async {
      emit(LocationLoading());
      try {
        final position = await _locationService.getCurrentPosition();
        final city = await _locationService.getCityFromPosition(position);
        final country = await _locationService.getCountryFromPosition(position);
        
        emit(LocationLoaded(
          latitude: position.latitude,
          longitude: position.longitude,
          city: city,
          country: country,
        ));
      } catch (e) {
        emit(LocationError(e.toString()));
      }
    });

    on<UpdateLocationManually>((event, emit) {
      emit(LocationLoaded(
        latitude: event.latitude,
        longitude: event.longitude,
        city: event.city,
        country: 'Manual',
      ));
    });
  }
}
