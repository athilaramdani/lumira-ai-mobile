/// Model untuk satu entry riwayat chat yang dikirim ke API
class ChatHistoryEntry {
  final String role; // 'user' atau 'assistant'
  final String content;

  const ChatHistoryEntry({required this.role, required this.content});

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
      };

  factory ChatHistoryEntry.fromJson(Map<String, dynamic> json) =>
      ChatHistoryEntry(
        role: json['role'] as String,
        content: json['content'] as String,
      );
}

/// Request body untuk POST /consultations
class ConsultationRequest {
  final String user;
  final String userPrompt;
  final List<ChatHistoryEntry> chatHistory;
  final String? image; // URL gambar opsional (mis. X-ray / scan)

  const ConsultationRequest({
    required this.user,
    required this.userPrompt,
    required this.chatHistory,
    this.image,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> body = {
      'user': user,
      'user_prompt': userPrompt,
      'chat_history': chatHistory.map((e) => e.toJson()).toList(),
    };
    if (image != null && image!.isNotEmpty) {
      body['image'] = image;
    }
    return body;
  }
}

/// Response dari POST /consultations
class ConsultationResponse {
  final String response;
  final String? sessionId;
  final Map<String, dynamic>? raw;

  const ConsultationResponse({
    required this.response,
    this.sessionId,
    this.raw,
  });

  factory ConsultationResponse.fromJson(Map<String, dynamic> json) {
    // Struktur API: { status, message, data: { consultation_result, profiling } }
    // Prioritas: data.consultation_result -> top-level response/answer/text
    // 'message' sengaja TIDAK digunakan karena isinya status string (bukan AI reply)
    String text = '';

    // 1. Baca dari nested data.consultation_result (struktur utama API)
    final data = json['data'];
    if (data is Map<String, dynamic>) {
      text = (data['consultation_result'] as String? ?? '').trim();
    }

    // 2. Fallback ke field top-level lainnya (jika struktur berubah)
    if (text.isEmpty) {
      text = json['response'] as String? ??
          json['answer'] as String? ??
          json['text'] as String? ??
          json['result'] as String? ??
          '';
    }

    return ConsultationResponse(
      response: text,
      sessionId: json['session_id'] as String?,
      raw: json,
    );
  }
}
