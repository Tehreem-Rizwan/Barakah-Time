import 'package:barakah_time/data/datasources/remote/adhan_service.dart';
import 'package:barakah_time/data/repositories/tasbeeh_repository.dart';
import 'package:barakah_time/data/repositories/qaza_repository.dart';
import 'package:barakah_time/core/services/home_widget_service.dart';
import 'package:barakah_time/core/services/geomagnetic_service.dart';
import 'package:barakah_time/core/services/ramadan_service.dart';
import 'package:barakah_time/core/services/memorial_reminder_service.dart';
import 'package:barakah_time/data/repositories/memorial_repository.dart';
import 'package:barakah_time/domain/repositories/spiritual_pulse_repository.dart';
import 'package:barakah_time/presentation/blocs/auth_bloc.dart';
import 'package:barakah_time/presentation/blocs/settings_bloc.dart';
import 'package:barakah_time/data/repositories/saved_verses_repository_impl.dart';
import 'package:barakah_time/domain/repositories/saved_verses_repository.dart';
import 'package:barakah_time/presentation/blocs/location_bloc.dart';
import 'package:barakah_time/core/services/location_service.dart';
import 'package:barakah_time/core/services/supabase_service.dart';
import 'package:barakah_time/core/services/firebase_service.dart';
import 'package:barakah_time/core/services/audio_service.dart';
import 'package:barakah_time/core/services/notification_service.dart';
import 'package:barakah_time/core/services/user_data_sync_service.dart';
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
  sl.registerFactory(
    () => AuthBloc(sl(), sl(), sl(), sync: sl<UserDataSyncService>()),
  );
  sl.registerFactory(() => PrayerBloc(sl(), sl()));
  sl.registerFactory(
    () => PulseBloc(repository: sl(), savedVersesRepository: sl()),
  );
  sl.registerFactory(() => QuranBloc(sl(), prefs: sl()));
  sl.registerFactory(
    () => SettingsBloc(
      sl(),
      notificationService: sl(),
      geocoder: sl<LocationService>().geocode,
      sync: sl<UserDataSyncService>(),
    ),
  );
  sl.registerFactory(() => LocationBloc(sl()));

  // Repositories
  sl.registerLazySingleton<PrayerRepository>(() => PrayerRepositoryImpl(sl()));
  sl.registerLazySingleton<SpiritualPulseRepository>(
    () => SpiritualPulseRepositoryImpl(sync: sl<UserDataSyncService>()),
  );
  sl.registerLazySingleton<SavedVersesRepository>(
    () => SavedVersesRepositoryImpl(sync: sl<UserDataSyncService>()),
  );
  sl.registerLazySingleton(() => QuranRepository());
  sl.registerLazySingleton(() => GeomagneticService());
  sl.registerLazySingleton(
    () => QazaRepository(sl(), sync: sl<UserDataSyncService>()),
  );
  sl.registerLazySingleton(
    () => TasbeehRepository(sl(), sync: sl<UserDataSyncService>()),
  );

  // External & Services (all resolve SDK instances lazily, so a failed
  // Firebase/Supabase init never breaks DI).
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => AdhanService());
  sl.registerLazySingleton(() => LocationService(prefs: sl()));
  sl.registerLazySingleton(
    () =>
        SupabaseService(idTokenProvider: () => sl<FirebaseService>().idToken()),
  );
  sl.registerLazySingleton(() => FirebaseService());
  sl.registerLazySingleton(() => UserDataSyncService(sl(), sl()));
  sl.registerLazySingleton(() => AudioService());
  sl.registerLazySingleton(() => NotificationService());
  sl.registerLazySingleton(() => HomeWidgetService());
  sl.registerLazySingleton(
    () => RamadanService(sl(), sync: sl<UserDataSyncService>()),
  );
  sl.registerLazySingleton(() => MemorialRepository());
  sl.registerLazySingleton(() => MemorialReminderService(sl()));
}
