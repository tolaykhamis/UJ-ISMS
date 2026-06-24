import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'notification_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<UserModel?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final uid = credential.user!.uid;

      final newUser = UserModel(
        userId: uid,
        name: name.trim(),
        email: email.trim(),
        role: 'Student',
      );

      await _db.collection('users').doc(uid).set(newUser.toMap());

      await NotificationService().saveTokenForUser(uid);

      await _logActivity(uid, 'User signed up: $email');

      return newUser;
    } catch (e) {
      rethrow;
    }
  }

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

      final doc = await _db.collection('users').doc(uid).get();

      if (!doc.exists) return null;

      final user = UserModel.fromMap(doc.data()!, uid);

      await NotificationService().saveTokenForUser(uid);

      await _logActivity(uid, '${user.name} logged in');

      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    if (currentUser != null) {
      await _logActivity(currentUser!.uid, 'User logged out');
    }
    await _auth.signOut();
  }

  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!, uid);
  }

  Future<void> _logActivity(String userId, String action) async {
    await _db.collection('activity_logs').add({
      'action': action,
      'userId': userId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}
