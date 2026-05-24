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

  MedgemmaChatSession({
    required this.id,
    required this.title,
    required this.snippet,
    required this.messages,
    required this.apiHistory,
    required this.lastUpdated,
    this.isTyping = false,
    this.error,
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

  MedgemmaChatSession? getSession(String id) {
    try {
      return state.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  // Handle sending message in background
  final ConsultationService _consultationService = ConsultationService();

  Future<void> sendMessage({
    required String sessionId,
    required MedgemmaMessage userMsg,
    required String enrichedPrompt,
    required String? imageUrl,
  }) async {
    // Get or create session
    MedgemmaChatSession session = getSession(sessionId) ?? MedgemmaChatSession(
      id: sessionId,
      title: userMsg.text,
      snippet: userMsg.text,
      messages: [],
      apiHistory: [],
      lastUpdated: DateTime.now(),
    );

    // Add user message, set typing
    final newMessages = List<MedgemmaMessage>.from(session.messages)..add(userMsg);
    final updatedSession = session.copyWith(
      messages: newMessages,
      title: session.title.isEmpty ? userMsg.text : session.title,
      snippet: userMsg.text,
      lastUpdated: DateTime.now(),
      isTyping: true,
      error: null,
    );
    addOrUpdateSession(updatedSession);

    // Snapshot history for API
    final historySnapshot = List<ChatHistoryEntry>.from(session.apiHistory);

    try {
      final result = await _consultationService.sendConsultation(
        user: 'Patient',
        userPrompt: enrichedPrompt,
        chatHistory: historySnapshot,
        imageUrl: imageUrl,
      );

      // Successfully got response
      final latestSession = getSession(sessionId);
      if (latestSession != null) {
        final finalMessages = List<MedgemmaMessage>.from(latestSession.messages)..add(MedgemmaMessage(
          text: result.response,
          isUser: false,
          time: _getCurrentTime(),
        ));
        final finalApiHistory = List<ChatHistoryEntry>.from(latestSession.apiHistory)
          ..add(ChatHistoryEntry(role: 'user', content: userMsg.text))
          ..add(ChatHistoryEntry(role: 'assistant', content: result.response));

        addOrUpdateSession(latestSession.copyWith(
          messages: finalMessages,
          apiHistory: finalApiHistory,
          snippet: result.response,
          lastUpdated: DateTime.now(),
          isTyping: false,
        ));
      }
    } catch (e) {
      // Failed
      final latestSession = getSession(sessionId);
      if (latestSession != null) {
        final finalMessages = List<MedgemmaMessage>.from(latestSession.messages)..add(MedgemmaMessage(
          text: 'Maaf, terjadi kesalahan: $e',
          isUser: false,
          time: _getCurrentTime(),
        ));
        final finalApiHistory = List<ChatHistoryEntry>.from(latestSession.apiHistory)
          ..add(ChatHistoryEntry(role: 'user', content: userMsg.text));

        addOrUpdateSession(latestSession.copyWith(
          messages: finalMessages,
          apiHistory: finalApiHistory,
          snippet: 'Kesalahan sistem',
          lastUpdated: DateTime.now(),
          isTyping: false,
          error: e.toString(),
        ));
      }
    }
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }
}

final medgemmaHistoryProvider = StateNotifierProvider<MedgemmaHistoryNotifier, List<MedgemmaChatSession>>((ref) {
  return MedgemmaHistoryNotifier();
});
