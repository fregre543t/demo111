class User {
  User({
    required this.id,
    required this.username,
    required this.role,
    required this.createdAt,
  });

  final String id;
  final String username;
  final String role;
  final DateTime createdAt;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      role: json['role'] as String,
      createdAt: DateTime.parse(json['created_at'] as String? ??
          json['createdAt'] as String? ??
          DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'role': role,
        'created_at': createdAt.toIso8601String(),
      };
}
