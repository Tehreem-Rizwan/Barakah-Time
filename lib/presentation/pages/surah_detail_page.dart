import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/services/audio_service.dart';
import '../../core/utils/arabic_text.dart' as arabic_utils;
import '../../data/repositories/quran_repository.dart';
import '../../domain/entities/ayah.dart';
import '../../domain/entities/saved_verse.dart';
import '../../domain/entities/spiritual_activity.dart';
import '../../domain/entities/surah.dart';
import '../../injection_container.dart';
import '../blocs/pulse_bloc.dart';
import '../blocs/quran_bloc.dart';
import '../blocs/settings_bloc.dart';
import '../widgets/widgets.dart';
import 'mushaf_view.dart';
import 'quran_page.dart' show NumberBadge;

/// "Continue reading" position, stored in SharedPreferences.
class QuranLastRead {
  static const surahKey = 'last_read_surah';
  static const ayahKey = 'last_read_ayah';

  final int surah;
  final int ayah;
  const QuranLastRead(this.surah, this.ayah);

  static SharedPreferences? get _prefs =>
      sl.isRegistered<SharedPreferences>() ? sl<SharedPreferences>() : null;

  static QuranLastRead? load() {
    final prefs = _prefs;
    final surah = prefs?.getInt(surahKey);
    if (surah == null || surah < 1 || surah > 114) return null;
    final ayah = prefs?.getInt(ayahKey) ?? 1;
    return QuranLastRead(surah, ayah < 1 ? 1 : ayah);
  }

  static Future<void> save(int surah, int ayah) async {
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.setInt(surahKey, surah);
    await prefs.setInt(ayahKey, ayah);
  }
}

/// Language code of an alquran.cloud edition id (`en.asad` → `en`).
String translationLanguageOf(String edition) {
  final code = edition.split('.').first.toLowerCase();
  return code.isEmpty ? 'en' : code;
}

/// Whether translation text in [languageCode] is written left-to-right.
bool isLtrLanguage(String languageCode) =>
    const {'en', 'tr'}.contains(languageCode);

class SurahDetailPage extends StatefulWidget {
  final Surah surah;

  /// Optional ayah (1-based, within the surah) to scroll to when opened.
  final int? initialAyah;

  const SurahDetailPage({super.key, required this.surah, this.initialAyah});

  @override
  State<SurahDetailPage> createState() => _SurahDetailPageState();
}

class _SurahDetailPageState extends State<SurahDetailPage> {
  late Future<List<Ayah>> _ayahsFuture;
  late String _edition;
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _ayahKeys = {};
  bool _scrolledToInitial = false;

  /// Ids logged during this page session (covers the window before
  /// PulseBloc reloads its state).
  final Set<String> _loggedIds = {};

  @override
  void initState() {
    super.initState();
    _edition = _readEdition();
    _load();
    QuranLastRead.save(widget.surah.number, widget.initialAyah ?? 1);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _readEdition() {
    try {
      return context.read<QuranBloc>().translationEdition;
    } catch (_) {
      return QuranRepository.defaultTranslationEdition;
    }
  }

  String get _translationLang => translationLanguageOf(_edition);

  void _load({bool forceRefresh = false}) {
    _ayahsFuture = sl<QuranRepository>().getSurahWithTranslation(
      widget.surah.number,
      translationEdition: _edition,
      forceRefresh: forceRefresh,
    );
  }

  GlobalKey _keyFor(int ayah) => _ayahKeys.putIfAbsent(ayah, GlobalKey.new);

  /// Scrolls to [widget.initialAyah]. Items far down the list are not built
  /// yet, so jump to an estimated offset first and retry a few frames.
  void _scrollToInitial(int itemCount, int index, [int attempt = 0]) {
    if (!mounted || attempt > 6) return;
    final ctx = _ayahKeys[widget.initialAyah]?.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: AppDurations.medium,
        curve: AppDurations.curve,
        alignment: 0.05,
      );
      return;
    }
    if (_scrollController.hasClients) {
      final pos = _scrollController.position;
      final estimate = pos.maxScrollExtent * index / itemCount;
      _scrollController.jumpTo(estimate.clamp(0, pos.maxScrollExtent));
    }
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollToInitial(itemCount, index, attempt + 1),
    );
  }

  String get _readActivityId {
    final now = DateTime.now();
    final day =
        '${now.year.toString().padLeft(4, '0')}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}';
    return 'surah_${widget.surah.number}_$day';
  }

  bool _alreadyLoggedToday(String id) {
    if (_loggedIds.contains(id)) return true;
    final state = context.read<PulseBloc>().state;
    if (state is PulseLoaded) {
      return state.pulse.recentActivities.any((a) => a.id == id);
    }
    return false;
  }

  void _markAsRead() {
    final l10n = context.l10n;
    final id = _readActivityId;
    if (_alreadyLoggedToday(id)) {
      showAppSnackBar(
        context,
        l10n.surah_already_logged_today,
        duration: const Duration(seconds: 2),
      );
      return;
    }
    _loggedIds.add(id);
    // Finished this surah: "Continue reading" points at the next one.
    final next = widget.surah.number < 114 ? widget.surah.number + 1 : 1;
    QuranLastRead.save(next, 1);
    final activity = SpiritualActivity(
      id: id,
      type: 'quran',
      subType: widget.surah.englishName,
      timestamp: DateTime.now(),
      points: 20, // 20 points for reading a surah
    );
    context.read<PulseBloc>().add(LogActivity(activity));
    showAppSnackBar(
      context,
      l10n.surah_logged.replaceAll('{name}', widget.surah.englishName),
      type: SnackType.success,
      duration: const Duration(seconds: 2),
    );
  }

  void _toggleSave(Ayah ayah, bool isSaved) {
    final verseId = '${widget.surah.number}:${ayah.numberInSurah}';
    context.read<PulseBloc>().add(
      ToggleSaveVerse(
        SavedVerse(
          id: verseId,
          surahNumber: widget.surah.number,
          ayahNumber: ayah.numberInSurah,
          text: ayah.text,
          translation: ayah.translation,
          surahName: widget.surah.englishName,
          timestamp: DateTime.now(),
        ),
      ),
    );
    QuranLastRead.save(widget.surah.number, ayah.numberInSurah);
    showAppSnackBar(
      context,
      isSaved ? context.l10n.verse_removed : context.l10n.verse_saved,
      type: isSaved ? SnackType.info : SnackType.success,
      duration: const Duration(seconds: 2),
    );
  }

  void _share(Ayah ayah) {
    final l10n = context.l10n;
    final heading = l10n.share_ayah_heading
        .replaceAll('{ayah}', '${ayah.numberInSurah}')
        .replaceAll('{surah}', widget.surah.englishName);
    final buffer = StringBuffer('📖 $heading\n\n${ayah.text}\n');
    if ((ayah.translation ?? '').isNotEmpty) {
      buffer.write('\n${ayah.translation}\n');
    }
    buffer.write('\n${l10n.shared_from_app} ✨');
    Share.share(buffer.toString());
  }

  String get _surahMediaId => 'surah_${widget.surah.number}';

  /// Whole-surah playback for the current mode. Mushaf: Arabic only.
  /// Translation: each ayah followed by its recorded translation, when one
  /// exists for the language (otherwise Arabic only).
  ({List<String> urls, String mediaId}) _surahPlaylist(
    List<Ayah> ayahs,
    bool mushaf,
  ) {
    if (mushaf) {
      return (
        urls: ayahs.map((a) => a.audio).whereType<String>().toList(),
        mediaId: _surahMediaId,
      );
    }
    final urls = <String>[];
    for (final a in ayahs) {
      if (a.audio != null) urls.add(a.audio!);
      final tr = QuranRepository.translationAudioUrl(
        _translationLang,
        a.number,
      );
      if (tr != null) urls.add(tr);
    }
    return (urls: urls, mediaId: '${_surahMediaId}_tr');
  }

  /// Whether [status] belongs to this surah's playback in the given mode
  /// (including "play from here" in mushaf mode).
  bool _isSurahMedia(AudioStatus status, bool mushaf) {
    final id = status.mediaId;
    if (id == null) return false;
    if (!mushaf) return id == '${_surahMediaId}_tr';
    return id == _surahMediaId || id.startsWith('${_surahMediaId}_from_');
  }

  void _toggleSurahPlayback(List<Ayah> ayahs, bool mushaf) {
    final audio = sl<AudioService>();
    final status = audio.status;
    if (_isSurahMedia(status, mushaf)) {
      if (status.isPlaying) {
        audio.pause();
        return;
      }
      if (status.isPaused) {
        audio.resume();
        return;
      }
    }
    final list = _surahPlaylist(ayahs, mushaf);
    audio.playList(
      list.urls,
      title: widget.surah.englishName,
      artist: 'Mishary Rashid Alafasy',
      mediaId: list.mediaId,
    );
  }

  /// Mushaf mode: recite from ayah [index] to the end of the surah.
  void _playFrom(List<Ayah> ayahs, int index) {
    final urls =
        ayahs.skip(index).map((a) => a.audio).whereType<String>().toList();
    if (urls.isEmpty) return;
    QuranLastRead.save(widget.surah.number, ayahs[index].numberInSurah);
    sl<AudioService>().playList(
      urls,
      title: widget.surah.englishName,
      artist: 'Mishary Rashid Alafasy',
      mediaId: index == 0 ? _surahMediaId : '${_surahMediaId}_from_$index',
    );
  }

  void _setMode(String mode) {
    context.read<SettingsBloc>().add(UpdateQuranMode(mode));
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
  }

  /// Mushaf mode: tapping an ayah shows its translation and actions.
  void _showAyahSheet(List<Ayah> ayahs, int index) {
    final ayah = ayahs[index];
    final l10n = context.l10n;
    final verseId = '${widget.surah.number}:${ayah.numberInSurah}';
    final lang = _translationLang;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.cardDark,
      builder:
          (sheetContext) => SafeArea(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.75,
              ),
              child: SingleChildScrollView(
                padding: EdgeInsetsDirectional.fromSTEB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.vLg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '${widget.surah.englishName} · ${l10n.ayah} ${ayah.numberInSurah}',
                      textAlign: TextAlign.center,
                      style: Theme.of(sheetContext).textTheme.titleMedium,
                    ),
                    SizedBox(height: AppSpacing.vMd),
                    ArabicText(
                      ayah.text,
                      textAlign: TextAlign.center,
                      fontSize:
                          context.read<SettingsBloc>().state.quranFontSize.sp,
                      height: 2.2,
                    ),
                    if ((ayah.translation ?? '').isNotEmpty) ...[
                      SizedBox(height: AppSpacing.vMd),
                      TranslationText(
                        ayah.translation!,
                        isLtr: isLtrLanguage(lang),
                      ),
                    ],
                    SizedBox(height: AppSpacing.vLg),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.vSm,
                      children: [
                        FilledButton.icon(
                          style: dialogActionStyle(
                            background: AppColors.secondaryGold,
                            foreground: AppColors.onGold,
                          ),
                          onPressed:
                              ayah.audio == null
                                  ? null
                                  : () {
                                    Navigator.pop(sheetContext);
                                    _playFrom(ayahs, index);
                                  },
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: Text(l10n.play_from_here),
                        ),
                        BlocBuilder<PulseBloc, PulseState>(
                          bloc: context.read<PulseBloc>(),
                          builder: (_, state) {
                            final isSaved =
                                state is PulseLoaded &&
                                state.savedVerses.any((v) => v.id == verseId);
                            return OutlinedButton.icon(
                              style: dialogActionStyle(),
                              onPressed: () => _toggleSave(ayah, isSaved),
                              icon: Icon(
                                isSaved
                                    ? Icons.bookmark_rounded
                                    : Icons.bookmark_border_rounded,
                              ),
                              label: Text(
                                isSaved
                                    ? l10n.remove_saved_verse
                                    : l10n.save_verse,
                              ),
                            );
                          },
                        ),
                        OutlinedButton.icon(
                          style: dialogActionStyle(),
                          onPressed: () => _share(ayah),
                          icon: const Icon(Icons.share_outlined),
                          label: Text(l10n.share),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final audioService = sl<AudioService>();
    final mushaf = context.select<SettingsBloc, bool>(
      (b) => b.state.quranMode == 'mushaf',
    );
    return AppScaffold(
      bottomBar: const AudioControlBar(),
      titleWidget: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.surah.englishName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          // Room for the Arabic diacritics so they don't touch the line above.
          SizedBox(height: 4.h),
          ArabicText(
            widget.surah.name,
            fontSize: 13.sp,
            height: 1.6,
            color: AppColors.secondaryGold,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      actions: [
        BlocBuilder<PulseBloc, PulseState>(
          builder: (context, state) {
            final logged = _alreadyLoggedToday(_readActivityId);
            return IconButton(
              icon: Icon(
                logged
                    ? Icons.check_circle_rounded
                    : Icons.check_circle_outline_rounded,
              ),
              onPressed: _markAsRead,
              tooltip:
                  logged ? l10n.surah_already_logged_today : l10n.mark_as_read,
            );
          },
        ),
        FutureBuilder<List<Ayah>>(
          future: _ayahsFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox.shrink();
            return StreamBuilder<AudioStatus>(
              stream: audioService.statusStream,
              initialData: audioService.status,
              builder: (context, statusSnapshot) {
                final status = statusSnapshot.data ?? AudioStatus.idle;
                final isPlaying =
                    status.isPlaying && _isSurahMedia(status, mushaf);
                return IconButton(
                  icon: Icon(
                    isPlaying
                        ? Icons.pause_circle_filled_rounded
                        : Icons.play_circle_fill_rounded,
                  ),
                  onPressed: () => _toggleSurahPlayback(snapshot.data!, mushaf),
                  tooltip: isPlaying ? l10n.pause : l10n.play_surah,
                );
              },
            );
          },
        ),
        SizedBox(width: AppSpacing.xs),
      ],
      body: FutureBuilder<List<Ayah>>(
        future: _ayahsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SkeletonList(
              itemCount: 4,
              itemHeight: 160.h,
              showLeading: false,
            );
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return StateView.error(
              icon: Icons.cloud_off_rounded,
              message: l10n.surah_load_error,
              onRetry: () => setState(() => _load(forceRefresh: true)),
            );
          }

          final ayahs = snapshot.data!;
          final showBismillah = arabic_utils.ArabicText.surahHasBismillahPrefix(
            widget.surah.number,
          );
          final header = _SurahHeader(
            surah: widget.surah,
            showBismillah: showBismillah,
            textTheme: textTheme,
          );
          return Column(
            children: [
              Padding(
                padding: AppSpacing.only(start: 20, end: 20, top: 4, bottom: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<String>(
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(
                        value: 'mushaf',
                        icon: const Icon(Icons.menu_book_rounded),
                        label: Text(l10n.mushaf),
                      ),
                      ButtonSegment(
                        value: 'translation',
                        icon: const Icon(Icons.translate_rounded),
                        label: Text(l10n.translation),
                      ),
                    ],
                    selected: {mushaf ? 'mushaf' : 'translation'},
                    onSelectionChanged: (s) => _setMode(s.first),
                  ),
                ),
              ),
              Expanded(
                child:
                    mushaf
                        ? BlocBuilder<SettingsBloc, SettingsState>(
                          buildWhen:
                              (p, c) => p.quranFontSize != c.quranFontSize,
                          builder:
                              (context, settings) => MushafView(
                                surahNumber: widget.surah.number,
                                ayahs: ayahs,
                                header: header,
                                fontSize: settings.quranFontSize.sp,
                                initialAyah: widget.initialAyah,
                                scrollController: _scrollController,
                                onAyahTap: (i) => _showAyahSheet(ayahs, i),
                              ),
                        )
                        : _buildTranslationList(ayahs, header),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTranslationList(List<Ayah> ayahs, Widget header) {
    final headerCount = 1;
    final target = widget.initialAyah;
    if (!_scrolledToInitial &&
        target != null &&
        target > 1 &&
        target <= ayahs.length) {
      _scrolledToInitial = true;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _scrollToInitial(
          ayahs.length + headerCount,
          target - 1 + headerCount,
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: AppSpacing.only(start: 20, end: 20, top: 8, bottom: 40),
      itemCount: ayahs.length + headerCount,
      itemBuilder: (context, index) {
        if (index == 0) return header;
        final ayah = ayahs[index - headerCount];
        return Padding(
          key: _keyFor(ayah.numberInSurah),
          padding: EdgeInsetsDirectional.only(bottom: AppSpacing.vLg),
          child: _buildAyah(context, ayah),
        );
      },
    );
  }

  Widget _buildAyah(BuildContext context, Ayah ayah) {
    final l10n = context.l10n;
    final audioService = sl<AudioService>();
    final ayahMediaId = 'ayah_${widget.surah.number}_${ayah.numberInSurah}';
    final transMediaId = 'trans_${widget.surah.number}_${ayah.numberInSurah}';
    final verseId = '${widget.surah.number}:${ayah.numberInSurah}';
    final highlighted = widget.initialAyah == ayah.numberInSurah;
    final lang = _translationLang;

    return AppCard(
      border:
          highlighted
              ? Border.all(
                color: AppColors.secondaryGold.withValues(alpha: 0.6),
              )
              : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              NumberBadge(ayah.numberInSurah, size: 34.r),
              const Spacer(),
              BlocBuilder<PulseBloc, PulseState>(
                builder: (context, state) {
                  final isSaved =
                      state is PulseLoaded &&
                      state.savedVerses.any((v) => v.id == verseId);
                  return IconButton(
                    tooltip:
                        isSaved ? l10n.remove_saved_verse : l10n.save_verse,
                    icon: Icon(
                      isSaved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      color:
                          isSaved
                              ? AppColors.secondaryGold
                              : AppColors.textSecondary,
                      size: 22.sp,
                    ),
                    onPressed: () => _toggleSave(ayah, isSaved),
                  );
                },
              ),
              StreamBuilder<AudioStatus>(
                stream: audioService.statusStream,
                initialData: audioService.status,
                builder: (context, snapshot) {
                  final status = snapshot.data ?? AudioStatus.idle;
                  final isPlaying = status.isPlayingMedia(ayahMediaId);
                  final isTransPlaying = status.isPlayingMedia(transMediaId);
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: AppColors.secondaryGold,
                          size: 24.sp,
                        ),
                        tooltip: isPlaying ? l10n.pause : l10n.play,
                        onPressed:
                            ayah.audio == null
                                ? null
                                : () {
                                  QuranLastRead.save(
                                    widget.surah.number,
                                    ayah.numberInSurah,
                                  );
                                  audioService.playUrl(
                                    ayah.audio!,
                                    title:
                                        '${widget.surah.englishName} : ${l10n.ayah} ${ayah.numberInSurah}',
                                    mediaId: ayahMediaId,
                                  );
                                },
                      ),
                      IconButton(
                        icon: Icon(
                          isTransPlaying
                              ? Icons.stop_circle_outlined
                              : Icons.record_voice_over_outlined,
                          color:
                              isTransPlaying
                                  ? AppColors.secondaryGold
                                  : AppColors.textSecondary,
                          size: 22.sp,
                        ),
                        tooltip:
                            isTransPlaying
                                ? l10n.stop
                                : l10n.listen_translation,
                        onPressed:
                            (ayah.translation ?? '').isEmpty
                                ? null
                                : () {
                                  if (isTransPlaying) {
                                    audioService.stop();
                                    return;
                                  }
                                  final title =
                                      '${l10n.translation}: ${l10n.ayah} ${ayah.numberInSurah}';
                                  // Prefer a person reading the translation
                                  // (e.g. Urdu by Shamshad Ali Khan); fall back
                                  // to the phone's text-to-speech.
                                  final url =
                                      QuranRepository.translationAudioUrl(
                                        lang,
                                        ayah.number,
                                      );
                                  if (url != null) {
                                    audioService.playUrl(
                                      url,
                                      title: title,
                                      artist:
                                          QuranRepository.translationReciter(
                                            lang,
                                          ),
                                      mediaId: transMediaId,
                                    );
                                  } else {
                                    audioService.playTts(
                                      ayah.translation!,
                                      title: title,
                                      mediaId: transMediaId,
                                      languageCode: lang,
                                    );
                                  }
                                },
                      ),
                    ],
                  );
                },
              ),
              IconButton(
                tooltip: l10n.share,
                onPressed: () => _share(ayah),
                icon: Icon(
                  Icons.share_outlined,
                  color: AppColors.textSecondary,
                  size: 22.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.vMd),
          BlocBuilder<SettingsBloc, SettingsState>(
            buildWhen: (p, c) => p.quranFontSize != c.quranFontSize,
            builder:
                (context, settingsState) => ArabicText(
                  ayah.text,
                  fontSize: settingsState.quranFontSize.sp,
                  height: 2.2,
                ),
          ),
          if ((ayah.translation ?? '').isNotEmpty) ...[
            SizedBox(height: AppSpacing.vMd),
            TranslationText(ayah.translation!, isLtr: isLtrLanguage(lang)),
          ],
        ],
      ),
    );
  }
}

class _SurahHeader extends StatelessWidget {
  const _SurahHeader({
    required this.surah,
    required this.showBismillah,
    required this.textTheme,
  });

  final Surah surah;
  final bool showBismillah;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final type = surah.revelationType.toLowerCase();
    final revelation = type.startsWith('med') ? l10n.medinan : l10n.meccan;
    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: AppSpacing.vLg),
      child: AppCard(
        blur: true,
        border: Border.all(color: AppColors.brass, width: 1.2),
        child: Column(
          children: [
            Text(
              surah.englishNameTranslation,
              textAlign: TextAlign.center,
              style: textTheme.titleMedium,
            ),
            SizedBox(height: AppSpacing.vXs),
            Text(
              '$revelation • ${surah.numberOfAyahs} ${l10n.ayahs}',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (showBismillah) ...[
              Divider(height: AppSpacing.vXl),
              ArabicText(
                'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                textAlign: TextAlign.center,
                fontSize: 24.sp,
                color: AppColors.secondaryGold,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
