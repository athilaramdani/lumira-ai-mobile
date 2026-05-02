import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message_model.dart';

abstract class ChatRemoteDataSource {
  /// Real-time stream of messages from Firestore for a given room.
  Stream<List<ChatMessageModel>> getMessages(String roomId);

  /// Write a new message document to Firestore.
  Future<void> sendMessage({
    required String roomId,
    required String senderId,
    required String senderRole,
    required String message,
  });

  /// Resolve or create a chat room. Returns the Firestore room document ID.
  Future<String> resolveRoom({
    required String patientId,
    required String doctorId,
  });
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final FirebaseFirestore _firestore;

  ChatRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ─── Firestore collection paths ───────────────────────────────────────
  CollectionReference get _rooms => _firestore.collection('chat_rooms');

  CollectionReference _messages(String roomId) =>
      _rooms.doc(roomId).collection('messages');

  // ─── Stream messages ──────────────────────────────────────────────────
  @override
  Stream<List<ChatMessageModel>> getMessages(String roomId) {
    return _messages(roomId)
        .orderBy('sent_at', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessageModel.fromFirestore(doc))
            .toList());
  }

  // ─── Send message ─────────────────────────────────────────────────────
  @override
  Future<void> sendMessage({
    required String roomId,
    required String senderId,
    required String senderRole,
    required String message,
  }) async {
    final model = ChatMessageModel(
      id: '', // Firestore will auto-generate ID
      senderId: senderId,
      senderRole: senderRole,
      message: message,
      sentAt: DateTime.now(),
    );

    await _messages(roomId).add(model.toFirestore());

    // Update room's last_message metadata for chat list preview
    await _rooms.doc(roomId).update({
      'last_message': message,
      'last_message_at': Timestamp.fromDate(model.sentAt),
      'last_sender_role': senderRole,
    });
  }

  // ─── Resolve / create room ────────────────────────────────────────────
  @override
  Future<String> resolveRoom({
    required String patientId,
    required String doctorId,
  }) async {
    // Use a deterministic room ID so doctor & patient always share the same room
    final roomId = _buildRoomId(patientId, doctorId);

    final roomRef = _rooms.doc(roomId);
    final snapshot = await roomRef.get();

    if (!snapshot.exists) {
      // Create room document
      await roomRef.set({
        'patient_id': patientId,
        'doctor_id': doctorId,
        'participants': [patientId, doctorId],
        'created_at': FieldValue.serverTimestamp(),
        'last_message': '',
        'last_message_at': FieldValue.serverTimestamp(),
      });
    }

    return roomId;
  }

  /// Room ID = patientId only.
  /// This ensures both doctor (who knows patientId) and patient (who knows their own ID)
  /// always share the same Firestore room without needing each other's ID upfront.
  String _buildRoomId(String patientId, String doctorId) {
    return 'room_$patientId';
  }
}
