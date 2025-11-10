import 'user_model.dart';

class MessageModel {
  final int id;
  final int roomId;
  final int userId;
  final UserModel? user;
  final String content;
  final String type;
  final DateTime? createdAt;

  MessageModel({
    required this.id,
    required this.roomId,
    required this.userId,
    this.user,
    required this.content,
    required this.type,
    this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? 0,
      roomId: json['room_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      content: json['content'] ?? '',
      type: json['type'] ?? 'text',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_id': roomId,
      'user_id': userId,
      'user': user?.toJson(),
      'content': content,
      'type': type,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
