// models/user_model.dart
class UserModel {
  final String userId;
  final String name;
  final String email;
  final String role;
  final String? fcmToken;

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    this.fcmToken,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      userId: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'Student',
      fcmToken: map['fcmToken'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'role': role,
      if (fcmToken != null) 'fcmToken': fcmToken,
    };
  }
}