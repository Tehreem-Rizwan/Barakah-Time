import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/services/notification_service.dart';
import '../../core/utils/calculation_methods.dart';
import '../../domain/entities/prayer_times.dart';
import '../../domain/entities/user.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/settings_bloc.dart';
import '../widgets/widgets.dart';
import 'about_page.dart';
import 'prayer_offsets_sheet.dart';
import 'auth/sign_in_page.dart';
import 'profile_page.dart'
    show
        ProfilePage,
        UserAvatar,
        accountAuthListenWhen,
        accountAuthListener,
        confirmDeleteAccount;

/// Supported UI languages, in picker order.
const List<String> _languageCodes = ['en', 'ar', 'fa', 'ur', 'tr'];

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const _androidPackageId = 'com.tehreem.barakah_time';

  /// No App Store listing yet, so "Rate us" is hidden on Apple platforms.
  static bool get _canRate =>
      !kIsWeb &&
      defaultTargetPlatform != TargetPlatform.iOS &&
      defaultTargetPlatform != TargetPlatform.macOS;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listenWhen:
              (previous, current) =>
                  current is Authenticated &&
                  current.feedback != null &&
                  current.feedback!.code != AuthCodes.reauthRequired &&
                  (previous is! Authenticated ||
                      previous.feedback != current.feedback),
          listener: (context, state) {
            if (ModalRoute.of(context)?.isCurrent == false) return;
            final feedback = (state as Authenticated).feedback!;
            showAppSnackBar(
              context,
              localizedAuthMessage(
                context.l10n,
                feedback.code,
                feedback.message,
              ),
              type: feedback.isError ? SnackType.error : SnackType.success,
            );
          },
        ),
        BlocListener<SettingsBloc, SettingsState>(
          listenWhen:
              (previous, current) =>
                  current.locationError != null &&
                  previous.locationError != current.locationError,
          listener: (context, state) {
            if (ModalRoute.of(context)?.isCurrent == false) return;
            showAppSnackBar(
              context,
              state.locationError!,
              type: SnackType.error,
            );
          },
        ),
      ],
      child: AppScaffold(
        title: l10n.settings,
        body: BlocListener<AuthBloc, AuthState>(
          listenWhen: accountAuthListenWhen,
          listener: accountAuthListener,
          child: BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, state) {
              return ListView(
                padding: AppSpacing.page,
                children: [
                  _section(l10n.settings_account, Icons.person_outline),
                  const _AccountCard(),
                  _gap(),
                  _section(l10n.settings_prayer, Icons.mosque_outlined),
                  _group([
                    ActionTile(
                      icon: Icons.calculate_outlined,
                      title: l10n.calculation_method,
                      subtitle: _methodName(l10n, state.calculationMethod),
                      onTap: () => _showCalculationMethodDialog(context, state),
                    ),
                    ActionTile(
                      icon: Icons.wb_sunny_outlined,
                      title: l10n.asr_calculation,
                      subtitle:
                          state.asrMadhab == AsrMadhab.hanafi
                              ? l10n.asr_hanafi
                              : l10n.asr_shafi,
                      onTap: () => _showMadhabDialog(context, state.asrMadhab),
                    ),
                    ActionTile(
                      icon: Icons.tune_rounded,
                      title: l10n.adjust_times,
                      subtitle: prayerOffsetsSummary(l10n, state.prayerOffsets),
                      onTap: () => showPrayerOffsetsSheet(context),
                    ),
                    ActionTile(
                      icon: Icons.location_on_outlined,
                      title: l10n.location,
                      subtitle:
                          state.useAutoLocation
                              ? l10n.auto_location
                              : state.manualLocation,
                      onTap: () => _showLocationDialog(context, state),
                    ),
                  ]),
                  _gap(),
                  _section(l10n.notifications, Icons.notifications_none),
                  _group([
                    ActionTile(
                      icon: Icons.notifications_active_outlined,
                      title: l10n.notifications,
                      subtitle: l10n.notifications_subtitle,
                      onTap:
                          () => context.read<SettingsBloc>().add(
                            ToggleNotifications(!state.notificationsEnabled),
                          ),
                      trailing: Transform.scale(
                        // A bit smaller than Material's default switch.
                        scale: 0.8,
                        child: Switch(
                          value: state.notificationsEnabled,
                          onChanged:
                              (value) => context.read<SettingsBloc>().add(
                                ToggleNotifications(value),
                              ),
                        ),
                      ),
                    ),
                    ActionTile(
                      icon: Icons.volume_up_outlined,
                      title: l10n.adhan_sound,
                      subtitle: l10n.adhan_sound_desc,
                      enabled: state.notificationsEnabled,
                      onTap:
                          () => context.read<SettingsBloc>().add(
                            ToggleAdhanSound(!state.adhanSoundEnabled),
                          ),
                      trailing: Transform.scale(
                        // A bit smaller than Material's default switch.
                        scale: 0.8,
                        child: Switch(
                          value: state.adhanSoundEnabled,
                          onChanged:
                              state.notificationsEnabled
                                  ? (value) => context.read<SettingsBloc>().add(
                                    ToggleAdhanSound(value),
                                  )
                                  : null,
                        ),
                      ),
                    ),
                    if (state.notificationsEnabled) const _ExactAlarmHint(),
                  ]),
                  _gap(),
                  _section(l10n.quran, Icons.menu_book_outlined),
                  _group([
                    ActionTile(
                      icon: Icons.format_size,
                      title: l10n.quran_font_size,
                      subtitle: '${state.quranFontSize.toInt()}',
                      onTap: () => _showFontSizeDialog(context),
                    ),
                  ]),
                  _gap(),
                  _section(l10n.language, Icons.language),
                  _group([
                    ActionTile(
                      icon: Icons.translate_rounded,
                      title: l10n.language,
                      subtitle: _languageName(l10n, state.languageCode),
                      onTap: () => _showLanguageDialog(context, state),
                    ),
                    ActionTile(
                      icon: Icons.dark_mode_outlined,
                      title: l10n.app_theme,
                      subtitle: _themeName(l10n, state.themeMode),
                      onTap: () => _showThemeDialog(context, state.themeMode),
                    ),
                  ]),
                  _gap(),
                  _section(l10n.support, Icons.favorite_border_rounded),
                  _group([
                    if (_canRate)
                      ActionTile(
                        icon: Icons.star_outline_rounded,
                        title: l10n.rate_us,
                        subtitle: l10n.settings_support_us,
                        onTap: () => _handleRateUs(context),
                      ),
                    FutureBuilder<String?>(
                      future: appVersion(),
                      builder:
                          (context, snapshot) => ActionTile(
                            icon: Icons.info_outline_rounded,
                            title: l10n.about,
                            subtitle:
                                snapshot.data == null
                                    ? null
                                    : l10n.settingsVersion(snapshot.data!),
                            onTap:
                                () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => const AboutPage(),
                                  ),
                                ),
                          ),
                    ),
                  ]),
                  // Sign out / delete account at the very end (as on My Profile).
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, auth) {
                      if (auth is! Authenticated)
                        return const SizedBox.shrink();
                      final busy = auth.isUpdating;
                      return Padding(
                        padding: EdgeInsetsDirectional.only(
                          top: AppSpacing.vXl,
                        ),
                        child: _group([
                          ActionTile(
                            icon: Icons.logout_rounded,
                            title: l10n.sign_out,
                            enabled: !busy,
                            onTap: () async {
                              final bloc = context.read<AuthBloc>();
                              final ok = await showConfirmDialog(
                                context,
                                title: l10n.sign_out,
                                message: l10n.sign_out_confirm,
                                confirmLabel: l10n.sign_out,
                              );
                              if (ok) bloc.add(SignOutRequested());
                            },
                          ),
                          ActionTile(
                            icon: Icons.delete_forever_outlined,
                            title: l10n.delete_account,
                            destructive: true,
                            enabled: !busy,
                            onTap: () => confirmDeleteAccount(context),
                          ),
                        ]),
                      );
                    },
                  ),
                  SizedBox(height: AppSpacing.vLg),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  static Widget _section(String title, IconData icon) => SectionHeader(
    title: title,
    icon: icon,
    padding: AppSpacing.only(start: 4, bottom: 12),
  );

  static Widget _gap() => SizedBox(height: AppSpacing.vXl);

  static Widget _group(List<Widget> tiles) => AppCard(
    padding: EdgeInsets.zero,
    child: Column(
      children: [
        for (var i = 0; i < tiles.length; i++) ...[
          if (i > 0) const Divider(height: 1),
          tiles[i],
        ],
      ],
    ),
  );

  static String _methodName(AppLocalizations l10n, String id) {
    final info = CalculationMethods.byId(id);
    return info == null ? id : l10n.translate(info.l10nKey);
  }

  static String _languageName(AppLocalizations l10n, String code) {
    switch (code) {
      case 'ar':
        return l10n.arabic;
      case 'fa':
        return l10n.farsi;
      case 'ur':
        return l10n.urdu;
      case 'tr':
        return l10n.turkish;
      default:
        return l10n.english;
    }
  }

  /// Simple single-choice dialog with a check on the selected option.
  static Future<T?> _showChoiceDialog<T>(
    BuildContext context, {
    required String title,
    required List<(T, String)> options,
    required T selected,
  }) {
    return showDialog<T>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(title),
            contentPadding: EdgeInsetsDirectional.only(
              top: AppSpacing.vMd,
              bottom: AppSpacing.vSm,
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final (value, label) in options)
                    ListTile(
                      title: Text(label),
                      selected: value == selected,
                      trailing:
                          value == selected
                              ? Icon(
                                Icons.check_rounded,
                                color: AppColors.secondaryGold,
                              )
                              : null,
                      onTap: () => Navigator.pop(dialogContext, value),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(dialogContext.l10n.cancel),
              ),
            ],
          ),
    );
  }

  Future<void> _showCalculationMethodDialog(
    BuildContext context,
    SettingsState state,
  ) async {
    final l10n = context.l10n;
    final bloc = context.read<SettingsBloc>();
    final chosen = await _showChoiceDialog<String>(
      context,
      title: l10n.calculation_method,
      selected: state.calculationMethod,
      options: [
        for (final m in CalculationMethods.all)
          (m.id, l10n.translate(m.l10nKey)),
      ],
    );
    if (chosen != null && chosen != state.calculationMethod) {
      bloc.add(UpdateCalculationMethod(chosen));
    }
  }

  Future<void> _showMadhabDialog(BuildContext context, String current) async {
    final l10n = context.l10n;
    final bloc = context.read<SettingsBloc>();
    final chosen = await _showChoiceDialog<String>(
      context,
      title: l10n.asr_calculation,
      selected: current,
      options: [
        (AsrMadhab.shafi, l10n.asr_shafi),
        (AsrMadhab.hanafi, l10n.asr_hanafi),
      ],
    );
    if (chosen != null && chosen != current) bloc.add(UpdateMadhab(chosen));
  }

  static String _themeName(AppLocalizations l10n, String mode) =>
      switch (mode) {
        'light' => l10n.theme_light,
        'dark' => l10n.theme_dark,
        _ => l10n.theme_system,
      };

  Future<void> _showThemeDialog(BuildContext context, String current) async {
    final l10n = context.l10n;
    final bloc = context.read<SettingsBloc>();
    final chosen = await _showChoiceDialog<String>(
      context,
      title: l10n.app_theme,
      selected: current,
      options: [
        for (final m in const ['system', 'light', 'dark'])
          (m, _themeName(l10n, m)),
      ],
    );
    if (chosen != null && chosen != current) bloc.add(UpdateThemeMode(chosen));
  }

  Future<void> _showLanguageDialog(
    BuildContext context,
    SettingsState state,
  ) async {
    final l10n = context.l10n;
    final bloc = context.read<SettingsBloc>();
    final chosen = await _showChoiceDialog<String>(
      context,
      title: l10n.language,
      selected: state.languageCode,
      options: [
        for (final code in _languageCodes) (code, _languageName(l10n, code)),
      ],
    );
    if (chosen != null && chosen != state.languageCode) {
      bloc.add(UpdateLanguage(chosen));
    }
  }

  void _showFontSizeDialog(BuildContext context) {
    final settingsBloc = context.read<SettingsBloc>();
    double value = settingsBloc.state.quranFontSize.clamp(16.0, 48.0);
    showDialog<void>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(dialogContext.l10n.quran_font_size),
            content: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ArabicText(
                      'بِسْمِ ٱللَّهِ',
                      fontSize: value.sp,
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      '${value.toInt()}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.secondaryGold,
                      ),
                    ),
                    Slider(
                      value: value,
                      min: 16,
                      max: 48,
                      divisions: 8,
                      label: '${value.toInt()}',
                      onChanged: (v) => setState(() => value = v),
                      onChangeEnd:
                          (v) => settingsBloc.add(UpdateQuranFontSize(v)),
                    ),
                  ],
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(dialogContext.l10n.close),
              ),
            ],
          ),
    );
  }

  void _showLocationDialog(BuildContext context, SettingsState state) {
    final settingsBloc = context.read<SettingsBloc>();
    showDialog<void>(
      context: context,
      builder:
          (_) => _LocationDialog(
            initialUseAuto: state.useAutoLocation,
            initialManualLocation: state.manualLocation,
            onSave: (useAuto, city) {
              final switching = useAuto != state.useAutoLocation;
              if (useAuto) {
                if (switching) settingsBloc.add(const ToggleLocationMode(true));
              } else if (city != state.manualLocation) {
                // Look the city up first; manual mode turns on only if found.
                settingsBloc.add(
                  UpdateManualLocation(city, switchToManual: switching),
                );
              } else if (switching) {
                // Same, already looked-up city: its coordinates are valid.
                settingsBloc.add(const ToggleLocationMode(false));
              }
            },
          ),
    );
  }

  void _handleRateUs(BuildContext context) {
    final l10n = context.l10n;
    showDialog<void>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(l10n.rate_us),
            content: Text(l10n.rate_us_message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                ),
                child: Text(l10n.later),
              ),
              FilledButton(
                style: dialogActionStyle(),
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  final opened = await _openStore();
                  if (!opened && context.mounted) {
                    showAppSnackBar(
                      context,
                      l10n.store_open_failed,
                      type: SnackType.error,
                    );
                  }
                },
                child: Text(l10n.rate_now),
              ),
            ],
          ),
    );
  }

  /// Opens the Play Store listing (market:// first, then the web page).
  Future<bool> _openStore() async {
    final marketUri = Uri.parse('market://details?id=$_androidPackageId');
    final webUri = Uri.parse(
      'https://play.google.com/store/apps/details?id=$_androidPackageId',
    );
    if (defaultTargetPlatform == TargetPlatform.android) {
      try {
        if (await launchUrl(marketUri, mode: LaunchMode.externalApplication)) {
          return true;
        }
      } catch (_) {}
    }
    try {
      return await launchUrl(webUri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}

// ─── Account ──────────────────────────────────────────────────────────────────

class _AccountCard extends StatelessWidget {
  const _AccountCard();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return _ProfileTile(user: state.user, isUpdating: state.isUpdating);
        }
        final unavailable =
            (state is GuestMode && state.authUnavailable) || !authAvailable();
        return AppCard(
          padding: EdgeInsets.zero,
          child: ActionTile(
            icon: Icons.cloud_sync_outlined,
            title: l10n.sign_in_to_sync,
            subtitle:
                unavailable
                    ? l10n.auth_unavailable_notice
                    : l10n.guest_mode_notice,
            enabled: !unavailable,
            onTap:
                unavailable
                    ? null
                    : () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const SignInPage(),
                      ),
                    ),
          ),
        );
      },
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({required this.user, required this.isUpdating});

  final UserEntity user;
  final bool isUpdating;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      onTap:
          () => Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: (_) => const ProfilePage())),
      semanticLabel: l10n.my_profile,
      padding: AppSpacing.only(start: 16, top: 12, end: 4, bottom: 12),
      child: Row(
        children: [
          UserAvatar(imagePath: user.profilePicPath, radius: 22.r),
          SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayNameOr(l10n.default_user_name),
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (user.email.isNotEmpty)
                  Text(
                    user.email,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (isUpdating)
            Padding(
              padding: EdgeInsetsDirectional.all(AppSpacing.md),
              child: SizedBox(
                width: 24.r,
                height: 24.r,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            // Photo, name and email are all edited on My Profile.
            IconButton(
              tooltip: l10n.edit_profile,
              onPressed:
                  () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ProfilePage(),
                    ),
                  ),
              icon: Icon(Icons.edit_outlined, size: 20.sp),
            ),
        ],
      ),
    );
  }
}

// ─── Exact alarm hint ─────────────────────────────────────────────────────────

/// Android 12+: shown when exact alarms aren't allowed, so reminders may be
/// late. Re-checked when the app resumes (e.g. back from system settings).
class _ExactAlarmHint extends StatefulWidget {
  const _ExactAlarmHint();

  @override
  State<_ExactAlarmHint> createState() => _ExactAlarmHintState();
}

class _ExactAlarmHintState extends State<_ExactAlarmHint>
    with WidgetsBindingObserver {
  bool _show = false;

  NotificationService? get _service =>
      GetIt.instance.isRegistered<NotificationService>()
          ? GetIt.instance<NotificationService>()
          : null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _check();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _check();
  }

  Future<void> _check() async {
    final service = _service;
    if (service == null) return;
    bool allowed = true;
    try {
      allowed = await service.canScheduleExactAlarms();
    } catch (_) {}
    if (mounted && _show == allowed) setState(() => _show = !allowed);
  }

  Future<void> _request() async {
    try {
      await _service?.requestExactAlarmsPermission();
    } catch (_) {}
    await _check();
  }

  @override
  Widget build(BuildContext context) {
    if (!_show) return const SizedBox.shrink();
    return ActionTile(
      icon: Icons.alarm_outlined,
      title: context.l10n.exact_alarms_hint,
      onTap: _request,
    );
  }
}

// ─── Dialogs ──────────────────────────────────────────────────────────────────

/// Owns its controllers so they outlive the dialog's exit animation.
class _LocationDialog extends StatefulWidget {
  final bool initialUseAuto;
  final String initialManualLocation;
  final void Function(bool useAuto, String city) onSave;

  const _LocationDialog({
    required this.initialUseAuto,
    required this.initialManualLocation,
    required this.onSave,
  });

  @override
  State<_LocationDialog> createState() => _LocationDialogState();
}

class _LocationDialogState extends State<_LocationDialog> {
  final _formKey = GlobalKey<FormState>();
  late bool _useAuto = widget.initialUseAuto;
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialManualLocation,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    if (!_useAuto && !(_formKey.currentState?.validate() ?? false)) return;
    Navigator.pop(context);
    widget.onSave(_useAuto, _controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.location_settings),
      scrollable: true,
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.auto_location),
              value: _useAuto,
              onChanged: (value) => setState(() => _useAuto = value),
            ),
            if (!_useAuto) ...[
              SizedBox(height: AppSpacing.vLg),
              TextFormField(
                controller: _controller,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.addressCity],
                decoration: InputDecoration(labelText: l10n.manual_location),
                validator:
                    (v) =>
                        (v == null || v.trim().isEmpty)
                            ? l10n.location_required
                            : null,
                onFieldSubmitted: (_) => _save(),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          style: dialogActionStyle(),
          onPressed: _save,
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
