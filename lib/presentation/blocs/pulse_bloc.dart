import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/spiritual_pulse.dart';
import '../../data/repositories/spiritual_pulse_repository_impl.dart';

// Events
abstract class PulseEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadPulseData extends PulseEvent {}

// States
abstract class PulseState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PulseInitial extends PulseState {}
class PulseLoading extends PulseState {}
class PulseLoaded extends PulseState {
  final SpiritualPulseEntity pulse;
  PulseLoaded(this.pulse);
  @override
  List<Object?> get props => [pulse];
}
class PulseError extends PulseState {
  final String message;
  PulseError(this.message);
}

// BLoC
class PulseBloc extends Bloc<PulseEvent, PulseState> {
  final SpiritualPulseRepository repository;

  PulseBloc(this.repository) : super(PulseInitial()) {
    on<LoadPulseData>((event, emit) async {
      emit(PulseLoading());
      try {
        final data = await repository.getPulseData();
        emit(PulseLoaded(data));
      } catch (e) {
        emit(PulseError(e.toString()));
      }
    });
  }
}
