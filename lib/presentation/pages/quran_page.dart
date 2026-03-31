import 'package:barakah_time/presentation/pages/surah_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../blocs/quran_bloc.dart';
import '../widgets/glass_box.dart';

class QuranPage extends StatelessWidget {
  const QuranPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSlate,
      appBar: AppBar(
        title: Text(
          'Holy Quran',
          style: TextStyle(
            color: AppColors.textMain,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocBuilder<QuranBloc, QuranState>(
        builder: (context, state) {
          if (state is QuranLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.secondaryGold),
            );
          }
          if (state is QuranError) {
            return Center(
              child: Text(
                state.message,
                style: TextStyle(color: AppColors.textMain),
              ),
            );
          }
          if (state is QuranLoaded) {
            return ListView.separated(
              padding: EdgeInsets.all(20.w),
              itemCount: state.surahs.length,
              separatorBuilder: (context, index) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final surah = state.surahs[index];
                return GlassBox(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: const BoxDecoration(
                        color: AppColors.secondaryGold,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${surah.number}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      surah.englishName,
                      style: TextStyle(
                        color: AppColors.textMain,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '${surah.englishNameTranslation} • ${surah.numberOfAyahs} Ayahs',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.sp,
                      ),
                    ),
                    trailing: Text(
                      surah.name,
                      style: TextStyle(
                        color: AppColors.secondaryGold,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SurahDetailPage(surah: surah),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
