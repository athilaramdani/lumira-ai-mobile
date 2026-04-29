import '../../data/models/chat_message_model.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String senderRole;
  final String message;
  final DateTime sentAt;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderRole,
    required this.message,
    required this.sentAt,
  });

  factory ChatMessage.fromModel(ChatMessageModel model) {
    return ChatMessage(
      id: model.id,
      senderId: model.senderId,
      senderRole: model.senderRole,
      message: model.message,
      sentAt: model.sentAt,
    );
  }

  ChatMessageModel toModel() {
    return ChatMessageModel(
      id: id,
      senderId: senderId,
      senderRole: senderRole,
      message: message,
      sentAt: sentAt,
    );
  }
}
