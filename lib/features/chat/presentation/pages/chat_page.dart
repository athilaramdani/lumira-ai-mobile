import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import '../../domain/entities/chat_message.dart';
import '../controllers/chat_controller.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../../core/widgets/creative_medical_loading.dart';

/// Patient-side chat page.
/// The family param for chatControllerProvider is the patient's own user ID.
/// The controller detects role='patient' from SharedPreferences and resolves the room correctly.
class ChatPage extends ConsumerStatefulWidget {
  final String? doctorName;
  final String? doctorId;
  final String? medicalRecordId;

  const ChatPage({super.key, this.doctorName, this.doctorId, this.medicalRecordId});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _medicalRecordId = '';

  @override
  void initState() {
    super.initState();
    _loadMedicalRecordId();
  }

  Future<void> _loadMedicalRecordId() async {
    if (widget.medicalRecordId != null && widget.medicalRecordId!.isNotEmpty) {
      if (mounted) setState(() => _medicalRecordId = widget.medicalRecordId!);
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final recordId = prefs.getString('medical_record_id') ?? '';
    if (mounted) setState(() => _medicalRecordId = recordId);
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String myId) {
    if (_textController.text.trim().isEmpty) return;
    ref.read(chatControllerProvider((otherUserId: widget.doctorId ?? '', medicalRecordId: _medicalRecordId)).notifier)
        .sendMessage(_textController.text.trim());
    _textController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    // For patients, their OWN user ID is used as the family param
    // The controller detects role='patient' and builds roomId = 'room_{patientId}'
    final myId = authState.user?.id ?? '';

    if (myId.isEmpty || _medicalRecordId.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(40.0),
            child: CreativeMedicalLoading(text: 'Preparing chat...'),
          ),
        ),
      );
    }

    // Use the loaded medicalRecordId
    final chatParams = (otherUserId: widget.doctorId ?? '', medicalRecordId: _medicalRecordId);
    final chatState = ref.watch(chatControllerProvider(chatParams));

    ref.listen(chatControllerProvider(chatParams), (previous, next) {
      if (previous != null && next.messages.length > previous.messages.length) {
        _scrollToBottom();
      }
    });

    final doctorLabel = widget.doctorName ?? 'Dokter';

    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: GoogleFonts.openSansTextTheme(Theme.of(context).textTheme),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black54),
            onPressed: () => Navigator.pop(context),
          ),
          titleSpacing: 0,
          title: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFE3F2FD),
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Image.asset(
                    AppAssets.doctorProfile,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctorLabel,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Surgical Oncologist',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.circle, color: Color(0xFF22C55E), size: 8),
                  SizedBox(width: 4),
                  Text('Online', style: TextStyle(color: Color(0xFF22C55E), fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Error banner
            if (chatState.error != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                color: Colors.red.shade50,
                child: Text(
                  chatState.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            // Messages list
            Expanded(
              child: Container(
                color: const Color(0xFFF8FAFC),
                child: chatState.isLoading && chatState.messages.isEmpty
                    ? const Center(
                        child: CreativeMedicalLoading(text: 'Loading messages...'),
                      )
                    : chatState.messages.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey.shade300),
                                const SizedBox(height: 16),
                                Text(
                                  'Belum ada pesan.\nMulai konsultasi dengan dokter Anda!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                            itemCount: chatState.messages.length,
                            itemBuilder: (context, index) {
                              return _buildMessageBubble(chatState.messages[index]);
                            },
                          ),
              ),
            ),
            // Input area
            _buildInputArea(myId),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final role = message.senderRole.toLowerCase();
    final isMe = role == 'patient' || role == 'optimistic';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF40B4FF) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'Dokter',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Text(
              message.message,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('HH:mm').format(message.sentAt.toLocal()),
                  style: TextStyle(
                    color: isMe ? Colors.white70 : Colors.grey,
                    fontSize: 10,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.senderRole == 'optimistic' ? Icons.access_time : Icons.done_all,
                    color: Colors.white70,
                    size: 14,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(String myId) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        left: false,
        right: false,
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12, top: 8),
          child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  hintText: 'Ketik pesan ke dokter...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                onSubmitted: (_) => _sendMessage(myId),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _sendMessage(myId),
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFF40B4FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
        ),
      ),
    );
  }
}
