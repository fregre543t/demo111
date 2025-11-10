class MessageModel {
  final String id;
  final String userId;
  final String username;
  final String content;
  final String type;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.content,
    required this.type,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
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
    
    return MessageModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      username: json['username'] ?? '',
      content: json['content'] ?? '',
      type: json['type'] ?? 'text',
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'username': username,
      'content': content,
      'type': type,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
