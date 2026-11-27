import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/services/notification_service.dart';
import '../../injection_container.dart';
import '../blocs/location_bloc.dart';
import '../blocs/settings_bloc.dart';
import '../widgets/widgets.dart';

/// Asks once, on first use, for permission to show the adhan notifications
/// (the app's main feature), right after the location question so the two
/// system dialogs never overlap. When granted, notifications are switched
/// on; Android 12+ then explains and opens "Alarms & reminders" so the adhan
/// fires exactly on time. Declining is respected: it can be enabled later
/// in Settings.
class FirstRunPrompts {
  FirstRunPrompts._();

  static const askedKey = 'notification_prompt_asked';

  static bool _running = false;

  /// Call after the first frame of the main screen.
  static Future<void> run(BuildContext context) async {
    if (_running) return;
    if (!sl.isRegistered<NotificationService>() ||
        !sl.isRegistered<SharedPreferences>()) {
      return;
    }
    final prefs = sl<SharedPreferences>();
    final settings = context.read<SettingsBloc>();
    if (prefs.getBool(askedKey) ?? false) return;
    if (settings.state.notificationsEnabled) {
      await prefs.setBool(askedKey, true);
      return;
    }
    _running = true;
    try {
      await _afterLocationQuestion(context.read<LocationBloc>());
      if (!context.mounted) return;
      await prefs.setBool(askedKey, true);

      final notifications = sl<NotificationService>();
      final granted = await notifications.requestPermission();
      if (!granted || !context.mounted) return;
      settings.add(const ToggleNotifications(true, askExactAlarms: false));

      if (await notifications.canScheduleExactAlarms()) return;
      if (!context.mounted) return;
      final open = await _explainExactAlarms(context);
      if (open) await notifications.requestExactAlarmsPermission();
    } catch (e) {
      debugPrint('First-run notification prompt failed: $e');
    } finally {
      _running = false;
    }
  }

  /// Waits until the location permission flow has finished (loaded or
  /// failed), at most 30 seconds.
  static Future<void> _afterLocationQuestion(LocationBloc bloc) async {
    bool settled(LocationState s) => s is LocationLoaded || s is LocationError;
    if (settled(bloc.state)) return;
    await bloc.stream
        .firstWhere(settled)
        .timeout(const Duration(seconds: 30), onTimeout: () => bloc.state);
  }

  static Future<bool> _explainExactAlarms(BuildContext context) async {
    final l10n = context.l10n;
    final result = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            icon: Icon(Icons.alarm_on_rounded, color: AppColors.secondaryGold),
            title: Text(l10n.exact_alarm_prompt_title),
            content: Text(l10n.exact_alarm_prompt_body),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                ),
                child: Text(l10n.later),
              ),
              FilledButton(
                style: dialogActionStyle(),
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(l10n.open_settings),
              ),
            ],
          ),
    );
    return result ?? false;
  }
}
