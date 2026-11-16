/// Which third-party SDKs initialised successfully at startup.
///
/// `main()` sets these. Services check them before touching
/// `FirebaseAuth.instance` / `Supabase.instance`, which throw when their SDK
/// failed to initialise (e.g. `[core/no-app]`), so the rest of the app keeps
/// working offline/as a guest instead of hanging or crashing.
class AppInitStatus {
  AppInitStatus._();

  /// `Hive.initFlutter()` completed (caches degrade to no-ops otherwise,
  /// e.g. in unit tests).
  static bool hiveReady = false;

  static bool firebaseReady = false;
  static bool googleSignInReady = false;

  /// For tests.
  static void reset() {
    hiveReady = false;
    firebaseReady = false;
    googleSignInReady = false;
  }
}
