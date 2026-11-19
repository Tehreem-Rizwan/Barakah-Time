import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences keys for app settings, and their mapping to the
/// Firestore document `users/{uid}/settings/app`.
class SettingsPrefs {
  SettingsPrefs._();

  static const method = 'calculation_method';
  static const fontSize = 'quran_font_size';
  static const useAuto = 'use_auto_location';
  static const manualLocation = 'manual_location';
  static const manualLat = 'manual_latitude';
  static const manualLng = 'manual_longitude';
  static const language = 'language_code';
  static const notifications = 'notifications_enabled';
  static const madhab = 'asr_madhab';
  static const adhanSound = 'adhan_sound_enabled';
  static const prayerOffsets = 'prayer_offsets';
  static const themeMode = 'theme_mode';

  /// Allowed [themeMode] values.
  static const themeModes = ['system', 'light', 'dark'];

  /// Prayers whose time the user can shift.
  static const offsetPrayers = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];

  /// Largest shift either way, in minutes.
  static const maxOffset = 30;

  /// Validated offsets from a decoded JSON/cloud map: known prayers only,
  /// clamped to ±[maxOffset], zeros dropped.
  static Map<String, int> cleanOffsets(Object? raw) {
    if (raw is! Map) return const {};
    final out = <String, int>{};
    for (final p in offsetPrayers) {
      final v = raw[p];
      if (v is num) {
        final m = v.round().clamp(-maxOffset, maxOffset);
        if (m != 0) out[p] = m;
      }
    }
    return out;
  }

  static Map<String, int> readOffsets(SharedPreferences prefs) {
    final s = prefs.getString(prayerOffsets);
    if (s == null || s.isEmpty) return const {};
    try {
      return cleanOffsets(jsonDecode(s));
    } catch (_) {
      return const {};
    }
  }

  /// Cloud payload from the persisted settings. Only keys that have been
  /// saved are included (unset values keep their device defaults).
  /// `updatedAt` is added by the sync service.
  static Map<String, dynamic> toCloud(SharedPreferences prefs) {
    final map = <String, dynamic>{};
    void put(String field, Object? value) {
      if (value != null) map[field] = value;
    }

    put('calculationMethod', prefs.getString(method));
    put('asrMadhab', prefs.getString(madhab));
    put('useAutoLocation', prefs.getBool(useAuto));
    put('manualLocation', prefs.getString(manualLocation));
    put('manualLatitude', prefs.getDouble(manualLat));
    put('manualLongitude', prefs.getDouble(manualLng));
    put('languageCode', prefs.getString(language));
    put('quranFontSize', prefs.getDouble(fontSize));
    put('notificationsEnabled', prefs.getBool(notifications));
    put('adhanSoundEnabled', prefs.getBool(adhanSound));
    put('themeMode', prefs.getString(themeMode));
    if (prefs.getString(prayerOffsets) != null) {
      map['prayerOffsets'] = readOffsets(prefs);
    }
    return map;
  }

  /// Writes cloud settings into prefs. Unknown/invalid values are ignored.
  ///
  /// `notificationsEnabled` is NOT applied: notification permission is per
  /// device, so a new device must opt in itself.
  static Future<void> applyCloud(
    SharedPreferences prefs,
    Map<String, dynamic> data,
  ) async {
    Future<void> str(String field, String key) async {
      final v = data[field];
      if (v is String && v.isNotEmpty) await prefs.setString(key, v);
    }

    Future<void> dbl(String field, String key) async {
      final v = data[field];
      if (v is num) await prefs.setDouble(key, v.toDouble());
    }

    Future<void> boolean(String field, String key) async {
      final v = data[field];
      if (v is bool) await prefs.setBool(key, v);
    }

    await str('calculationMethod', method);
    final m = data['asrMadhab'];
    if (m == 'shafi' || m == 'hanafi')
      await prefs.setString(madhab, m as String);
    await boolean('useAutoLocation', useAuto);
    await str('manualLocation', manualLocation);
    await dbl('manualLatitude', manualLat);
    await dbl('manualLongitude', manualLng);
    await str('languageCode', language);
    await dbl('quranFontSize', fontSize);
    await boolean('adhanSoundEnabled', adhanSound);
    final t = data['themeMode'];
    if (t is String && themeModes.contains(t)) {
      await prefs.setString(themeMode, t);
    }
    if (data['prayerOffsets'] is Map) {
      await prefs.setString(
        prayerOffsets,
        jsonEncode(cleanOffsets(data['prayerOffsets'])),
      );
    }
  }
}
