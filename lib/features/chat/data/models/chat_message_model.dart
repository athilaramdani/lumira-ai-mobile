import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessageModel {
  final String id;
  final String senderId;
  final String senderRole;
  final String message;
  final DateTime sentAt;

  ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.senderRole,
    required this.message,
    required this.sentAt,
  });

  /// Parse from a Firestore DocumentSnapshot
  factory ChatMessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessageModel(
      id: doc.id,
      senderId: data['sender_id']?.toString() ?? '',
      senderRole: data['sender_type'] ?? data['sender_role'] ?? 'patient',
      message: data['message'] ?? '',
      sentAt: (data['created_at'] as Timestamp?)?.toDate() ?? (data['sent_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert to Firestore-compatible map
  Map<String, dynamic> toFirestore() {
    return {
      'sender_id': senderId,
      'sender_role': senderRole,
      'message': message,
      'sent_at': Timestamp.fromDate(sentAt),
    };
  }

  /// Fallback: parse from a plain JSON map (REST API compatibility)
  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id']?.toString() ?? '',
      senderId: json['sender_id']?.toString() ?? '',
      senderRole: json['sender_type'] ?? json['sender_role'] ?? 'patient',
      message: json['message'] ?? '',
      sentAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : (json['sent_at'] != null ? DateTime.parse(json['sent_at']) : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'sender_role': senderRole,
      'message': message,
      'sent_at': sentAt.toIso8601String(),
    };
  }
}
