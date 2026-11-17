import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/localization/app_localizations.dart';
import '../widgets/widgets.dart';

/// External links shown in Settings / About.
///
/// [privacyPolicy] and [terms] are hosted on GitHub Pages from the
/// `barakah-time-legal` repository.
abstract final class AppLinks {
  static const String privacyPolicy = 'https://tehreem-rizwan.github.io/barakah-time-legal/privacy.html';
  static const String terms = 'https://tehreem-rizwan.github.io/barakah-time-legal/terms.html';

  static const String quranApi = 'https://alquran.cloud';
  static const String osmCopyright = 'https://www.openstreetmap.org/copyright';
  static const String adhanLibrary = 'https://github.com/batoulapps/adhan-dart';
}

Future<String?>? _versionFuture;

/// "1.2.3 (45)" from the platform, or null when unavailable. Cached.
Future<String?> appVersion() => _versionFuture ??= () async {
  try {
    final info = await PackageInfo.fromPlatform();
    if (info.version.isEmpty) return null;
    return info.buildNumber.isEmpty
        ? info.version
        : '${info.version} (${info.buildNumber})';
  } catch (_) {
    return null;
  }
}();

/// Opens [url] externally; shows a snackbar if that fails.
Future<void> openExternalLink(BuildContext context, String url) async {
  final message = context.l10n.about_link_failed;
  bool opened = false;
  try {
    opened = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  } catch (_) {
    opened = false;
  }
  if (!opened && context.mounted) {
    showAppSnackBar(context, message, type: SnackType.error);
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    return AppScaffold(
      title: l10n.about_title,
      body: ListView(
        padding: AppSpacing.page,
        children: [
          SizedBox(height: AppSpacing.vLg),
          Center(
            child: Container(
              padding: EdgeInsetsDirectional.all(AppSpacing.lg),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondaryGold.withValues(alpha: 0.1),
              ),
              child: Icon(
                Icons.mosque_outlined,
                size: 48.sp,
                color: AppColors.secondaryGold,
              ),
            ),
          ),
          SizedBox(height: AppSpacing.vLg),
          Text(
            l10n.app_name,
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          FutureBuilder<String?>(
            future: appVersion(),
            builder: (context, snapshot) {
              final version = snapshot.data;
              if (version == null) return const SizedBox.shrink();
              return Padding(
                padding: EdgeInsetsDirectional.only(top: AppSpacing.vXs),
                child: Text(
                  l10n.settingsVersion(version),
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              );
            },
          ),
          SizedBox(height: AppSpacing.vLg),
          Text(
            l10n.about_description,
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          SizedBox(height: AppSpacing.vXl),
          const PrivacyPromiseCard(),
          SizedBox(height: AppSpacing.vXl),
          SectionHeader(
            title: l10n.about_credits,
            icon: Icons.volunteer_activism_outlined,
          ),
          SizedBox(height: AppSpacing.vMd),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ActionTile(
                  icon: Icons.menu_book_outlined,
                  title: l10n.about_quran_data,
                  subtitle: 'alquran.cloud',
                  trailing: const _ExternalIcon(),
                  onTap: () => openExternalLink(context, AppLinks.quranApi),
                ),
                const Divider(height: 1),
                ActionTile(
                  icon: Icons.map_outlined,
                  title: l10n.about_map_data,
                  subtitle: l10n.about_map_license,
                  trailing: const _ExternalIcon(),
                  onTap: () => openExternalLink(context, AppLinks.osmCopyright),
                ),
                const Divider(height: 1),
                ActionTile(
                  icon: Icons.schedule_outlined,
                  title: l10n.about_prayer_calc,
                  subtitle: l10n.about_prayer_calc_source,
                  trailing: const _ExternalIcon(),
                  onTap: () => openExternalLink(context, AppLinks.adhanLibrary),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.vLg),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ActionTile(
                  icon: Icons.privacy_tip_outlined,
                  title: l10n.about_privacy,
                  trailing: const _ExternalIcon(),
                  onTap:
                      () => openExternalLink(context, AppLinks.privacyPolicy),
                ),
                const Divider(height: 1),
                ActionTile(
                  icon: Icons.description_outlined,
                  title: l10n.about_terms,
                  trailing: const _ExternalIcon(),
                  onTap: () => openExternalLink(context, AppLinks.terms),
                ),
                const Divider(height: 1),
                ActionTile(
                  icon: Icons.code_rounded,
                  title: l10n.about_licenses,
                  onTap: () async {
                    final version = await appVersion();
                    if (!context.mounted) return;
                    showLicensePage(
                      context: context,
                      applicationName: l10n.app_name,
                      applicationVersion: version,
                    );
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.vXl),
          Text(
            l10n.about_made_with_love,
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.secondaryGold,
              fontStyle: FontStyle.italic,
            ),
          ),
          SizedBox(height: AppSpacing.vLg),
        ],
      ),
    );
  }
}

class _ExternalIcon extends StatelessWidget {
  const _ExternalIcon();

  @override
  Widget build(BuildContext context) => Icon(
    Icons.open_in_new_rounded,
    size: 18.sp,
    color: AppColors.textSecondary,
  );
}
