import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import '../../domain/entities/chat_message.dart';
import '../controllers/chat_controller.dart';
import '../../../patients/presentation/controllers/patients_controller.dart';
import 'package:lumira_ai_mobile/features/medical_review/presentation/pages/medical_review_page.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/widgets/patient_card.dart';
import 'medgemma_chat_page.dart';

class PatientChatPage extends ConsumerStatefulWidget {
  final String patientName;
  final String patientId;

  const PatientChatPage({
    super.key,
    required this.patientName,
    required this.patientId,
  });

  @override
  ConsumerState<PatientChatPage> createState() => _PatientChatPageState();
}

class _PatientChatPageState extends ConsumerState<PatientChatPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _hasMedicalRecord = false;
  bool _isLoadingPatient = true;
  String _medicalRecordId = '';

  @override
  void initState() {
    super.initState();
    _checkMedicalRecord();
  }

  Future<void> _checkMedicalRecord() async {
    final patient = await ref.read(patientsControllerProvider.notifier).getPatientById(widget.patientId);
    if (mounted) {
      setState(() {
        _hasMedicalRecord = patient?.medicalRecords?.isNotEmpty == true;
        _medicalRecordId = patient?.latestRecord?.id ?? patient?.medicalRecords?.firstOrNull?.id ?? '';
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

  void _sendMessage() {
    if (_textController.text.trim().isEmpty) return;
    ref.read(chatControllerProvider((patientId: widget.patientId, medicalRecordId: _medicalRecordId)).notifier)
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
    final chatParams = (patientId: widget.patientId, medicalRecordId: _medicalRecordId);
    final chatState = ref.watch(chatControllerProvider(chatParams));

    // Auto-scroll when new messages arrive
    ref.listen(chatControllerProvider(chatParams), (previous, next) {
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
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.grey, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Chat Pasien',
            style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          centerTitle: false,
        ),
        body: Column(
          children: [
            _buildPatientInfoBar(),
            const Divider(height: 1, color: AppColors.border),
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
            Expanded(
              child: Container(
                color: const Color(0xFFF8FAFC),
                child: chatState.isLoading && chatState.messages.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : chatState.messages.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey.shade300),
                                const SizedBox(height: 16),
                                Text(
                                  'Belum ada pesan dengan pasien ini.',
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
            _buildActionButtons(),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientInfoBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blue.shade100, width: 2),
              image: const DecorationImage(
                image: AssetImage(AppAssets.doctorProfile),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.patientName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Row(
                children: [
                  Text(
                    'ID: ${widget.patientId}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    // Assuming local user is doctor -> senderRole could be 'doctor' or 'optimistic'
    final isDoctor = message.senderRole == 'doctor' || message.senderRole == 'optimistic';

    return Align(
      alignment: isDoctor ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isDoctor ? const Color(0xFF60A5FA) : Colors.white,
          borderRadius: BorderRadius.circular(16),
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
            Text(
              message.message,
              style: TextStyle(
                color: isDoctor ? Colors.white : Colors.black87,
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
                    color: isDoctor ? Colors.white70 : Colors.grey,
                    fontSize: 10,
                  ),
                ),
                if (isDoctor) ...[
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

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildActionButton(Icons.assignment_outlined, 'Diagnosis', () {
            _navigateToMedicalReview(context);
          }),
          const SizedBox(width: 12),
          _buildActionButton(Icons.smart_toy_outlined, 'Ask AI', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MedgemmaChatPage(),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _navigateToMedicalReview(BuildContext context) async {
    final patient = await ref.read(patientsControllerProvider.notifier).getPatientById(widget.patientId);
    final latestRecord = patient?.latestRecord ?? (patient?.medicalRecords?.isNotEmpty == true ? patient!.medicalRecords!.first : null);

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicalReviewPage(
          patientId: widget.patientId,
          recordId: latestRecord?.id,
          patientName: widget.patientName,
          aiResult: AIResult.unknown,
          phone: patient?.contactNumber ?? '08123456789',
          rawImage: latestRecord?.imageUrl,
          gradCamImage: latestRecord?.imageUrl,
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF60A5FA), size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF60A5FA),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
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
            onTap: isDisabled ? null : _sendMessage,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: isDisabled ? Colors.grey : const Color(0xFF60A5FA),
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
