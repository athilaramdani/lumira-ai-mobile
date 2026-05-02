import '../entities/chat_message.dart';
import '../repositories/chat_repository.dart';

/// Provides a real-time stream of chat messages for a given room.
class GetMessagesUseCase {
  final ChatRepository repository;
  GetMessagesUseCase(this.repository);

  Stream<List<ChatMessage>> call(String roomId) {
    return repository.getMessages(roomId);
  }
}

/// Sends a message to a chat room.
class SendMessageUseCase {
  final ChatRepository repository;
  SendMessageUseCase(this.repository);

  Future<void> call({
    required String roomId,
    required String senderId,
    required String senderRole,
    required String message,
  }) {
    return repository.sendMessage(
      roomId: roomId,
      senderId: senderId,
      senderRole: senderRole,
      message: message,
    );
  }
}

/// Resolves (or creates) a chat room via the backend API.
class ResolveRoomUseCase {
  final ChatRepository repository;
  ResolveRoomUseCase(this.repository);

  Future<String> call({
    required String patientId,
    required String doctorId,
    required String medicalRecordId,
  }) {
    return repository.resolveRoom(
      patientId: patientId,
      doctorId: doctorId,
      medicalRecordId: medicalRecordId,
    );
  }
}

/// Mints a Firebase custom token and signs in to Firebase Auth.
class MintFirebaseTokenUseCase {
  final ChatRepository repository;
  MintFirebaseTokenUseCase(this.repository);

  Future<void> call() => repository.mintFirebaseToken();
}

/// Gets the list of chat rooms for the authenticated actor.
class GetRoomsUseCase {
  final ChatRepository repository;
  GetRoomsUseCase(this.repository);

  Future<List<dynamic>> call() => repository.getRooms();
}
