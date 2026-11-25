import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/services/audio_service.dart';
import '../../domain/entities/ayah.dart';
import '../../injection_container.dart';
import '../widgets/widgets.dart';

/// Arabic-Indic digits (١٢٣) for ayah markers.
String arabicDigits(int n) {
  const digits = '٠١٢٣٤٥٦٧٨٩';
  return n.toString().split('').map((d) => digits[int.parse(d)]).join();
}

/// End-of-ayah marker, e.g. ﴿١٢﴾. U+FD3F / U+FD3E are not mirrored, so
/// in right-to-left text the "﴿" comes first to sit on the right. A no-break
/// space keeps the marker on the same line as the ayah's last word.
String ayahMarker(int numberInSurah) => ' ﴿${arabicDigits(numberInSurah)}﴾';

/// One printed-mushaf page worth of a surah's ayahs.
class MushafPage {
  const MushafPage({
    required this.page,
    required this.juz,
    required this.start,
    required this.end,
  });

  /// Page number in the standard Madani mushaf (1–604).
  final int page;
  final int juz;

  /// Index range in the surah's ayah list: [start, end).
  final int start;
  final int end;

  bool contains(int index) => index >= start && index < end;
}

/// Splits [ayahs] into pages using each ayah's mushaf page number, so the
/// page breaks match the printed Madani mushaf.
List<MushafPage> groupAyahsByPage(List<Ayah> ayahs) {
  final pages = <MushafPage>[];
  var start = 0;
  for (var i = 1; i <= ayahs.length; i++) {
    if (i == ayahs.length || ayahs[i].page != ayahs[start].page) {
      pages.add(
        MushafPage(
          page: ayahs[start].page,
          juz: ayahs[start].juz,
          start: start,
          end: i,
        ),
      );
      start = i;
    }
  }
  return pages;
}

/// Index of the ayah being recited for this surah, or null.
///
/// Mushaf playback uses media ids `surah_<n>` (whole surah) or
/// `surah_<n>_from_<i>` (from ayah index i); the player's current index is
/// relative to where playback started.
int? playingAyahIndex(AudioStatus status, int? playerIndex, int surah) {
  final id = status.mediaId;
  if (id == null || playerIndex == null || !status.isActive) return null;
  final base = 'surah_$surah';
  if (id == base) return playerIndex;
  final prefix = '${base}_from_';
  if (id.startsWith(prefix)) {
    final offset = int.tryParse(id.substring(prefix.length));
    if (offset != null) return offset + playerIndex;
  }
  return null;
}

/// Arabic-only reading view laid out in mushaf pages.
class MushafView extends StatefulWidget {
  const MushafView({
    super.key,
    required this.surahNumber,
    required this.ayahs,
    required this.header,
    required this.fontSize,
    required this.onAyahTap,
    this.initialAyah,
    this.scrollController,
  });

  final int surahNumber;
  final List<Ayah> ayahs;

  /// Shown above the first page (surah name, bismillah).
  final Widget header;
  final double fontSize;

  /// Called with the tapped ayah's index in [ayahs].
  final ValueChanged<int> onAyahTap;

  /// Ayah (1-based, within the surah) to scroll to and mark when opened.
  final int? initialAyah;
  final ScrollController? scrollController;

  @override
  State<MushafView> createState() => _MushafViewState();
}

class _MushafViewState extends State<MushafView> {
  late List<MushafPage> _pages = groupAyahsByPage(widget.ayahs);
  final Map<int, GlobalKey> _pageKeys = {};
  int? _followedPage;
  bool _scrolledToInitial = false;

  AudioService? get _audio =>
      sl.isRegistered<AudioService>() ? sl<AudioService>() : null;

  @override
  void didUpdateWidget(MushafView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.ayahs, widget.ayahs)) {
      _pages = groupAyahsByPage(widget.ayahs);
    }
  }

  GlobalKey _keyFor(int page) => _pageKeys.putIfAbsent(page, GlobalKey.new);

  int _pageIndexOf(int ayahIndex) =>
      _pages.indexWhere((p) => p.contains(ayahIndex));

  void _ensurePageVisible(int pageIndex, [int attempt = 0]) {
    if (!mounted || pageIndex < 0 || attempt > 6) return;
    final ctx = _pageKeys[_pages[pageIndex].page]?.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: AppDurations.medium,
        curve: AppDurations.curve,
        alignment: 0.02,
      );
      return;
    }
    // Not built yet: jump close to it, then retry.
    final controller = widget.scrollController;
    if (controller != null && controller.hasClients) {
      final pos = controller.position;
      final estimate =
          pos.maxScrollExtent * (pageIndex + 1) / (_pages.length + 1);
      controller.jumpTo(estimate.clamp(0, pos.maxScrollExtent));
    }
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _ensurePageVisible(pageIndex, attempt + 1),
    );
  }

  /// Keeps the page being recited on screen.
  void _follow(int? playing) {
    if (playing == null) return;
    final pageIndex = _pageIndexOf(playing);
    if (pageIndex < 0 || pageIndex == _followedPage) return;
    _followedPage = pageIndex;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _ensurePageVisible(pageIndex),
    );
  }

  @override
  Widget build(BuildContext context) {
    final initial = widget.initialAyah;
    if (!_scrolledToInitial && initial != null && initial > 1) {
      _scrolledToInitial = true;
      final pageIndex = _pageIndexOf(initial - 1);
      if (pageIndex > 0) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _ensurePageVisible(pageIndex),
        );
      }
    }
    final audio = _audio;
    if (audio == null) return _buildList(context, null);
    return StreamBuilder<AudioStatus>(
      stream: audio.statusStream,
      initialData: audio.status,
      builder:
          (context, status) => StreamBuilder<int?>(
            stream: audio.currentIndexStream,
            initialData: audio.currentIndex,
            builder: (context, index) {
              final playing = playingAyahIndex(
                status.data ?? AudioStatus.idle,
                index.data,
                widget.surahNumber,
              );
              _follow(playing);
              return _buildList(context, playing);
            },
          ),
    );
  }

  Widget _buildList(BuildContext context, int? playing) {
    final markIndex =
        playing ??
        (widget.initialAyah == null ? null : widget.initialAyah! - 1);
    return ListView.builder(
      controller: widget.scrollController,
      padding: AppSpacing.only(start: 16, end: 16, top: 8, bottom: 40),
      itemCount: _pages.length + 1,
      itemBuilder: (context, i) {
        if (i == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              widget.header,
              Padding(
                padding: EdgeInsetsDirectional.only(bottom: AppSpacing.vMd),
                child: Text(
                  context.l10n.mushaf_tap_hint,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          );
        }
        final page = _pages[i - 1];
        return Padding(
          key: _keyFor(page.page),
          padding: EdgeInsetsDirectional.only(bottom: AppSpacing.vMd),
          child: _MushafPageCard(
            page: page,
            ayahs: widget.ayahs,
            fontSize: widget.fontSize,
            markedIndex:
                markIndex != null && page.contains(markIndex)
                    ? markIndex
                    : null,
            isPlaying: playing != null,
            onAyahTap: widget.onAyahTap,
          ),
        );
      },
    );
  }
}

class _MushafPageCard extends StatefulWidget {
  const _MushafPageCard({
    required this.page,
    required this.ayahs,
    required this.fontSize,
    required this.markedIndex,
    required this.isPlaying,
    required this.onAyahTap,
  });

  final MushafPage page;
  final List<Ayah> ayahs;
  final double fontSize;

  /// Ayah to highlight (being recited, or the one the user came to read).
  final int? markedIndex;
  final bool isPlaying;
  final ValueChanged<int> onAyahTap;

  @override
  State<_MushafPageCard> createState() => _MushafPageCardState();
}

class _MushafPageCardState extends State<_MushafPageCard> {
  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void initState() {
    super.initState();
    _buildRecognizers();
  }

  @override
  void didUpdateWidget(_MushafPageCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.page.start != widget.page.start ||
        oldWidget.page.end != widget.page.end ||
        oldWidget.onAyahTap != widget.onAyahTap) {
      _disposeRecognizers();
      _buildRecognizers();
    }
  }

  void _buildRecognizers() {
    for (var i = widget.page.start; i < widget.page.end; i++) {
      _recognizers.add(
        TapGestureRecognizer()..onTap = () => widget.onAyahTap(i),
      );
    }
  }

  void _disposeRecognizers() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
  }

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final page = widget.page;
    final highlight = AppColors.secondaryGold.withValues(
      alpha: widget.isPlaying ? 0.18 : 0.10,
    );
    final spans = <InlineSpan>[];
    for (var i = page.start; i < page.end; i++) {
      final ayah = widget.ayahs[i];
      final recognizer = _recognizers[i - page.start];
      final marked = widget.markedIndex == i;
      spans
        ..add(
          TextSpan(
            text: ayah.text,
            recognizer: recognizer,
            style: marked ? TextStyle(backgroundColor: highlight) : null,
          ),
        )
        ..add(
          TextSpan(
            text: ayahMarker(ayah.numberInSurah),
            recognizer: recognizer,
            style: TextStyle(
              color: AppColors.secondaryGold,
              backgroundColor: marked ? highlight : null,
            ),
          ),
        );
      if (i < page.end - 1) spans.add(const TextSpan(text: ' '));
    }

    return Container(
      padding: AppSpacing.only(start: 18, end: 18, top: 18, bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.brass.withValues(alpha: 0.55),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text.rich(
            TextSpan(children: spans),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.justify,
            locale: const Locale('ar'),
            style: AppFonts.quran(
              quranFontOf(context),
              TextStyle(
                fontSize: widget.fontSize,
                height: 2.2,
                color: AppColors.textMain,
              ),
            ),
          ),
          Divider(
            height: AppSpacing.vLg,
            color: AppColors.brass.withValues(alpha: 0.35),
          ),
          Text(
            '${l10n.juzN(page.juz)}  ·  ${l10n.pageN(page.page)}',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
