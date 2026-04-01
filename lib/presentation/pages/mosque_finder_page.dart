import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/glass_box.dart';

class MosqueFinderPage extends StatelessWidget {
  const MosqueFinderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> mosques = [
      {'name': 'Faisal Mosque', 'distance': '2.1 km', 'address': 'Islamabad, Pakistan'},
      {'name': 'Lal Masjid', 'distance': '4.5 km', 'address': 'Sector G-6, Islamabad'},
      {'name': 'Golra Sharif Mosque', 'distance': '12.3 km', 'address': 'Golra Sharif, Islamabad'},
      {'name': 'Shah Faisal Masjid', 'distance': '1.8 km', 'address': 'Margalla Hills, Islamabad'},
      {'name': 'Jamia Masjid G-9', 'distance': '3.2 km', 'address': 'Sector G-9, Islamabad'},
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundSlate,
      appBar: AppBar(
        title: const Text('Mosque Finder', style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.secondaryGold),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(24.w),
            child: GlassBox(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
              child: const TextField(
                style: TextStyle(color: AppColors.textMain),
                decoration: InputDecoration(
                  hintText: 'Search for mosques...',
                  hintStyle: TextStyle(color: AppColors.textSecondary),
                  prefixIcon: Icon(Icons.search, color: AppColors.secondaryGold),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              itemCount: mosques.length,
              itemBuilder: (context, index) {
                final m = mosques[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: GlassBox(
                    padding: EdgeInsets.all(20.w),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryGold.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.mosque, color: AppColors.secondaryGold, size: 24.sp),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(m['name']!, style: TextStyle(color: AppColors.textMain, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                              SizedBox(height: 4.h),
                              Text(m['address']!, style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(m['distance']!, style: TextStyle(color: AppColors.secondaryGold, fontWeight: FontWeight.bold)),
                            SizedBox(height: 4.h),
                            const Icon(Icons.directions, color: AppColors.textSecondary, size: 16),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
