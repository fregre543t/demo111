class User {
  const User({
    required this.id,
    required this.username,
    required this.role,
    required this.disabled,
    required this.createdAt,
  });

  final String id;
  final String username;
  final String role;
  final bool disabled;
  final DateTime createdAt;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      role: json['role'] as String? ?? 'user',
      disabled: json['disabled'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'role': role,
    'disabled': disabled,
    'createdAt': createdAt.toIso8601String(),
  };
}
