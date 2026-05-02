import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<ChatMessage>> getMessages(String roomId) {
    return remoteDataSource.getMessages(roomId).map(
          (models) =>
              models.map((model) => ChatMessage.fromModel(model)).toList(),
        );
  }

  @override
  Future<void> sendMessage({
    required String roomId,
    required String senderId,
    required String senderRole,
    required String message,
  }) {
    return remoteDataSource.sendMessage(
      roomId: roomId,
      senderId: senderId,
      senderRole: senderRole,
      message: message,
    );
  }

  @override
  Future<String> resolveRoom({
    required String patientId,
    required String doctorId,
    required String medicalRecordId,
  }) {
    return remoteDataSource.resolveRoom(
      patientId: patientId,
      doctorId: doctorId,
      medicalRecordId: medicalRecordId,
    );
  }

  @override
  Future<void> mintFirebaseToken() => remoteDataSource.mintFirebaseToken();

  @override
  Future<List<dynamic>> getRooms() => remoteDataSource.getRooms();
}
