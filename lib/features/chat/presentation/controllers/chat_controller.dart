import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/usecases/chat_usecases.dart';
import '../../data/datasources/chat_remote_data_source.dart';
import '../../data/repositories/chat_repository_impl.dart';

// Providers
final chatRemoteDataSourceProvider = Provider((ref) => ChatRemoteDataSourceImpl());
final chatRepositoryProvider = Provider((ref) => ChatRepositoryImpl(remoteDataSource: ref.watch(chatRemoteDataSourceProvider)));

final getChatHistoryUseCaseProvider = Provider((ref) => GetChatHistoryUseCase(ref.watch(chatRepositoryProvider)));
final sendMessageUseCaseProvider = Provider((ref) => SendMessageUseCase(ref.watch(chatRepositoryProvider)));

final unreadChatCountProvider = StateProvider<int>((ref) => 0);

class ChatState {
  final bool isLoading;
  final String? error;
  final List<ChatMessage> messages;

  ChatState({
    this.isLoading = false,
    this.error,
    this.messages = const [],
  });

  ChatState copyWith({
    bool? isLoading,
    String? error,
    List<ChatMessage>? messages,
  }) {
    return ChatState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      messages: messages ?? this.messages,
    );
  }
}

class ChatController extends StateNotifier<ChatState> {
  final GetChatHistoryUseCase _getChatHistory;
  final SendMessageUseCase _sendMessage;
  Timer? _pollingTimer;
  String? _currentPatientId;

  ChatController(this._getChatHistory, this._sendMessage) : super(ChatState());

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> loadChatHistory(String patientId) async {
    _currentPatientId = patientId;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final messages = await _getChatHistory(patientId);
      state = state.copyWith(isLoading: false, messages: messages);
      _startPolling();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (_currentPatientId == null) return;
      try {
        final messages = await _getChatHistory(_currentPatientId!);
        // Only update if new messages arrived
        if (messages.length > state.messages.length) {
           state = state.copyWith(messages: messages);
        }
      } catch (e) {
        // Silently ignore polling errors
      }
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _currentPatientId = null;
  }

  Future<void> sendMessage(String patientId, String text) async {
    // Optimistic Update
    final tempId = DateTime.now().millisecondsSinceEpoch.toString();
    final tempMessage = ChatMessage(
      id: tempId,
      senderId: 'current_user', // Assume local user
      senderRole: 'optimistic', // Temporary role
      message: text,
      sentAt: DateTime.now(),
    );

    final currentMessages = List<ChatMessage>.from(state.messages);
    state = state.copyWith(messages: [...currentMessages, tempMessage]);

    try {
      final realMessage = await _sendMessage(patientId, text);
      final updatedMessages = state.messages.map((m) => m.id == tempId ? realMessage : m).toList();
      state = state.copyWith(messages: updatedMessages);
    } catch (e) {
      // Jangan rollback untuk keperluan demo agar pesan tidak langsung hilang
      // Ubah role optimistic menjadi 'patient' atau 'doctor' (sesuai auth) agar UI merender dengan baik
      final fallbackMessage = tempMessage; // Di real app harusnya ada status "failed"
      final updatedMessages = state.messages.map((m) => m.id == tempId ? fallbackMessage : m).toList();
      
      state = state.copyWith(
        messages: updatedMessages,
        error: 'Gagal mengirim pesan: ${e.toString()}',
      );
    }
  }
}

final chatControllerProvider = StateNotifierProvider.family<ChatController, ChatState, String>((ref, patientId) {
  final controller = ChatController(
    ref.watch(getChatHistoryUseCaseProvider),
    ref.watch(sendMessageUseCaseProvider),
  );
  // Auto load history when the provider is created
  controller.loadChatHistory(patientId);
  ref.onDispose(() {
    controller.stopPolling();
  });
  return controller;
});
