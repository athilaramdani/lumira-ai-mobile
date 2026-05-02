import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/usecases/chat_usecases.dart';
import '../../data/datasources/chat_remote_data_source.dart';
import '../../data/repositories/chat_repository_impl.dart';

// ─── Providers ───────────────────────────────────────────────────────────────

final chatRemoteDataSourceProvider =
    Provider((ref) => ChatRemoteDataSourceImpl());

final chatRepositoryProvider = Provider(
  (ref) => ChatRepositoryImpl(
    remoteDataSource: ref.watch(chatRemoteDataSourceProvider),
  ),
);

final getMessagesUseCaseProvider =
    Provider((ref) => GetMessagesUseCase(ref.watch(chatRepositoryProvider)));

final sendMessageUseCaseProvider =
    Provider((ref) => SendMessageUseCase(ref.watch(chatRepositoryProvider)));

final resolveRoomUseCaseProvider =
    Provider((ref) => ResolveRoomUseCase(ref.watch(chatRepositoryProvider)));

final unreadChatCountProvider = StateProvider<int>((ref) => 0);

// ─── State ────────────────────────────────────────────────────────────────────

class ChatState {
  final bool isLoading;
  final String? error;
  final List<ChatMessage> messages;
  final String? roomId;

  const ChatState({
    this.isLoading = false,
    this.error,
    this.messages = const [],
    this.roomId,
  });

  ChatState copyWith({
    bool? isLoading,
    String? error,
    List<ChatMessage>? messages,
    String? roomId,
  }) {
    return ChatState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      messages: messages ?? this.messages,
      roomId: roomId ?? this.roomId,
    );
  }
}

// ─── Controller ───────────────────────────────────────────────────────────────

class ChatController extends StateNotifier<ChatState> {
  final GetMessagesUseCase _getMessages;
  final SendMessageUseCase _sendMessage;
  final ResolveRoomUseCase _resolveRoom;

  StreamSubscription<List<ChatMessage>>? _messagesSub;

  ChatController(this._getMessages, this._sendMessage, this._resolveRoom)
      : super(const ChatState());

  @override
  void dispose() {
    _messagesSub?.cancel();
    super.dispose();
  }

  // ─── Room Setup ─────────────────────────────────────────────────────────

  /// Resolves the Firestore room then subscribes to real-time messages.
  Future<void> initRoom({
    required String patientId,
    required String doctorId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final roomId =
          await _resolveRoom(patientId: patientId, doctorId: doctorId);
      state = state.copyWith(roomId: roomId);
      _listenToMessages(roomId);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void _listenToMessages(String roomId) {
    _messagesSub?.cancel();
    _messagesSub = _getMessages(roomId).listen(
      (messages) {
        state = state.copyWith(isLoading: false, messages: messages, error: null);
      },
      onError: (e) {
        state = state.copyWith(isLoading: false, error: e.toString());
      },
    );
  }

  // ─── Send ─────────────────────────────────────────────────────────────────

  Future<void> sendMessage(String text) async {
    final roomId = state.roomId;
    if (roomId == null || text.trim().isEmpty) return;

    // Optimistic update — add a temporary message immediately
    final tempId = 'optimistic_${DateTime.now().millisecondsSinceEpoch}';
    final tempMessage = ChatMessage(
      id: tempId,
      senderId: 'me',
      senderRole: 'optimistic',
      message: text.trim(),
      sentAt: DateTime.now(),
    );
    state = state.copyWith(messages: [...state.messages, tempMessage]);

    // Retrieve actual sender ID from SharedPreferences (saved at login)
    final prefs = await SharedPreferences.getInstance();
    final senderId = prefs.getString('user_id') ?? 'doctor';
    final senderRole = prefs.getString('user_role') ?? 'doctor';

    try {
      await _sendMessage(
        roomId: roomId,
        senderId: senderId,
        senderRole: senderRole,
        message: text.trim(),
      );
      // The real message will arrive via the Firestore stream and replace the optimistic one.
    } catch (e) {
      // Remove optimistic message on failure and show error
      final msgs = state.messages.where((m) => m.id != tempId).toList();
      state = state.copyWith(
        messages: msgs,
        error: 'Gagal mengirim pesan: ${e.toString()}',
      );
    }
  }
}

// ─── Provider Factory ─────────────────────────────────────────────────────────

/// Takes `otherPartyId` as the family parameter:
/// - For DOCTOR: pass the patient's ID
/// - For PATIENT: pass the doctor's ID (or 'default' to let controller resolve)
final chatControllerProvider = StateNotifierProvider.family<
    ChatController, ChatState, String>((ref, otherPartyId) {
  final controller = ChatController(
    ref.watch(getMessagesUseCaseProvider),
    ref.watch(sendMessageUseCaseProvider),
    ref.watch(resolveRoomUseCaseProvider),
  );

  // Init room asynchronously — determine patientId and doctorId based on role
  Future(() async {
    final prefs = await SharedPreferences.getInstance();
    final myId = prefs.getString('user_id') ?? '';
    final myRole = prefs.getString('user_role') ?? 'doctor';

    String patientId;
    String doctorId;

    if (myRole == 'patient') {
      // I am the patient — otherPartyId is the doctor's ID
      patientId = myId;
      doctorId = otherPartyId.isNotEmpty ? otherPartyId : 'default_doctor';
    } else {
      // I am the doctor — otherPartyId is the patient's ID
      patientId = otherPartyId;
      doctorId = myId.isNotEmpty ? myId : 'default_doctor';
    }

    await controller.initRoom(patientId: patientId, doctorId: doctorId);
  });

  ref.onDispose(() {
    controller._messagesSub?.cancel();
  });

  return controller;
});
