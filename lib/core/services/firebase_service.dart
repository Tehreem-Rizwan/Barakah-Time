import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
        'profilePicUrl': profilePicUrl,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save user profile to Firebase: $e');
    }
  }

  Future<DocumentSnapshot> getUserProfile(String uid) async {
    try {
      return await _firestore.collection('users').doc(uid).get();
    } catch (e) {
      throw Exception('Failed to get user profile from Firebase: $e');
    }
  }

  // Example for other data (e.g. Prayer Settings, Spiritual Pulse)
  Future<void> saveUserActivity(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('activities')
          .add({...data, 'timestamp': FieldValue.serverTimestamp()});
    } catch (e) {
      throw Exception('Failed to save activity to Firebase: $e');
    }
  }
}
