import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/glass_box.dart';

class NamesOfAllahPage extends StatefulWidget {
  const NamesOfAllahPage({super.key});

  @override
  State<NamesOfAllahPage> createState() => _NamesOfAllahPageState();
}

class _NamesOfAllahPageState extends State<NamesOfAllahPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _filteredNames = [];

  @override
  void initState() {
    super.initState();
    _filteredNames = names;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _filteredNames = names
          .where((name) =>
              name['name']!.toLowerCase().contains(_searchController.text.toLowerCase()) ||
              name['meaning']!.toLowerCase().contains(_searchController.text.toLowerCase()) ||
              name['arabic']!.contains(_searchController.text))
          .toList();
    });
  }

  final List<Map<String, String>> names = const [
    {'name': 'Ar-Rahman', 'meaning': 'The Most Gracious', 'arabic': 'الرحمن'},
    {'name': 'Ar-Rahim', 'meaning': 'The Most Merciful', 'arabic': 'الرحيم'},
    {'name': 'Al-Malik', 'meaning': 'The Sovereign Lord', 'arabic': 'الملك'},
    {'name': 'Al-Quddus', 'meaning': 'The Holy', 'arabic': 'القدوس'},
    {'name': 'As-Salam', 'meaning': 'The Source of Peace', 'arabic': 'السلام'},
    {'name': 'Al-Mu’min', 'meaning': 'The Guardian of Faith', 'arabic': 'المؤمن'},
    {'name': 'Al-Muhaymin', 'meaning': 'The Protector', 'arabic': 'المهيمن'},
    {'name': 'Al-Aziz', 'meaning': 'The Mighty', 'arabic': 'العزيز'},
    {'name': 'Al-Jabbar', 'meaning': 'The Compeller', 'arabic': 'الجبار'},
    {'name': 'Al-Mutakabbir', 'meaning': 'The Majestic', 'arabic': 'المتكبر'},
    {'name': 'Al-Khaliq', 'meaning': 'The Creator', 'arabic': 'الخالق'},
    {'name': 'Al-Bari’', 'meaning': 'The Evolver', 'arabic': 'البارئ'},
    {'name': 'Al-Musawwir', 'meaning': 'The Fashioner', 'arabic': 'المصور'},
    {'name': 'Al-Ghaffar', 'meaning': 'The Forgiver', 'arabic': 'الغفار'},
    {'name': 'Al-Qahhar', 'meaning': 'The Subduer', 'arabic': 'القهار'},
    {'name': 'Al-Wahhab', 'meaning': 'The Bestower', 'arabic': 'الوهاب'},
    {'name': 'Ar-Razzaq', 'meaning': 'The Provider', 'arabic': 'الرزاق'},
    {'name': 'Al-Fattah', 'meaning': 'The Opener', 'arabic': 'الفتاح'},
    {'name': 'Al-Alim', 'meaning': 'The All-Knowing', 'arabic': 'العليم'},
    {'name': 'Al-Qabid', 'meaning': 'The Constrictor', 'arabic': 'القابض'},
    {'name': 'Al-Basit', 'meaning': 'The Expander', 'arabic': 'الباسط'},
    {'name': 'Al-Khafid', 'meaning': 'The Abaser', 'arabic': 'الخافض'},
    {'name': 'Ar-Rafi', 'meaning': 'The Exalter', 'arabic': 'الرافع'},
    {'name': 'Al-Mu’izz', 'meaning': 'The Honorer', 'arabic': 'المعز'},
    {'name': 'Al-Mudhill', 'meaning': 'The Dishonorer', 'arabic': 'المذل'},
    {'name': 'As-Sami’', 'meaning': 'The All-Hearing', 'arabic': 'السميع'},
    {'name': 'Al-Basir', 'meaning': 'The All-Seeing', 'arabic': 'البصير'},
    {'name': 'Al-Hakam', 'meaning': 'The Judge', 'arabic': 'الحكم'},
    {'name': 'Al-Adl', 'meaning': 'The Just', 'arabic': 'العدل'},
    {'name': 'Al-Latif', 'meaning': 'The Subtle One', 'arabic': 'اللطيف'},
    {'name': 'Al-Khabir', 'meaning': 'The All-Aware', 'arabic': 'الخبير'},
    {'name': 'Al-Halim', 'meaning': 'The Forbearing', 'arabic': 'الحليم'},
    {'name': 'Al-Azim', 'meaning': 'The Magnificent', 'arabic': 'العظيم'},
    {'name': 'Al-Ghafur', 'meaning': 'The Forgiving', 'arabic': 'الغفور'},
    {'name': 'Ash-Shakur', 'meaning': 'The Grateful', 'arabic': 'الشكور'},
    {'name': 'Al-Ali', 'meaning': 'The Most High', 'arabic': 'العلي'},
    {'name': 'Al-Kabir', 'meaning': 'The Most Great', 'arabic': 'الكبير'},
    {'name': 'Al-Hafiz', 'meaning': 'The Preserver', 'arabic': 'الحفيظ'},
    {'name': 'Al-Muqit', 'meaning': 'The Sustainer', 'arabic': 'المقيت'},
    {'name': 'Al-Hasib', 'meaning': 'The Reckoner', 'arabic': 'الحسيب'},
    {'name': 'Al-Jalil', 'meaning': 'The Sublime One', 'arabic': 'الجليل'},
    {'name': 'Al-Karim', 'meaning': 'The Generous One', 'arabic': 'الكريم'},
    {'name': 'Ar-Raqib', 'meaning': 'The Watchful', 'arabic': 'الرقيب'},
    {'name': 'Al-Mujib', 'meaning': 'The Responsive', 'arabic': 'المجيب'},
    {'name': 'Al-Wasi’', 'meaning': 'The All-Embracing', 'arabic': 'الواسع'},
    {'name': 'Al-Hakim', 'meaning': 'The Wise', 'arabic': 'الحكيم'},
    {'name': 'Al-Wadud', 'meaning': 'The Loving', 'arabic': 'الودود'},
    {'name': 'Al-Majid', 'meaning': 'The Most Glorious', 'arabic': 'المجيد'},
    {'name': 'Al-Ba’ith', 'meaning': 'The Resurrector', 'arabic': 'الباعث'},
    {'name': 'Ash-Shahid', 'meaning': 'The Witness', 'arabic': 'الشهيد'},
    {'name': 'Al-Haqq', 'meaning': 'The Truth', 'arabic': 'الحق'},
    {'name': 'Al-Wakil', 'meaning': 'The Trustee', 'arabic': 'الوكيل'},
    {'name': 'Al-Qawiyy', 'meaning': 'The Most Strong', 'arabic': 'القوي'},
    {'name': 'Al-Matin', 'meaning': 'The Firm One', 'arabic': 'المتين'},
    {'name': 'Al-Waliyy', 'meaning': 'The Protecting Friend', 'arabic': 'الولي'},
    {'name': 'Al-Hamid', 'meaning': 'The Praiseworthy', 'arabic': 'الحميد'},
    {'name': 'Al-Muhsi', 'meaning': 'The Reckoner', 'arabic': 'المحصي'},
    {'name': 'Al-Mubdi’', 'meaning': 'The Originator', 'arabic': 'المبدئ'},
    {'name': 'Al-Mu’id', 'meaning': 'The Restorer', 'arabic': 'المعيد'},
    {'name': 'Al-Muhyi', 'meaning': 'The Giver of Life', 'arabic': 'المحيي'},
    {'name': 'Al-Mumit', 'meaning': 'The Creator of Death', 'arabic': 'المميت'},
    {'name': 'Al-Hayy', 'meaning': 'The Alive', 'arabic': 'الحي'},
    {'name': 'Al-Qayyum', 'meaning': 'The Self-Subsisting', 'arabic': 'القيوم'},
    {'name': 'Al-Wajid', 'meaning': 'The Finder', 'arabic': 'الواجد'},
    {'name': 'Al-Majid', 'meaning': 'The Noble', 'arabic': 'الماجد'},
    {'name': 'Al-Wahid', 'meaning': 'The Unique', 'arabic': 'الواحد'},
    {'name': 'Al-Ahad', 'meaning': 'The One', 'arabic': 'الاحد'},
    {'name': 'As-Samad', 'meaning': 'The Eternal', 'arabic': 'الصمد'},
    {'name': 'Al-Qadir', 'meaning': 'The Able', 'arabic': 'القادر'},
    {'name': 'Al-Muqtadir', 'meaning': 'The Powerful', 'arabic': 'المقتدر'},
    {'name': 'Al-Muqaddim', 'meaning': 'The Expediter', 'arabic': 'المقدم'},
    {'name': 'Al-Mu’akhkhir', 'meaning': 'The Delayer', 'arabic': 'المؤخر'},
    {'name': 'Al-Awwal', 'meaning': 'The First', 'arabic': 'الأول'},
    {'name': 'Al-Akhir', 'meaning': 'The Last', 'arabic': 'الأخر'},
    {'name': 'Az-Zahir', 'meaning': 'The Manifest', 'arabic': 'الظاهر'},
    {'name': 'Al-Batin', 'meaning': 'The Hidden', 'arabic': 'الباطن'},
    {'name': 'Al-Wali', 'meaning': 'The Governor', 'arabic': 'الوالي'},
    {'name': 'Al-Muta’ali', 'meaning': 'The Most Exalted', 'arabic': 'المتعالي'},
    {'name': 'Al-Barr', 'meaning': 'The Source of All Goodness', 'arabic': 'البر'},
    {'name': 'At-Tawwab', 'meaning': 'The Acceptor of Repentance', 'arabic': 'التواب'},
    {'name': 'Al-Muntaqim', 'meaning': 'The Avenger', 'arabic': 'المنتقم'},
    {'name': 'Al-Afuww', 'meaning': 'The Pardoner', 'arabic': 'العفو'},
    {'name': 'Ar-Ra’uf', 'meaning': 'The Compassionate', 'arabic': 'الرؤوف'},
    {'name': 'Malik-ul-Mulk', 'meaning': 'The Eternal Owner of Sovereignty', 'arabic': 'مالك الملك'},
    {'name': 'Dhul-Jalal wal-Ikram', 'meaning': 'The Lord of Majesty and Generosity', 'arabic': 'ذو الجلال والإكرام'},
    {'name': 'Al-Muqsit', 'meaning': 'The Equitable', 'arabic': 'المقسط'},
    {'name': 'Al-Jami’', 'meaning': 'The Gatherer', 'arabic': 'الجامع'},
    {'name': 'Al-Ghaniyy', 'meaning': 'The Self-Sufficient', 'arabic': 'الغني'},
    {'name': 'Al-Mughni', 'meaning': 'The Enricher', 'arabic': 'المغني'},
    {'name': 'Al-Mani’', 'meaning': 'The Preventer', 'arabic': 'المانع'},
    {'name': 'Ad-Darr', 'meaning': 'The Distressor', 'arabic': 'الضار'},
    {'name': 'An-Nafi’', 'meaning': 'The Propitious', 'arabic': 'النافع'},
    {'name': 'An-Nur', 'meaning': 'The Light', 'arabic': 'النور'},
    {'name': 'Al-Hadi', 'meaning': 'The Guide', 'arabic': 'الهادي'},
    {'name': 'Al-Badi’', 'meaning': 'The Incomparable', 'arabic': 'البديع'},
    {'name': 'Al-Baqi', 'meaning': 'The Everlasting', 'arabic': 'الباقي'},
    {'name': 'Al-Warith', 'meaning': 'The Supreme Inheritor', 'arabic': 'الوارث'},
    {'name': 'Ar-Rashid', 'meaning': 'The Guide to the Right Path', 'arabic': 'الرشيد'},
    {'name': 'As-Sabur', 'meaning': 'The Patient', 'arabic': 'الصبور'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSlate,
      appBar: AppBar(
        title: Text('99 Names of Allah', style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.secondaryGold),
      ),
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
                    hintText: 'Search names...',
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
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16.h,
                crossAxisSpacing: 16.w,
                childAspectRatio: 1.0, // Increased from 1.1 for more height
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final name = _filteredNames[index];
                  return GlassBox(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: AppColors.textSecondary.withOpacity(0.3),
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          name['arabic']!,
                          style: TextStyle(
                            color: AppColors.secondaryGold,
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            name['name']!,
                            style: TextStyle(
                              color: AppColors.textMain,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        SizedBox(
                          height: 28.h,
                          child: Center(
                            child: Text(
                              name['meaning']!,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 9.sp,
                                height: 1.1,
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  );
                },
                childCount: _filteredNames.length,
              ),
            ),
          ),
          if (_filteredNames.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, color: AppColors.textSecondary, size: 48.sp),
                    SizedBox(height: 16.h),
                    const Text(
                      'No names found',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          SliverToBoxAdapter(child: SizedBox(height: 24.h)),
        ],
      ),
    );
  }
}
