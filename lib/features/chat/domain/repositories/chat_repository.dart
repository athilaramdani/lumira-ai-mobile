import '../entities/chat_message.dart';

abstract class ChatRepository {
  Future<List<ChatMessage>> getChatHistory(String patientId);
  Future<ChatMessage> sendMessage(String patientId, String message);
}
