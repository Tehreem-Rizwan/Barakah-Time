import 'package:barakah_time/data/datasources/remote/adhan_service.dart';
import 'package:get_it/get_it.dart';

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
  sl.registerFactory(() => PulseBloc(sl()));
  sl.registerFactory(() => QuranBloc(sl()));

  // Repositories
  sl.registerLazySingleton<PrayerRepository>(() => PrayerRepositoryImpl(sl()));
  sl.registerLazySingleton<SpiritualPulseRepository>(
    () => MockSpiritualPulseRepository(),
  );
  sl.registerLazySingleton(() => QuranRepository());

  // Data Sources
  sl.registerLazySingleton(() => AdhanService());
}
