import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final GoogleSignIn _googleSignIn;
  // ── Getters ──────────────────────────────────────────────────────────────
  User? get currentUser => _auth.currentUser;

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
