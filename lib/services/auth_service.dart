// services/auth_service.dart
// Handles all authentication with Firebase Auth
// Also creates/reads the user document in Firestore

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'notification_service.dart';

class AuthService {
  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get the currently signed-in Firebase user
  User? get currentUser => _auth.currentUser;

  // ─── SIGN UP ───────────────────────────────────────────────────────────────
  // Creates a Firebase Auth account and a Firestore user document
  Future<UserModel?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // 1. Create the Firebase Auth account
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final uid = credential.user!.uid;

      // 2. Save user profile in Firestore with default role "Student"
      final newUser = UserModel(
        userId: uid,
        name: name.trim(),
        email: email.trim(),
        role: 'Student', // default role — admin can change this later
      );

      await _db.collection('users').doc(uid).set(newUser.toMap());

      // 3. Save FCM token so this device can receive push notifications
      await NotificationService().saveTokenForUser(uid);

      // 4. Log the sign-up action
      await _logActivity(uid, 'User signed up: $email');

      return newUser;
    } catch (e) {
      // Rethrow so the UI can show the error message
      rethrow;
    }
  }

  // ─── SIGN IN ───────────────────────────────────────────────────────────────
  // Signs in with email/password and fetches the Firestore user profile
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final uid = credential.user!.uid;

      // Fetch the user document from Firestore
      final doc = await _db.collection('users').doc(uid).get();

      if (!doc.exists) return null;

      final user = UserModel.fromMap(doc.data()!, uid);

      // Save / refresh FCM token so push notifications reach this device
      await NotificationService().saveTokenForUser(uid);

      // Log the login action
      await _logActivity(uid, '${user.name} logged in');

      return user;
    } catch (e) {
      rethrow;
    }
  }

  // ─── SIGN OUT ──────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    if (currentUser != null) {
      await _logActivity(currentUser!.uid, 'User logged out');
    }
    await _auth.signOut();
  }

  // ─── GET USER PROFILE ──────────────────────────────────────────────────────
  // Fetch the Firestore user document for any UID
  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!, uid);
  }

  // ─── PRIVATE HELPER ────────────────────────────────────────────────────────
  // Writes a record to the activity_logs collection
  Future<void> _logActivity(String userId, String action) async {
    await _db.collection('activity_logs').add({
      'action': action,
      'userId': userId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}