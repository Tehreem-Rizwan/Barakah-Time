import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/services/audio_service.dart';
import '../../core/utils/arabic_text.dart' as arabic_utils;
import '../../injection_container.dart';
import '../../core/constants/content_translations.dart';
import '../../data/repositories/quran_repository.dart';
import '../widgets/widgets.dart';

class DuasPage extends StatefulWidget {
  const DuasPage({super.key});

  @override
  State<DuasPage> createState() => _DuasPageState();
}

class _DuasPageState extends State<DuasPage> {
  String _query = '';

  /// Lowercases and drops apostrophes/hyphens so "al-hamdu" matches
  /// "alhamdu".
  static String _latinKey(String s) =>
      s.toLowerCase().replaceAll(RegExp(r"[\-'’`ʿʾ]"), '');

  List<Map<String, String>> _filter(AppLocalizations l10n) {
    final raw = _query.trim();
    if (raw.isEmpty) return kDuas;
    final lower = raw.toLowerCase();
    final latin = _latinKey(raw);
    final arabic = arabic_utils.ArabicText.normalize(raw);
    return kDuas.where((d) {
      final index = [
        l10n.translate(d['key']!).toLowerCase(),
        d['meaning']!.toLowerCase(),
        duaMeaning(d, l10n.locale.languageCode).toLowerCase(),
        _latinKey(d['transliteration']!),
        arabic_utils.ArabicText.normalize(d['arabic']!),
      ].join('\n');
      return index.contains(lower) ||
          (latin.isNotEmpty && index.contains(latin)) ||
          (arabic.isNotEmpty && index.contains(arabic));
    }).toList();
  }

  String _shareText(AppLocalizations l10n, Map<String, String> dua) =>
      '🤲 ${l10n.translate(dua['key']!)}\n\n${dua['arabic']}\n\n'
      '${dua['transliteration']}\n\n${duaMeaning(dua, l10n.locale.languageCode)}\n\n'
      '${l10n.shared_from_app} ✨';

  Future<void> _copy(Map<String, String> dua) async {
    final l10n = context.l10n;
    await Clipboard.setData(ClipboardData(text: _shareText(l10n, dua)));
    if (!mounted) return;
    showAppSnackBar(
      context,
      l10n.copied,
      type: SnackType.success,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final visible = _filter(l10n);
    return AppScaffold(
      title: l10n.daily_duas,
      bottomBar: const AudioControlBar(),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: AppSpacing.only(start: 24, end: 24, top: 16, bottom: 16),
            sliver: SliverToBoxAdapter(
              child: AppSearchField(
                hint: l10n.search_duas,
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
          ),
          if (visible.isEmpty)
            SliverToBoxAdapter(
              child: StateView.empty(
                icon: Icons.search_off_rounded,
                message: l10n.no_duas_found,
              ),
            )
          else
            SliverPadding(
              padding: AppSpacing.only(start: 24, end: 24, bottom: 32),
              sliver: SliverList.separated(
                itemCount: visible.length,
                separatorBuilder: (_, _) => SizedBox(height: AppSpacing.vLg),
                itemBuilder:
                    (context, index) => _DuaCard(
                      dua: visible[index],
                      onCopy: () => _copy(visible[index]),
                      onShare:
                          () => Share.share(_shareText(l10n, visible[index])),
                    ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DuaCard extends StatelessWidget {
  const _DuaCard({
    required this.dua,
    required this.onCopy,
    required this.onShare,
  });

  final Map<String, String> dua;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final audioService = sl<AudioService>();
    final title = l10n.translate(dua['key']!);
    final mediaId = dua['key']!;
    final reference = dua['reference'];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.secondaryGold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              StreamBuilder<AudioStatus>(
                stream: audioService.statusStream,
                initialData: audioService.status,
                builder: (context, snapshot) {
                  final status = snapshot.data ?? AudioStatus.idle;
                  final isPlaying = status.isPlayingMedia(mediaId);
                  return IconButton(
                    tooltip: isPlaying ? l10n.stop : l10n.play,
                    icon: Icon(
                      isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
                      color: AppColors.secondaryGold,
                      size: 26.sp,
                    ),
                    onPressed: () {
                      if (isPlaying) {
                        audioService.stop();
                      } else if (dua['ayah'] != null) {
                        // A full Quran ayah: Alafasy's recitation, then the
                        // translation read by a person when one exists.
                        final ayah = int.parse(dua['ayah']!);
                        final lang =
                            Localizations.localeOf(context).languageCode;
                        final translation = QuranRepository.translationAudioUrl(
                          lang,
                          ayah,
                        );
                        audioService.playList(
                          [
                            QuranRepository.arabicAudioUrl(ayah),
                            if (translation != null) translation,
                          ],
                          title: title,
                          artist: 'Mishary Rashid Alafasy',
                          mediaId: mediaId,
                        );
                      } else {
                        final lang =
                            Localizations.localeOf(context).languageCode;
                        final translated =
                            kDuaMeanings[lang]?[dua['key']] != null;
                        audioService.playArabicThenTranslation(
                          dua['arabic']!,
                          duaMeaning(dua, lang),
                          title: title,
                          mediaId: mediaId,
                          translationLang: translated ? lang : 'en',
                        );
                      }
                    },
                  );
                },
              ),
            ],
          ),
          SizedBox(height: AppSpacing.vMd),
          ArabicText(dua['arabic']!, fontSize: 22.sp),
          SizedBox(height: AppSpacing.vMd),
          TranslationText(
            dua['transliteration']!,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textMain,
              fontStyle: FontStyle.italic,
            ),
          ),
          SizedBox(height: AppSpacing.vSm),
          Builder(
            builder: (context) {
              final lang = Localizations.localeOf(context).languageCode;
              final meaning = duaMeaning(dua, lang);
              return TranslationText(
                meaning,
                isLtr: meaning == dua['meaning'] || !_isRtl(lang),
              );
            },
          ),
          if (reference != null) ...[
            SizedBox(height: AppSpacing.vXs),
            Text(
              reference,
              textDirection: TextDirection.ltr,
              style: textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          SizedBox(height: AppSpacing.vSm),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                tooltip: l10n.copy,
                icon: Icon(
                  Icons.copy_rounded,
                  color: AppColors.textSecondary,
                  size: 20.sp,
                ),
                onPressed: onCopy,
              ),
              IconButton(
                tooltip: l10n.share,
                icon: Icon(
                  Icons.share_outlined,
                  color: AppColors.textSecondary,
                  size: 20.sp,
                ),
                onPressed: onShare,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Meaning of [dua] in [lang] (English when no translation exists).
String duaMeaning(Map<String, String> dua, String lang) =>
    kDuaMeanings[lang]?[dua['key']] ?? dua['meaning']!;

bool _isRtl(String lang) => const {'ar', 'fa', 'ur'}.contains(lang);

/// Dua data. Titles are l10n keys; meanings here are English, other
/// languages are in `kDuaMeanings`.
const List<Map<String, String>> kDuas = [
  {
    'key': 'dua_before_sleeping',
    'arabic': 'بِاسْمِكَ رَبِّي وَضَعْتُ جَنْبِي، وَبِكَ أَرْفَعُهُ',
    'transliteration': 'Bismika Rabbi wadatu janbi, wa bika arfauhu',
    'meaning': 'In Your name, my Lord, I lie down and in Your name I rise.',
  },
  {
    'key': 'dua_waking_up',
    'arabic':
        'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ',
    'transliteration':
        'Alhamdu lillahil-ladhi ahyana bada ma amatana wa ilaihin-nushur',
    'meaning':
        'Praise be to Allah who gave us life after our death and to Him is the return.',
  },
  {
    'key': 'dua_before_eating',
    'arabic': 'بِسْمِ اللَّهِ',
    'transliteration': 'Bismillah',
    'meaning': 'In the name of Allah.',
  },
  {
    'key': 'dua_after_eating',
    'arabic':
        'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنَا وَسَقَانَا وَجَعَلَنَا مُسْلِمِينَ',
    'transliteration':
        'Alhamdu lillahil-ladhi atamana wa saqana wa jaalana muslimin',
    'meaning':
        'Praise be to Allah who fed us and gave us drink and made us Muslims.',
  },
  {
    'key': 'dua_entering_home',
    'arabic': 'بِسْمِ اللَّهِ وَلَجْنَا، وَبِسْمِ اللَّهِ خَرَجْنَا',
    'transliteration': 'Bismillahi walajna, wa bismillahi kharajna',
    'meaning':
        'In the name of Allah we enter and in the name of Allah we leave.',
  },
  {
    'key': 'dua_leaving_home',
    'arabic':
        'بِسْمِ اللَّهِ تَوَكَّلْتُ عَلَى اللَّهِ، لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
    'transliteration':
        'Bismillahi tawakkaltu alallahi, la hawla wala quwwata illa billah',
    'meaning':
        'In the name of Allah, I place my trust in Allah, there is no might nor power except with Allah.',
  },
  {
    'key': 'dua_entering_mosque',
    'arabic': 'اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ',
    'transliteration': 'Allahummaftah li abwaba rahmatik',
    'meaning': 'O Allah, open for me the gates of Your mercy.',
  },
  {
    'key': 'dua_leaving_mosque',
    'arabic': 'اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ فَضْلِكَ',
    'transliteration': 'Allahummainni asaluka min fadlik',
    'meaning': 'O Allah, I ask You from Your favor.',
  },
  {
    'key': 'dua_for_parents',
    'arabic': 'رَّبِّ ارْحَمْهُمَا كَمَا رَبَّيَانِي صَغِيرًا',
    'transliteration': 'Rabbi irhamhuma kama rabbayani saghira',
    'meaning':
        'My Lord, have mercy upon them as they brought me up [when I was] small.',
  },
  {
    'key': 'dua_for_knowledge',
    'arabic': 'رَّبِّ زِدْنِي عِلْمًا',
    'transliteration': 'Rabbi zidni ilma',
    'meaning': 'My Lord, increase me in knowledge.',
  },
  {
    'key': 'dua_forgiveness',
    'arabic': 'أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ',
    'transliteration': 'Astaghfirullah wa atubu ilaih',
    'meaning': 'I seek forgiveness from Allah and turn to Him in repentance.',
  },
  {
    'key': 'dua_entering_washroom',
    'arabic': 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْخُبُثِ وَالْخَبَائِثِ',
    'transliteration': 'Allahummainni audhu bika minal-khubuthi wal-khabaith',
    'meaning': 'O Allah, I seek refuge in You from the male and female devils.',
  },
  {
    'key': 'dua_leaving_washroom',
    'arabic': 'غُفْرَانَكَ',
    'transliteration': 'Ghufranak',
    'meaning': 'I ask for Your forgiveness.',
  },
  {
    'key': 'dua_before_wudu',
    'arabic': 'بِسْمِ اللَّهِ',
    'transliteration': 'Bismillah',
    'meaning': 'In the name of Allah.',
  },
  {
    'key': 'dua_after_wudu',
    'arabic':
        'أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ',
    'transliteration': 'Ashhadu an la ilaha illallahu wahdahu la sharika lah',
    'meaning':
        'I bear witness that there is no god but Allah alone, without partner.',
  },
  {
    'key': 'dua_traveling',
    'arabic':
        'سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ',
    'transliteration':
        'Subhanalladhi sakhkhara lana hadha wa ma kunna lahu muqrinin',
    'meaning':
        'Glory be to Him who has placed this service at our disposal, for we could not have done it by ourselves.',
  },
  {
    'key': 'dua_morning_evening',
    'arabic': 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
    'transliteration': 'Subhanallahi wa bihamdihi',
    'meaning': 'Glory be to Allah and praise be to Him.',
  },
  {
    'key': 'dua_protection',
    'arabic':
        'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ',
    'transliteration':
        'Bismillahi-ladhi la yadurru maasmihi shaiun fil-ardi wala fis-samai',
    'meaning':
        'In the name of Allah, with whose name nothing can cause harm in the earth or in the sky.',
  },
  {
    'key': 'dua_ayatul_kursi',
    'reference': '2:255',
    // Global ayah number: played as the real recitation, not text-to-speech.
    'ayah': '262',
    'arabic':
        'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَنْ ذَا الَّذِي يَشْفَعُ عِنْدَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ',
    'transliteration':
        "Allahu la ilaha illa Huwal-Hayyul-Qayyum. La ta'khudhuhu sinatun wa la nawm. Lahu ma fis-samawati wa ma fil-ard. Man dhal-ladhi yashfa'u 'indahu illa bi-idhnih. Ya'lamu ma bayna aydihim wa ma khalfahum, wa la yuhituna bi-shay'im-min 'ilmihi illa bima sha'. Wasi'a kursiyyuhus-samawati wal-ard, wa la ya'uduhu hifzuhuma, wa Huwal-'Aliyyul-'Azim.",
    'meaning':
        'Allah: there is no god but Him, the Ever-Living, the Sustainer of all that exists. Neither drowsiness nor sleep overtakes Him. To Him belongs everything in the heavens and everything on the earth. Who could intercede with Him except by His leave? He knows what lies before them and what lies behind them, and they grasp nothing of His knowledge except what He wills. His Kursi extends over the heavens and the earth, and guarding them does not weary Him. He is the Most High, the Most Great. (Al-Baqarah 2:255)',
  },
  {
    'key': 'dua_mirror',
    'arabic': 'اللَّهُمَّ كَمَا حَسَّنْتَ خَلْقِي فَحَسِّنْ خُلُقِي',
    'transliteration': 'Allahumma kama hassanta khalqi fahassin khuluqi',
    'meaning':
        'O Allah, as You have made my physical appearance beautiful, make my character beautiful.',
  },
  {
    'key': 'dua_wearing_clothes',
    'arabic': 'الْحَمْدُ لِلَّهِ الَّذِي كَسَانِي هَذَا الثَّوْبَ',
    'transliteration': 'Alhamdu lillahil-ladhi kasani hadhath-thaub',
    'meaning': 'Praise be to Allah who has clothed me with this garment.',
  },
];
