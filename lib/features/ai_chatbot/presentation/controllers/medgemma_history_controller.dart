import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lumira_ai_mobile/features/ai_chatbot/data/models/consultation_model.dart';
import 'package:lumira_ai_mobile/features/ai_chatbot/presentation/pages/medgemma_chat_page.dart';

class MedgemmaChatSession {
  final String id;
  final String title;
  final String snippet;
  final List<MedgemmaMessage> messages;
  final List<ChatHistoryEntry> apiHistory;
  final DateTime lastUpdated;

  MedgemmaChatSession({
    required this.id,
    required this.title,
    required this.snippet,
    required this.messages,
    required this.apiHistory,
    required this.lastUpdated,
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
  }) {
    return MedgemmaChatSession(
      id: id ?? this.id,
      title: title ?? this.title,
      snippet: snippet ?? this.snippet,
      messages: messages ?? this.messages,
      apiHistory: apiHistory ?? this.apiHistory,
      lastUpdated: lastUpdated ?? this.lastUpdated,
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
      final historyStr = prefs.getString(_prefKey);
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
      final encodedStr = json.encode(sessions.map((e) => e.toJson()).toList());
      await prefs.setString(_prefKey, encodedStr);
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
}

final medgemmaHistoryProvider = StateNotifierProvider<MedgemmaHistoryNotifier, List<MedgemmaChatSession>>((ref) {
  return MedgemmaHistoryNotifier();
});
