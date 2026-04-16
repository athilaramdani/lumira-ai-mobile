import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_assets.dart';

class PatientChatMessage {
  final String text;
  final bool isUser; // is doctor
  final bool isAi;
  final String time;
  final AiSuggstion? aiSuggestion;

  PatientChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
    this.isAi = false,
    this.aiSuggestion,
  });
}

class AiSuggstion {
  final String title;
  final String confidence;
  final List<String> recommendations;

  AiSuggstion({
    required this.title,
    required this.confidence,
    required this.recommendations,
  });
}

class PatientChatPage extends StatefulWidget {
  final String patientName;
  final String patientId;

  const PatientChatPage({
    super.key,
    required this.patientName,
    required this.patientId,
  });

  @override
  State<PatientChatPage> createState() => _PatientChatPageState();
}

class _PatientChatPageState extends State<PatientChatPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<PatientChatMessage> _messages = [
    PatientChatMessage(
      text: 'Dok, hasil saya bagaimana ya?',
      isUser: false,
      time: '12:15',
    ),
    PatientChatMessage(
      text: 'Berdasarkan hasil analisis AI, terdapat indikasi malignant. Namun, perlu pemeriksaan lanjutan untuk memastikan diagnosis.',
      isUser: true,
      time: '12:17',
    ),
    PatientChatMessage(
      text: 'Berdasarkan citra USG, ditemukan pola yang mengarah pada malignant lesion.',
      isUser: true,
      isAi: true,
      time: '12:17',
      aiSuggestion: AiSuggstion(
        title: 'MedGemma AI',
        confidence: '91%',
        recommendations: [
          'Biopsi lanjutan',
          'Konsultasi spesialis onkologi',
        ],
      ),
    ),
    PatientChatMessage(
      text: 'Saya sarankan untuk segera melakukan pemeriksaan lanjutan di rumah sakit terdekat ya.',
      isUser: true,
      time: '12:20',
    ),
    PatientChatMessage(
      text: 'Baik dok, terima kasih banyak',
      isUser: false,
      time: '12:22',
    ),
  ];

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_textController.text.trim().isEmpty) return;
    setState(() {
      _messages.add(PatientChatMessage(
        text: _textController.text,
        isUser: true,
        time: _getCurrentTime(),
      ));
      _textController.clear();
    });
    _scrollToBottom();
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
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
    return Scaffold(
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
          Expanded(
            child: Container(
              color: const Color(0xFFF8FAFC),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _buildMessageBubble(_messages[index]);
                },
              ),
            ),
          ),
          _buildActionButtons(),
          _buildInputArea(),
        ],
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
                  const SizedBox(width: 16),
                  const Text(
                    'Malignant',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.statusMalignant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(PatientChatMessage message) {
    if (message.isAi && message.aiSuggestion != null) {
      return _buildAiMessageBubble(message);
    }

    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isUser ? const Color(0xFF60A5FA) : Colors.white,
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
              message.text,
              style: TextStyle(
                color: message.isUser ? Colors.white : Colors.black87,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message.time,
                  style: TextStyle(
                    color: message.isUser ? Colors.white70 : Colors.grey,
                    fontSize: 10,
                  ),
                ),
                if (message.isUser) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.done_all, color: Colors.white70, size: 14),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiMessageBubble(PatientChatMessage message) {
    final ai = message.aiSuggestion!;
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        width: MediaQuery.of(context).size.width * 0.75,
        decoration: BoxDecoration(
          color: const Color(0xFF1E3A8A),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.smart_toy_outlined, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    ai.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                message.text,
                style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'Confidence: ${ai.confidence}',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Rekomendasi:', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ...ai.recommendations.map((rec) => Padding(
                    padding: const EdgeInsets.only(left: 8.0, top: 4),
                    child: Text('- $rec', style: const TextStyle(color: Colors.white, fontSize: 13)),
                  )),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    message.time,
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.done_all, color: Colors.white70, size: 14),
                ],
              ),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildActionButton(Icons.assignment_outlined, 'Diagnosis'),
          _buildActionButton(Icons.smart_toy_outlined, 'Ask AI'),
          _buildActionButton(Icons.attach_file, 'Attach Image'),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Container(
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
    );
  }

  Widget _buildInputArea() {
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
                decoration: const InputDecoration(
                  hintText: 'Ketik pesan...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF60A5FA),
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
