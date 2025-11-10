class UserModel {
  final String id;
  final String username;
  final String email;
  final String avatar;
  final bool isOnline;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.avatar,
    required this.isOnline,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    DateTime createdAt;
    try {
      if (json['created_at'] is String) {
        createdAt = DateTime.parse(json['created_at']);
      } else {
        createdAt = DateTime.now();
      }
    } catch (e) {
      createdAt = DateTime.now();
    }
    
    return UserModel(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'] ?? '',
      isOnline: json['is_online'] ?? false,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatar': avatar,
      'is_online': isOnline,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
