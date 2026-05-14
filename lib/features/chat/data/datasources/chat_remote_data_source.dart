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
  CollectionReference get _rooms => _firestore.collection('rooms');

  CollectionReference _messages(String roomId) =>
      _rooms.doc(roomId).collection('messages');

  // ─── Stream messages ──────────────────────────────────────────────────
  @override
  Stream<List<ChatMessageModel>> getMessages(String roomId) {
    return _messages(roomId)
        .orderBy('created_at', descending: false)
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
    // 1. Get room data to satisfy security rules (need patient_id, doctor_id)
    final roomDoc = await _rooms.doc(roomId).get();
    final roomData = roomDoc.data() as Map<String, dynamic>?;
    if (roomData == null) {
      throw Exception('Room metadata not found for $roomId');
    }

    final patientId = roomData['patient_id'] as String;
    final doctorId = roomData['doctor_id'] as String;

    final docRef = _messages(roomId).doc();

    final expectedSenderType = senderId == patientId ? 'patient' : (senderId == doctorId ? 'doctor' : '');
    final receiverId = senderId == patientId ? doctorId : patientId;

    // 2. Build exact payload required by rules
    final payload = {
      'message_id': docRef.id,
      'room_id': roomId,
      'patient_id': patientId,
      'doctor_id': doctorId,
      'sender_type': expectedSenderType,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'message': message,
      'is_read': false,
      'created_at': FieldValue.serverTimestamp(),
    };

    // 3. Save message
    await docRef.set(payload);

    // Note: We DO NOT update _rooms.doc(roomId) here because security rules forbid client writes to room metadata!

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
