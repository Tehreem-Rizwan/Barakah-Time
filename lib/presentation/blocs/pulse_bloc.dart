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

/// Logs [activity]. A no-op if an activity with the same id already exists.
/// [onResult] (optional) receives true if it was stored, false if duplicate
/// or failed.
class LogActivity extends PulseEvent {
  final SpiritualActivity activity;
  final void Function(bool added)? onResult;
  LogActivity(this.activity, {this.onResult});
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

  /// Activities logged today (used e.g. to show which prayers are done).
  final List<SpiritualActivity> todayActivities;

  /// Last non-fatal error (data above is still valid). Null when none.
  final String? error;

  PulseLoaded({
    required this.pulse,
    this.savedVerses = const [],
    this.todayActivities = const [],
    this.error,
  });

  bool isPrayerLoggedToday(String subType) =>
      todayActivities.any((a) => a.type == 'prayer' && a.subType == subType);

  PulseLoaded copyWith({String? error, bool clearError = false}) => PulseLoaded(
    pulse: pulse,
    savedVerses: savedVerses,
    todayActivities: todayActivities,
    error: clearError ? null : (error ?? this.error),
  );

  @override
  List<Object?> get props => [pulse, savedVerses, todayActivities, error];
}

class PulseError extends PulseState {
  final String message;
  PulseError(this.message);
  @override
  List<Object?> get props => [message];
}

/// Processes events one at a time, in order.
EventTransformer<E> _sequential<E>() =>
    (events, mapper) => events.asyncExpand(mapper);

// BLoC
class PulseBloc extends Bloc<PulseEvent, PulseState> {
  final SpiritualPulseRepository repository;
  final SavedVersesRepository savedVersesRepository;

  PulseBloc({required this.repository, required this.savedVersesRepository})
    : super(PulseInitial()) {
    on<LogActivity>(_onLogActivity, transformer: _sequential());
    on<LoadPulseData>(_onLoad, transformer: _sequential());
    on<LoadSavedVerses>(_onLoadSavedVerses, transformer: _sequential());
    on<ToggleSaveVerse>(_onToggleSaveVerse, transformer: _sequential());
  }

  Future<void> _onLogActivity(
    LogActivity event,
    Emitter<PulseState> emit,
  ) async {
    bool added = false;
    try {
      added = await repository.logActivity(event.activity);
      if (added) await _reload(emit);
    } catch (e) {
      _emitError(emit, e);
    }
    event.onResult?.call(added);
  }

  Future<void> _onLoad(LoadPulseData event, Emitter<PulseState> emit) async {
    if (state is! PulseLoaded) emit(PulseLoading());
    try {
      await _reload(emit);
    } catch (e) {
      _emitError(emit, e);
    }
  }

  Future<void> _onLoadSavedVerses(
    LoadSavedVerses event,
    Emitter<PulseState> emit,
  ) => _onLoad(LoadPulseData(), emit);

  Future<void> _onToggleSaveVerse(
    ToggleSaveVerse event,
    Emitter<PulseState> emit,
  ) async {
    try {
      final isSaved = await savedVersesRepository.isVerseSaved(event.verse.id);
      if (isSaved) {
        await savedVersesRepository.deleteVerse(event.verse.id);
      } else {
        await savedVersesRepository.saveVerse(event.verse);
      }
      await _reload(emit);
    } catch (e) {
      _emitError(emit, e);
    }
  }

  /// Reloads data and emits it in place (no loading state => no flicker).
  Future<void> _reload(Emitter<PulseState> emit) async {
    final data = await repository.getPulseData();
    final saved = await savedVersesRepository.getSavedVerses();
    final today = await repository.getActivitiesOn(DateTime.now());
    emit(PulseLoaded(pulse: data, savedVerses: saved, todayActivities: today));
  }

  /// Keeps previously loaded data and surfaces the error via a field.
  void _emitError(Emitter<PulseState> emit, Object e) {
    final current = state;
    if (current is PulseLoaded) {
      emit(current.copyWith(error: e.toString()));
    } else {
      emit(PulseError(e.toString()));
    }
  }
}
