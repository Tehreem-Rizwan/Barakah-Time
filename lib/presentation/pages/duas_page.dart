import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/glass_box.dart';
import '../../core/localization/app_localizations.dart';

class DuasPage extends StatefulWidget {
  const DuasPage({super.key});

  @override
  State<DuasPage> createState() => _DuasPageState();
}

class _DuasPageState extends State<DuasPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _filteredDuas = [];

  final List<Map<String, String>> duas = const [
    {
      'title': 'Before Sleeping',
      'arabic': 'بِاسْمِكَ رَبِّي وَضَعْتُ جَنْبِي، وَبِكَ أَرْفَعُهُ',
      'transliteration': 'Bismika Rabbi wadatu janbi, wa bika arfauhu',
      'meaning': 'In Your name, my Lord, I lie down and in Your name I rise.',
    },
    {
      'title': 'Waking Up',
      'arabic': 'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ',
      'transliteration': 'Alhamdu lillahil-ladhi ahyana bada ma amatana wa ilaihin-nushur',
      'meaning': 'Praise be to Allah who gave us life after our death and to Him is the return.',
    },
    {
      'title': 'Before Eating',
      'arabic': 'بِسْمِ اللَّهِ',
      'transliteration': 'Bismillah',
      'meaning': 'In the name of Allah.',
    },
    {
      'title': 'After Eating',
      'arabic': 'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنَا وَسَقَانَا وَجَعَلَنَا مُسْلِمِينَ',
      'transliteration': 'Alhamdu lillahil-ladhi atamana wa saqana wa jaalana muslimin',
      'meaning': 'Praise be to Allah who fed us and gave us drink and made us Muslims.',
    },
    {
      'title': 'Entering Home',
      'arabic': 'بِسْمِ اللَّهِ وَلَجْنَا، وَبِسْمِ اللَّهِ خَرَجْنَا',
      'transliteration': 'Bismillahi walajna, wa bismillahi kharajna',
      'meaning': 'In the name of Allah we enter and in the name of Allah we leave.',
    },
    {
      'title': 'Leaving Home',
      'arabic': 'بِسْمِ اللَّهِ تَوَكَّلْتُ عَلَى اللَّهِ، لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
      'transliteration': 'Bismillahi tawakkaltu alallahi, la hawla wala quwwata illa billah',
      'meaning': 'In the name of Allah, I place my trust in Allah, there is no might nor power except with Allah.',
    },
    {
      'title': 'Entering Mosque',
      'arabic': 'اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ',
      'transliteration': 'Allahummaftah li abwaba rahmatik',
      'meaning': 'O Allah, open for me the gates of Your mercy.',
    },
    {
      'title': 'Leaving Mosque',
      'arabic': 'اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ فَضْلِكَ',
      'transliteration': 'Allahummainni asaluka min fadlik',
      'meaning': 'O Allah, I ask You from Your favor.',
    },
    {
      'title': 'For Parents',
      'arabic': 'رَّبِّ ارْحَمْهُمَا كَمَا رَبَّيَانِي صَغِيرًا',
      'transliteration': 'Rabbi irhamhuma kama rabbayani saghira',
      'meaning': 'My Lord, have mercy upon them as they brought me up [when I was] small.',
    },
    {
      'title': 'For Knowledge',
      'arabic': 'رَّبِّ زِدْنِي عِلْمًا',
      'transliteration': 'Rabbi zidni ilma',
      'meaning': 'My Lord, increase me in knowledge.',
    },
    {
      'title': 'For Forgiveness (Istighfar)',
      'arabic': 'أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ',
      'transliteration': 'Astaghfirullah wa atubu ilaih',
      'meaning': 'I seek forgiveness from Allah and turn to Him in repentance.',
    },
    {
      'title': 'Entering Washroom',
      'arabic': 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْخُبُثِ وَالْخَبَائِثِ',
      'transliteration': 'Allahummainni audhu bika minal-khubuthi wal-khabaith',
      'meaning': 'O Allah, I seek refuge in You from the male and female devils.',
    },
    {
      'title': 'Leaving Washroom',
      'arabic': 'غُفْرَانَكَ',
      'transliteration': 'Ghufranak',
      'meaning': 'I ask for Your forgiveness.',
    },
    {
      'title': 'Before Wudu',
      'arabic': 'بِسْمِ اللَّهِ',
      'transliteration': 'Bismillah',
      'meaning': 'In the name of Allah.',
    },
    {
      'title': 'After Wudu',
      'arabic': 'أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ',
      'transliteration': 'Ashhadu an la ilaha illallahu wahdahu la sharika lah',
      'meaning': 'I bear witness that there is no god but Allah alone, without partner.',
    },
    {
      'title': 'Traveling',
      'arabic': 'سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ',
      'transliteration': 'Subhanalladhi sakhkhara lana hadha wa ma kunna lahu muqrinin',
      'meaning': 'Glory be to Him who has placed this service at our disposal, for we could not have done it by ourselves.',
    },
    {
      'title': 'Morning/Evening',
      'arabic': 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
      'transliteration': 'Subhanallahi wa bihamdihi',
      'meaning': 'Glory be to Allah and praise be to Him.',
    },
    {
      'title': 'For Protection',
      'arabic': 'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ',
      'transliteration': 'Bismillahi-ladhi la yadurru maasmihi shaiun fil-ardi wala fis-samai',
      'meaning': 'In the name of Allah, with whose name nothing can cause harm in the earth or in the sky.',
    },
    {
      'title': 'Ayatul Kursi (After Prayer)',
      'arabic': 'اللَّهُ لَا إِلَهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ',
      'transliteration': 'Allahu la ilaha illa huwal hayyul qayyum',
      'meaning': 'Allah! There is no god but He, the Living, the Self-subsisting.',
    },
    {
      'title': 'Looking in Mirror',
      'arabic': 'اللَّهُمَّ كَمَا حَسَّنْتَ خَلْقِي فَحَسِّنْ خُلُقِي',
      'transliteration': 'Allahumma kama hassanta khalqi fahassin khuluqi',
      'meaning': 'O Allah, as You have made my physical appearance beautiful, make my character beautiful.',
    },
    {
      'title': 'Wearing Clothes',
      'arabic': 'الْحَمْدُ لِلَّهِ الَّذِي كَسَانِي هَذَا الثَّوْبَ',
      'transliteration': 'Alhamdu lillahil-ladhi kasani hadhath-thaub',
      'meaning': 'Praise be to Allah who has clothed me with this garment.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _filteredDuas = duas;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _filteredDuas = duas
          .where((dua) =>
              dua['title']!.toLowerCase().contains(_searchController.text.toLowerCase()) ||
              dua['meaning']!.toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSlate,
      appBar: AppBar(title: Text(context.l10n.daily_duas)),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 24.h),
              child: GlassBox(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: AppColors.textMain),
                  decoration: InputDecoration(
                    hintText: context.l10n.search_duas,
                    hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
                    prefixIcon: const Icon(Icons.search, color: AppColors.secondaryGold),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: AppColors.textSecondary, size: 18),
                            onPressed: () => _searchController.clear(),
                          )
                        : null,
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final dua = _filteredDuas[index];
                  return Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: GlassBox(
                      padding: EdgeInsets.all(20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                dua['title']!,
                                style: TextStyle(
                                  color: AppColors.secondaryGold,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(Icons.bookmark_border, color: AppColors.secondaryGold.withOpacity(0.5), size: 20.sp),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            dua['arabic']!,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: AppColors.textMain,
                              fontSize: 22.sp,
                              fontFamily: 'Amiri',
                              height: 1.8,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            dua['transliteration']!,
                            style: TextStyle(
                              color: AppColors.textMain.withOpacity(0.8),
                              fontSize: 14.sp,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            dua['meaning']!,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12.sp,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: _filteredDuas.length,
              ),
            ),
          ),
          if (_filteredDuas.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, color: AppColors.textSecondary, size: 48.sp),
                    SizedBox(height: 16.h),
                    Text(
                      context.l10n.no_duas_found,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          SliverToBoxAdapter(child: SizedBox(height: 40.h)),
        ],
      ),
    );
  }
}
