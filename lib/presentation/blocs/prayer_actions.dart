import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'location_bloc.dart';
import 'prayer_bloc.dart';
import 'settings_bloc.dart';

/// Reloads prayer times (and the location label) using the CURRENT settings.
/// Use this for retry buttons instead of dispatching events with defaults.
void reloadPrayerTimesFromSettings(
  BuildContext context, {
  bool forceLocationRefresh = false,
}) {
  final settings = context.read<SettingsBloc>().state;
  context.read<PrayerBloc>().add(
    LoadPrayerTimes(
      PrayerConfig.fromSettings(settings),
      forceLocationRefresh: forceLocationRefresh,
    ),
  );
  syncLocationWithSettings(
    context.read<LocationBloc>(),
    settings,
    forceRefresh: forceLocationRefresh,
  );
}

/// Points [LocationBloc] at GPS (auto mode) or the manual city.
void syncLocationWithSettings(
  LocationBloc bloc,
  SettingsState settings, {
  bool forceRefresh = false,
}) {
  if (settings.useAutoLocation) {
    bloc.add(FetchLocation(forceRefresh: forceRefresh));
  } else {
    bloc.add(
      UpdateLocationManually(
        latitude: settings.manualLatitude,
        longitude: settings.manualLongitude,
        city: settings.manualLocation,
      ),
    );
  }
}
