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

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id']?.toString() ?? '',
      senderId: json['sender_id']?.toString() ?? '',
      senderRole: json['sender_role'] ?? 'patient',
      message: json['message'] ?? '',
      sentAt: json['sent_at'] != null ? DateTime.parse(json['sent_at']) : DateTime.now(),
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
