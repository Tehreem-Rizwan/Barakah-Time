import 'package:barakah_time/domain/entities/saved_verse.dart';
import 'package:barakah_time/domain/entities/spiritual_activity.dart';
import 'package:barakah_time/domain/entities/spiritual_pulse.dart';
import 'package:barakah_time/domain/repositories/saved_verses_repository.dart';
import 'package:barakah_time/domain/repositories/spiritual_pulse_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class PulseEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadPulseData extends PulseEvent {}

class LogActivity extends PulseEvent {
  final SpiritualActivity activity;
  LogActivity(this.activity);
  @override
  List<Object?> get props => [activity];
}

class LoadSavedVerses extends PulseEvent {}

class ToggleSaveVerse extends PulseEvent {
  final SavedVerse verse;
  ToggleSaveVerse(this.verse);
  @override
  List<Object?> get props => [verse];
}

// States
abstract class PulseState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PulseInitial extends PulseState {}

class PulseLoading extends PulseState {}

class PulseLoaded extends PulseState {
  final SpiritualPulseEntity pulse;
  final List<SavedVerse> savedVerses;
  PulseLoaded({required this.pulse, this.savedVerses = const []});
  @override
  List<Object?> get props => [pulse, savedVerses];
}

class PulseError extends PulseState {
  final String message;
  PulseError(this.message);
}

// BLoC
class PulseBloc extends Bloc<PulseEvent, PulseState> {
  final SpiritualPulseRepository repository;
  final SavedVersesRepository savedVersesRepository;

  PulseBloc({required this.repository, required this.savedVersesRepository})
    : super(PulseInitial()) {
    on<LogActivity>((event, emit) async {
      try {
        await repository.logActivity(event.activity);
        add(LoadPulseData());
      } catch (e) {
        emit(PulseError(e.toString()));
      }
    });

    on<LoadPulseData>((event, emit) async {
      final currentState = state;
      List<SavedVerse> currentSaved = [];
      if (currentState is PulseLoaded) {
        currentSaved = currentState.savedVerses;
      }

      emit(PulseLoading());
      try {
        final data = await repository.getPulseData();
        final saved = await savedVersesRepository.getSavedVerses();
        emit(PulseLoaded(pulse: data, savedVerses: saved));
      } catch (e) {
        emit(PulseError(e.toString()));
      }
    });

    on<ToggleSaveVerse>((event, emit) async {
      try {
        final isSaved = await savedVersesRepository.isVerseSaved(
          event.verse.id,
        );
        if (isSaved) {
          await savedVersesRepository.deleteVerse(event.verse.id);
        } else {
          await savedVersesRepository.saveVerse(event.verse);
        }
        add(LoadPulseData());
      } catch (e) {
        emit(PulseError(e.toString()));
      }
    });
  }
}
