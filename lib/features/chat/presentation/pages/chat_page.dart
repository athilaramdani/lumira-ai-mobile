import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import '../../domain/entities/chat_message.dart';
import '../controllers/chat_controller.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../patients/presentation/controllers/patients_controller.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _hasMedicalRecord = false;
  bool _isLoadingPatient = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkMedicalRecord();
    });
  }

  Future<void> _checkMedicalRecord() async {
    final authState = ref.read(authControllerProvider);
    final patientId = authState.user?.id;
    if (patientId == null) {
      if (mounted) {
        setState(() {
          _isLoadingPatient = false;
        });
      }
      return;
    }

    final patient = await ref.read(patientsControllerProvider.notifier).getPatientById(patientId);
    if (mounted) {
      setState(() {
        _hasMedicalRecord = patient?.medicalRecords?.isNotEmpty == true;
        _isLoadingPatient = false;
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String patientId) {
    if (_textController.text.trim().isEmpty || !_hasMedicalRecord) return;
    ref.read(chatControllerProvider(patientId).notifier).sendMessage(
      patientId,
      _textController.text.trim(),
    );
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
    final patientId = authState.user?.id;

    if (patientId == null) {
      return const Scaffold(
        body: Center(child: Text('User ID not found.')),
      );
    }

    final chatState = ref.watch(chatControllerProvider(patientId));

    // Optional: auto-scroll when new messages arrive
    ref.listen(chatControllerProvider(patientId), (previous, next) {
      if (previous != null && next.messages.length > previous.messages.length) {
        _scrollToBottom();
      }
    });

    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: GoogleFonts.openSansTextTheme(
          Theme.of(context).textTheme,
        ),
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
              const CircleAvatar(
                radius: 18,
                backgroundImage: AssetImage(AppAssets.doctor), 
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Dr. Sarah', // Dummy doctor name for now
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
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
        ),
        body: Column(
          children: [
            if (!_isLoadingPatient && !_hasMedicalRecord)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: Colors.amber.shade50,
                child: const Text(
                  'Anda belum memiliki rekam medis. Chat dinonaktifkan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.deepOrange, fontSize: 12),
                ),
              ),
            Expanded(
              child: Container(
                color: const Color(0xFFF8FAFC),
                child: chatState.isLoading && chatState.messages.isEmpty
                    ? const Center(child: CircularProgressIndicator())
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
            _buildInputArea(patientId),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    // Local user is patient -> senderRole could be 'patient' or 'optimistic'
    final isPatient = message.senderRole == 'patient' || message.senderRole == 'optimistic';

    return Align(
      alignment: isPatient ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isPatient ? const Color(0xFF40B4FF) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isPatient ? [] : [
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
            Text(
              message.message,
              style: TextStyle(
                color: isPatient ? Colors.white : Colors.black87,
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
                    color: isPatient ? Colors.white70 : Colors.grey,
                    fontSize: 10,
                  ),
                ),
                if (isPatient) ...[
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

  Widget _buildInputArea(String patientId) {
    final isDisabled = _isLoadingPatient || !_hasMedicalRecord;

    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24, top: 8),
      color: Colors.white,
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
                enabled: !isDisabled,
                decoration: InputDecoration(
                  hintText: isDisabled ? 'Chat tidak tersedia' : 'Ketik pesan...',
                  border: InputBorder.none,
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: isDisabled ? null : () => _sendMessage(patientId),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: isDisabled ? Colors.grey : const Color(0xFF40B4FF),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Text(
                'Kirim',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
