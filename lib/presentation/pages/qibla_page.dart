import 'dart:async';
import 'dart:math' as math;

import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/services/location_service.dart';
import '../../injection_container.dart';
import '../blocs/location_bloc.dart';
import '../blocs/settings_bloc.dart';
import '../widgets/widgets.dart';

class QiblaPage extends StatefulWidget {
  const QiblaPage({super.key});

  @override
  State<QiblaPage> createState() => _QiblaPageState();
}

class _QiblaPageState extends State<QiblaPage> {
  StreamSubscription<CompassEvent>? _compassSub;
  Timer? _sensorTimeout;

  /// Device heading in degrees from North, or null if unknown.
  double? _heading;
  double? _accuracy;

  /// False when the device has no usable compass sensor.
  bool _compassAvailable = true;

  @override
  void initState() {
    super.initState();
    _listenCompass();
  }

  void _listenCompass() {
    Stream<CompassEvent>? events;
    try {
      events = FlutterCompass.events;
    } catch (_) {
      events = null;
    }
    if (events == null) {
      _compassAvailable = false;
      return;
    }
    _compassSub = events.listen(
      (event) {
        if (!mounted) return;
        _sensorTimeout?.cancel();
        setState(() {
          _heading = event.heading;
          _accuracy = event.accuracy;
          _compassAvailable = event.heading != null;
        });
      },
      onError: (_) {
        if (mounted) setState(() => _compassAvailable = false);
      },
    );
    // If no reading arrives, assume there is no sensor.
    _sensorTimeout = Timer(const Duration(seconds: 3), () {
      if (mounted && _heading == null) {
        setState(() => _compassAvailable = false);
      }
    });
  }

  @override
  void dispose() {
    _sensorTimeout?.cancel();
    _compassSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: context.l10n.qibla_finder,
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settings) {
          return BlocBuilder<LocationBloc, LocationState>(
            builder: (context, locationState) {
              double? lat;
              double? lng;
              if (!settings.useAutoLocation) {
                lat = settings.manualLatitude;
                lng = settings.manualLongitude;
              } else if (locationState is LocationLoaded) {
                lat = locationState.latitude;
                lng = locationState.longitude;
              }

              if (lat == null || lng == null) {
                return _buildNoLocation(context, locationState);
              }
              final qibla = Qibla(Coordinates(lat, lng)).direction;
              return _buildCompass(context, qibla);
            },
          );
        },
      ),
    );
  }

  Widget _buildNoLocation(BuildContext context, LocationState state) {
    final l10n = context.l10n;
    if (state is LocationLoading || state is LocationInitial) {
      return StateView.loading(message: l10n.detecting_location);
    }
    return StateView.error(
      icon: Icons.location_off_outlined,
      message: l10n.location_error_message,
      onRetry:
          () => context.read<LocationBloc>().add(
            FetchLocation(forceRefresh: true),
          ),
      secondaryLabel: l10n.location_settings,
      onSecondary: () => sl<LocationService>().openLocationSettings(),
    );
  }

  /// Screen-reader description of where the Qibla is relative to the phone.
  String _compassSemantics(
    AppLocalizations l10n,
    double qibla,
    double relative,
    bool facing,
  ) {
    if (!_compassAvailable || _heading == null) {
      return l10n.degrees_from_north.replaceAll(
        '{deg}',
        qibla.toStringAsFixed(0),
      );
    }
    if (facing) return l10n.qibla_semantics_ahead;
    if (relative <= 180) {
      return l10n.qibla_semantics_right.replaceAll(
        '{deg}',
        relative.round().toString(),
      );
    }
    return l10n.qibla_semantics_left.replaceAll(
      '{deg}',
      (360 - relative).round().toString(),
    );
  }

  Widget _buildCompass(BuildContext context, double qibla) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final heading = _compassAvailable ? (_heading ?? 0) : 0.0;
    // Angle of the Qibla relative to the top of the phone.
    final relative = (qibla - heading) % 360;
    final diff = relative > 180 ? 360 - relative : relative;
    final facing = _compassAvailable && _heading != null && diff <= 5;
    final needsCalibration = _accuracy != null && _accuracy! > 30;
    final dialSize = 300.r;
    final accent = facing ? AppColors.success : AppColors.secondaryGold;
    final cardinals = {
      l10n.cardinal_n: 0.0,
      l10n.cardinal_e: 90.0,
      l10n.cardinal_s: 180.0,
      l10n.cardinal_w: 270.0,
    };

    return SingleChildScrollView(
      padding: AppSpacing.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        children: [
          Semantics(
            label: l10n.qibla_compass,
            value: _compassSemantics(l10n, qibla, relative, facing),
            liveRegion: facing,
            container: true,
            excludeSemantics: true,
            child: SizedBox(
              width: dialSize,
              height: dialSize,
              child: GlassBox(
                width: dialSize,
                height: dialSize,
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      facing
                          ? AppColors.success
                          : AppColors.secondaryGold.withValues(alpha: 0.3),
                  width: facing ? 4 : 2,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Cardinal letters: positioned around the dial according
                    // to the heading but never rotated, so they stay upright.
                    // Physical directions: deliberately not mirrored in RTL.
                    for (final entry in cardinals.entries)
                      Align(
                        alignment: _alignmentFor(entry.value - heading, 0.8),
                        child: Text(
                          entry.key,
                          style: textTheme.labelLarge?.copyWith(
                            color:
                                entry.value == 0
                                    ? AppColors.error
                                    : AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    // Kaaba / mosque icon in centre
                    Icon(
                      Icons.mosque,
                      color: AppColors.glassFill,
                      size: 100.sp,
                    ),
                    // Qibla pointer
                    Transform.rotate(
                      angle: relative * math.pi / 180,
                      child: SizedBox(
                        width: dialSize,
                        height: dialSize,
                        child: Align(
                          alignment: const Alignment(0, -0.55),
                          child: Icon(
                            Icons.navigation_rounded,
                            color: accent,
                            size: 48.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.vXxl),
          Text(
            facing ? l10n.facing_qibla : l10n.qibla_direction,
            textAlign: TextAlign.center,
            style: textTheme.headlineMedium?.copyWith(
              color: facing ? AppColors.success : AppColors.textMain,
            ),
          ),
          SizedBox(height: AppSpacing.vSm),
          Text(
            l10n.degrees_from_north.replaceAll(
              '{deg}',
              qibla.toStringAsFixed(1),
            ),
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: AppSpacing.vXl),
          AppCard(
            width: double.infinity,
            padding: AppSpacing.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      _compassAvailable
                          ? Icons.explore_outlined
                          : Icons.info_outline_rounded,
                      color: AppColors.secondaryGold,
                      size: 22.sp,
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        _compassAvailable
                            ? l10n.qibla_hint
                            : l10n.compass_unavailable,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.secondaryGold,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                if (_compassAvailable) ...[
                  SizedBox(height: AppSpacing.vSm),
                  Row(
                    children: [
                      Icon(
                        needsCalibration
                            ? Icons.warning_amber_rounded
                            : Icons.screen_rotation_alt_rounded,
                        color:
                            needsCalibration
                                ? AppColors.warning
                                : AppColors.textSecondary,
                        size: 22.sp,
                      ),
                      SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          l10n.calibrate_compass,
                          style: textTheme.bodySmall?.copyWith(
                            color:
                                needsCalibration
                                    ? AppColors.warning
                                    : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Alignment for a point on a circle at [degrees] clockwise from the top.
  Alignment _alignmentFor(double degrees, double radius) {
    final rad = degrees * math.pi / 180;
    return Alignment(math.sin(rad) * radius, -math.cos(rad) * radius);
  }
}
