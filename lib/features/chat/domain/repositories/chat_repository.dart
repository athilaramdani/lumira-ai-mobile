import '../entities/chat_message.dart';

abstract class ChatRepository {
  /// Returns a real-time stream of messages for the given room.
  Stream<List<ChatMessage>> getMessages(String roomId);

  /// Sends a message to Firestore and optionally triggers a backend notify call.
  Future<void> sendMessage({
    required String roomId,
    required String senderId,
    required String senderRole,
    required String message,
  });

  /// Resolves (or creates) a chat room for a doctor-patient pair.
  /// Returns the Firestore room ID.
  Future<String> resolveRoom({
    required String patientId,
    required String doctorId,
  });
}
