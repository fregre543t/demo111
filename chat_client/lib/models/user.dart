class User {
  final int id;
  final String username;
  final String nickname;
  final String avatar;
  final bool isOnline;
  final bool isAdmin;
  final DateTime? lastSeen;

  User({
    required this.id,
    required this.username,
    required this.nickname,
    required this.avatar,
    this.isOnline = false,
    this.isAdmin = false,
    this.lastSeen,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      nickname: json['nickname'] ?? '',
      avatar: json['avatar'] ?? '',
      isOnline: json['is_online'] ?? false,
      isAdmin: json['is_admin'] ?? false,
      lastSeen: json['last_seen'] != null 
          ? DateTime.parse(json['last_seen']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'nickname': nickname,
      'avatar': avatar,
      'is_online': isOnline,
      'is_admin': isAdmin,
      'last_seen': lastSeen?.toIso8601String(),
    };
  }

  User copyWith({
    int? id,
    String? username,
    String? nickname,
    String? avatar,
    bool? isOnline,
    bool? isAdmin,
    DateTime? lastSeen,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      nickname: nickname ?? this.nickname,
      avatar: avatar ?? this.avatar,
      isOnline: isOnline ?? this.isOnline,
      isAdmin: isAdmin ?? this.isAdmin,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}
