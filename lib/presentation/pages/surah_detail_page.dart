import 'package:barakah_time/presentation/blocs/settings_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/surah.dart';
import '../../domain/entities/ayah.dart';
import '../../data/repositories/quran_repository.dart';
import '../widgets/glass_box.dart';
import 'package:barakah_time/domain/entities/saved_verse.dart';
import '../../domain/entities/spiritual_activity.dart';
import '../../injection_container.dart';
import '../blocs/pulse_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SurahDetailPage extends StatefulWidget {
  final Surah surah;
  const SurahDetailPage({super.key, required this.surah});

  @override
  State<SurahDetailPage> createState() => _SurahDetailPageState();
}

class _SurahDetailPageState extends State<SurahDetailPage> {
  late Future<List<Ayah>> _ayahsFuture;

  @override
  void initState() {
    super.initState();
    _ayahsFuture = sl<QuranRepository>().getSurahWithTranslation(
      widget.surah.number,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSlate,
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              widget.surah.englishName,
              style: TextStyle(color: AppColors.textMain, fontSize: 18.sp),
            ),
            Text(
              widget.surah.name,
              style: TextStyle(color: AppColors.secondaryGold, fontSize: 14.sp),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.secondaryGold),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            onPressed: () {
              final activity = SpiritualActivity(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                type: 'quran',
                subType: widget.surah.englishName,
                timestamp: DateTime.now(),
                points: 20, // 20 points for reading a surah
              );
              context.read<PulseBloc>().add(LogActivity(activity));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Surah ${widget.surah.englishName} logged! ✨'),
                  backgroundColor: AppColors.primaryEmerald,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            tooltip: 'Mark as Read',
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: FutureBuilder<List<Ayah>>(
        future: _ayahsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.secondaryGold),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final ayahs = snapshot.data!;

          return ListView.builder(
            padding: EdgeInsets.fromLTRB(24.w, 10.h, 24.w, 40.h),
            itemCount: ayahs.length,
            itemBuilder: (context, index) {
              final ayah = ayahs[index];
              return Container(
                margin: EdgeInsets.only(bottom: 32.h),
                padding: EdgeInsets.all(20.sp),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 32.w,
                          height: 32.h,
                          decoration: BoxDecoration(
                            color: AppColors.secondaryGold.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${ayah.numberInSurah}',
                            style: TextStyle(
                              color: AppColors.secondaryGold,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            BlocBuilder<PulseBloc, PulseState>(
                              builder: (context, state) {
                                bool isSaved = false;
                                if (state is PulseLoaded) {
                                  isSaved = state.savedVerses.any(
                                    (v) =>
                                        v.id ==
                                        '${widget.surah.number}:${ayah.numberInSurah}',
                                  );
                                }
                                return IconButton(
                                  icon: Icon(
                                    isSaved
                                        ? Icons.bookmark
                                        : Icons.bookmark_border,
                                    color:
                                        isSaved
                                            ? AppColors.secondaryGold
                                            : AppColors.textSecondary,
                                    size: 20.sp,
                                  ),
                                  onPressed: () {
                                    final savedVerse = SavedVerse(
                                      id:
                                          '${widget.surah.number}:${ayah.numberInSurah}',
                                      surahNumber: widget.surah.number,
                                      ayahNumber: ayah.numberInSurah,
                                      text: ayah.text,
                                      translation: ayah.translation,
                                      surahName: widget.surah.englishName,
                                      timestamp: DateTime.now(),
                                    );
                                    context.read<PulseBloc>().add(
                                      ToggleSaveVerse(savedVerse),
                                    );
                                  },
                                );
                              },
                            ),
                            GestureDetector(
                              onTap: () {
                                Share.share(
                                  '📖 *Ayah ${ayah.numberInSurah}* of *Surah ${widget.surah.englishName}*\n\n${ayah.text}\n\n${ayah.translation ?? ""}\n\nShared from *Barakah Time* ✨',
                                );
                              },
                              child: const Icon(
                                Icons.share_outlined,
                                color: AppColors.textSecondary,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    BlocBuilder<SettingsBloc, SettingsState>(
                      builder: (context, settingsState) {
                        return Text(
                          ayah.text,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: AppColors.textMain,
                            fontSize: settingsState.quranFontSize.sp,
                            fontFamily: 'Amiri',
                            height: 2.2,
                            letterSpacing: 0.5,
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      ayah.translation ?? '',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14.sp,
                        height: 1.5,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
