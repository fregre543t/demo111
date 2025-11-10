class UserModel {
  final int id;
  final String username;
  final String email;
  final String? nickname;
  final String? avatar;
  final bool isAdmin;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.nickname,
    this.avatar,
    required this.isAdmin,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['user_id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      nickname: json['nickname'],
      avatar: json['avatar'],
      isAdmin: json['is_admin'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'nickname': nickname,
      'avatar': avatar,
      'is_admin': isAdmin,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
