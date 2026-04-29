import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ChatMessage>> getChatHistory(String patientId) async {
    final models = await remoteDataSource.getChatHistory(patientId);
    return models.map((model) => ChatMessage.fromModel(model)).toList();
  }

  @override
  Future<ChatMessage> sendMessage(String patientId, String message) async {
    final model = await remoteDataSource.sendMessage(patientId, message);
    return ChatMessage.fromModel(model);
  }
}
