import 'user.dart';

class Message {
  final int? id;
  final int fromUserId;
  final int toUserId;
  final String content;
  final String messageType;
  final bool isRead;
  final DateTime createdAt;
  final User? fromUser;
  final User? toUser;

  Message({
    this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.content,
    this.messageType = 'text',
    this.isRead = false,
    required this.createdAt,
    this.fromUser,
    this.toUser,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      fromUserId: json['from_user_id'] ?? 0,
      toUserId: json['to_user_id'] ?? 0,
      content: json['content'] ?? '',
      messageType: json['message_type'] ?? 'text',
      isRead: json['is_read'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      fromUser: json['from_user'] != null
          ? User.fromJson(json['from_user'])
          : null,
      toUser: json['to_user'] != null
          ? User.fromJson(json['to_user'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'from_user_id': fromUserId,
      'to_user_id': toUserId,
      'content': content,
      'message_type': messageType,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class Conversation {
  final int userId;
  final String username;
  final String nickname;
  final String avatar;
  final String lastMessage;
  final DateTime lastTime;
  final int unreadCount;
  final bool isOnline;

  Conversation({
    required this.userId,
    required this.username,
    required this.nickname,
    required this.avatar,
    required this.lastMessage,
    required this.lastTime,
    this.unreadCount = 0,
    this.isOnline = false,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      userId: json['user_id'] ?? 0,
      username: json['username'] ?? '',
      nickname: json['nickname'] ?? '',
      avatar: json['avatar'] ?? '',
      lastMessage: json['last_message'] ?? '',
      lastTime: json['last_time'] != null
          ? DateTime.parse(json['last_time'])
          : DateTime.now(),
      unreadCount: json['unread_count'] ?? 0,
      isOnline: json['is_online'] ?? false,
    );
  }
}
