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

final mintFirebaseTokenUseCaseProvider =
    Provider((ref) => MintFirebaseTokenUseCase(ref.watch(chatRepositoryProvider)));

final getRoomsUseCaseProvider =
    Provider((ref) => GetRoomsUseCase(ref.watch(chatRepositoryProvider)));

final unreadChatCountProvider = StateProvider<int>((ref) => 0);

/// Rooms list provider — used by ChatListPage to show rooms from backend API.
final chatRoomsProvider = FutureProvider<List<dynamic>>((ref) async {
  final useCase = ref.watch(getRoomsUseCaseProvider);
  return useCase();
});

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
  final MintFirebaseTokenUseCase _mintToken;

  StreamSubscription<List<ChatMessage>>? _messagesSub;

  ChatController(this._getMessages, this._sendMessage, this._resolveRoom, this._mintToken)
      : super(const ChatState());

  @override
  void dispose() {
    _messagesSub?.cancel();
    super.dispose();
  }

  // ─── Room Setup ─────────────────────────────────────────────────────────

  /// Step 1: Mint Firebase token from backend → sign in to Firebase Auth.
  /// Step 2: Resolve / create room via backend API using medicalRecordId.
  /// Step 3: Subscribe to Firestore real-time messages for that room.
  Future<void> initRoom({
    required String patientId,
    required String doctorId,
    required String medicalRecordId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Step 1: Get custom token from backend & authenticate with Firebase
      print('[ChatController] Minting Firebase custom token...');
      await _mintToken();

      // Step 2: Resolve / create room via backend API
      print('[ChatController] Resolving room. patient=$patientId doctor=$doctorId record=$medicalRecordId');
      final roomId = await _resolveRoom(
        patientId: patientId,
        doctorId: doctorId,
        medicalRecordId: medicalRecordId,
      );
      print('[ChatController] Room resolved: $roomId');
      state = state.copyWith(roomId: roomId);

      // Step 3: Listen to Firestore for real-time messages
      _listenToMessages(roomId);
    } catch (e) {
      print('[ChatController] initRoom error: $e');
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
    print('[ChatController] sendMessage called. text: $text, roomId: $roomId');
    if (roomId == null || text.trim().isEmpty) return;

    // Optimistic update — show message immediately before Firebase confirms
    final tempId = 'optimistic_${DateTime.now().millisecondsSinceEpoch}';
    final tempMessage = ChatMessage(
      id: tempId,
      senderId: 'me',
      senderRole: 'optimistic',
      message: text.trim(),
      sentAt: DateTime.now(),
    );
    state = state.copyWith(messages: [...state.messages, tempMessage]);

    final prefs = await SharedPreferences.getInstance();
    final senderId = prefs.getString('user_id') ?? '';
    final senderRole = prefs.getString('user_role') ?? 'doctor';

    try {
      print('[ChatController] Sending to Firestore. senderId: $senderId, senderRole: $senderRole');
      await _sendMessage(
        roomId: roomId,
        senderId: senderId,
        senderRole: senderRole,
        message: text.trim(),
      );
      print('[ChatController] Send success!');
      // Real message arrives via Firestore stream, replacing optimistic one.
    } catch (e) {
      print('[ChatController] Send error: $e');
      final msgs = state.messages.where((m) => m.id != tempId).toList();
      state = state.copyWith(
        messages: msgs,
        error: 'Gagal mengirim pesan: ${e.toString()}',
      );
    }
  }
}

// ─── Provider Factory ─────────────────────────────────────────────────────────

/// Family param is a Dart Record with named fields.
/// - For DOCTOR: patientId = patient's ID, medicalRecordId = patient's latest record ID
/// - For PATIENT: patientId = own user ID,  medicalRecordId = own medical record ID
final chatControllerProvider = StateNotifierProvider.family<
    ChatController, ChatState, ({String otherUserId, String medicalRecordId})>(
  (ref, params) {
    final controller = ChatController(
      ref.watch(getMessagesUseCaseProvider),
      ref.watch(sendMessageUseCaseProvider),
      ref.watch(resolveRoomUseCaseProvider),
      ref.watch(mintFirebaseTokenUseCaseProvider),
    );

    Future(() async {
      final prefs = await SharedPreferences.getInstance();
      final myId = prefs.getString('user_id') ?? '';
      final myRole = prefs.getString('user_role') ?? 'doctor';

      String patientId;
      String doctorId;

      if (myRole == 'patient') {
        // I am the patient — otherUserId is the doctor's ID (not strictly needed now)
        patientId = myId;
        doctorId = 'default_doctor';
      } else {
        // I am the doctor — otherUserId is the patient's ID
        patientId = params.otherUserId;
        doctorId = 'default_doctor';
      }

      await controller.initRoom(
        patientId: patientId,
        doctorId: doctorId,
        medicalRecordId: params.medicalRecordId,
      );
    });

    ref.onDispose(() {
      controller._messagesSub?.cancel();
    });

    return controller;
  },
);
