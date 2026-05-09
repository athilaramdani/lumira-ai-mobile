import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
      
      String? customToken;
      if (response.data != null && response.data is Map && response.data['data'] != null && response.data['data']['customToken'] != null) {
        customToken = response.data['data']['customToken'];
      } else if (response.data != null && response.data is Map) {
        customToken = response.data['customToken'];
      }

      if (customToken != null) {
        await _firebaseAuth.signInWithCustomToken(customToken);
        print('Successfully minted and signed in with custom token');
        return;
      } else {
        print('Error: Custom token is null from response, falling back to anonymous');
      }
    } catch (e) {
      print('Error minting firebase token: $e. Falling back to anonymous auth.');
    }

    // Fallback to anonymous sign in if custom token API fails or is not available
    try {
      await _firebaseAuth.signInAnonymously();
      print('Successfully signed in anonymously as fallback');
    } catch (e) {
      print('Error signing in anonymously: $e');
      print('Warning: Ignoring Auth failure. Firestore might work unauthenticated (e.g., in Emulator).');
      return; // Never throw, allow chat to load
    }
  }

  @override
  Future<List<dynamic>> getRooms() async {
    try {
      final response = await _dio.get('/chat/rooms');
      if (response.data != null && response.data['data'] != null) {
        return response.data['data'] as List<dynamic>;
      }
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
      // Try to GET existing rooms first (crucial for patients who might not have POST permission)
      try {
        final getResponse = await _dio.get('/chat/rooms');
        if (getResponse.data != null && getResponse.data['data'] != null) {
          final List<dynamic> rooms = getResponse.data['data'];
          for (var room in rooms) {
            if (room['patientId'] == patientId && 
                room['doctorId'] == doctorId && 
                room['medicalRecordId'] == medicalRecordId) {
              return room['id']; // Found existing room!
            }
          }
        }
      } catch (e) {
        print('Error getting existing rooms during resolve: $e');
      }

      // If not found, try to CREATE it (usually doctors have this permission)
      try {
        final response = await _dio.post('/chat/rooms', data: {
          'patientId': patientId,
          'doctorId': doctorId,
          'medicalRecordId': medicalRecordId,
        });
        if (response.data != null && response.data['data'] != null && response.data['data']['id'] != null) {
          return response.data['data']['id'];
        }
        return response.data['id'];
      } catch (e) {
        print('Error resolving/creating room: $e');
        // Fallback for development if API fails. Must be deterministic for BOTH doctor and patient!
        return 'room_${patientId}_${doctorId}_${medicalRecordId}';
      }
  }
}
