import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lumira_ai_mobile/features/ai_chatbot/data/models/consultation_model.dart';
import 'package:lumira_ai_mobile/features/ai_chatbot/presentation/pages/medgemma_chat_page.dart';
import 'package:lumira_ai_mobile/features/ai_chatbot/data/datasources/consultation_service.dart';

class MedgemmaChatSession {
  final String id;
  final String title;
  final String snippet;
  final List<MedgemmaMessage> messages;
  final List<ChatHistoryEntry> apiHistory;
  final DateTime lastUpdated;
  final bool isTyping;
  final String? error;

  /// Teks AI yang sedang distream secara real-time (sebelum selesai/committed).
  /// Null berarti tidak sedang streaming.
  final String? streamingText;

  MedgemmaChatSession({
    required this.id,
    required this.title,
    required this.snippet,
    required this.messages,
    required this.apiHistory,
    required this.lastUpdated,
    this.isTyping = false,
    this.error,
    this.streamingText,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'snippet': snippet,
        'messages': messages.map((e) => e.toJson()).toList(),
        'apiHistory': apiHistory.map((e) => e.toJson()).toList(),
        'lastUpdated': lastUpdated.toIso8601String(),
      };

  factory MedgemmaChatSession.fromJson(Map<String, dynamic> json) =>
      MedgemmaChatSession(
        id: json['id'] as String,
        title: json['title'] as String,
        snippet: json['snippet'] as String,
        messages: (json['messages'] as List<dynamic>)
            .map((e) => MedgemmaMessage.fromJson(e as Map<String, dynamic>))
            .toList(),
        apiHistory: (json['apiHistory'] as List<dynamic>)
            .map((e) => ChatHistoryEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
        lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      );

  MedgemmaChatSession copyWith({
    String? id,
    String? title,
    String? snippet,
    List<MedgemmaMessage>? messages,
    List<ChatHistoryEntry>? apiHistory,
    DateTime? lastUpdated,
    bool? isTyping,
    String? error,
    String? streamingText,
    bool clearStreamingText = false,
  }) {
    return MedgemmaChatSession(
      id: id ?? this.id,
      title: title ?? this.title,
      snippet: snippet ?? this.snippet,
      messages: messages ?? this.messages,
      apiHistory: apiHistory ?? this.apiHistory,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isTyping: isTyping ?? this.isTyping,
      error: error, // overwrite error completely
      streamingText: clearStreamingText ? null : (streamingText ?? this.streamingText),
    );
  }
}

class MedgemmaHistoryNotifier extends StateNotifier<List<MedgemmaChatSession>> {
  static const _prefKey = 'medgemma_history_sessions';

  MedgemmaHistoryNotifier() : super([]) {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? prefs.getString('user_email') ?? 'unknown';
      final userKey = '${_prefKey}_$userId';

      String? historyStr = prefs.getString(userKey);

      // Clean up legacy global key if it exists to prevent future leaks
      final legacyStr = prefs.getString(_prefKey);
      if (legacyStr != null) {
        await prefs.remove(_prefKey);
      }

      if (historyStr != null && historyStr.isNotEmpty) {
        final List<dynamic> decodedList = json.decode(historyStr);
        state = decodedList
            .map((e) => MedgemmaChatSession.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      print('Error loading Medgemma history: $e');
    }
  }

  Future<void> _saveHistory(List<MedgemmaChatSession> sessions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? prefs.getString('user_email') ?? 'unknown';
      final userKey = '${_prefKey}_$userId';

      final encodedStr = json.encode(sessions.map((e) => e.toJson()).toList());
      await prefs.setString(userKey, encodedStr);
    } catch (e) {
      print('Error saving Medgemma history: $e');
    }
  }

  void addOrUpdateSession(MedgemmaChatSession session) {
    final index = state.indexWhere((s) => s.id == session.id);
    List<MedgemmaChatSession> updated;
    if (index >= 0) {
      updated = List<MedgemmaChatSession>.from(state);
      updated[index] = session;
    } else {
      updated = [session, ...state];
    }
    state = updated;
    _saveHistory(updated);
  }

  /// Update session di-state tanpa menyimpan ke SharedPreferences.
  /// Digunakan untuk update streaming yang sangat frequent agar performa tetap baik.
  void _updateSessionInMemory(MedgemmaChatSession session) {
    final index = state.indexWhere((s) => s.id == session.id);
    if (index < 0) return;
    final updated = List<MedgemmaChatSession>.from(state);
    updated[index] = session;
    state = updated;
  }

  MedgemmaChatSession? getSession(String id) {
    try {
      return state.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  // Handle sending message via SSE Streaming
  final ConsultationService _consultationService = ConsultationService();

  Future<void> sendMessage({
    required String sessionId,
    required MedgemmaMessage userMsg,
    required String enrichedPrompt,
    required String? imageUrl,
  }) async {
    // Get or create session
    MedgemmaChatSession session = getSession(sessionId) ??
        MedgemmaChatSession(
          id: sessionId,
          title: userMsg.text,
          snippet: userMsg.text,
          messages: [],
          apiHistory: [],
          lastUpdated: DateTime.now(),
        );

    // Add user message, set typing, clear previous streaming text
    final newMessages = List<MedgemmaMessage>.from(session.messages)..add(userMsg);
    final updatedSession = session.copyWith(
      messages: newMessages,
      title: session.title.isEmpty ? userMsg.text : session.title,
      snippet: userMsg.text,
      lastUpdated: DateTime.now(),
      isTyping: true,
      error: null,
      clearStreamingText: true,
    );
    addOrUpdateSession(updatedSession);

    // Snapshot history for API
    final historySnapshot = List<ChatHistoryEntry>.from(session.apiHistory);

    // Buffer untuk menampung token yang masuk
    final StringBuffer tokenBuffer = StringBuffer();

    try {
      final stream = _consultationService.streamConsultation(
        user: 'Patient',
        userPrompt: enrichedPrompt,
        chatHistory: historySnapshot,
        imageUrl: imageUrl,
      );

      await for (final token in stream) {
        tokenBuffer.write(token);

        // Update streamingText di-state secara real-time (tanpa save ke disk)
        final currentSession = getSession(sessionId);
        if (currentSession != null) {
          _updateSessionInMemory(currentSession.copyWith(
            streamingText: tokenBuffer.toString(),
            isTyping: true,
          ));
        }
      }

      // Stream selesai – commit teks final ke messages
      final rawAiText = tokenBuffer.toString();
      final cleanedAiText = _consultationService.cleanAiText(rawAiText);
      final finalAiText = cleanedAiText.isEmpty
          ? 'Mohon maaf, pemrosesan jawaban terpotong karena batas sistem. Silakan ajukan pertanyaan yang lebih singkat atau buat sesi obrolan baru.'
          : cleanedAiText;

      final latestSession = getSession(sessionId);
      if (latestSession != null) {
        final finalMessages = List<MedgemmaMessage>.from(latestSession.messages)
          ..add(MedgemmaMessage(
            text: finalAiText,
            isUser: false,
            time: _getCurrentTime(),
          ));
        final finalApiHistory =
            List<ChatHistoryEntry>.from(latestSession.apiHistory)
              ..add(ChatHistoryEntry(role: 'user', content: userMsg.text))
              ..add(ChatHistoryEntry(role: 'assistant', content: finalAiText));

        addOrUpdateSession(latestSession.copyWith(
          messages: finalMessages,
          apiHistory: finalApiHistory,
          snippet: finalAiText,
          lastUpdated: DateTime.now(),
          isTyping: false,
          clearStreamingText: true,
        ));
      }
    } catch (e) {
      // Failed – tampilkan error sebagai pesan AI
      final latestSession = getSession(sessionId);
      if (latestSession != null) {
        // Jika sudah ada teks yang ter-stream sebagian, commit dulu lalu tambahkan error notice
        String errorText = 'Maaf, terjadi kesalahan: $e';
        final partialText = tokenBuffer.toString().trim();
        if (partialText.isNotEmpty) {
          // Ada respons parsial – commit dulu, lalu tambah pesan error terpisah
          final cleanedPartial = _consultationService.cleanAiText(partialText);
          final partialMsg = MedgemmaMessage(
            text: '⚠️ *Respons terpotong:*\n\n$cleanedPartial',
            isUser: false,
            time: _getCurrentTime(),
          );
          final errorMsg = MedgemmaMessage(
            text: errorText,
            isUser: false,
            time: _getCurrentTime(),
          );
          final finalMessages = List<MedgemmaMessage>.from(latestSession.messages)
            ..add(partialMsg)
            ..add(errorMsg);
          final finalApiHistory =
              List<ChatHistoryEntry>.from(latestSession.apiHistory)
                ..add(ChatHistoryEntry(role: 'user', content: userMsg.text));

          addOrUpdateSession(latestSession.copyWith(
            messages: finalMessages,
            apiHistory: finalApiHistory,
            snippet: 'Kesalahan sistem',
            lastUpdated: DateTime.now(),
            isTyping: false,
            error: e.toString(),
            clearStreamingText: true,
          ));
        } else {
          final finalMessages =
              List<MedgemmaMessage>.from(latestSession.messages)
                ..add(MedgemmaMessage(
                  text: errorText,
                  isUser: false,
                  time: _getCurrentTime(),
                ));
          final finalApiHistory =
              List<ChatHistoryEntry>.from(latestSession.apiHistory)
                ..add(ChatHistoryEntry(role: 'user', content: userMsg.text));

          addOrUpdateSession(latestSession.copyWith(
            messages: finalMessages,
            apiHistory: finalApiHistory,
            snippet: 'Kesalahan sistem',
            lastUpdated: DateTime.now(),
            isTyping: false,
            error: e.toString(),
            clearStreamingText: true,
          ));
        }
      }
    }
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }
}

final medgemmaHistoryProvider =
    StateNotifierProvider<MedgemmaHistoryNotifier, List<MedgemmaChatSession>>(
        (ref) {
  return MedgemmaHistoryNotifier();
});
