import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart'
    show FirebaseAuthException, User;
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/entry_route.dart';
import '../../core/services/firebase_service.dart';
import '../../core/services/supabase_service.dart';
import '../../core/services/user_data_sync_service.dart';
import '../../data/datasources/local/local_store.dart';
import '../../domain/entities/user.dart';

// ─── Events ───────────────────────────────────────────────────────────────────

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;
  const SignInRequested(this.email, this.password);
  @override
  List<Object?> get props => [email, password];
}

class GoogleSignInRequested extends AuthEvent {}

/// Sign in with Apple (iOS/macOS; check
/// `FirebaseService.isAppleSignInAvailable()` before showing the button).
class AppleSignInRequested extends AuthEvent {}

class SignUpRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  const SignUpRequested(this.name, this.email, this.password);
  @override
  List<Object?> get props => [name, email, password];
}

/// Use the app without an account (data stays on this device and is
/// uploaded on a later sign-in).
class ContinueAsGuest extends AuthEvent {}

class SignOutRequested extends AuthEvent {}

class ForgotPasswordRequested extends AuthEvent {
  final String email;
  const ForgotPasswordRequested(this.email);
  @override
  List<Object?> get props => [email];
}

class UpdateProfileImageRequested extends AuthEvent {
  final String imagePath;
  const UpdateProfileImageRequested(this.imagePath);
  @override
  List<Object?> get props => [imagePath];
}

class UpdateProfileRequested extends AuthEvent {
  final String name;
  final String email;
  const UpdateProfileRequested({required this.name, required this.email});
  @override
  List<Object?> get props => [name, email];
}

/// Resends the email-verification link (feedback code
/// [AuthCodes.verificationResent]).
class ResendVerificationEmail extends AuthEvent {}

/// Re-checks the session (dispatch on app resume): picks up email
/// verification and signs out if the account was disabled/deleted.
class RefreshSession extends AuthEvent {}

/// Permanently deletes the account and all its data. If the sign-in is not
/// recent, emits `Authenticated` with feedback code
/// [AuthCodes.reauthRequired] and deletes nothing: ask the user to confirm
/// (password field for `user.isPasswordAccount`, otherwise a "Continue with
/// Google/Apple" button) and dispatch [ReauthenticateAndDelete].
class DeleteAccountRequested extends AuthEvent {}

/// Re-authenticates ([password] for email accounts; Google/Apple accounts
/// re-run the provider sign-in), then deletes the account.
class ReauthenticateAndDelete extends AuthEvent {
  final String? password;
  const ReauthenticateAndDelete({this.password});
  @override
  List<Object?> get props => [password];
}

/// Internal: Firebase session changed (userChanges stream).
class _AuthUserChanged extends AuthEvent {
  final User? user;
  const _AuthUserChanged(this.user);
  @override
  List<Object?> get props => [user?.uid, user?.emailVerified];
}

// ─── Feedback codes ───────────────────────────────────────────────────────────

/// Stable codes for messages emitted by the bloc. UI maps them to l10n.
class AuthCodes {
  static const profileUpdated = 'profile-updated';
  static const photoUpdated = 'photo-updated';
  static const verificationEmailSent = 'verification-email-sent';
  static const verificationResent = 'verification-resent';
  static const uploadFailed = 'upload-failed';
  static const profileUpdateFailed = 'profile-update-failed';
  static const googleFailed = 'google-sign-in-failed';
  static const appleFailed = 'apple-sign-in-failed';
  static const invalidName = 'invalid-name';
  static const authUnavailable = 'auth-unavailable';

  /// Account deletion needs a fresh sign-in: show the re-auth prompt.
  static const reauthRequired = 'reauth-required';
  static const deleteFailed = 'delete-account-failed';
  static const unknown = 'unknown';
}

/// One-shot message attached to [Authenticated] (e.g. after a profile edit).
/// [id] makes repeated identical messages distinguishable for listeners.
class AuthFeedback extends Equatable {
  final String code;
  final String message;
  final bool isError;
  final int id;

  AuthFeedback({
    required this.code,
    required this.message,
    this.isError = false,
  }) : id = DateTime.now().microsecondsSinceEpoch;

  @override
  List<Object?> get props => [code, message, isError, id];
}

// ─── States ───────────────────────────────────────────────────────────────────

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

/// Only used for sign-in / sign-up / password-reset flows, never while a
/// user is signed in (profile updates use [Authenticated.isUpdating]).
class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final UserEntity user;

  /// True during profile updates and account deletion.
  final bool isUpdating;
  final AuthFeedback? feedback;
  const Authenticated(this.user, {this.isUpdating = false, this.feedback});

  bool get isEmailVerified => user.emailVerified;

  @override
  List<Object?> get props => [user, isUpdating, feedback];
}

class Unauthenticated extends AuthState {}

/// The account was deleted (also an [Unauthenticated] state).
class AccountDeleted extends Unauthenticated {}

/// The session ended outside the app (account disabled/deleted, signed out
/// on the server). Also an [Unauthenticated] state.
class SessionExpired extends Unauthenticated {}

/// Using the app without an account. [authUnavailable] is true when
/// Firebase failed to initialise (sign-in impossible; hide auth buttons or
/// show "try again later").
class GuestMode extends AuthState {
  final bool authUnavailable;
  const GuestMode({this.authUnavailable = false});
  @override
  List<Object?> get props => [authUnavailable];
}

class AuthError extends AuthState {
  final String message;
  final String code;
  const AuthError(this.message, {this.code = AuthCodes.unknown});
  @override
  List<Object?> get props => [message, code];
}

class ForgotPasswordSent extends AuthState {
  const ForgotPasswordSent();
}

// ─── Message helpers ──────────────────────────────────────────────────────────

/// Maps an auth code to an l10n key, or null if there is none.
String? authMessageKey(String code) {
  switch (code) {
    case 'invalid-email':
      return 'invalid_email';
    case 'user-not-found':
      return 'err_user_not_found';
    case 'wrong-password':
    case 'invalid-credential':
      return 'err_wrong_credentials';
    case 'email-already-in-use':
      return 'err_email_in_use';
    case 'weak-password':
      return 'password_too_short';
    case 'network-request-failed':
      return 'err_network';
    case 'too-many-requests':
      return 'err_too_many_requests';
    case 'requires-recent-login':
      return 'err_recent_login';
    case 'user-disabled':
      return 'err_user_disabled';
    case 'account-exists-with-different-credential':
      return 'err_account_exists_different_provider';
    case 'user-mismatch':
      return 'err_user_mismatch';
    case 'missing-password':
      return 'password_required';
    case AuthCodes.uploadFailed:
      return 'err_upload_failed';
    case AuthCodes.profileUpdateFailed:
      return 'err_profile_update_failed';
    case AuthCodes.googleFailed:
      return 'err_google_failed';
    case AuthCodes.appleFailed:
      return 'err_apple_failed';
    case AuthCodes.authUnavailable:
      return 'err_auth_unavailable';
    case AuthCodes.reauthRequired:
      return 'reauth_required_delete';
    case AuthCodes.deleteFailed:
      return 'err_delete_account_failed';
    case AuthCodes.invalidName:
      return 'name_required';
    case AuthCodes.profileUpdated:
      return 'profile_updated';
    case AuthCodes.photoUpdated:
      return 'photo_updated';
    case AuthCodes.verificationEmailSent:
      return 'verification_email_sent';
    case AuthCodes.verificationResent:
      return 'verification_link_resent';
    default:
      return null;
  }
}

/// Removes "Exception: " style prefixes from raw error text.
String cleanErrorMessage(Object error) {
  if (error is AuthFailure) return error.message;
  var text = error.toString();
  for (final prefix in ['Exception: ', 'FormatException: ', 'Error: ']) {
    while (text.startsWith(prefix)) {
      text = text.substring(prefix.length);
    }
  }
  return text.trim().isEmpty ? 'An error occurred. Please try again.' : text;
}

/// Localized text for an auth [code], falling back to [fallback].
String localizedAuthMessage(
  AppLocalizations l10n,
  String code,
  String fallback,
) {
  final key = authMessageKey(code);
  if (key != null) {
    final text = l10n.translate(key);
    if (text != key) return text;
  }
  return fallback;
}

// ─── Form validators ──────────────────────────────────────────────────────────

final RegExp _emailRegExp = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

bool isValidEmail(String? value) =>
    value != null && _emailRegExp.hasMatch(value.trim());

String? validateName(AppLocalizations l10n, String? value) =>
    (value == null || value.trim().isEmpty) ? l10n.name_required : null;

String? validateEmail(AppLocalizations l10n, String? value) {
  if (value == null || value.trim().isEmpty) return l10n.email_required;
  return isValidEmail(value) ? null : l10n.invalid_email;
}

String? validatePassword(AppLocalizations l10n, String? value) {
  if (value == null || value.isEmpty) return l10n.password_required;
  return value.length < 6 ? l10n.password_too_short : null;
}

// ─── BLoC ─────────────────────────────────────────────────────────────────────

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SharedPreferences prefs;
  final SupabaseService supabaseService;
  final FirebaseService firebaseService;
  final UserDataSyncService? sync;

  StreamSubscription<User?>? _userSub;

  /// True while this bloc itself signs out / deletes, so the resulting
  /// session-ended event from Firebase is not treated as external.
  bool _busy = false;

  AuthBloc(this.prefs, this.supabaseService, this.firebaseService, {this.sync})
    : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<SignInRequested>(_onSignInRequested);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<AppleSignInRequested>(_onAppleSignInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<ContinueAsGuest>(_onContinueAsGuest);
    on<SignOutRequested>(_onSignOutRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<UpdateProfileImageRequested>(_onUpdateProfileImage);
    on<UpdateProfileRequested>(_onUpdateProfile);
    on<ResendVerificationEmail>(_onResendVerification);
    on<RefreshSession>(_onRefreshSession);
    on<DeleteAccountRequested>(_onDeleteAccount);
    on<ReauthenticateAndDelete>(_onReauthenticateAndDelete);
    on<_AuthUserChanged>(_onUserChanged);

    try {
      _userSub = firebaseService.userChanges().listen((user) {
        if (!isClosed) add(_AuthUserChanged(user));
      }, onError: (Object e) => debugPrint('userChanges error: $e'));
    } catch (e) {
      debugPrint('Could not subscribe to auth changes: $e');
    }
  }

  @override
  Future<void> close() async {
    await _userSub?.cancel();
    return super.close();
  }

  bool get _isGuestPref => prefs.getBool(EntryPrefsKeys.guestMode) ?? false;

  // ── Session Check ───────────────────────────────────────────────────────────
  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (!firebaseService.isAvailable) {
      emit(const GuestMode(authUnavailable: true));
      return;
    }
    final firebaseUser = firebaseService.currentUser;
    if (firebaseUser == null) {
      emit(_isGuestPref ? const GuestMode() : Unauthenticated());
      return;
    }
    // Emit immediately from the locally cached profile, then refresh from
    // Firestore (the source of truth for name/photo).
    final cached = _userFromCache(firebaseUser);
    emit(Authenticated(cached));
    try {
      final resolved = await _resolveUser(firebaseUser);
      if (state is Authenticated &&
          (state as Authenticated).user.id == resolved.id &&
          !(state as Authenticated).isUpdating) {
        emit(Authenticated(resolved));
      }
    } catch (_) {
      // Keep cached user.
    }
  }

  // ── Firebase session stream ─────────────────────────────────────────────────
  Future<void> _onUserChanged(
    _AuthUserChanged event,
    Emitter<AuthState> emit,
  ) async {
    if (_busy) return;
    final current = state;
    if (current is! Authenticated) return;
    final user = event.user;
    if (user == null) {
      // Signed out outside this bloc (disabled/deleted account, revoked
      // session, another plugin).
      await _wipeLocal();
      emit(SessionExpired());
      return;
    }
    if (user.uid != current.user.id) return;
    if (user.emailVerified != current.user.emailVerified) {
      emit(
        Authenticated(
          current.user.copyWith(emailVerified: user.emailVerified),
          isUpdating: current.isUpdating,
        ),
      );
    }
  }

  Future<void> _onRefreshSession(
    RefreshSession event,
    Emitter<AuthState> emit,
  ) async {
    final current = state;
    if (current is! Authenticated || _busy) return;
    final user = firebaseService.currentUser;
    if (user == null) {
      await _wipeLocal();
      emit(SessionExpired());
      return;
    }
    try {
      await user.reload();
    } on FirebaseAuthException catch (e) {
      if (const {
        'user-disabled',
        'user-not-found',
        'user-token-expired',
        'invalid-user-token',
      }.contains(e.code)) {
        _busy = true;
        try {
          await firebaseService.signOut();
        } catch (_) {}
        await _wipeLocal();
        _busy = false;
        emit(SessionExpired());
      }
      return;
    } catch (_) {
      return; // offline etc.
    }
    final fresh = firebaseService.currentUser;
    final latest = state;
    if (fresh != null &&
        latest is Authenticated &&
        fresh.emailVerified != latest.user.emailVerified) {
      emit(
        Authenticated(
          latest.user.copyWith(emailVerified: fresh.emailVerified),
          isUpdating: latest.isUpdating,
        ),
      );
    }
  }

  // ── Email Sign In ───────────────────────────────────────────────────────────
  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final firebaseUser = await firebaseService.signIn(
        email: event.email.trim(),
        password: event.password,
      );
      emit(Authenticated(await _resolveUser(firebaseUser)));
    } catch (e) {
      emit(_errorState(e));
    }
  }

  // ── Google Sign In ──────────────────────────────────────────────────────────
  Future<void> _onGoogleSignInRequested(
    GoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    final previous = state;
    emit(AuthLoading());
    try {
      final firebaseUser = await firebaseService.signInWithGoogle();
      emit(Authenticated(await _resolveUser(firebaseUser)));
    } on GoogleSignInCanceled {
      // User closed the picker: silently return to the previous state.
      emit(_signedOutState(previous));
    } catch (e) {
      emit(_errorState(e, fallbackCode: AuthCodes.googleFailed));
    }
  }

  // ── Apple Sign In ───────────────────────────────────────────────────────────
  Future<void> _onAppleSignInRequested(
    AppleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    final previous = state;
    emit(AuthLoading());
    try {
      final firebaseUser = await firebaseService.signInWithApple();
      emit(Authenticated(await _resolveUser(firebaseUser)));
    } on AppleSignInCanceled {
      emit(_signedOutState(previous));
    } catch (e) {
      emit(_errorState(e, fallbackCode: AuthCodes.appleFailed));
    }
  }

  AuthState _signedOutState(AuthState previous) =>
      previous is GuestMode || _isGuestPref
          ? const GuestMode()
          : Unauthenticated();

  // ── Sign Up ──────────────────────────────────────────────────────────────────
  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final firebaseUser = await firebaseService.signUp(
        name: event.name.trim(),
        email: event.email.trim(),
        password: event.password,
      );
      emit(
        Authenticated(
          await _resolveUser(firebaseUser, fallbackName: event.name.trim()),
        ),
      );
    } catch (e) {
      emit(_errorState(e));
    }
  }

  // ── Guest ────────────────────────────────────────────────────────────────────
  Future<void> _onContinueAsGuest(
    ContinueAsGuest event,
    Emitter<AuthState> emit,
  ) async {
    await prefs.setBool(EntryPrefsKeys.guestMode, true);
    emit(GuestMode(authUnavailable: !firebaseService.isAvailable));
  }

  // ── Sign Out ─────────────────────────────────────────────────────────────────
  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    _busy = true;
    try {
      await _stopAudio();
      try {
        await firebaseService.signOut();
      } catch (_) {}
      // Data lives in Firestore, so the local cache can be wiped.
      await _wipeLocal();
      try {
        await prefs.remove(EntryPrefsKeys.guestMode);
      } catch (_) {}
    } finally {
      _busy = false;
      emit(Unauthenticated());
    }
  }

  Future<void> _stopAudio() async {
    try {
      if (GetIt.instance.isRegistered<AudioService>()) {
        await GetIt.instance<AudioService>().stop();
      }
    } catch (_) {}
  }

  Future<void> _wipeLocal() async {
    try {
      await (sync?.wipeLocalUserData() ?? UserDataSyncService.wipeLocal(prefs));
    } catch (e) {
      debugPrint('Local wipe failed: $e');
    }
  }

  // ── Account deletion ────────────────────────────────────────────────────────
  Future<void> _onDeleteAccount(
    DeleteAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
    final current = state;
    if (current is! Authenticated || current.isUpdating) return;
    if (!firebaseService.hasRecentLogin) {
      emit(_reauthRequired(current.user));
      return;
    }
    emit(Authenticated(current.user, isUpdating: true));
    await _deleteEverything(current.user, emit);
  }

  Future<void> _onReauthenticateAndDelete(
    ReauthenticateAndDelete event,
    Emitter<AuthState> emit,
  ) async {
    final current = state;
    if (current is! Authenticated || current.isUpdating) return;
    final user = current.user;
    emit(Authenticated(user, isUpdating: true));
    try {
      await firebaseService.reauthenticate(password: event.password);
    } on GoogleSignInCanceled {
      emit(Authenticated(user));
      return;
    } on AppleSignInCanceled {
      emit(Authenticated(user));
      return;
    } catch (e) {
      final failure = _toFailure(e, AuthCodes.deleteFailed);
      emit(
        Authenticated(
          user,
          feedback: AuthFeedback(
            code: failure.code,
            message: failure.message,
            isError: true,
          ),
        ),
      );
      return;
    }
    await _deleteEverything(user, emit);
  }

  Authenticated _reauthRequired(UserEntity user) => Authenticated(
    user,
    feedback: AuthFeedback(
      code: AuthCodes.reauthRequired,
      message:
          'For security, please confirm your sign-in to delete your account.',
      isError: true,
    ),
  );

  Future<void> _deleteEverything(
    UserEntity user,
    Emitter<AuthState> emit,
  ) async {
    _busy = true;
    try {
      // Data first (needs the signed-in user for Firestore rules and the
      // Supabase token), then the Auth account.
      final s = sync;
      if (s != null) {
        await s.deleteAllUserData(user.id).timeout(const Duration(seconds: 45));
      }
      await supabaseService.deleteAllUserImages(user.id);
      await firebaseService.deleteCurrentUser();
    } catch (e) {
      _busy = false;
      final failure = _toFailure(e, AuthCodes.deleteFailed);
      if (failure.code == 'requires-recent-login') {
        emit(_reauthRequired(user));
      } else {
        emit(
          Authenticated(
            user,
            feedback: AuthFeedback(
              code:
                  failure.code == AuthCodes.unknown
                      ? AuthCodes.deleteFailed
                      : failure.code,
              message: 'Could not delete your account. Please try again.',
              isError: true,
            ),
          ),
        );
      }
      return;
    }
    await _stopAudio();
    await _wipeLocal();
    try {
      await prefs.remove(EntryPrefsKeys.guestMode);
    } catch (_) {}
    _busy = false;
    emit(AccountDeleted());
  }

  // ── Forgot Password ───────────────────────────────────────────────────────────
  Future<void> _onForgotPasswordRequested(
    ForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await firebaseService.sendPasswordResetEmail(event.email.trim());
      emit(const ForgotPasswordSent());
    } catch (e) {
      emit(_errorState(e));
    }
  }

  // ── Email verification ────────────────────────────────────────────────────────
  Future<void> _onResendVerification(
    ResendVerificationEmail event,
    Emitter<AuthState> emit,
  ) async {
    final current = state;
    if (current is! Authenticated) return;
    try {
      await firebaseService.sendEmailVerification();
      emit(
        Authenticated(
          current.user,
          feedback: AuthFeedback(
            code: AuthCodes.verificationResent,
            message: 'Verification email sent.',
          ),
        ),
      );
    } catch (e) {
      final failure = _toFailure(e, AuthCodes.unknown);
      emit(
        Authenticated(
          current.user,
          feedback: AuthFeedback(
            code: failure.code,
            message: failure.message,
            isError: true,
          ),
        ),
      );
    }
  }

  // ── Update Profile Image ──────────────────────────────────────────────────────
  Future<void> _onUpdateProfileImage(
    UpdateProfileImageRequested event,
    Emitter<AuthState> emit,
  ) async {
    final current = state;
    if (current is! Authenticated || current.isUpdating) return;
    final user = current.user;
    emit(Authenticated(user, isUpdating: true));
    try {
      final imageUrl = await supabaseService.uploadProfileImage(
        uid: user.id,
        filePath: event.imagePath,
      );
      await firebaseService.saveUserProfile(
        uid: user.id,
        profilePicUrl: imageUrl,
      );
      try {
        await firebaseService.updatePhotoURL(imageUrl);
      } catch (_) {
        // Firestore is the source of truth; Auth photoURL is best-effort.
      }
      await prefs.setString(UserPrefsKeys.userProfilePic, imageUrl);
      unawaited(
        supabaseService.deletePreviousProfileImage(
          uid: user.id,
          previousUrl: user.profilePicPath,
        ),
      );

      emit(
        Authenticated(
          user.copyWith(profilePicPath: imageUrl),
          feedback: AuthFeedback(
            code: AuthCodes.photoUpdated,
            message: 'Profile photo updated.',
          ),
        ),
      );
    } catch (e) {
      emit(
        Authenticated(
          user,
          feedback: AuthFeedback(
            code: AuthCodes.uploadFailed,
            message: 'Failed to upload image. Please try again.',
            isError: true,
          ),
        ),
      );
    }
  }

  // ── Update Profile ────────────────────────────────────────────────────────────
  Future<void> _onUpdateProfile(
    UpdateProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    final current = state;
    if (current is! Authenticated || current.isUpdating) return;
    final user = current.user;
    final name = event.name.trim();
    final email = event.email.trim();

    if (name.isEmpty) {
      emit(
        Authenticated(
          user,
          feedback: AuthFeedback(
            code: AuthCodes.invalidName,
            message: 'Please enter your name.',
            isError: true,
          ),
        ),
      );
      return;
    }

    emit(Authenticated(user, isUpdating: true));
    final emailChanged =
        email.isNotEmpty && email.toLowerCase() != user.email.toLowerCase();
    try {
      // Email first: if it needs a recent login nothing else is changed.
      if (emailChanged) {
        await firebaseService.verifyBeforeUpdateEmail(email);
      }
      if (name != user.name) {
        await firebaseService.updateDisplayName(name);
        // Email is NOT written here: it only changes once verified, and is
        // then synced from Firebase Auth on the next session check.
        await firebaseService.saveUserProfile(uid: user.id, name: name);
        await prefs.setString(UserPrefsKeys.userName, name);
      }

      emit(
        Authenticated(
          user.copyWith(name: name),
          feedback:
              emailChanged
                  ? AuthFeedback(
                    code: AuthCodes.verificationEmailSent,
                    message:
                        'A verification link was sent to $email. Your email will update once you confirm it.',
                  )
                  : AuthFeedback(
                    code: AuthCodes.profileUpdated,
                    message: 'Profile updated.',
                  ),
        ),
      );
    } catch (e) {
      final failure = _toFailure(e, AuthCodes.profileUpdateFailed);
      emit(
        Authenticated(
          user,
          feedback: AuthFeedback(
            code: failure.code,
            message: failure.message,
            isError: true,
          ),
        ),
      );
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────
  AuthError _errorState(Object e, {String fallbackCode = AuthCodes.unknown}) {
    final failure = _toFailure(e, fallbackCode);
    return AuthError(failure.message, code: failure.code);
  }

  AuthFailure _toFailure(Object e, String fallbackCode) {
    if (e is AuthFailure) return e;
    if (e is FirebaseAuthException) return FirebaseService.mapAuthException(e);
    return AuthFailure(fallbackCode, cleanErrorMessage(e));
  }

  String? _nonEmpty(Object? value) {
    if (value is! String) return null;
    final v = value.trim();
    return v.isEmpty ? null : v;
  }

  /// Builds a user from SharedPreferences (if it belongs to the same uid)
  /// and Firebase Auth, preferring locally cached (edited) values. The name
  /// is empty when unknown (UI shows `default_user_name`).
  UserEntity _userFromCache(User firebaseUser) {
    final sameUser = prefs.getString(UserPrefsKeys.userId) == firebaseUser.uid;
    return UserEntity(
      id: firebaseUser.uid,
      name:
          (sameUser
              ? _nonEmpty(prefs.getString(UserPrefsKeys.userName))
              : null) ??
          _nonEmpty(firebaseUser.displayName) ??
          '',
      email:
          firebaseUser.email ??
          (sameUser ? prefs.getString(UserPrefsKeys.userEmail) : null) ??
          '',
      profilePicPath:
          (sameUser
              ? _nonEmpty(prefs.getString(UserPrefsKeys.userProfilePic))
              : null) ??
          _nonEmpty(firebaseUser.photoURL),
      memberSince: firebaseUser.metadata.creationTime,
      emailVerified: _emailVerified(firebaseUser),
      signInProvider: FirebaseService.primaryProviderOf(firebaseUser),
    );
  }

  /// Provider accounts (Google/Apple) count as verified.
  static bool _emailVerified(User u) =>
      u.emailVerified ||
      FirebaseService.primaryProviderOf(u) != AuthProviderIds.password;

  /// Resolves the profile: Firestore (if a doc exists) wins over Auth for
  /// name and photo. Firestore is only seeded from Auth when no doc exists,
  /// and a custom photo is never overwritten by the provider's photo.
  Future<UserEntity> _resolveUser(
    User firebaseUser, {
    String? fallbackName,
  }) async {
    final uid = firebaseUser.uid;
    final authEmail = firebaseUser.email ?? '';
    final verified = _emailVerified(firebaseUser);
    final provider = FirebaseService.primaryProviderOf(firebaseUser);
    Map<String, dynamic>? data;
    var fetched = false;
    try {
      data = await firebaseService
          .fetchUserProfileData(uid)
          .timeout(const Duration(seconds: 10));
      fetched = true;
    } catch (_) {}

    UserEntity user;
    if (data != null) {
      final name =
          _nonEmpty(data['name']) ??
          _nonEmpty(firebaseUser.displayName) ??
          fallbackName ??
          '';
      final storedPhoto = _nonEmpty(data['profilePicUrl']);
      final photo = storedPhoto ?? _nonEmpty(firebaseUser.photoURL);
      user = UserEntity(
        id: uid,
        name: name,
        email:
            authEmail.isNotEmpty ? authEmail : (_nonEmpty(data['email']) ?? ''),
        profilePicPath: photo,
        memberSince: firebaseUser.metadata.creationTime,
        emailVerified: verified,
        signInProvider: provider,
      );
      // Sync a verified email change, fill in a missing photo or name.
      final needsEmailSync =
          authEmail.isNotEmpty && _nonEmpty(data['email']) != authEmail;
      final needsPhotoSeed = storedPhoto == null && photo != null;
      final needsNameSeed = _nonEmpty(data['name']) == null && name.isNotEmpty;
      if (needsEmailSync || needsPhotoSeed || needsNameSeed) {
        try {
          await firebaseService.saveUserProfile(
            uid: uid,
            email: needsEmailSync ? authEmail : null,
            profilePicUrl: needsPhotoSeed ? photo : null,
            name: needsNameSeed ? name : null,
          );
        } catch (_) {}
      }
    } else if (fetched) {
      // No profile yet: seed from Auth.
      user = UserEntity(
        id: uid,
        name: fallbackName ?? _nonEmpty(firebaseUser.displayName) ?? '',
        email: authEmail,
        profilePicPath: _nonEmpty(firebaseUser.photoURL),
        memberSince: firebaseUser.metadata.creationTime,
        emailVerified: verified,
        signInProvider: provider,
      );
      try {
        await firebaseService.saveUserProfile(
          uid: uid,
          name: user.hasName ? user.name : null,
          email: user.email,
          profilePicUrl: user.profilePicPath,
          isNew: true,
        );
      } catch (_) {}
    } else {
      // Firestore unreachable: don't write anything, use local cache.
      user = _userFromCache(firebaseUser);
      if (fallbackName != null &&
          prefs.getString(UserPrefsKeys.userId) != uid) {
        user = user.copyWith(name: fallbackName);
      }
    }

    await prefs.setString(UserPrefsKeys.userId, uid);
    await prefs.setString(UserPrefsKeys.userName, user.name);
    await prefs.setString(UserPrefsKeys.userEmail, user.email);
    if (user.profilePicPath != null) {
      await prefs.setString(UserPrefsKeys.userProfilePic, user.profilePicPath!);
    } else {
      await prefs.remove(UserPrefsKeys.userProfilePic);
    }
    // Signed in: no longer a guest (local guest data is migrated by
    // UserDataSyncService.syncOnSignIn).
    await prefs.remove(EntryPrefsKeys.guestMode);
    return user;
  }
}
