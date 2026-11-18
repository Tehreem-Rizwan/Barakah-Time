import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/utils/arabic_text.dart' as arabic_utils;
import '../../domain/entities/surah.dart';
import '../blocs/quran_bloc.dart';
import '../widgets/widgets.dart';
import 'surah_detail_page.dart';

/// Filters [surahs] by Arabic name, English name, English meaning or number.
List<Surah> filterSurahs(List<Surah> surahs, String rawQuery) {
  final query = rawQuery.trim().toLowerCase();
  if (query.isEmpty) return surahs;
  final latin = _latinKey(query);
  final arabic = arabic_utils.ArabicText.normalize(query);
  return surahs.where((s) {
    if ('${s.number}' == query) return true;
    if (latin.isNotEmpty &&
        (_latinKey(s.englishName).contains(latin) ||
            _latinKey(s.englishNameTranslation).contains(latin))) {
      return true;
    }
    return arabic.isNotEmpty &&
        arabic_utils.ArabicText.normalize(s.name).contains(arabic);
  }).toList();
}

String _latinKey(String s) =>
    s.toLowerCase().replaceAll(RegExp(r"[\-'’`ʿʾ\s]"), '');

class QuranPage extends StatefulWidget {
  const QuranPage({super.key});

  @override
  State<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage> {
  String _query = '';
  QuranLastRead? _lastRead;

  @override
  void initState() {
    super.initState();
    _lastRead = QuranLastRead.load();
  }

  Future<void> _refresh() async {
    final bloc = context.read<QuranBloc>();
    bloc.add(LoadSurahs(forceRefresh: true));
    await bloc.stream
        .firstWhere((s) => s is QuranLoaded || s is QuranError)
        .timeout(const Duration(seconds: 30), onTimeout: () => bloc.state);
  }

  Future<void> _open(Surah surah, {int? ayah}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SurahDetailPage(surah: surah, initialAyah: ayah),
      ),
    );
    if (mounted) setState(() => _lastRead = QuranLastRead.load());
  }

  /// Translation languages offered, by their own names.
  static const Map<String, String> _translationLanguages = {
    'ur': 'اردو',
    'en': 'English',
    'ar': 'العربية',
    'fa': 'فارسی',
    'tr': 'Türkçe',
  };

  Future<void> _pickTranslationLanguage(BuildContext context) async {
    final l10n = context.l10n;
    final bloc = context.read<QuranBloc>();
    final chosen = bloc.chosenTranslationLanguage;
    final result = await showModalBottomSheet<String>(
      context: context,
      // Let the sheet grow to fit all six options, and scroll on small
      // screens or with large text.
      isScrollControlled: true,
      useSafeArea: true,
      builder:
          (sheet) => SafeArea(
            child: RadioGroup<String>(
              groupValue: chosen ?? '',
              onChanged: (v) => Navigator.of(sheet).pop(v),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: Text(
                        l10n.translate('quran_translation_language'),
                        style: Theme.of(sheet).textTheme.titleMedium,
                      ),
                      subtitle: Text(
                        l10n.translate('quran_translation_audio_note'),
                      ),
                    ),
                    RadioListTile<String>(
                      value: '',
                      title: Text(
                        l10n.translate('quran_translation_same_as_app'),
                      ),
                    ),
                    for (final e in _translationLanguages.entries)
                      RadioListTile<String>(value: e.key, title: Text(e.value)),
                    SizedBox(height: 8.h),
                  ],
                ),
              ),
            ),
          ),
    );
    if (result == null) return;
    bloc.add(SetTranslationLanguage(result.isEmpty ? null : result));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppScaffold(
      title: l10n.quran,
      actions: [
        IconButton(
          tooltip: l10n.translate('quran_translation_language'),
          icon: const Icon(Icons.translate_rounded),
          onPressed: () => _pickTranslationLanguage(context),
        ),
      ],
      body: BlocConsumer<QuranBloc, QuranState>(
        listenWhen: (prev, curr) => curr is QuranLoaded && curr.refreshFailed,
        listener: (context, state) {
          showAppSnackBar(
            context,
            context.l10n.quran_load_error,
            type: SnackType.error,
          );
        },
        builder: (context, state) {
          if (state is QuranError) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: StateView.error(
                icon: Icons.cloud_off_rounded,
                message: l10n.quran_load_error,
                onRetry: () => context.read<QuranBloc>().add(LoadSurahs()),
              ),
            );
          }
          if (state is! QuranLoaded) {
            return const SkeletonList(itemCount: 8);
          }
          return _buildList(context, state.surahs);
        },
      ),
    );
  }

  Widget _buildList(BuildContext context, List<Surah> surahs) {
    final l10n = context.l10n;
    final visible = filterSurahs(surahs, _query);
    final lastRead = _lastRead;
    Surah? lastSurah;
    if (lastRead != null && _query.isEmpty) {
      for (final s in surahs) {
        if (s.number == lastRead.surah) {
          lastSurah = s;
          break;
        }
      }
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: AppSpacing.only(start: 24, end: 24, top: 16, bottom: 8),
            sliver: SliverToBoxAdapter(
              child: AppSearchField(
                hint: l10n.search_surahs,
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
          ),
          if (lastSurah != null)
            SliverPadding(
              padding: AppSpacing.only(start: 24, end: 24, top: 8, bottom: 8),
              sliver: SliverToBoxAdapter(
                child: _ContinueReadingCard(
                  surah: lastSurah,
                  ayah: lastRead!.ayah,
                  onTap: () => _open(lastSurah!, ayah: lastRead.ayah),
                ),
              ),
            ),
          if (visible.isEmpty)
            SliverToBoxAdapter(
              child: StateView.empty(
                icon: Icons.search_off_rounded,
                message: l10n.no_surahs_found,
              ),
            )
          else
            SliverPadding(
              padding: AppSpacing.only(start: 24, end: 24, top: 8, bottom: 24),
              sliver: SliverList.separated(
                itemCount: visible.length,
                separatorBuilder: (_, _) => SizedBox(height: AppSpacing.vMd),
                itemBuilder: (context, index) {
                  final surah = visible[index];
                  return _SurahTile(surah: surah, onTap: () => _open(surah));
                },
              ),
            ),
        ],
      ),
    );
  }
}

String _revelationLabel(BuildContext context, String type) {
  final t = type.toLowerCase();
  if (t.startsWith('mec') || t.startsWith('mak')) return context.l10n.meccan;
  if (t.startsWith('med')) return context.l10n.medinan;
  return type;
}

/// Circular surah/ayah number badge: gold text on a translucent gold fill
/// (never white on gold).
class NumberBadge extends StatelessWidget {
  const NumberBadge(this.number, {super.key, this.size});

  final int number;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final d = size ?? 40.r;
    return Container(
      width: d,
      height: d,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.secondaryGold.withValues(alpha: 0.12),
        border: Border.all(
          color: AppColors.secondaryGold.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.r),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '$number',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.secondaryGold,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _SurahTile extends StatelessWidget {
  const _SurahTile({required this.surah, required this.onTap});

  final Surah surah;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    return AppCard(
      onTap: onTap,
      padding: AppSpacing.tile,
      borderRadius: AppRadius.mdAll,
      semanticLabel: '${surah.number}. ${surah.englishName}',
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppSizes.minTapTarget),
        child: Row(
          children: [
            NumberBadge(surah.number),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    surah.englishName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppSpacing.vXs),
                  Text(
                    '${surah.englishNameTranslation} • '
                    '${_revelationLabel(context, surah.revelationType)} • '
                    '${surah.numberOfAyahs} ${l10n.ayahs}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 110.w),
              child: ArabicText(
                surah.name,
                fontSize: 20.sp,
                height: 1.4,
                color: AppColors.secondaryGold,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContinueReadingCard extends StatelessWidget {
  const _ContinueReadingCard({
    required this.surah,
    required this.ayah,
    required this.onTap,
  });

  final Surah surah;
  final int ayah;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    return AppCard(
      onTap: onTap,
      blur: true,
      border: Border.all(color: AppColors.brass, width: 1.2),
      semanticLabel:
          '${l10n.continue_reading}: ${surah.englishName}, ${l10n.ayah} $ayah',
      child: Row(
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.secondaryGold.withValues(alpha: 0.15),
            ),
            child: Icon(
              Icons.auto_stories_rounded,
              color: AppColors.secondaryGold,
              size: 22.sp,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.continue_reading,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelLarge?.copyWith(
                    color: AppColors.secondaryGold,
                  ),
                ),
                SizedBox(height: AppSpacing.vXs),
                Text(
                  '${surah.englishName} • ${l10n.ayah} $ayah',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded, // mirrors automatically in RTL
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
