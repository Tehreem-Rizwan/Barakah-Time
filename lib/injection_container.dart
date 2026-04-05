import 'package:barakah_time/data/datasources/remote/adhan_service.dart';
import 'package:barakah_time/domain/repositories/spiritual_pulse_repository.dart';
import 'package:barakah_time/presentation/blocs/auth_bloc.dart';
import 'package:barakah_time/presentation/blocs/settings_bloc.dart';
import 'package:barakah_time/data/repositories/saved_verses_repository_impl.dart';
import 'package:barakah_time/domain/repositories/saved_verses_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/repositories/prayer_repository_impl.dart';
import '../data/repositories/quran_repository.dart';
import '../data/repositories/spiritual_pulse_repository_impl.dart';
import '../domain/repositories/prayer_repository.dart';
import '../presentation/blocs/prayer_bloc.dart';
import '../presentation/blocs/pulse_bloc.dart';
import '../presentation/blocs/quran_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Blocs
  sl.registerFactory(() => PrayerBloc(sl()));
  sl.registerFactory(
    () => PulseBloc(repository: sl(), savedVersesRepository: sl()),
  );
  sl.registerFactory(() => QuranBloc(sl()));
  sl.registerFactory(() => AuthBloc(sl()));
  sl.registerFactory(() => SettingsBloc(sl()));

  // Repositories
  sl.registerLazySingleton<PrayerRepository>(() => PrayerRepositoryImpl(sl()));
  sl.registerLazySingleton<SpiritualPulseRepository>(
    () => SpiritualPulseRepositoryImpl(),
  );
  sl.registerLazySingleton<SavedVersesRepository>(() => SavedVersesRepositoryImpl());
  sl.registerLazySingleton(() => QuranRepository());

  // External & Services
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => AdhanService());
}
