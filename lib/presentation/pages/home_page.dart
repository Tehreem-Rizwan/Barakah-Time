import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:share_plus/share_plus.dart';

import '../../core/constants/daily_ayats.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/services/audio_service.dart';
import '../../domain/entities/prayer_times.dart';
import '../../domain/entities/spiritual_pulse.dart';
import '../../domain/entities/badge.dart';
import '../../domain/entities/user.dart';
import '../../injection_container.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/prayer_bloc.dart';
import '../blocs/pulse_bloc.dart';
import '../widgets/widgets.dart';
import 'duas_page.dart';
import 'hijri_label.dart';
import 'islamic_calendar_page.dart';
import 'main_navigation_scope.dart';
import 'names_all_page.dart';
import 'prayer_times_page.dart';
import 'profile_page.dart' show ProfilePage, UserAvatar;
import 'pulse_page.dart';
import 'qibla_page.dart';
import 'quran_page.dart';
import 'ramadan_page.dart';
import 'tasbeeh_page.dart';
import 'tools_grid_page.dart';

/// Number of daily ayats shown in the slider (starting from today's ayat).
const int _ayatsShown = 5;

/// Index of today's ayat; changes every calendar day.
int dailyAyatStartIndex(DateTime now, int count) {
  if (count == 0) return 0;
  final start = DateTime.utc(now.year, 1, 1);
  final today = DateTime.utc(now.year, now.month, now.day);
  final dayOfYear = today.difference(start).inDays;
  return (now.year * 366 + dayOfYear) % count;
}

/// l10n key of the time-of-day greeting for [now].
String homeGreetingKey(DateTime now) {
  final h = now.hour;
  if (h >= 4 && h < 12) return 'good_morning';
  if (h >= 12 && h < 17) return 'good_afternoon';
  return 'good_evening';
}

/// First name of [user], or [fallback] when the user has no name.
String homeFirstName(UserEntity user, String fallback) {
  if (!user.hasName) return fallback;
  return user.name.trim().split(RegExp(r'\s+')).first;
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _refresh(BuildContext context) =>
      Future.wait([refreshPrayerTimes(context), refreshPulse(context)]);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    Widget padded(Widget child) => SliverToBoxAdapter(
      child: Padding(padding: AppSpacing.pageHorizontal, child: child),
    );
    SliverToBoxAdapter gap(double h) =>
        SliverToBoxAdapter(child: SizedBox(height: h));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.overlayOnBand,
      child: AppScaffold(
        gradientBackground: true,
        safeAreaTop: false,
        body: RefreshIndicator(
          onRefresh: () => _refresh(context),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    // Turquoise tile band behind the greeting and the top of
                    // the prayer arch.
                    IslamicHeaderBand(
                      height: MediaQuery.paddingOf(context).top + 190.h,
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.only(
                        top: MediaQuery.paddingOf(context).top + AppSpacing.vLg,
                        start: AppSpacing.xl,
                        end: AppSpacing.xl,
                      ),
                      child: Column(
                        children: [
                          const _HomeHeader(),
                          SizedBox(height: AppSpacing.vXl),
                          const _PrayerHeroCard(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              padded(const RamadanHomeCard()),
              gap(AppSpacing.vXl),
              padded(
                SectionHeader(
                  title: l10n.essential_tools,
                  actionLabel: l10n.see_all,
                  onAction:
                      () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ToolsGridPage(),
                        ),
                      ),
                ),
              ),
              gap(AppSpacing.vMd),
              padded(const HomeQuickActions()),
              gap(AppSpacing.vXl),
              padded(
                SectionHeader(
                  title: l10n.daily_ayats,
                  icon: Icons.format_quote_rounded,
                ),
              ),
              gap(AppSpacing.vMd),
              const SliverToBoxAdapter(child: _DailyAyatCarousel()),
              gap(AppSpacing.vXl),
              padded(
                SectionHeader(title: l10n.pulse, icon: Icons.bolt_rounded),
              ),
              gap(AppSpacing.vMd),
              padded(const _PulseSummaryCard()),
              gap(AppSpacing.vXxl),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context).languageCode;
    final now = DateTime.now();
    final comma = const {'ar', 'fa', 'ur'}.contains(locale) ? '، ' : ', ';

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, auth) {
        final user = auth is Authenticated ? auth.user : null;
        final name =
            user == null ? null : homeFirstName(user, l10n.default_user_name);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.translate(homeGreetingKey(now)),
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.ivoryOnTeal.withValues(alpha: 0.85),
                    ),
                  ),
                  SizedBox(height: AppSpacing.vXs),
                  Text(
                    name == null
                        ? l10n.assalamualaikum
                        : '${l10n.assalamualaikum}$comma$name',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.headlineSmall?.copyWith(
                      color: AppColors.ivoryOnTeal,
                    ),
                  ),
                  SizedBox(height: AppSpacing.vXs),
                  Text(
                    '${hijriDateLabel(now, l10n)}  ·  '
                    '${gregorianDateLabel(now, locale)}',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.ivoryOnTeal.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Tooltip(
              message: l10n.profile,
              child: Semantics(
                button: true,
                label: l10n.profile,
                excludeSemantics: true,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap:
                      () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ProfilePage()),
                      ),
                  child: Padding(
                    padding: AppSpacing.all(4),
                    // Ivory disc with a brass ring so it stands out on the
                    // turquoise band.
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.cardDark,
                        border: Border.all(color: AppColors.brass, width: 1.5),
                      ),
                      child: UserAvatar(
                        imagePath: user?.profilePicPath,
                        radius: 22.r,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Next-prayer hero
// ---------------------------------------------------------------------------

class _PrayerHeroCard extends StatelessWidget {
  const _PrayerHeroCard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrayerBloc, PrayerState>(
      buildWhen: keepLoadedWhileReloading,
      builder: (context, state) {
        if (state is PrayerLoaded) {
          return NextPrayerBuilder(
            times: state.prayerTimes,
            builder:
                (context, next, now) =>
                    _PrayerHeroContent(times: state.prayerTimes, next: next),
          );
        }
        if (state is PrayerError) {
          return AppCard(
            padding: EdgeInsets.zero,
            child: PrayerErrorView(state: state),
          );
        }
        return AppCard(
          padding: AppSpacing.symmetric(vertical: 32),
          child: StateView.loading(message: context.l10n.locating),
        );
      },
    );
  }
}

class _PrayerHeroContent extends StatelessWidget {
  const _PrayerHeroContent({required this.times, required this.next});

  final PrayerTimesEntity times;
  final NextPrayer next;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final name =
        next.isTomorrow ? l10n.tomorrow_fajr : l10n.translate(next.prayer.key);

    return LayoutBuilder(
      builder:
          (context, constraints) => AppCard(
            // Mihrab-shaped card with a brass outline.
            borderRadius: archRadius(
              width: constraints.maxWidth,
              archHeight: 70.r,
              bottom: 20.r,
            ),
            border: Border.all(color: AppColors.brass, width: 1.5),
            padding: AppSpacing.only(start: 20, end: 20, top: 34, bottom: 20),
            onTap:
                () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PrayerTimesPage()),
                ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      l10n.prayer_in_label.replaceAll('{prayer}', name),
                      textAlign: TextAlign.center,
                      style: textTheme.titleSmall?.copyWith(
                        color: AppColors.brassDeep,
                        letterSpacing: 0.4,
                      ),
                    ),
                    SizedBox(height: AppSpacing.vXs),
                    Center(
                      child: PrayerCountdown(
                        target: next.time,
                        style: textTheme.displayMedium?.copyWith(
                          color: AppColors.secondaryGold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacing.vSm),
                    const Center(child: PrayerLocationText()),
                    Padding(
                      padding: EdgeInsetsDirectional.symmetric(
                        vertical: AppSpacing.vMd,
                      ),
                      child: const Divider(height: 1),
                    ),
                    _PrayerStrip(times: times, next: next),
                  ],
                ),
              ],
            ),
          ),
    );
  }
}

/// Compact row of the five prayer times; the next one highlighted and
/// logged prayers marked with a check.
class _PrayerStrip extends StatelessWidget {
  const _PrayerStrip({required this.times, required this.next});

  final PrayerTimesEntity times;
  final NextPrayer next;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context).languageCode;

    return BlocBuilder<PulseBloc, PulseState>(
      builder: (context, pulse) {
        return Row(
          children: [
            for (final prayer in PrayerName.values)
              Expanded(
                child: Builder(
                  builder: (context) {
                    final isNext = !next.isTomorrow && next.prayer == prayer;
                    final logged =
                        pulse is PulseLoaded &&
                        pulse.isPrayerLoggedToday(prayer.key);
                    final label = l10n.translate(prayer.key);
                    final time = DateFormat.jm(
                      locale,
                    ).format(times.today.timeOf(prayer));
                    return Semantics(
                      label:
                          '$label $time'
                          '${logged ? ', ${l10n.logged}' : ''}',
                      selected: isNext,
                      excludeSemantics: true,
                      child: Container(
                        margin: AppSpacing.symmetric(horizontal: 2),
                        padding: AppSpacing.symmetric(
                          horizontal: 2,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isNext
                                  ? AppColors.secondaryGold.withValues(
                                    alpha: 0.15,
                                  )
                                  : null,
                          borderRadius: AppRadius.smAll,
                          border:
                              isNext
                                  ? Border.all(
                                    color: AppColors.secondaryGold.withValues(
                                      alpha: 0.4,
                                    ),
                                  )
                                  : null,
                        ),
                        child: Column(
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                label,
                                maxLines: 1,
                                style: textTheme.labelSmall?.copyWith(
                                  color:
                                      isNext
                                          ? AppColors.secondaryGold
                                          : AppColors.textSecondary,
                                ),
                              ),
                            ),
                            SizedBox(height: AppSpacing.vXs),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                time,
                                maxLines: 1,
                                style: textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(height: AppSpacing.vXs),
                            Icon(
                              logged
                                  ? Icons.check_circle_rounded
                                  : Icons.circle_outlined,
                              size: 14.sp,
                              color:
                                  logged
                                      ? AppColors.success
                                      : AppColors.glassStrokeStrong,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Quick actions
// ---------------------------------------------------------------------------

/// Stable identifiers for quick actions (never route on localized labels).
enum HomeQuickAction {
  prayer,
  qibla,
  quran,
  tasbeeh,
  duas,
  names,
  calendar,
  more,
}

/// The 2×4 grid of quick actions on Home.
class HomeQuickActions extends StatelessWidget {
  const HomeQuickActions({super.key});

  static IconData iconOf(HomeQuickAction action) => switch (action) {
    HomeQuickAction.prayer => Icons.access_time_rounded,
    HomeQuickAction.qibla => Icons.explore_outlined,
    HomeQuickAction.quran => Icons.menu_book_rounded,
    HomeQuickAction.tasbeeh => Icons.blur_circular_rounded,
    HomeQuickAction.duas => Icons.volunteer_activism_outlined,
    HomeQuickAction.names => Icons.auto_awesome,
    HomeQuickAction.calendar => Icons.calendar_month_outlined,
    HomeQuickAction.more => Icons.apps_rounded,
  };

  static String labelOf(AppLocalizations l10n, HomeQuickAction action) =>
      switch (action) {
        HomeQuickAction.prayer => l10n.prayer_times,
        HomeQuickAction.qibla => l10n.qibla_short,
        HomeQuickAction.quran => l10n.quran,
        HomeQuickAction.tasbeeh => l10n.tasbeeh_short,
        HomeQuickAction.duas => l10n.duas_short,
        HomeQuickAction.names => l10n.names_99_short,
        HomeQuickAction.calendar => l10n.calendar_short,
        HomeQuickAction.more => l10n.more,
      };

  static void open(BuildContext context, HomeQuickAction action) {
    void push(Widget page) =>
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
    switch (action) {
      case HomeQuickAction.prayer:
        push(const PrayerTimesPage());
      case HomeQuickAction.qibla:
        push(const QiblaPage());
      case HomeQuickAction.quran:
        MainNavigationScope.openTab(
          context,
          MainTab.quran,
          fallback: (_) => const QuranPage(),
        );
      case HomeQuickAction.tasbeeh:
        push(const TasbeehPage());
      case HomeQuickAction.duas:
        push(const DuasPage());
      case HomeQuickAction.names:
        push(const NamesOfAllahPage());
      case HomeQuickAction.calendar:
        push(const IslamicCalendarPage());
      case HomeQuickAction.more:
        push(const ToolsGridPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    const actions = HomeQuickAction.values;
    Widget row(int from) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = from; i < from + 4; i++)
          Expanded(
            child: _QuickActionTile(
              icon: iconOf(actions[i]),
              label: labelOf(l10n, actions[i]),
              onTap: () => open(context, actions[i]),
            ),
          ),
      ],
    );
    return Column(children: [row(0), SizedBox(height: AppSpacing.vMd), row(4)]);
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdAll,
        child: Padding(
          padding: AppSpacing.symmetric(horizontal: 2, vertical: 4),
          child: Column(
            children: [
              GlassBox(
                width: 60.r,
                height: 60.r,
                blur: false,
                // Small mihrab-shaped tile with a brass outline.
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30.r),
                  bottom: Radius.circular(10.r),
                ),
                border: Border.all(color: AppColors.brass, width: 1.2),
                child: Center(
                  child: Icon(
                    icon,
                    color: AppColors.secondaryGold,
                    size: 26.sp,
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.vSm),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Daily ayat
// ---------------------------------------------------------------------------

class _DailyAyatCarousel extends StatefulWidget {
  const _DailyAyatCarousel();

  @override
  State<_DailyAyatCarousel> createState() => _DailyAyatCarouselState();
}

class _DailyAyatCarouselState extends State<_DailyAyatCarousel> {
  final PageController _controller = PageController(viewportFraction: 0.88);
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (dailyAyats.isEmpty) return const SizedBox.shrink();
    // Today's ayat comes first; the slider continues from there.
    final start = dailyAyatStartIndex(DateTime.now(), dailyAyats.length);
    final count =
        dailyAyats.length < _ayatsShown ? dailyAyats.length : _ayatsShown;
    // Grow with the user's text size so the preview never clips.
    final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.6);

    return Column(
      children: [
        SizedBox(
          height: 190.h * scale,
          child: PageView.builder(
            controller: _controller,
            itemCount: count,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, index) {
              final ayatIndex = (start + index) % dailyAyats.length;
              return Padding(
                padding: AppSpacing.symmetric(horizontal: 6),
                child: _DailyAyatCard(
                  ayat: dailyAyats[ayatIndex],
                  mediaId: 'daily_ayat_$ayatIndex',
                ),
              );
            },
          ),
        ),
        SizedBox(height: AppSpacing.vMd),
        ExcludeSemantics(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < count; i++)
                AnimatedContainer(
                  duration: AppDurations.medium,
                  curve: AppDurations.curve,
                  margin: AppSpacing.symmetric(horizontal: 3),
                  width: i == _page ? 18.w : 6.w,
                  height: 6.w,
                  decoration: BoxDecoration(
                    color:
                        i == _page
                            ? AppColors.secondaryGold
                            : AppColors.glassStrokeStrong,
                    borderRadius: AppRadius.pillAll,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DailyAyatCard extends StatelessWidget {
  const _DailyAyatCard({required this.ayat, required this.mediaId});

  final DailyAyat ayat;
  final String mediaId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      onTap: () => showDailyAyahSheet(context, ayat, mediaId),
      semanticLabel: l10n.read_full_ayah,
      padding: AppSpacing.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  ayat.surah,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelMedium?.copyWith(
                    color: AppColors.secondaryGold,
                  ),
                ),
              ),
              Icon(
                Icons.open_in_full_rounded,
                size: 16.sp,
                color: AppColors.textSecondary,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.vSm),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: ArabicText(
                    ayat.arabic,
                    fontSize: 20.sp,
                    height: 1.7,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: AppSpacing.vSm),
                Flexible(
                  child: TranslationText(
                    ayat.translation,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: AppColors.textMain,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Full daily ayah (Arabic + translation) with share and play.
Future<void> showDailyAyahSheet(
  BuildContext context,
  DailyAyat ayat,
  String mediaId,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder:
        (sheetContext) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder:
              (context, controller) => _AyahSheetBody(
                ayat: ayat,
                mediaId: mediaId,
                controller: controller,
              ),
        ),
  );
}

class _AyahSheetBody extends StatelessWidget {
  const _AyahSheetBody({
    required this.ayat,
    required this.mediaId,
    required this.controller,
  });

  final DailyAyat ayat;
  final String mediaId;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final audio = sl<AudioService>();

    return ListView(
      controller: controller,
      padding: AppSpacing.page,
      children: [
        Text(
          ayat.surah,
          textAlign: TextAlign.center,
          style: textTheme.titleMedium?.copyWith(
            color: AppColors.secondaryGold,
          ),
        ),
        SizedBox(height: AppSpacing.vLg),
        ArabicText(ayat.arabic, fontSize: 26.sp, textAlign: TextAlign.center),
        SizedBox(height: AppSpacing.vLg),
        // The daily ayat translations are English text.
        TranslationText(
          ayat.translation,
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge?.copyWith(color: AppColors.textMain),
        ),
        SizedBox(height: AppSpacing.vXl),
        Row(
          children: [
            Expanded(
              child: SecondaryButton(
                label: l10n.share,
                icon: Icons.share_outlined,
                onPressed:
                    () => Share.share(
                      '${ayat.arabic}\n\n${ayat.translation}\n— ${ayat.surah}'
                      '\n\n${l10n.shared_from_app}',
                    ),
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: StreamBuilder<AudioStatus>(
                stream: audio.statusStream,
                initialData: audio.status,
                builder: (context, snapshot) {
                  final playing = (snapshot.data ?? audio.status)
                      .isPlayingMedia(mediaId);
                  return PrimaryButton(
                    label: playing ? l10n.stop : l10n.play,
                    icon:
                        playing ? Icons.stop_rounded : Icons.play_arrow_rounded,
                    onPressed: () {
                      if (playing) {
                        audio.stop();
                      } else {
                        audio.playArabicThenTranslation(
                          ayat.arabic,
                          ayat.translation,
                          title: l10n.daily_ayats,
                          mediaId: mediaId,
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Pulse summary
// ---------------------------------------------------------------------------

class _PulseSummaryCard extends StatelessWidget {
  const _PulseSummaryCard();

  void _openPulse(BuildContext context) => MainNavigationScope.openTab(
    context,
    MainTab.pulse,
    fallback: (_) => const PulsePage(),
  );

  void _share(AppLocalizations l10n, SpiritualPulseEntity pulse) {
    final text = l10n.pulse_share_text
        .replaceAll('{streak}', '${pulse.currentStreak}')
        .replaceAll('{points}', '${weeklyPointsOf(pulse)}');
    Share.share(
      '$text\n${l10n.translate(pulse.motivation.l10nKey)}'
      '\n\n${l10n.shared_from_app}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    return BlocBuilder<PulseBloc, PulseState>(
      builder: (context, state) {
        if (state is PulseLoaded) {
          final pulse = state.pulse;
          return AppCard(
            onTap: () => _openPulse(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Semantics(
                        label: l10n.day_streak_count.replaceAll(
                          '{n}',
                          '${pulse.currentStreak}',
                        ),
                        excludeSemantics: true,
                        child: Container(
                          padding: AppSpacing.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryGold.withValues(
                              alpha: 0.12,
                            ),
                            borderRadius: AppRadius.pillAll,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.local_fire_department_rounded,
                                size: 16.sp,
                                color: AppColors.secondaryGold,
                              ),
                              SizedBox(width: AppSpacing.xs),
                              Flexible(
                                child: Text(
                                  l10n.day_streak_count.replaceAll(
                                    '{n}',
                                    '${pulse.currentStreak}',
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.labelMedium?.copyWith(
                                    color: AppColors.secondaryGold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: l10n.share,
                      icon: const Icon(Icons.share_outlined),
                      color: AppColors.secondaryGold,
                      onPressed: () => _share(l10n, pulse),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.vSm),
                Text(
                  l10n.translate(pulse.motivation.l10nKey),
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: AppSpacing.vLg),
                WeeklyBars(points: pulse.dailyPoints, barHeight: 64.h),
                if (pulse.badges.isNotEmpty) ...[
                  SizedBox(height: AppSpacing.vMd),
                  Row(
                    children: [
                      Icon(
                        Icons.military_tech_outlined,
                        size: 18.sp,
                        color: AppColors.secondaryGold,
                      ),
                      SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          l10n.translate(badgeL10nKey(pulse.badges.last)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.labelMedium,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        }
        if (state is PulseError) {
          return AppCard(
            padding: EdgeInsets.zero,
            child: StateView.error(
              message: l10n.pulse_load_failed,
              onRetry: () => context.read<PulseBloc>().add(LoadPulseData()),
            ),
          );
        }
        return AppCard(
          padding: AppSpacing.symmetric(vertical: 24),
          child: const StateView.loading(),
        );
      },
    );
  }
}
