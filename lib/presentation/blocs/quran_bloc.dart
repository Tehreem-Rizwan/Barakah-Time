import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/quran_repository.dart';
import '../../domain/entities/surah.dart';

// Events
abstract class QuranEvent {}

/// Loads the surah list (cache first). [forceRefresh] is for
/// pull-to-refresh. [languageCode] (optional) selects the translation
/// edition exposed as [QuranLoaded.translationEdition].
class LoadSurahs extends QuranEvent {
  final bool forceRefresh;
  final String? languageCode;
  LoadSurahs({this.forceRefresh = false, this.languageCode});
}

/// Changes the translation language without reloading the list.
class ChangeQuranLanguage extends QuranEvent {
  final String languageCode;
  ChangeQuranLanguage(this.languageCode);
}

// States
abstract class QuranState {}

class QuranInitial extends QuranState {}

class QuranLoading extends QuranState {}

class QuranLoaded extends QuranState {
  final List<Surah> surahs;

  /// True when a refresh failed and [surahs] is the previously loaded list.
  final bool refreshFailed;

  /// alquran.cloud edition to pass to
  /// `QuranRepository.getSurahWithTranslation(n, translationEdition: ...)`.
  final String translationEdition;

  QuranLoaded(
    this.surahs, {
    this.refreshFailed = false,
    this.translationEdition = QuranRepository.defaultTranslationEdition,
  });
}

/// Load failed. [message] is technical detail for logging only; the UI shows
/// a localized, friendly message and a Retry button.
class QuranError extends QuranState {
  final String message;
  QuranError(this.message);
}

// BLoC
class QuranBloc extends Bloc<QuranEvent, QuranState> {
  final QuranRepository repository;

  String _edition = QuranRepository.defaultTranslationEdition;

  /// Current translation edition (see [QuranRepository.translationEditionFor]).
  String get translationEdition => _edition;

  QuranBloc(this.repository) : super(QuranInitial()) {
    on<LoadSurahs>((event, emit) async {
      if (event.languageCode != null) {
        _edition = QuranRepository.translationEditionFor(event.languageCode!);
      }
      // Keep showing an already-loaded list during a pull-to-refresh.
      if (state is! QuranLoaded) emit(QuranLoading());
      try {
        final surahs = await repository.getSurahs(
          forceRefresh: event.forceRefresh,
        );
        emit(QuranLoaded(surahs, translationEdition: _edition));
      } catch (e) {
        debugPrint('Quran load failed: $e');
        final current = state;
        if (current is QuranLoaded) {
          // Keep stale data on refresh error, but let the UI know.
          emit(
            QuranLoaded(
              current.surahs,
              refreshFailed: true,
              translationEdition: _edition,
            ),
          );
          return;
        }
        emit(QuranError(e.toString().replaceFirst('Exception: ', '')));
      }
    });

    on<ChangeQuranLanguage>((event, emit) {
      _edition = QuranRepository.translationEditionFor(event.languageCode);
      final current = state;
      if (current is QuranLoaded) {
        emit(QuranLoaded(current.surahs, translationEdition: _edition));
      }
    });
  }
}
