import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/audio_service.dart';
import '../../injection_container.dart';

class AudioControlBar extends StatelessWidget {
  const AudioControlBar({super.key});

  @override
  Widget build(BuildContext context) {
    final audioService = sl<AudioService>();

    return StreamBuilder<PlayerState>(
      stream: audioService.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final processingState = playerState?.processingState;
        final playing = playerState?.playing ?? false;

        if (processingState == ProcessingState.idle) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppColors.backgroundSlate.withOpacity(0.95),
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
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
                StreamBuilder<Duration?>(
                  stream: audioService.durationStream,
                  builder: (context, snapshot) {
                    final duration = snapshot.data ?? Duration.zero;
                    return StreamBuilder<Duration>(
                      stream: audioService.positionStream,
                      builder: (context, snapshot) {
                        var position = snapshot.data ?? Duration.zero;
                        if (position > duration) {
                          position = duration;
                        }
                        return ProgressBar(
                          progress: position,
                          total: duration,
                          onSeek: audioService.seek,
                          baseBarColor: Colors.white.withOpacity(0.1),
                          progressBarColor: AppColors.secondaryGold,
                          bufferedBarColor: Colors.white.withOpacity(0.2),
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            audioService.currentTitle ?? "Playing...",
                            style: TextStyle(
                              color: AppColors.textMain,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            audioService.currentArtist ?? "",
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
                      icon: Icon(
                        playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: AppColors.secondaryGold,
                        size: 32.sp,
                      ),
                      onPressed: () {
                        if (playing) {
                          audioService.pause();
                        } else {
                          audioService.resume();
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.stop_rounded,
                        color: AppColors.textSecondary,
                        size: 28.sp,
                      ),
                      onPressed: () => audioService.stop(),
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
