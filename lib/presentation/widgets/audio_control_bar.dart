import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/audio_service.dart';
import '../../core/localization/app_localizations.dart';
import '../../data/datasources/local/settings_prefs.dart';
import '../../injection_container.dart';
import '../blocs/settings_bloc.dart';

/// "0.75×", "1×", "1.5×" …
String speedLabel(double speed) {
  final text =
      speed == speed.roundToDouble()
          ? speed.toStringAsFixed(0)
          : speed.toString().replaceFirst(RegExp(r'0+$'), '');
  return '$text\u00D7';
}

/// Mini player shown while recorded audio or text-to-speech is active.
///
/// Driven entirely by [AudioService.statusStream], so it hides itself when
/// playback stops or finishes. It also surfaces [AudioService.errorStream]
/// messages as a SnackBar (only from the route that is currently visible, so
/// stacked pages don't show duplicates).
class AudioControlBar extends StatefulWidget {
  const AudioControlBar({super.key});

  @override
  State<AudioControlBar> createState() => _AudioControlBarState();
}

class _AudioControlBarState extends State<AudioControlBar> {
  final AudioService _audioService = sl<AudioService>();
  StreamSubscription<String>? _errorSub;

  @override
  void initState() {
    super.initState();
    _errorSub = _audioService.errorStream.listen(_showError);
  }

  double get _speed {
    try {
      return _audioService.speed;
    } catch (_) {
      return 1.0;
    }
  }

  void _setSpeed(double speed) {
    _audioService.setSpeed(speed);
    // Persist (and sync) the choice; the app applies it on next launch.
    try {
      context.read<SettingsBloc>().add(UpdateAudioSpeed(speed));
    } catch (_) {}
    setState(() {});
  }

  void _showError(String message) {
    if (!mounted) return;
    final route = ModalRoute.of(context);
    if (route != null && !route.isCurrent) return;
    ScaffoldMessenger.maybeOf(context)
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(context.l10n.translate(message)),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  void dispose() {
    _errorSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AudioStatus>(
      stream: _audioService.statusStream,
      initialData: _audioService.status,
      builder: (context, snapshot) {
        final status = snapshot.data ?? AudioStatus.idle;
        // Keeps content clear of the system navigation bar on pages where
        // this bar is the Scaffold's bottom bar (0 inside the main tabs).
        final inset = MediaQuery.paddingOf(context).bottom;
        if (!status.isActive) {
          return SizedBox(height: inset);
        }
        final playing = status.isPlaying;

        return Container(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h + inset),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            border: Border(top: BorderSide(color: AppColors.glassStroke)),
            boxShadow: [
              BoxShadow(
                color: AppColors.textMain.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!status.isTts)
                  StreamBuilder<Duration?>(
                    stream: _audioService.durationStream,
                    builder: (context, snapshot) {
                      final duration = snapshot.data ?? Duration.zero;
                      return StreamBuilder<Duration>(
                        stream: _audioService.positionStream,
                        builder: (context, snapshot) {
                          var position = snapshot.data ?? Duration.zero;
                          if (position > duration) {
                            position = duration;
                          }
                          return ProgressBar(
                            progress: position,
                            total: duration,
                            onSeek: _audioService.seek,
                            baseBarColor: AppColors.glassFill,
                            progressBarColor: AppColors.secondaryGold,
                            bufferedBarColor: AppColors.glassStrokeStrong,
                            thumbColor: AppColors.secondaryGold,
                            barHeight: 3.h,
                            thumbRadius: 6.r,
                            timeLabelTextStyle: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 10.sp,
                            ),
                          );
                        },
                      );
                    },
                  ),
                Row(
                  children: [
                    if (status.isTts)
                      Padding(
                        padding: EdgeInsetsDirectional.only(end: 12.w),
                        child: Icon(
                          Icons.record_voice_over_outlined,
                          color: AppColors.secondaryGold,
                          size: 22.sp,
                        ),
                      ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            status.title ?? context.l10n.now_playing,
                            style: TextStyle(
                              color: AppColors.textMain,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if ((status.artist ?? '').isNotEmpty)
                            Text(
                              status.artist!,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12.sp,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    if (!status.isTts)
                      PopupMenuButton<double>(
                        tooltip: context.l10n.playback_speed,
                        initialValue: _speed,
                        onSelected: _setSpeed,
                        itemBuilder:
                            (_) => [
                              for (final s in SettingsPrefs.audioSpeeds)
                                PopupMenuItem<double>(
                                  value: s,
                                  child: Text(
                                    speedLabel(s),
                                    textDirection: TextDirection.ltr,
                                  ),
                                ),
                            ],
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: AppColors.secondaryGold.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                          child: Text(
                            speedLabel(_speed),
                            textDirection: TextDirection.ltr,
                            style: TextStyle(
                              color: AppColors.secondaryGold,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    IconButton(
                      tooltip: playing ? context.l10n.pause : context.l10n.play,
                      icon: Icon(
                        playing
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: AppColors.secondaryGold,
                        size: 32.sp,
                      ),
                      onPressed: () {
                        if (playing) {
                          _audioService.pause();
                        } else {
                          _audioService.resume();
                        }
                      },
                    ),
                    IconButton(
                      tooltip: context.l10n.stop,
                      icon: Icon(
                        Icons.stop_rounded,
                        color: AppColors.textSecondary,
                        size: 28.sp,
                      ),
                      onPressed: () => _audioService.stop(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
