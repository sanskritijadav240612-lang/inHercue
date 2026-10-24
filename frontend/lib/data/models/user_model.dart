/// Represents a user profile in inHercue.
/// Directly mirrors the backend user schema (backend/src/models/user.model.js).
class UserModel {
  final String userId;
  final String email;
  final String name;
  final int? age;
  final bool onboardingCompleted;
  final DateTime? createdAt;

  const UserModel({
    required this.userId,
    required this.email,
    required this.name,
    this.age,
    this.onboardingCompleted = false,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    if (json['createdAt'] != null) {
      parsedDate = DateTime.tryParse(json['createdAt'].toString());
    }

    return UserModel(
      userId: json['userId'] as String? ?? json['_id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      age: json['age'] != null ? int.tryParse(json['age'].toString()) : null,
      onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'name': name,
      if (age != null) 'age': age,
      'onboardingCompleted': onboardingCompleted,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }

  @override
  String toString() => 'UserModel(userId: $userId, email: $email, name: $name)';
}
