import '../entities/chat_message.dart';

abstract class ChatRepository {
  /// Returns a real-time stream of messages for the given room.
  Stream<List<ChatMessage>> getMessages(String roomId);

  /// Sends a message to Firestore and triggers backend notify call.
  Future<void> sendMessage({
    required String roomId,
    required String senderId,
    required String senderRole,
    required String message,
  });

  /// Resolves (or creates) a chat room via the backend API.
  /// Returns the room ID (e.g. CHR-123456).
  Future<String> resolveRoom({
    required String patientId,
    required String doctorId,
    required String medicalRecordId,
  });

  /// Mints a Firebase custom token from the backend and signs in.
  Future<void> mintFirebaseToken();

  /// Gets the list of rooms for the authenticated actor.
  Future<List<dynamic>> getRooms();

  /// Streams the last message text for a given Firestore room.
  Stream<String?> getLastMessage(String roomId);
}
