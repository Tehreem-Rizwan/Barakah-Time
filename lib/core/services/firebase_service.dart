import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart' as g_sign_in;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'app_init_status.dart';

/// A user-facing auth failure. [code] is a stable identifier (Firebase error
/// code or an app-specific one) that the UI maps to a localized message;
/// [message] is a friendly English fallback.
class AuthFailure implements Exception {
  final String code;
  final String message;
  const AuthFailure(this.code, this.message);

  @override
  String toString() => message;
}

/// Thrown when the user dismisses the Google account picker. Not an error.
class GoogleSignInCanceled implements Exception {
  const GoogleSignInCanceled();
}

/// Thrown when the user dismisses the Apple sign-in sheet. Not an error.
class AppleSignInCanceled implements Exception {
  const AppleSignInCanceled();
}

/// Sign-in provider ids as reported by Firebase (`UserInfo.providerId`).
class AuthProviderIds {
  AuthProviderIds._();
  static const password = 'password';
  static const google = 'google.com';
  static const apple = 'apple.com';
}

class FirebaseService {
  // Resolved lazily: `FirebaseAuth.instance` throws `[core/no-app]` when
  // Firebase failed to initialise, which must not crash DI.
  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  g_sign_in.GoogleSignIn get _googleSignIn => g_sign_in.GoogleSignIn.instance;

  static const _unavailable = AuthFailure(
    'auth-unavailable',
    'Sign-in is unavailable right now. Check your connection and restart the app.',
  );

  /// Whether Firebase initialised. When false every auth call fails with
  /// code `auth-unavailable` and [currentUser] is null.
  bool get isAvailable => AppInitStatus.firebaseReady;

  void _ensureAvailable() {
    if (!isAvailable) throw _unavailable;
  }

  // ── Getters ──────────────────────────────────────────────────────────────
  User? get currentUser {
    if (!isAvailable) return null;
    try {
      return _auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  /// Emits on sign-in, sign-out, token refresh and profile changes (e.g.
  /// email verified). Emits null when the session ends — including when
  /// Firebase revokes it because the account was disabled or deleted.
  Stream<User?> userChanges() {
    if (!isAvailable) return const Stream.empty();
    try {
      return _auth.userChanges();
    } catch (_) {
      return const Stream.empty();
    }
  }

  /// Emits on sign-in/out and ID-token refresh.
  Stream<User?> idTokenChanges() {
    if (!isAvailable) return const Stream.empty();
    try {
      return _auth.idTokenChanges();
    } catch (_) {
      return const Stream.empty();
    }
  }

  /// The Firebase ID token for Supabase third-party auth (null when signed
  /// out or Firebase is unavailable).
  Future<String?> idToken() async {
    final user = currentUser;
    if (user == null) return null;
    try {
      return await user.getIdToken();
    } catch (e) {
      debugPrint('getIdToken failed: $e');
      return null;
    }
  }

  /// Main sign-in provider of [user]: 'password', 'google.com', 'apple.com'.
  static String? primaryProviderOf(User? user) {
    if (user == null) return null;
    final ids = user.providerData.map((p) => p.providerId).toList();
    for (final id in [
      AuthProviderIds.apple,
      AuthProviderIds.google,
      AuthProviderIds.password,
    ]) {
      if (ids.contains(id)) return id;
    }
    return ids.isEmpty ? null : ids.first;
  }

  // ── Google Sign In ────────────────────────────────────────────────────────
  Future<User> signInWithGoogle() async {
    _ensureAvailable();
    try {
      final credential = await _googleCredential();
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) {
        throw const AuthFailure(
          'google-sign-in-failed',
          'Google Sign-In failed. Please try again.',
        );
      }
      return user;
    } on FirebaseAuthException catch (e) {
      throw mapAuthException(e);
    }
  }

  Future<AuthCredential> _googleCredential() async {
    try {
      // google_sign_in v7: authenticate() throws GoogleSignInException
      // (code: canceled) when the user dismisses the picker.
      final g_sign_in.GoogleSignInAccount googleUser =
          await _googleSignIn.authenticate();
      final String? idToken = googleUser.authentication.idToken;
      if (idToken == null) {
        throw const AuthFailure(
          'google-sign-in-failed',
          'Google Sign-In failed. Please try again.',
        );
      }
      return GoogleAuthProvider.credential(idToken: idToken);
    } on g_sign_in.GoogleSignInException catch (e) {
      if (e.code == g_sign_in.GoogleSignInExceptionCode.canceled ||
          e.code == g_sign_in.GoogleSignInExceptionCode.interrupted) {
        throw const GoogleSignInCanceled();
      }
      throw const AuthFailure(
        'google-sign-in-failed',
        'Google Sign-In failed. Please try again.',
      );
    } on AuthFailure {
      rethrow;
    } catch (_) {
      throw const AuthFailure(
        'google-sign-in-failed',
        'Google Sign-In failed. Please try again.',
      );
    }
  }

  // ── Apple Sign In ─────────────────────────────────────────────────────────
  static bool get _isApplePlatform =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);

  /// True on iOS 13+/macOS 10.15+ when Firebase is available. Show the
  /// "Sign in with Apple" button only when this is true.
  Future<bool> isAppleSignInAvailable() async {
    if (!_isApplePlatform || !isAvailable) return false;
    try {
      return await SignInWithApple.isAvailable();
    } catch (_) {
      return false;
    }
  }

  /// Signs in with Apple. Throws [AppleSignInCanceled] when the user closes
  /// the sheet. On the first sign-in Apple provides the name once; it is
  /// stored as the Firebase display name.
  Future<User> signInWithApple() async {
    _ensureAvailable();
    final apple = await _appleCredential();
    try {
      final result = await _auth.signInWithCredential(apple.credential);
      final user = result.user;
      if (user == null) {
        throw const AuthFailure(
          'apple-sign-in-failed',
          'Sign in with Apple failed. Please try again.',
        );
      }
      final name = apple.fullName;
      if (name != null && (user.displayName ?? '').trim().isEmpty) {
        try {
          await user.updateDisplayName(name);
          await user.reload();
        } catch (_) {}
        return _auth.currentUser ?? user;
      }
      return user;
    } on FirebaseAuthException catch (e) {
      throw mapAuthException(e);
    }
  }

  Future<({OAuthCredential credential, String? fullName})>
  _appleCredential() async {
    final rawNonce = generateNonce();
    try {
      final apple = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: sha256OfString(rawNonce),
      );
      final idToken = apple.identityToken;
      if (idToken == null) {
        throw const AuthFailure(
          'apple-sign-in-failed',
          'Sign in with Apple failed. Please try again.',
        );
      }
      final credential = OAuthProvider('apple.com').credential(
        idToken: idToken,
        rawNonce: rawNonce,
        accessToken: apple.authorizationCode,
      );
      final parts = [
        apple.givenName,
        apple.familyName,
      ].whereType<String>().map((s) => s.trim()).where((s) => s.isNotEmpty);
      return (
        credential: credential,
        fullName: parts.isEmpty ? null : parts.join(' '),
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw const AppleSignInCanceled();
      }
      throw const AuthFailure(
        'apple-sign-in-failed',
        'Sign in with Apple failed. Please try again.',
      );
    } on AuthFailure {
      rethrow;
    } catch (_) {
      throw const AuthFailure(
        'apple-sign-in-failed',
        'Sign in with Apple failed. Please try again.',
      );
    }
  }

  /// Cryptographically secure random nonce.
  static String generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  static String sha256OfString(String input) =>
      sha256.convert(utf8.encode(input)).toString();

  // ── Email / Password ──────────────────────────────────────────────────────
  Future<User> signIn({required String email, required String password}) async {
    _ensureAvailable();
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return cred.user!;
    } on FirebaseAuthException catch (e) {
      throw mapAuthException(e);
    }
  }

  /// Creates the account and sends a verification email (best-effort; the
  /// app is usable before verifying).
  Future<User> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    _ensureAvailable();
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await cred.user!.updateDisplayName(name.trim());
      try {
        await cred.user!.sendEmailVerification();
      } catch (e) {
        debugPrint('sendEmailVerification failed: $e');
      }
      await cred.user!.reload();
      return _auth.currentUser!;
    } on FirebaseAuthException catch (e) {
      throw mapAuthException(e);
    }
  }

  // ── Email verification ────────────────────────────────────────────────────
  bool get isEmailVerified => currentUser?.emailVerified ?? false;

  Future<void> sendEmailVerification() async {
    final user = currentUser;
    if (user == null) throw _unavailable;
    try {
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw mapAuthException(e);
    }
  }

  /// Reloads the user (e.g. to pick up `emailVerified`). Returns the fresh
  /// user or null.
  Future<User?> reloadUser() async {
    final user = currentUser;
    if (user == null) return null;
    try {
      await user.reload();
    } catch (_) {}
    return currentUser;
  }

  // ── Profile (Firebase Auth) ───────────────────────────────────────────────
  Future<void> updateDisplayName(String name) async {
    final user = currentUser;
    if (user == null) return;
    try {
      await user.updateDisplayName(name);
    } on FirebaseAuthException catch (e) {
      throw mapAuthException(e);
    }
  }

  Future<void> updatePhotoURL(String url) async {
    final user = currentUser;
    if (user == null) return;
    try {
      await user.updatePhotoURL(url);
    } on FirebaseAuthException catch (e) {
      throw mapAuthException(e);
    }
  }

  /// Sends a verification link to [newEmail]. The account email only changes
  /// once the user clicks the link.
  Future<void> verifyBeforeUpdateEmail(String newEmail) async {
    final user = currentUser;
    if (user == null) {
      throw const AuthFailure(
        'requires-recent-login',
        'Please sign in again to change your email.',
      );
    }
    try {
      await user.verifyBeforeUpdateEmail(newEmail.trim());
    } on FirebaseAuthException catch (e) {
      throw mapAuthException(e);
    }
  }

  // ── Re-authentication & deletion ──────────────────────────────────────────
  /// Whether the last sign-in is recent enough for sensitive operations
  /// (Firebase requires roughly the last 5 minutes).
  bool get hasRecentLogin {
    final last = currentUser?.metadata.lastSignInTime;
    if (last == null) return false;
    return DateTime.now().difference(last) < const Duration(minutes: 4);
  }

  /// Re-authenticates the current user: with [password] for email accounts,
  /// otherwise by re-running the Google/Apple sign-in flow.
  /// Throws [GoogleSignInCanceled]/[AppleSignInCanceled] on cancel.
  Future<void> reauthenticate({String? password}) async {
    final user = currentUser;
    if (user == null) throw _unavailable;
    final provider = primaryProviderOf(user);
    try {
      final AuthCredential credential;
      if (provider == AuthProviderIds.password) {
        if (password == null || password.isEmpty || user.email == null) {
          throw const AuthFailure(
            'missing-password',
            'Please enter your password.',
          );
        }
        credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
      } else if (provider == AuthProviderIds.apple) {
        credential = (await _appleCredential()).credential;
      } else {
        credential = await _googleCredential();
      }
      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw mapAuthException(e);
    }
  }

  /// Deletes the Firebase Auth account. Throws [AuthFailure] with code
  /// `requires-recent-login` when the user must re-authenticate first.
  Future<void> deleteCurrentUser() async {
    final user = currentUser;
    if (user == null) throw _unavailable;
    try {
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw mapAuthException(e);
    }
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
  }

  // ── Sign Out ──────────────────────────────────────────────────────────────
  /// Always signs out of Firebase, even if the Google sign-out fails.
  Future<void> signOut() async {
    if (!isAvailable) return;
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // Ignore: the user may not have used Google, or the plugin failed.
    } finally {
      await _auth.signOut();
    }
  }

  // ── Password Reset ────────────────────────────────────────────────────────
  Future<void> sendPasswordResetEmail(String email) async {
    _ensureAvailable();
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw mapAuthException(e);
    }
  }

  // ── Firestore ─────────────────────────────────────────────────────────────
  /// Merges the given fields into `users/<uid>`. Null fields are not written.
  Future<void> saveUserProfile({
    required String uid,
    String? name,
    String? email,
    String? profilePicUrl,
    bool isNew = false,
  }) async {
    try {
      _ensureAvailable();
      await _firestore.collection('users').doc(uid).set({
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (profilePicUrl != null) 'profilePicUrl': profilePicUrl,
        if (isNew) 'createdAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw const AuthFailure(
        'profile-update-failed',
        'Failed to save your profile. Please try again.',
      );
    }
  }

  /// Returns the stored profile map, or `null` if no document exists.
  /// Throws if Firestore cannot be reached (so callers don't mistake an
  /// outage for "no profile" and overwrite data).
  Future<Map<String, dynamic>?> fetchUserProfileData(String uid) async {
    _ensureAvailable();
    final snap = await _firestore.collection('users').doc(uid).get();
    if (!snap.exists) return null;
    return snap.data();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  static AuthFailure mapAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return AuthFailure(e.code, 'No account found with this email.');
      case 'wrong-password':
      case 'invalid-credential':
      case 'INVALID_LOGIN_CREDENTIALS':
        return const AuthFailure(
          'invalid-credential',
          'Incorrect email or password.',
        );
      case 'email-already-in-use':
        return AuthFailure(
          e.code,
          'An account with this email already exists.',
        );
      case 'account-exists-with-different-credential':
        return AuthFailure(
          e.code,
          'An account already exists with this email using a different sign-in method.',
        );
      case 'weak-password':
        return AuthFailure(e.code, 'Password must be at least 6 characters.');
      case 'invalid-email':
        return AuthFailure(e.code, 'Please enter a valid email address.');
      case 'too-many-requests':
        return AuthFailure(e.code, 'Too many attempts. Try again later.');
      case 'network-request-failed':
        return AuthFailure(e.code, 'Network error. Check your connection.');
      case 'requires-recent-login':
        return AuthFailure(
          e.code,
          'For security, please sign out and sign in again before changing your email.',
        );
      case 'user-disabled':
        return AuthFailure(e.code, 'This account has been disabled.');
      case 'user-mismatch':
        return AuthFailure(
          e.code,
          'Please sign in with the same account you are deleting.',
        );
      default:
        return AuthFailure(
          e.code,
          e.message ?? 'An error occurred. Please try again.',
        );
    }
  }
}
