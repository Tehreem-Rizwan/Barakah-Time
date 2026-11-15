import 'package:shared_preferences/shared_preferences.dart';

import 'app_init_status.dart';
import 'firebase_service.dart';

/// Where the splash screen should send the user.
enum AppEntryRoute { onboarding, signIn, main }

/// SharedPreferences keys shared by onboarding/guest flows.
class EntryPrefsKeys {
  EntryPrefsKeys._();
  static const hasSeenOnboarding = 'has_seen_onboarding';
  static const guestMode = 'guest_mode';
}

/// Pure routing decision (unit-tested).
///
/// * signed in → main
/// * first launch → onboarding
/// * guest → main
/// * Firebase failed to initialise → main (sign-in is impossible, so the app
///   is used as a guest rather than stranding the user on a broken form)
/// * otherwise → sign-in
AppEntryRoute decideEntryRoute({
  required bool firebaseReady,
  required bool signedIn,
  required bool isGuest,
  required bool hasSeenOnboarding,
}) {
  if (firebaseReady && signedIn) return AppEntryRoute.main;
  if (!hasSeenOnboarding) return AppEntryRoute.onboarding;
  if (isGuest || !firebaseReady) return AppEntryRoute.main;
  return AppEntryRoute.signIn;
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
    isGuest: p?.getBool(EntryPrefsKeys.guestMode) ?? false,
    hasSeenOnboarding: p?.getBool(EntryPrefsKeys.hasSeenOnboarding) ?? false,
  );
}
