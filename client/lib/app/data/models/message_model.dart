class Message {
  Message({
    required this.id,
    required this.senderId,
    required this.content,
    required this.createdAt,
    this.receiverId,
    this.roomId,
  });

  final String id;
  final String senderId;
  final String content;
  final DateTime createdAt;
  final String? receiverId;
  final String? roomId;

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String? ?? json['message_id'] as String? ?? '',
      senderId: json['sender_id'] as String? ?? json['senderId'] as String? ?? '',
      content: json['content'] as String? ?? '',
      createdAt: DateTime.parse(
        json['created_at'] as String? ??
            json['createdAt'] as String? ??
            DateTime.now().toIso8601String(),
      ),
      receiverId: json['receiver_id'] as String? ?? json['receiverId'] as String?,
      roomId: json['room_id'] as String? ?? json['roomId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sender_id': senderId,
        'receiver_id': receiverId,
        'content': content,
        'created_at': createdAt.toIso8601String(),
        'room_id': roomId,
      };
}
