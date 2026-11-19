import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/localization/app_localizations.dart';
import '../../domain/entities/saved_verse.dart';
import '../../domain/entities/surah.dart';
import '../blocs/pulse_bloc.dart';
import '../blocs/quran_bloc.dart';
import '../widgets/widgets.dart';
import 'surah_detail_page.dart';

final RegExp _rtlScript = RegExp(r'[֐-ࣿיִ-﷿ﹰ-﻿]');

/// Saved ayat; updates live from [PulseBloc]. Swipe or tap the remove
/// button to unsave (with undo); tap a card to open its surah.
class SavedVersesPage extends StatefulWidget {
  const SavedVersesPage({super.key});

  @override
  State<SavedVersesPage> createState() => _SavedVersesPageState();
}

class _SavedVersesPageState extends State<SavedVersesPage> {
  /// Ids removed in this session but possibly not yet reflected in the bloc
  /// state (a dismissed Dismissible must leave the tree immediately).
  final Set<String> _removed = {};

  void _remove(SavedVerse verse) {
    final bloc = context.read<PulseBloc>();
    setState(() => _removed.add(verse.id));
    bloc.add(ToggleSaveVerse(verse));
    final l10n = context.l10n;
    showAppSnackBar(
      context,
      l10n.verse_removed,
      type: SnackType.success,
      actionLabel: l10n.profile_undo,
      onAction: () {
        bloc.add(ToggleSaveVerse(verse));
        if (mounted) setState(() => _removed.remove(verse.id));
      },
    );
  }

  void _open(SavedVerse verse) {
    Surah? surah;
    try {
      final quran = context.read<QuranBloc>().state;
      if (quran is QuranLoaded) {
        for (final s in quran.surahs) {
          if (s.number == verse.surahNumber) {
            surah = s;
            break;
          }
        }
      }
    } catch (_) {
      // No QuranBloc above this page: fall back to the saved data.
    }
    surah ??= Surah(
      number: verse.surahNumber,
      name: '',
      englishName: verse.surahName,
      englishNameTranslation: '',
      numberOfAyahs: 0,
      revelationType: '',
    );
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder:
            (_) =>
                SurahDetailPage(surah: surah!, initialAyah: verse.ayahNumber),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppScaffold(
      title: l10n.profile_saved_verses,
      body: BlocBuilder<PulseBloc, PulseState>(
        builder: (context, state) {
          if (state is PulseInitial || state is PulseLoading) {
            return const StateView.loading();
          }
          if (state is PulseError) {
            return StateView.error(
              message: l10n.pulse_load_failed,
              onRetry: () => context.read<PulseBloc>().add(LoadPulseData()),
            );
          }
          final loaded = state as PulseLoaded;
          // Forget local removals once the bloc no longer has them.
          final ids = {for (final v in loaded.savedVerses) v.id};
          _removed.retainAll(ids);
          final verses =
              loaded.savedVerses.where((v) => !_removed.contains(v.id)).toList()
                ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
          if (verses.isEmpty) {
            return StateView.empty(
              icon: Icons.bookmark_border_rounded,
              message: l10n.profile_no_saved_verses,
            );
          }
          return ListView.separated(
            padding: AppSpacing.page,
            itemCount: verses.length,
            separatorBuilder: (_, _) => SizedBox(height: AppSpacing.vMd),
            itemBuilder: (context, index) {
              final verse = verses[index];
              return Dismissible(
                key: ValueKey('saved_${verse.id}'),
                onDismissed: (_) => _remove(verse),
                background: const _DismissBackground(
                  alignment: AlignmentDirectional.centerStart,
                ),
                secondaryBackground: const _DismissBackground(
                  alignment: AlignmentDirectional.centerEnd,
                ),
                child: _SavedVerseCard(
                  verse: verse,
                  onTap: () => _open(verse),
                  onRemove: () => _remove(verse),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _DismissBackground extends StatelessWidget {
  const _DismissBackground({required this.alignment});

  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      padding: EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.15),
        borderRadius: AppRadius.lgAll,
      ),
      child: Icon(
        Icons.delete_outline_rounded,
        color: AppColors.error,
        size: 24.sp,
      ),
    );
  }
}

class _SavedVerseCard extends StatelessWidget {
  const _SavedVerseCard({
    required this.verse,
    required this.onTap,
    required this.onRemove,
  });

  final SavedVerse verse;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final translation = verse.translation?.trim();
    return AppCard(
      onTap: onTap,
      padding: AppSpacing.only(start: 16, top: 8, end: 4, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${verse.surahName} · ${verse.surahNumber}:${verse.ayahNumber}',
                  style: textTheme.titleSmall?.copyWith(
                    color: AppColors.secondaryGold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                tooltip: l10n.profile_remove_verse,
                onPressed: onRemove,
                icon: Icon(Icons.bookmark_remove_outlined, size: 22.sp),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsetsDirectional.only(end: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ArabicText(verse.text, fontSize: 22.sp),
                if (translation != null && translation.isNotEmpty) ...[
                  SizedBox(height: AppSpacing.vSm),
                  TranslationText(
                    translation,
                    isLtr: !_rtlScript.hasMatch(translation),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
