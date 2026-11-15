import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/utils/arabic_text.dart' as arabic_utils;
import '../widgets/widgets.dart';

/// One of the 99 names with its real position (1-99).
class NameOfAllah {
  final int number;
  final String name;
  final String meaning;
  final String arabic;
  final String _arabicKey;

  NameOfAllah(this.number, Map<String, String> data)
    : name = data['name']!,
      meaning = data['meaning']!,
      arabic = data['arabic']!,
      _arabicKey = arabic_utils.ArabicText.normalize(data['arabic']!);
}

final List<NameOfAllah> kNumberedNames = [
  for (var i = 0; i < kNamesOfAllah.length; i++)
    NameOfAllah(i + 1, kNamesOfAllah[i]),
];

String _latinKey(String s) =>
    s.toLowerCase().replaceAll(RegExp(r"[\-'’`ʿʾ\s]"), '');

/// Filters by transliteration, meaning, exact number or Arabic text.
/// Filtering keeps each name's real number.
List<NameOfAllah> filterNames(List<NameOfAllah> names, String rawQuery) {
  final query = rawQuery.trim().toLowerCase();
  if (query.isEmpty) return names;
  final latin = _latinKey(query);
  final arabic = arabic_utils.ArabicText.normalize(query);
  return names
      .where(
        (n) =>
            '${n.number}' == query ||
            (latin.isNotEmpty && _latinKey(n.name).contains(latin)) ||
            n.meaning.toLowerCase().contains(query) ||
            (arabic.isNotEmpty && n._arabicKey.contains(arabic)),
      )
      .toList();
}

class NamesOfAllahPage extends StatefulWidget {
  const NamesOfAllahPage({super.key});

  @override
  State<NamesOfAllahPage> createState() => _NamesOfAllahPageState();
}

class _NamesOfAllahPageState extends State<NamesOfAllahPage> {
  String _query = '';

  void _showDetails(NameOfAllah name) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _NameDetailsSheet(name: name),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final visible = filterNames(kNumberedNames, _query);
    // Fixed tile height that grows with the user's text size.
    final textScaler = MediaQuery.textScalerOf(context);
    final tileExtent = 2 * AppSpacing.vMd + textScaler.scale(118.sp);

    return AppScaffold(
      title: l10n.names_of_allah,
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: AppSpacing.only(start: 24, end: 24, top: 16, bottom: 16),
            sliver: SliverToBoxAdapter(
              child: AppSearchField(
                hint: l10n.search_names,
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
          ),
          if (visible.isEmpty)
            SliverToBoxAdapter(
              child: StateView.empty(
                icon: Icons.search_off_rounded,
                message: l10n.no_names_found,
              ),
            )
          else
            SliverPadding(
              padding: AppSpacing.only(start: 24, end: 24, bottom: 24),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 220,
                  mainAxisExtent: tileExtent,
                  mainAxisSpacing: AppSpacing.vMd,
                  crossAxisSpacing: AppSpacing.md,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _NameTile(
                    name: visible[index],
                    onTap: () => _showDetails(visible[index]),
                  ),
                  childCount: visible.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NameTile extends StatelessWidget {
  const _NameTile({required this.name, required this.onTap});

  final NameOfAllah name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      onTap: onTap,
      borderRadius: AppRadius.mdAll,
      padding: AppSpacing.symmetric(horizontal: 10, vertical: 12),
      semanticLabel: '${name.number}. ${name.name}, ${name.meaning}',
      child: ExcludeSemantics(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${name.number}',
              style: textTheme.labelMedium?.copyWith(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSpacing.vXs),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: ArabicText(
                name.arabic,
                fontSize: 22.sp,
                height: 1.4,
                color: AppColors.secondaryGold,
                fontWeight: FontWeight.bold,
                maxLines: 1,
              ),
            ),
            SizedBox(height: AppSpacing.vXs),
            Text(
              name.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              textDirection: TextDirection.ltr,
              style: textTheme.titleSmall?.copyWith(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              name.meaning,
              textAlign: TextAlign.center,
              textDirection: TextDirection.ltr,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(
                fontSize: 11.sp,
                height: 1.25,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NameDetailsSheet extends StatelessWidget {
  const _NameDetailsSheet({required this.name});

  final NameOfAllah name;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: SingleChildScrollView(
        padding: AppSpacing.only(start: 24, end: 24, bottom: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.name_number.replaceAll('{n}', '${name.number}'),
              textAlign: TextAlign.center,
              style: textTheme.labelLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: AppSpacing.vMd),
            ArabicText(
              name.arabic,
              textAlign: TextAlign.center,
              fontSize: 40.sp,
              color: AppColors.secondaryGold,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: AppSpacing.vLg),
            Text(
              l10n.transliteration,
              style: textTheme.labelMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: AppSpacing.vXs),
            TranslationText(
              name.name,
              style: textTheme.titleLarge?.copyWith(color: AppColors.textMain),
            ),
            SizedBox(height: AppSpacing.vMd),
            Text(
              l10n.meaning,
              style: textTheme.labelMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: AppSpacing.vXs),
            TranslationText(name.meaning),
          ],
        ),
      ),
    );
  }
}

const List<Map<String, String>> kNamesOfAllah = [
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
  {
    'name': 'Al-Barr',
    'meaning': 'The Source of All Goodness',
    'arabic': 'البر',
  },
  {
    'name': 'At-Tawwab',
    'meaning': 'The Acceptor of Repentance',
    'arabic': 'التواب',
  },
  {'name': 'Al-Muntaqim', 'meaning': 'The Avenger', 'arabic': 'المنتقم'},
  {'name': 'Al-Afuww', 'meaning': 'The Pardoner', 'arabic': 'العفو'},
  {'name': 'Ar-Ra’uf', 'meaning': 'The Compassionate', 'arabic': 'الرؤوف'},
  {
    'name': 'Malik-ul-Mulk',
    'meaning': 'The Eternal Owner of Sovereignty',
    'arabic': 'مالك الملك',
  },
  {
    'name': 'Dhul-Jalal wal-Ikram',
    'meaning': 'The Lord of Majesty and Generosity',
    'arabic': 'ذو الجلال والإكرام',
  },
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
  {
    'name': 'Ar-Rashid',
    'meaning': 'The Guide to the Right Path',
    'arabic': 'الرشيد',
  },
  {'name': 'As-Sabur', 'meaning': 'The Patient', 'arabic': 'الصبور'},
];
