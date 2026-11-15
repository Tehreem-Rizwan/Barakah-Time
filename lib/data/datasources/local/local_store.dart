/// Names of per-user local stores (wiped on sign-out / account deletion).
class LocalBoxes {
  LocalBoxes._();

  /// `Box<SpiritualActivity>` keyed by activity id.
  static const activities = 'spiritual_activities';

  /// `Box<SavedVerse>` keyed by `<surah>:<ayah>`.
  static const savedVerses = 'saved_verses';

  /// Untyped box: [badgesKey] → `Map<String, String>` (badge id → ISO date).
  static const pulseMeta = 'pulse_meta';
  static const badgesKey = 'badges';

  static const all = [activities, savedVerses, pulseMeta];
}

/// Per-user SharedPreferences keys (wiped on sign-out).
class UserPrefsKeys {
  UserPrefsKeys._();

  static const userId = 'user_id';
  static const userName = 'user_name';
  static const userEmail = 'user_email';
  static const userProfilePic = 'user_profile_pic';
  static const tasbeehCount = 'tasbeeh_count';
  static const tasbeehLoggedCount = 'tasbeeh_logged_count';

  /// `migrated_<uid>`: local (guest/legacy) data was uploaded for this uid.
  static String migrated(String uid) => 'migrated_$uid';
  static const migratedPrefix = 'migrated_';

  static const all = [
    userId,
    userName,
    userEmail,
    userProfilePic,
    tasbeehCount,
    tasbeehLoggedCount,
  ];
}
