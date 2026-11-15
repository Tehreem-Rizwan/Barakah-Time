import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/audio_service.dart';
import '../../core/localization/app_localizations.dart';
import '../../injection_container.dart';

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

  void _showError(String message) {
    if (!mounted) return;
    final route = ModalRoute.of(context);
    if (route != null && !route.isCurrent) return;
    ScaffoldMessenger.maybeOf(context)
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
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
        if (!status.isActive) {
          return const SizedBox.shrink();
        }
        final playing = status.isPlaying;

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppColors.backgroundSlate.withValues(alpha: 0.95),
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
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
                            baseBarColor: Colors.white.withValues(alpha: 0.1),
                            progressBarColor: AppColors.secondaryGold,
                            bufferedBarColor: Colors.white.withValues(alpha: 0.2),
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
