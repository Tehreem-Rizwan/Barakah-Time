import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../core/localization/app_localizations.dart';
import '../../domain/entities/badge.dart';
import '../../domain/entities/user.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/pulse_bloc.dart';
import '../widgets/widgets.dart';
import 'activity_history_page.dart';
import 'auth/sign_in_page.dart';
import 'saved_verses_page.dart';
import 'main_navigation_scope.dart';
import 'settings_page.dart';

export 'activity_history_page.dart' show ActivityHistoryPage;
export 'saved_verses_page.dart' show SavedVersesPage;

/// Compact number formatting: 150 → "150", 1500 → "1.5k", 2000000 → "2M".
String formatCompactNumber(int value) {
  String trim(double v) {
    final s = v.toStringAsFixed(1);
    return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
  }

  final abs = value.abs();
  if (abs >= 1000000) return '${trim(value / 1000000)}M';
  if (abs >= 1000) return '${trim(value / 1000)}k';
  return value.toString();
}

/// Profile avatar that handles remote URLs, local files and missing images.
class UserAvatar extends StatelessWidget {
  final String? imagePath;
  final double radius;
  const UserAvatar({super.key, required this.imagePath, required this.radius});

  ImageProvider? _provider() {
    final path = imagePath?.trim();
    if (path == null || path.isEmpty) return null;
    final uri = Uri.tryParse(path);
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      return NetworkImage(path);
    }
    final file = File(path);
    return file.existsSync() ? FileImage(file) : null;
  }

  @override
  Widget build(BuildContext context) {
    final fallback = Icon(
      Icons.person,
      color: AppColors.secondaryGold,
      size: radius,
    );
    final provider = _provider();
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.secondaryGold.withValues(alpha: 0.1),
      child:
          provider == null
              ? fallback
              : ClipOval(
                child: Image(
                  image: provider,
                  width: radius * 2,
                  height: radius * 2,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => fallback,
                  loadingBuilder:
                      (context, child, progress) =>
                          progress == null
                              ? child
                              : SizedBox(
                                width: radius * 2,
                                height: radius * 2,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                ),
              ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: accountAuthListenWhen,
      listener: accountAuthListener,
      builder: (context, authState) {
        final Widget body;
        if (authState is Authenticated) {
          body = _AuthenticatedProfile(state: authState);
        } else if (authState is AuthInitial || authState is AuthLoading) {
          body = const StateView.loading();
        } else {
          // Guest, signed out, or a failed sign-in / password reset started
          // from here: show the sign-in options, never an endless spinner.
          body = _GuestProfile(
            authUnavailable:
                authState is GuestMode && authState.authUnavailable,
          );
        }
        return AppScaffold(
          title: l10n.my_profile,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: l10n.settings,
              onPressed:
                  () => MainNavigationScope.openTab(
                    context,
                    MainTab.settings,
                    fallback: (_) => const SettingsPage(),
                  ),
            ),
          ],
          body: body,
        );
      },
    );
  }
}

void _push(BuildContext context, Widget page) {
  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
}

// ─── Account deletion ─────────────────────────────────────────────────────────

/// Reacts to sign-out, account deletion and account feedback (e.g. the
/// re-authentication step before deleting). Used by My Profile and the
/// Settings tab, which both offer Sign out / Delete account.
bool accountAuthListenWhen(AuthState previous, AuthState current) {
  if (current is Unauthenticated) return previous is Authenticated;
  return current is Authenticated &&
      current.feedback != null &&
      (previous is! Authenticated || previous.feedback != current.feedback);
}

void accountAuthListener(BuildContext context, AuthState state) {
  // Only the visible page reacts (Profile pushed over Settings, or the
  // Settings tab itself), so nothing runs twice.
  if (ModalRoute.of(context)?.isCurrent == false) return;
  final l10n = context.l10n;
  if (state is Unauthenticated) {
    // Signed out / deleted / session ended: clear stale pulse data, then
    // reset the stack to Sign In so back can't return into the app.
    context.read<PulseBloc>().add(LoadPulseData());
    if (state is AccountDeleted) {
      showAppSnackBar(context, l10n.account_deleted, type: SnackType.success);
    } else if (state is SessionExpired) {
      showAppSnackBar(context, l10n.session_expired, type: SnackType.warning);
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const SignInPage()),
      (route) => false,
    );
    return;
  }
  final authState = state as Authenticated;
  final feedback = authState.feedback!;
  if (feedback.code == AuthCodes.reauthRequired) {
    _promptReauth(context, authState.user);
    return;
  }
  showAppSnackBar(
    context,
    localizedAuthMessage(l10n, feedback.code, feedback.message),
    type: feedback.isError ? SnackType.error : SnackType.success,
  );
}

/// Step 1: destructive confirmation (type DELETE), then [DeleteAccountRequested].
Future<void> confirmDeleteAccount(BuildContext context) async {
  final l10n = context.l10n;
  final bloc = context.read<AuthBloc>();
  final confirmed = await showConfirmDialog(
    context,
    title: l10n.delete_account_confirm_title,
    message: l10n.delete_account_confirm_message,
    confirmLabel: l10n.delete_account,
    destructive: true,
    requireTypedText: l10n.delete_confirm_word,
  );
  if (confirmed) bloc.add(DeleteAccountRequested());
}

/// Step 2 (only if the sign-in is not recent): re-authenticate with the
/// password or the original provider, then delete.
Future<void> _promptReauth(BuildContext context, UserEntity user) async {
  final l10n = context.l10n;
  final bloc = context.read<AuthBloc>();
  if (user.isPasswordAccount) {
    final password = await showDialog<String>(
      context: context,
      builder: (_) => const _ReauthPasswordDialog(),
    );
    if (password != null && password.isNotEmpty) {
      bloc.add(ReauthenticateAndDelete(password: password));
    }
    return;
  }
  final provider = switch (user.signInProvider) {
    'apple.com' => 'Apple',
    _ => 'Google',
  };
  final confirmed = await showConfirmDialog(
    context,
    title: l10n.delete_account_confirm_title,
    message: l10n.reauth_required_delete,
    confirmLabel: l10n
        .translate('confirm_with_provider')
        .replaceAll('{provider}', provider),
    destructive: true,
  );
  if (confirmed) bloc.add(const ReauthenticateAndDelete());
}

class _ReauthPasswordDialog extends StatefulWidget {
  const _ReauthPasswordDialog();

  @override
  State<_ReauthPasswordDialog> createState() => _ReauthPasswordDialogState();
}

class _ReauthPasswordDialogState extends State<_ReauthPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.pop(context, _controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.delete_account_confirm_title),
      scrollable: true,
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.reauth_required_delete),
            SizedBox(height: AppSpacing.vLg),
            AuthTextField(
              controller: _controller,
              label: l10n.confirm_with_password,
              icon: Icons.lock_outline,
              isPassword: true,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              onFieldSubmitted: (_) => _submit(),
              validator:
                  (v) =>
                      (v == null || v.isEmpty) ? l10n.password_required : null,
            ),
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
          onPressed: _submit,
          style: dialogActionStyle(
            background: AppColors.error,
            foreground: AppColors.onGold,
          ),
          child: Text(l10n.delete_account),
        ),
      ],
    );
  }
}

// ─── Authenticated profile ────────────────────────────────────────────────────

class _AuthenticatedProfile extends StatelessWidget {
  const _AuthenticatedProfile({required this.state});

  final Authenticated state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final user = state.user;
    final busy = state.isUpdating;
    return Column(
      children: [
        if (busy) const LinearProgressIndicator(minHeight: 2),
        Expanded(
          child: ListView(
            padding: AppSpacing.page,
            children: [
              _ProfileHeader(user: user, isUpdating: busy),
              if (!user.emailVerified) ...[
                SizedBox(height: AppSpacing.vLg),
                AuthNotice(
                  message: l10n.email_not_verified,
                  icon: Icons.mark_email_unread_outlined,
                  action: TextButton(
                    onPressed:
                        busy
                            ? null
                            : () => context.read<AuthBloc>().add(
                              ResendVerificationEmail(),
                            ),
                    child: Text(l10n.resend_verification),
                  ),
                ),
              ],
              SizedBox(height: AppSpacing.vXl),
              const _PulseSummary(),
              SizedBox(height: AppSpacing.vXl),
              const _ActivityLinks(),
              SizedBox(height: AppSpacing.vLg),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
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
                    const Divider(height: 1),
                    ActionTile(
                      icon: Icons.delete_forever_outlined,
                      title: l10n.delete_account,
                      destructive: true,
                      enabled: !busy,
                      onTap: () => confirmDeleteAccount(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user, required this.isUpdating});

  final UserEntity user;
  final bool isUpdating;

  String? _memberSince(BuildContext context) {
    final date = user.memberSince;
    if (date == null) return null;
    final formatted = formatLocalizedDate(
      context,
      date,
      (l) => DateFormat.yMMM(l),
    );
    return '${context.l10n.member_since} $formatted';
  }

  void _editProfile(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    showDialog<void>(
      context: context,
      builder:
          (_) => EditProfileDialog(
            currentName: user.name,
            currentEmail: user.email,
            onSave:
                (name, email) => authBloc.add(
                  UpdateProfileRequested(name: name, email: email),
                ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final memberSince = _memberSince(context);
    final avatarRadius = 56.r;
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Semantics(
              button: true,
              label: l10n.profile_change_photo,
              child: GestureDetector(
                onTap: isUpdating ? null : () => _pickImage(context),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    UserAvatar(
                      imagePath: user.profilePicPath,
                      radius: avatarRadius,
                    ),
                    if (isUpdating)
                      Container(
                        width: avatarRadius * 2,
                        height: avatarRadius * 2,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                  ],
                ),
              ),
            ),
            PositionedDirectional(
              end: -4,
              bottom: -4,
              child: IconButton.filled(
                tooltip: l10n.profile_change_photo,
                onPressed: isUpdating ? null : () => _pickImage(context),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.secondaryGold,
                  foregroundColor: AppColors.onGold,
                  minimumSize: const Size(
                    AppSizes.minTapTarget,
                    AppSizes.minTapTarget,
                  ),
                ),
                icon: Icon(Icons.camera_alt_rounded, size: 20.sp),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.vLg),
        // Name with an edit button: photo (camera above) and name/email
        // are all changed here.
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: AppSizes.minTapTarget),
            Flexible(
              child: Text(
                user.displayNameOr(l10n.default_user_name),
                textAlign: TextAlign.center,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              tooltip: l10n.edit_profile,
              onPressed: isUpdating ? null : () => _editProfile(context),
              icon: Icon(Icons.edit_outlined, size: 20.sp),
            ),
          ],
        ),
        if (user.email.isNotEmpty) ...[
          SizedBox(height: AppSpacing.vXs),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  user.email,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              if (user.emailVerified) ...[
                SizedBox(width: AppSpacing.xs),
                Icon(
                  Icons.verified_rounded,
                  size: 16.sp,
                  color: AppColors.success,
                  semanticLabel: '✓',
                ),
              ],
            ],
          ),
        ],
        if (memberSince != null) ...[
          SizedBox(height: AppSpacing.vXs),
          Text(
            memberSince,
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final l10n = context.l10n;
    final authBloc = context.read<AuthBloc>();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder:
          (sheetContext) => SafeArea(
            child: Padding(
              padding: EdgeInsetsDirectional.only(bottom: AppSpacing.vLg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ActionTile(
                    icon: Icons.photo_camera_outlined,
                    title: l10n.profile_take_photo,
                    trailing: const SizedBox.shrink(),
                    onTap:
                        () => Navigator.pop(sheetContext, ImageSource.camera),
                  ),
                  ActionTile(
                    icon: Icons.photo_library_outlined,
                    title: l10n.profile_choose_gallery,
                    trailing: const SizedBox.shrink(),
                    onTap:
                        () => Navigator.pop(sheetContext, ImageSource.gallery),
                  ),
                ],
              ),
            ),
          ),
    );
    if (source == null || !context.mounted) return;
    XFile? image;
    try {
      image = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
    } on PlatformException catch (e) {
      if (!context.mounted) return;
      final denied = e.code.contains('denied') || e.code.contains('access');
      showAppSnackBar(
        context,
        denied ? l10n.photo_permission_denied : l10n.photo_pick_failed,
        type: SnackType.error,
      );
      return;
    } catch (_) {
      if (!context.mounted) return;
      showAppSnackBar(context, l10n.photo_pick_failed, type: SnackType.error);
      return;
    }
    if (!context.mounted || image == null) return;
    authBloc.add(UpdateProfileImageRequested(image.path));
  }
}

// ─── Guest profile ────────────────────────────────────────────────────────────

class _GuestProfile extends StatelessWidget {
  const _GuestProfile({required this.authUnavailable});

  final bool authUnavailable;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: AppSpacing.page,
      children: [
        AppCard(
          padding: AppSpacing.all(24),
          child: Column(
            children: [
              Container(
                width: 72.r,
                height: 72.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondaryGold.withValues(alpha: 0.1),
                ),
                child: Icon(
                  Icons.cloud_sync_outlined,
                  size: 34.sp,
                  color: AppColors.secondaryGold,
                ),
              ),
              SizedBox(height: AppSpacing.vLg),
              Text(
                l10n.profile_guest_title,
                textAlign: TextAlign.center,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: AppSpacing.vSm),
              Text(
                authUnavailable
                    ? l10n.auth_unavailable_notice
                    : l10n.guest_mode_notice,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: AppSpacing.vXl),
              PrimaryButton(
                label: l10n.sign_in_to_sync,
                icon: Icons.login_rounded,
                onPressed:
                    authUnavailable
                        ? null
                        : () => _push(context, const SignInPage()),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.vXl),
        const _PulseSummary(),
        SizedBox(height: AppSpacing.vXl),
        const _ActivityLinks(),
      ],
    );
  }
}

// ─── Shared sections ──────────────────────────────────────────────────────────

/// Lifetime points, streaks and badges from [PulseBloc].
class _PulseSummary extends StatelessWidget {
  const _PulseSummary();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    return BlocBuilder<PulseBloc, PulseState>(
      builder: (context, state) {
        final pulse = state is PulseLoaded ? state.pulse : null;
        final badges = [
          for (final id in BadgeIds.all)
            if (pulse?.badges.contains(id) ?? false) id,
          // Unknown (future) ids last.
          for (final id in pulse?.badges ?? const <String>[])
            if (!BadgeIds.all.contains(id)) id,
        ];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StatRow(
              children: [
                StatTile(
                  icon: Icons.stars_rounded,
                  value: formatCompactNumber(pulse?.totalPoints ?? 0),
                  label: l10n.lifetime_points,
                ),
                StatTile(
                  icon: Icons.local_fire_department_rounded,
                  value: '${pulse?.currentStreak ?? 0}',
                  label: l10n.current_streak,
                ),
              ],
            ),
            SizedBox(height: AppSpacing.vMd),
            StatRow(
              children: [
                StatTile(
                  icon: Icons.emoji_events_outlined,
                  value: '${pulse?.longestStreak ?? 0}',
                  label: l10n.longest_streak,
                ),
                StatTile(
                  icon: Icons.workspace_premium_outlined,
                  value: '${badges.length}',
                  label: l10n.badges,
                ),
              ],
            ),
            SizedBox(height: AppSpacing.vXl),
            SectionHeader(
              title: l10n.badges,
              icon: Icons.workspace_premium_outlined,
            ),
            SizedBox(height: AppSpacing.vMd),
            if (badges.isEmpty)
              AppCard(
                child: Text(
                  l10n.no_badges_yet,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              )
            else
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (var i = 0; i < badges.length; i++) ...[
                      if (i > 0) const Divider(height: 1),
                      ActionTile(
                        icon: Icons.military_tech_outlined,
                        title: l10n.translate(badgeL10nKey(badges[i])),
                        subtitle: l10n.translate(
                          badgeDescriptionL10nKey(badges[i]),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Saved verses / activity history / settings tiles.
class _ActivityLinks extends StatelessWidget {
  const _ActivityLinks();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<PulseBloc, PulseState>(
      builder: (context, state) {
        final loaded = state is PulseLoaded ? state : null;
        final activities = [...?loaded?.pulse.recentActivities]
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
        final savedCount = loaded?.savedVerses.length ?? 0;
        return AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              ActionTile(
                icon: Icons.bookmark_outline_rounded,
                title: l10n.profile_saved_verses,
                subtitle: l10n.profileSavedCount(savedCount),
                onTap: () => _push(context, const SavedVersesPage()),
              ),
              const Divider(height: 1),
              ActionTile(
                icon: Icons.history_rounded,
                title: l10n.profile_activity_history,
                subtitle:
                    activities.isEmpty
                        ? null
                        : l10n.profileLastActivity(
                          activityLabel(l10n, activities.first),
                        ),
                onTap: () => _push(context, const ActivityHistoryPage()),
              ),
              const Divider(height: 1),
              ActionTile(
                icon: Icons.settings_outlined,
                title: l10n.settings,
                onTap:
                    () => MainNavigationScope.openTab(
                      context,
                      MainTab.settings,
                      fallback: (_) => const SettingsPage(),
                    ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Edits the name (and email) of the signed-in user.
class EditProfileDialog extends StatefulWidget {
  final String currentName;
  final String currentEmail;
  final void Function(String name, String email) onSave;

  const EditProfileDialog({
    required this.currentName,
    required this.currentEmail,
    required this.onSave,
  });

  @override
  State<EditProfileDialog> createState() => EditProfileDialogState();
}

class EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController = TextEditingController(
    text: widget.currentName,
  );
  late final TextEditingController _emailController = TextEditingController(
    text: widget.currentEmail,
  );

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    Navigator.pop(context);
    if (name == widget.currentName &&
        email.toLowerCase() == widget.currentEmail.toLowerCase()) {
      return;
    }
    widget.onSave(name, email);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.edit_profile),
      scrollable: true,
      // Wider than the default so a full email address fits.
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      contentPadding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              decoration: InputDecoration(labelText: l10n.name),
              validator: (v) => validateName(l10n, v),
            ),
            SizedBox(height: AppSpacing.vLg),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              // Long addresses wrap to a second line instead of being cut.
              minLines: 1,
              maxLines: 2,
              style: Theme.of(context).textTheme.bodyLarge,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.email],
              decoration: InputDecoration(labelText: l10n.email),
              validator: (v) => validateEmail(l10n, v),
              onFieldSubmitted: (_) => _save(),
            ),
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

/// Location settings dialog. Toggling Auto off keeps the dialog open and
/// reveals the manual city field; an empty city can't be saved.
