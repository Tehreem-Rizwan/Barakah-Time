import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/quran_repository.dart';
import '../../domain/entities/surah.dart';

// Events
abstract class QuranEvent {}
class LoadSurahs extends QuranEvent {}

// States
abstract class QuranState {}
class QuranInitial extends QuranState {}
class QuranLoading extends QuranState {}
class QuranLoaded extends QuranState {
  final List<Surah> surahs;
  QuranLoaded(this.surahs);
}
class QuranError extends QuranState {
  final String message;
  QuranError(this.message);
}

// BLoC
class QuranBloc extends Bloc<QuranEvent, QuranState> {
  final QuranRepository repository;

  QuranBloc(this.repository) : super(QuranInitial()) {
    on<LoadSurahs>((event, emit) async {
      emit(QuranLoading());
      try {
        final surahs = await repository.getSurahs();
        emit(QuranLoaded(surahs));
      } catch (e) {
        emit(QuranError(e.toString()));
      }
    });
  }
}
