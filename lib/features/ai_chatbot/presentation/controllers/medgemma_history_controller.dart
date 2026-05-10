import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  MedgemmaHistoryNotifier() : super([]);

  void addOrUpdateSession(MedgemmaChatSession session) {
    final index = state.indexWhere((s) => s.id == session.id);
    if (index >= 0) {
      final updated = List<MedgemmaChatSession>.from(state);
      updated[index] = session;
      state = updated;
    } else {
      state = [session, ...state];
    }
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
