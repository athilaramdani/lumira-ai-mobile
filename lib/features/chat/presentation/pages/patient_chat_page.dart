
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
import 'package:lumira_ai_mobile/features/ai_chatbot/presentation/pages/medgemma_chat_page.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import 'package:lumira_ai_mobile/core/widgets/creative_medical_loading.dart';

class PatientChatPage extends ConsumerStatefulWidget {
  final String patientName;
  final String patientId;
  final String? medicalRecordId;

  const PatientChatPage({
    super.key,
    required this.patientName,
    required this.patientId,
    this.medicalRecordId,
  });

  @override
  ConsumerState<PatientChatPage> createState() => _PatientChatPageState();
}

class _PatientChatPageState extends ConsumerState<PatientChatPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _hasMedicalRecord = false;
  bool _isLoadingPatient = true;
  bool _isNavigatingToDiagnosis = false;
  String _medicalRecordId = '';

  @override
  void initState() {
    super.initState();
    if (widget.medicalRecordId != null && widget.medicalRecordId!.isNotEmpty) {
      _medicalRecordId = widget.medicalRecordId!;
      _isLoadingPatient = false;
      _hasMedicalRecord = true;
    } else {
      _checkMedicalRecord();
    }
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
    ref.read(chatControllerProvider((otherUserId: widget.patientId, medicalRecordId: _medicalRecordId)).notifier)
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
    if (_isLoadingPatient) {
      return const Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(40.0),
            child: CreativeMedicalLoading(text: 'Loading...'),
          ),
        ),
      );
    }

    final chatParams = (otherUserId: widget.patientId, medicalRecordId: _medicalRecordId);
    final chatState = ref.watch(chatControllerProvider(chatParams));
    
    final authState = ref.watch(authControllerProvider);
    final isPatientRole = authState.user?.role == 'patient';
    final counterpartImage = isPatientRole ? AppAssets.doctorProfile : AppAssets.patientProfile;

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
            _buildPatientInfoBar(counterpartImage),
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

  Widget _buildPatientInfoBar(String imagePath) {
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
              color: const Color(0xFFE3F2FD),
              border: Border.all(color: Colors.blue.shade100, width: 2),
            ),
            child: ClipOval(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                ),
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
    final role = message.senderRole.toLowerCase();
    final isDoctor = role == 'doctor' || role == 'optimistic';

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
            if (!_isNavigatingToDiagnosis) {
              _navigateToMedicalReview(context);
            }
          }, isLoading: _isNavigatingToDiagnosis),
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
    if (_isNavigatingToDiagnosis) return;
    setState(() {
      _isNavigatingToDiagnosis = true;
    });

    try {
      final patient = await ref.read(patientsControllerProvider.notifier).getPatientById(widget.patientId);
      final latestRecord = patient?.latestRecord ?? (patient?.medicalRecords?.isNotEmpty == true ? patient!.medicalRecords!.first : null);

      bool hasReview = false;
      final diag = latestRecord?.doctorDiagnosis?.trim().toLowerCase();
      if (diag != null && diag.isNotEmpty && diag != 'null') {
        hasReview = true;
      }
      final agree = latestRecord?.agreement?.trim().toLowerCase();
      if (agree != null && agree.isNotEmpty && agree != 'null') {
        hasReview = true;
      }
      final status = latestRecord?.validationStatus?.toUpperCase();
      final isDone = status == 'DONE' || status == 'VALIDATED' || hasReview;

      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MedicalReviewPage(
            patientId: widget.patientId,
            recordId: latestRecord?.id,
            patientName: widget.patientName,
            aiResult: AIResult.unknown,
            phone: patient?.contactNumber ?? '08123456789',
            rawImage: latestRecord?.imageUrl,
            gradCamImage: latestRecord?.gradcamImageUrl,
            isDone: isDone,
            initialDoctorDiagnosis: latestRecord?.doctorDiagnosis,
            initialDoctorNote: latestRecord?.doctorNotes,
            initialAgreement: latestRecord?.agreement,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isNavigatingToDiagnosis = false;
        });
      }
    }
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap, {bool isLoading = false}) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
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
            if (isLoading)
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF60A5FA),
                ),
              )
            else
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
    final isDisabled = _isLoadingPatient;

    return Container(
      color: Colors.white,
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
        ),
      ),
    );
  }
}
