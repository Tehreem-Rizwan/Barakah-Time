import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/localization/app_localizations.dart';
import '../widgets/widgets.dart';
import 'duas_page.dart';
import 'hajj_guide_page.dart';
import 'hijri_label.dart';
import 'islamic_calendar_page.dart';
import 'main_navigation_scope.dart';
import 'mosque_finder_page.dart';
import 'names_all_page.dart';
import 'prayer_times_page.dart';
import 'pulse_page.dart';
import 'qibla_page.dart';
import 'quran_page.dart';
import 'settings_page.dart';
import 'tasbeeh_page.dart';
import 'zakat_calculator_page.dart';

class _Tool {
  const _Tool({
    required this.icon,
    required this.label,
    required this.page,
    this.tab,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final WidgetBuilder page;

  /// Set for destinations that are bottom-navigation tabs.
  final MainTab? tab;
}

class ToolsGridPage extends StatelessWidget {
  const ToolsGridPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final tools = <_Tool>[
      _Tool(
        icon: Icons.access_time_rounded,
        label: l10n.prayer_times,
        page: (_) => const PrayerTimesPage(),
      ),
      _Tool(
        icon: Icons.menu_book_rounded,
        label: l10n.quran,
        page: (_) => const QuranPage(),
        tab: MainTab.quran,
      ),
      _Tool(
        icon: Icons.blur_circular_rounded,
        label: l10n.tasbeeh,
        page: (_) => const TasbeehPage(),
      ),
      _Tool(
        icon: Icons.auto_awesome,
        label: l10n.names_of_allah,
        page: (_) => const NamesOfAllahPage(),
      ),
      _Tool(
        icon: Icons.explore_outlined,
        label: l10n.qibla_finder,
        page: (_) => const QiblaPage(),
      ),
      _Tool(
        icon: Icons.volunteer_activism_outlined,
        label: l10n.daily_duas,
        page: (_) => const DuasPage(),
      ),
      _Tool(
        icon: Icons.calculate_outlined,
        label: l10n.zakat_calculator,
        page: (_) => const ZakatCalculatorPage(),
      ),
      _Tool(
        icon: Icons.calendar_month_outlined,
        label: l10n.islamic_calendar,
        subtitle: hijriDateLabel(DateTime.now(), l10n, withYear: false),
        page: (_) => const IslamicCalendarPage(),
      ),
      _Tool(
        icon: Icons.mosque_outlined,
        label: l10n.mosque_finder,
        page: (_) => const MosqueFinderPage(),
      ),
      _Tool(
        icon: Icons.directions_walk_rounded,
        label: l10n.hajj_guide,
        page: (_) => const HajjGuidePage(),
      ),
      _Tool(
        icon: Icons.bolt_rounded,
        label: l10n.pulse,
        page: (_) => const PulsePage(),
        tab: MainTab.pulse,
      ),
      _Tool(
        icon: Icons.settings_outlined,
        label: l10n.settings,
        page: (_) => const SettingsPage(),
        tab: MainTab.settings,
      ),
    ];

    return AppScaffold(
      title: l10n.all_tools,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 600 ? 4 : 3;
          return GridView.builder(
            padding: AppSpacing.page,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: AppSpacing.vMd,
              crossAxisSpacing: AppSpacing.md,
              // Taller cells when text is enlarged so labels never clip.
              childAspectRatio:
                  0.82 /
                  MediaQuery.textScalerOf(context).scale(1).clamp(1, 1.6),
            ),
            itemCount: tools.length,
            itemBuilder: (context, index) => _ToolTile(tool: tools[index]),
          );
        },
      ),
    );
  }
}

class _ToolTile extends StatelessWidget {
  const _ToolTile({required this.tool});

  final _Tool tool;

  void _open(BuildContext context) {
    final tab = tool.tab;
    if (tab != null) {
      MainNavigationScope.openTab(context, tab, fallback: tool.page);
    } else {
      Navigator.of(context).push(MaterialPageRoute(builder: tool.page));
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      onTap: () => _open(context),
      borderRadius: AppRadius.mdAll,
      padding: AppSpacing.all(8),
      semanticLabel:
          tool.subtitle == null
              ? tool.label
              : '${tool.label}, ${tool.subtitle}',
      child: ExcludeSemantics(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48.r,
              height: 48.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondaryGold.withValues(alpha: 0.12),
              ),
              child: Icon(
                tool.icon,
                color: AppColors.secondaryGold,
                size: 26.sp,
              ),
            ),
            SizedBox(height: AppSpacing.vSm),
            Flexible(
              child: Text(
                tool.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelMedium,
              ),
            ),
            if (tool.subtitle != null)
              Text(
                tool.subtitle!,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
