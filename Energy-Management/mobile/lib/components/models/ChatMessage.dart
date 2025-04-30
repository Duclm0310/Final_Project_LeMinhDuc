// class ChatMessage {
//   final String fromUID;
//   final String toUID;
//   final String message;
//   final DateTime sendTime;
//   final String messageType;
//
//   ChatMessage({
//     required this.fromUID,
//     required this.toUID,
//     required this.message,
//     required this.messageType,
//     required this.sendTime,
//   });
// }


class ChatMessage {
  final String id;
  final String senderId;
  final String? receiverId;
  final String? groupId;
  final String content;
  final DateTime timestamp;
  final bool isMe; // true nếu tin nhắn do mình gửi

  ChatMessage({
    required this.id,
    required this.senderId,
    this.receiverId,
    this.groupId,
    required this.content,
    required this.timestamp,
    this.isMe = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json, String myUserId) {
    return ChatMessage(
      id: json['_id'] ?? '',
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      groupId: json['group_id'],
      content: json['content'],
      timestamp: DateTime.parse(json['created_at']),
      isMe: json['sender_id'] == myUserId,
    );
  }
}
