import 'package:shared_preferences/shared_preferences.dart';

import 'app_init_status.dart';
import 'firebase_service.dart';

/// Where the splash screen should send the user.
enum AppEntryRoute { onboarding, main }

/// SharedPreferences keys shared by onboarding/guest flows.
class EntryPrefsKeys {
  EntryPrefsKeys._();
  static const hasSeenOnboarding = 'has_seen_onboarding';
  static const guestMode = 'guest_mode';
}

/// Pure routing decision (unit-tested).
///
/// Signing in is optional: the whole app works without an account, so the
/// only screen shown before the app is onboarding on first launch. Sign-in
/// lives in Profile / Settings for people who want to back up their data.
///
/// * signed in → main (even on a fresh install that restored a session)
/// * first launch → onboarding
/// * otherwise → main
AppEntryRoute decideEntryRoute({
  required bool firebaseReady,
  required bool signedIn,
  required bool hasSeenOnboarding,
}) {
  if (firebaseReady && signedIn) return AppEntryRoute.main;
  if (!hasSeenOnboarding) return AppEntryRoute.onboarding;
  return AppEntryRoute.main;
}

/// Resolves the entry route for the splash page. Never throws.
Future<AppEntryRoute> resolveEntryRoute({
  SharedPreferences? prefs,
  FirebaseService? firebaseService,
}) async {
  SharedPreferences? p = prefs;
  try {
    p ??= await SharedPreferences.getInstance();
  } catch (_) {}
  final firebaseReady = AppInitStatus.firebaseReady;
  bool signedIn = false;
  if (firebaseReady) {
    try {
      signedIn = (firebaseService ?? FirebaseService()).currentUser != null;
    } catch (_) {}
  }
  return decideEntryRoute(
    firebaseReady: firebaseReady,
    signedIn: signedIn,
    hasSeenOnboarding: p?.getBool(EntryPrefsKeys.hasSeenOnboarding) ?? false,
  );
}
