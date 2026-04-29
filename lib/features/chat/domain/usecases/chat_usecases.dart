import '../entities/chat_message.dart';
import '../repositories/chat_repository.dart';

class GetChatHistoryUseCase {
  final ChatRepository repository;
  GetChatHistoryUseCase(this.repository);

  Future<List<ChatMessage>> call(String patientId) async {
    return await repository.getChatHistory(patientId);
  }
}

class SendMessageUseCase {
  final ChatRepository repository;
  SendMessageUseCase(this.repository);

  Future<ChatMessage> call(String patientId, String message) async {
    return await repository.sendMessage(patientId, message);
  }
}
