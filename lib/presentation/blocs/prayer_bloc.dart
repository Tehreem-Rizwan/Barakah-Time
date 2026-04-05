import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/entities/prayer_times.dart';
import '../../domain/repositories/prayer_repository.dart';

// Events
abstract class PrayerEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadPrayerTimesWithLocation extends PrayerEvent {
  final String method;
  final double? latitude;
  final double? longitude;
  LoadPrayerTimesWithLocation({this.method = 'Karachi', this.latitude, this.longitude});
  @override
  List<Object?> get props => [method, latitude, longitude];
}

class LoadPrayerTimes extends PrayerEvent {
  final double latitude;
  final double longitude;
  final String method;
  LoadPrayerTimes(this.latitude, this.longitude, {this.method = 'Karachi'});
  @override
  List<Object?> get props => [latitude, longitude, method];
}

// States
abstract class PrayerState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PrayerInitial extends PrayerState {}

class PrayerLoading extends PrayerState {}

class PrayerLoaded extends PrayerState {
  final PrayerTimesEntity prayerTimes;
  PrayerLoaded(this.prayerTimes);
  @override
  List<Object?> get props => [prayerTimes];
}

class PrayerError extends PrayerState {
  final String message;
  PrayerError(this.message);
}

// BLoC
class PrayerBloc extends Bloc<PrayerEvent, PrayerState> {
  final PrayerRepository repository;

  PrayerBloc(this.repository) : super(PrayerInitial()) {
    on<LoadPrayerTimes>((event, emit) async {
      emit(PrayerLoading());
      try {
        final times = await repository.getPrayerTimes(
          event.latitude,
          event.longitude,
          method: event.method,
        );
        emit(PrayerLoaded(times));
      } catch (e) {
        emit(PrayerError(e.toString()));
      }
    });

    on<LoadPrayerTimesWithLocation>((event, emit) async {
      emit(PrayerLoading());
      try {
        double lat, lng;
        if (event.latitude != null && event.longitude != null) {
          lat = event.latitude!;
          lng = event.longitude!;
        } else {
          bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
          if (!serviceEnabled) {
            throw Exception('Location services are disabled.');
          }

          LocationPermission permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
            if (permission == LocationPermission.denied) {
              throw Exception('Location permissions are denied');
            }
          }

          if (permission == LocationPermission.deniedForever) {
            throw Exception('Location permissions are permanently denied');
          }

          final position = await Geolocator.getCurrentPosition();
          lat = position.latitude;
          lng = position.longitude;
        }

        final times = await repository.getPrayerTimes(
          lat,
          lng,
          method: event.method,
        );
        emit(PrayerLoaded(times));
      } catch (e) {
        emit(PrayerError(e.toString()));
      }
    });
  }
}
