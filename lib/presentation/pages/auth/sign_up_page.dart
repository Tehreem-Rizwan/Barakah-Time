import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/localization/app_localizations.dart';
import '../../blocs/auth_bloc.dart';
import '../../widgets/widgets.dart';
import '../main_navigation_page.dart';
import 'sign_in_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    TextInput.finishAutofillContext();
    setState(() => _action = AuthAction.email);
    context.read<AuthBloc>().add(
      SignUpRequested(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      ),
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

  void _goToSignIn() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    } else {
      navigator.pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const SignInPage()),
      );
    }
  }

  void _listener(BuildContext context, AuthState state) {
    if (ModalRoute.of(context)?.isCurrent == false) return;
    final l10n = context.l10n;
    if (state is Authenticated) {
      // Email sign-ups get a verification link (provider accounts are
      // already verified).
      if (_action == AuthAction.email && !state.isEmailVerified) {
        showAppSnackBar(
          context,
          l10n.authAccountCreatedVerify(state.user.email),
          type: SnackType.success,
          duration: const Duration(seconds: 6),
        );
      }
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    return AppScaffold(
      gradientBackground: true,
      // Empty title: gives an app bar with the automatic back button.
      titleWidget: const SizedBox.shrink(),
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
                        const AuthLogo(),
                        SizedBox(height: AppSpacing.vXl),
                        Semantics(
                          header: true,
                          child: Text(
                            l10n.auth_create_account,
                            textAlign: TextAlign.center,
                            style: textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: AppSpacing.vSm),
                        Text(
                          l10n.auth_sign_up_subtitle,
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: AppSpacing.vXl),
                        AuthTextField(
                          controller: _nameController,
                          label: l10n.auth_full_name,
                          icon: Icons.person_outline,
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.name],
                          onFieldSubmitted: (_) => _emailFocus.requestFocus(),
                          validator: (v) => validateName(l10n, v),
                        ),
                        SizedBox(height: AppSpacing.vLg),
                        AuthTextField(
                          controller: _emailController,
                          focusNode: _emailFocus,
                          label: l10n.auth_email_address,
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
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
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.newPassword],
                          onFieldSubmitted: (_) => _confirmFocus.requestFocus(),
                          validator: (v) => validatePassword(l10n, v),
                        ),
                        SizedBox(height: AppSpacing.vLg),
                        AuthTextField(
                          controller: _confirmPasswordController,
                          focusNode: _confirmFocus,
                          label: l10n.confirm_password,
                          icon: Icons.lock_outline,
                          isPassword: true,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.newPassword],
                          onFieldSubmitted: (_) {
                            if (!busy) _submit();
                          },
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return l10n.password_required;
                            }
                            return v != _passwordController.text
                                ? l10n.passwords_do_not_match
                                : null;
                          },
                        ),
                        SizedBox(height: AppSpacing.vXl),
                        PrimaryButton(
                          label: l10n.auth_register,
                          loading: busy && _action == AuthAction.email,
                          onPressed: busy ? null : _submit,
                        ),
                        SizedBox(height: AppSpacing.vXl),
                        const AuthDivider(),
                        SizedBox(height: AppSpacing.vXl),
                        GoogleSignInButton(
                          loading: busy && _action == AuthAction.google,
                          onPressed: busy ? null : _google,
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
                          prompt: l10n.auth_have_account,
                          action: l10n.auth_sign_in,
                          onPressed: busy ? null : _goToSignIn,
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
