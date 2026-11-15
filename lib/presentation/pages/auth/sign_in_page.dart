import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/services/app_init_status.dart';
import '../../../core/services/firebase_service.dart';
import '../../blocs/auth_bloc.dart';
import '../../widgets/widgets.dart';
import '../main_navigation_page.dart';
import 'sign_up_page.dart';

/// Which auth button started the current [AuthLoading] (for its spinner).
enum AuthAction { email, google, apple }

FirebaseService? _firebaseOrNull() =>
    GetIt.instance.isRegistered<FirebaseService>()
        ? GetIt.instance<FirebaseService>()
        : null;

/// Whether Firebase Auth can be used (false if it failed to initialise).
bool authAvailable() => AppInitStatus.firebaseReady;

/// Resolves whether to show the "Sign in with Apple" button.
Future<bool> appleSignInAvailable() async {
  try {
    return await _firebaseOrNull()?.isAppleSignInAvailable() ?? false;
  } catch (_) {
    return false;
  }
}

/// Enters guest mode and resets the stack to the main app.
void continueAsGuest(BuildContext context) {
  context.read<AuthBloc>().add(ContinueAsGuest());
  if (!authAvailable()) {
    showAppSnackBar(
      context,
      context.l10n.auth_unavailable_notice,
      type: SnackType.warning,
    );
  }
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute<void>(builder: (_) => const MainNavigationPage()),
    (route) => false,
  );
}

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocus = FocusNode();
  bool _appleAvailable = false;
  AuthAction? _action;

  @override
  void initState() {
    super.initState();
    appleSignInAvailable().then((available) {
      if (mounted && available) setState(() => _appleAvailable = true);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    TextInput.finishAutofillContext();
    setState(() => _action = AuthAction.email);
    context.read<AuthBloc>().add(
      SignInRequested(_emailController.text.trim(), _passwordController.text),
    );
  }

  void _google() {
    setState(() => _action = AuthAction.google);
    context.read<AuthBloc>().add(GoogleSignInRequested());
  }

  void _apple() {
    setState(() => _action = AuthAction.apple);
    context.read<AuthBloc>().add(AppleSignInRequested());
  }

  Future<void> _showForgotPasswordDialog() async {
    final email = await showDialog<String>(
      context: context,
      builder:
          (_) =>
              _ForgotPasswordDialog(initialEmail: _emailController.text.trim()),
    );
    if (!mounted || email == null) return;
    setState(() => _action = null);
    context.read<AuthBloc>().add(ForgotPasswordRequested(email));
  }

  void _listener(BuildContext context, AuthState state) {
    // Only the top-most auth route reacts (SignUp may be pushed above).
    if (ModalRoute.of(context)?.isCurrent == false) return;
    final l10n = context.l10n;
    if (state is Authenticated) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const MainNavigationPage()),
        (route) => false,
      );
    } else if (state is AuthError) {
      showAppSnackBar(
        context,
        localizedAuthMessage(l10n, state.code, state.message),
        type: SnackType.error,
      );
    } else if (state is ForgotPasswordSent) {
      showAppSnackBar(context, l10n.reset_email_sent, type: SnackType.success);
    } else if (state is GuestMode && state.authUnavailable) {
      showAppSnackBar(
        context,
        l10n.auth_unavailable_notice,
        type: SnackType.warning,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final available = authAvailable();

    return AppScaffold(
      gradientBackground: true,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: _listener,
        builder: (context, state) {
          final busy = state is AuthLoading;
          return Center(
            child: SingleChildScrollView(
              padding: AppSpacing.page,
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: AutofillGroup(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: AppSpacing.vXl),
                        const AuthLogo(),
                        SizedBox(height: AppSpacing.vXl),
                        Semantics(
                          header: true,
                          child: Text(
                            l10n.auth_welcome_back,
                            textAlign: TextAlign.center,
                            style: textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: AppSpacing.vSm),
                        Text(
                          l10n.auth_sign_in_subtitle,
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: AppSpacing.vXl),
                        if (!available) ...[
                          AuthNotice(message: l10n.auth_unavailable_notice),
                          SizedBox(height: AppSpacing.vLg),
                        ],
                        AuthTextField(
                          controller: _emailController,
                          label: l10n.auth_email_address,
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [
                            AutofillHints.email,
                            AutofillHints.username,
                          ],
                          enabled: available,
                          onFieldSubmitted:
                              (_) => _passwordFocus.requestFocus(),
                          validator: (v) => validateEmail(l10n, v),
                        ),
                        SizedBox(height: AppSpacing.vLg),
                        AuthTextField(
                          controller: _passwordController,
                          focusNode: _passwordFocus,
                          label: l10n.auth_password,
                          icon: Icons.lock_outline,
                          isPassword: true,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.password],
                          enabled: available,
                          onFieldSubmitted: (_) {
                            if (!busy) _submit();
                          },
                          validator:
                              (v) =>
                                  (v == null || v.isEmpty)
                                      ? l10n.password_required
                                      : null,
                        ),
                        Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: TextButton(
                            onPressed:
                                busy || !available
                                    ? null
                                    : _showForgotPasswordDialog,
                            child: Text(l10n.forgot_password),
                          ),
                        ),
                        SizedBox(height: AppSpacing.vMd),
                        PrimaryButton(
                          label: l10n.auth_sign_in,
                          loading: busy && _action == AuthAction.email,
                          onPressed: busy || !available ? null : _submit,
                        ),
                        SizedBox(height: AppSpacing.vXl),
                        const AuthDivider(),
                        SizedBox(height: AppSpacing.vXl),
                        GoogleSignInButton(
                          loading: busy && _action == AuthAction.google,
                          onPressed: busy || !available ? null : _google,
                        ),
                        if (_appleAvailable) ...[
                          SizedBox(height: AppSpacing.vMd),
                          AppleSignInButton(
                            label: l10n.sign_in_with_apple,
                            loading: busy && _action == AuthAction.apple,
                            onPressed: busy ? null : _apple,
                          ),
                        ],
                        SizedBox(height: AppSpacing.vLg),
                        AuthSwitchPrompt(
                          prompt: l10n.auth_no_account,
                          action: l10n.auth_sign_up,
                          onPressed:
                              busy || !available
                                  ? null
                                  : () => Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => const SignUpPage(),
                                    ),
                                  ),
                        ),
                        Center(
                          child: TextButton(
                            onPressed:
                                busy ? null : () => continueAsGuest(context),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.textSecondary,
                            ),
                            child: Text(l10n.continue_as_guest),
                          ),
                        ),
                        SizedBox(height: AppSpacing.vLg),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Mosque emblem shown on the auth screens.
class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ExcludeSemantics(
        child: Container(
          padding: EdgeInsetsDirectional.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.secondaryGold.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.mosque, size: 56.sp, color: AppColors.secondaryGold),
        ),
      ),
    );
  }
}

/// "—— or ——" separator.
class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            context.l10n.auth_or,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

/// "Don't have an account? [Sign Up]" row that wraps at large text sizes.
class AuthSwitchPrompt extends StatelessWidget {
  const AuthSwitchPrompt({
    super.key,
    required this.prompt,
    required this.action,
    required this.onPressed,
  });

  final String prompt;
  final String action;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          prompt,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        TextButton(onPressed: onPressed, child: Text(action)),
      ],
    );
  }
}

/// Informational banner (info icon + text) used on auth / profile screens.
class AuthNotice extends StatelessWidget {
  const AuthNotice({
    super.key,
    required this.message,
    this.icon = Icons.info_outline_rounded,
    this.color = AppColors.warning,
    this.action,
  });

  final String message;
  final IconData icon;
  final Color color;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: color,
      border: Border.all(color: color.withValues(alpha: 0.4)),
      borderRadius: AppRadius.mdAll,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 22.sp),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          if (action != null)
            Align(alignment: AlignmentDirectional.centerEnd, child: action),
        ],
      ),
    );
  }
}

/// Owns its controller so it outlives the dialog's exit animation.
class _ForgotPasswordDialog extends StatefulWidget {
  final String initialEmail;
  const _ForgotPasswordDialog({required this.initialEmail});

  @override
  State<_ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<_ForgotPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialEmail,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.pop(context, _controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.reset_password),
      scrollable: true,
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.reset_password_hint),
            SizedBox(height: AppSpacing.vMd),
            TextFormField(
              controller: _controller,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              textInputAction: TextInputAction.send,
              autofocus: true,
              decoration: InputDecoration(labelText: l10n.email),
              validator: (v) => validateEmail(l10n, v),
              onFieldSubmitted: (_) => _send(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _send, child: Text(l10n.send_link)),
      ],
    );
  }
}
