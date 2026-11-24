import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_config.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/services/location_service.dart';
import '../../injection_container.dart';
import '../widgets/widgets.dart';
import 'about_page.dart';

/// Pre-filled feedback email. Only the app version and OS version are
/// added (to help reproduce problems); no account or personal details.
@visibleForTesting
Uri feedbackEmailUri({String? version, String? os}) {
  final subject =
      'Barakah Time feedback${version == null ? '' : ' (v$version)'}';
  final body = [
    '',
    '',
    '---',
    if (version != null) 'App version: $version',
    if (os != null) 'Device: $os',
  ].join('\n');
  // Encode by hand: Uri.queryParameters turns spaces into "+", which some
  // mail apps show literally.
  return Uri.parse(
    'mailto:${AppConfig.supportEmail}'
    '?subject=${Uri.encodeComponent(subject)}'
    '&body=${Uri.encodeComponent(body)}',
  );
}

Future<void> sendFeedback(BuildContext context) async {
  final l10n = context.l10n;
  String? os;
  try {
    if (!kIsWeb)
      os = '${Platform.operatingSystem} ${Platform.operatingSystemVersion}';
  } catch (_) {}
  final uri = feedbackEmailUri(version: await appVersion(), os: os);
  var opened = false;
  try {
    opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {}
  if (!opened && context.mounted) {
    showAppSnackBar(
      context,
      l10n.feedbackNoEmailApp(AppConfig.supportEmail),
      type: SnackType.warning,
    );
  }
}

/// Android only: why the adhan can be late on battery-saving phones, with a
/// shortcut to this app's system settings.
Future<void> showAdhanHelp(BuildContext context) {
  final l10n = context.l10n;
  return showDialog<void>(
    context: context,
    builder:
        (dialogContext) => AlertDialog(
          title: Text(l10n.adhan_help),
          content: SingleChildScrollView(child: Text(l10n.adhan_help_body)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
              ),
              child: Text(l10n.close),
            ),
            FilledButton(
              style: dialogActionStyle(),
              onPressed: () {
                Navigator.pop(dialogContext);
                final service =
                    sl.isRegistered<LocationService>()
                        ? sl<LocationService>()
                        : LocationService();
                service.openAppSettings();
              },
              child: Text(l10n.open_settings),
            ),
          ],
        ),
  );
}
