import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart' as g_sign_in;

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final g_sign_in.GoogleSignIn _googleSignIn = g_sign_in.GoogleSignIn.instance;
  // ── Getters ──────────────────────────────────────────────────────────────
  User? get currentUser => _auth.currentUser;

  // ── Google Sign In ────────────────────────────────────────────────────────
  Future<User> signInWithGoogle() async {
    try {
      // In version 7.0.0+, authenticate() is used instead of signIn()
      final g_sign_in.GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();
      if (googleUser == null) {
        throw Exception('Google Sign-In canceled');
      }

      // authentication is now a getter, not a Future
      final g_sign_in.GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // To get an accessToken in v7.0.0+, we use authorizationClient
      final authorization = await googleUser.authorizationClient.authorizeScopes([
        'email',
        'https://www.googleapis.com/auth/userinfo.profile',
      ]);

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: authorization.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      return userCredential.user!;
    } catch (e) {
      if (e is FirebaseAuthException) {
        throw _authException(e);
      }
      throw Exception('Failed to sign in with Google: $e');
    }
  }

  // ── Email / Password ──────────────────────────────────────────────────────
  Future<User> signIn({required String email, required String password}) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return cred.user!;
    } on FirebaseAuthException catch (e) {
      throw _authException(e);
    }
  }

  Future<User> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await cred.user!.updateDisplayName(name.trim());
      await cred.user!.reload();
      return _auth.currentUser!;
    } on FirebaseAuthException catch (e) {
      throw _authException(e);
    }
  }

  // ── Sign Out ──────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // ── Password Reset ────────────────────────────────────────────────────────
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _authException(e);
    }
  }

  // ── Firestore ─────────────────────────────────────────────────────────────
  Future<void> saveUserProfile({
    required String uid,
    required String name,
    required String email,
    String? profilePicUrl,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        if (profilePicUrl != null) 'profilePicUrl': profilePicUrl,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save user profile: $e');
    }
  }

  Future<DocumentSnapshot> getUserProfile(String uid) async {
    try {
      return await _firestore.collection('users').doc(uid).get();
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  Future<void> saveUserActivity(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('activities')
          .add({...data, 'timestamp': FieldValue.serverTimestamp()});
    } catch (e) {
      throw Exception('Failed to save activity: $e');
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  String _authException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return e.message ?? 'An error occurred. Please try again.';
    }
  }
}
