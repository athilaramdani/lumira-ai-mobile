import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
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

  /// Mint a custom Firebase token and sign in to Firebase Auth.
  Future<void> mintFirebaseToken();

  /// Resolve or create a chat room via the backend API.
  Future<String> resolveRoom({
    required String patientId,
    required String doctorId,
    required String medicalRecordId,
  });

  /// Get the list of chat rooms from the backend.
  Future<List<dynamic>> getRooms();
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;
  final Dio _dio;

  ChatRemoteDataSourceImpl({FirebaseFirestore? firestore, FirebaseAuth? firebaseAuth, Dio? dio})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _dio = dio ?? ApiClient().dio;

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

    final docRef = await _messages(roomId).add(model.toFirestore());

    // Update room's last_message metadata for chat list preview, using set with merge so it creates the doc if not exists
    await _rooms.doc(roomId).set({
      'last_message': message,
      'last_message_at': Timestamp.fromDate(model.sentAt),
      'last_sender_role': senderRole,
    }, SetOptions(merge: true));

    // Notify backend
    try {
      await _dio.post('/chat/rooms/$roomId/notify', data: {
        'messageId': docRef.id,
      });
    } catch (e) {
      print('Failed to send FCM notify: $e');
    }
  }

  @override
  Future<void> mintFirebaseToken() async {
    try {
      final response = await _dio.post('/chat/firebase-token');
      final customToken = response.data['customToken'];
      if (customToken != null) {
        await _firebaseAuth.signInWithCustomToken(customToken);
        print('Successfully minted and signed in with custom token');
      }
    } catch (e) {
      print('Error minting firebase token: $e');
      throw Exception('Gagal mendapatkan akses chat realtime');
    }
  }

  @override
  Future<List<dynamic>> getRooms() async {
    try {
      final response = await _dio.get('/chat/rooms');
      return response.data as List<dynamic>;
    } catch (e) {
      print('Error getting rooms: $e');
      throw Exception('Gagal mendapatkan daftar chat');
    }
  }

  // ─── Resolve / create room ────────────────────────────────────────────
  @override
  Future<String> resolveRoom({
    required String patientId,
    required String doctorId,
    required String medicalRecordId,
  }) async {
    try {
      final response = await _dio.post('/chat/rooms', data: {
        'patientId': patientId,
        'doctorId': doctorId,
        'medicalRecordId': medicalRecordId,
      });
      return response.data['id'];
    } catch (e) {
      print('Error resolving room: $e');
      // Fallback for development if API fails, generate one locally
      return 'room_$patientId';
    }
  }
}
