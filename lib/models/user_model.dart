// Dados do usuário logado

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? avatarPath;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarPath,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'avatar_path': avatarPath,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      avatarPath: map['avatar_path'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }
}
