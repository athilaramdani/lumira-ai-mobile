import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumira_ai_mobile/core/theme/app_colors.dart';
import 'package:lumira_ai_mobile/core/constants/app_assets.dart';
import 'package:lumira_ai_mobile/features/ai_chatbot/data/datasources/consultation_service.dart';
import 'package:lumira_ai_mobile/features/ai_chatbot/data/models/consultation_model.dart';
import 'package:lumira_ai_mobile/features/ai_chatbot/presentation/controllers/medgemma_history_controller.dart';

// ---------------------------------------------------------------------------
// Message model lokal
// ---------------------------------------------------------------------------
class MedgemmaMessage {
  final String text;
  final bool isUser;
  final String time;
  final String? imageUrl; // gambar yang disertakan oleh user

  MedgemmaMessage({
    required this.text,
    required this.isUser,
    required this.time,
    this.imageUrl,
  });
}

// ---------------------------------------------------------------------------
// Page
// ---------------------------------------------------------------------------
class MedgemmaChatPage extends ConsumerStatefulWidget {
  /// Jika dibuka dari halaman scan, image URL bisa langsung dioper
  final String? initialImageUrl;
  final String? sessionId;

  const MedgemmaChatPage({super.key, this.initialImageUrl, this.sessionId});

  @override
  ConsumerState<MedgemmaChatPage> createState() => _MedgemmaChatPageState();
}

class _MedgemmaChatPageState extends ConsumerState<MedgemmaChatPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isAiTyping = false;
  bool _showImageInput = false;
  late AnimationController _progressController;

  /// Riwayat pesan di UI
  final List<MedgemmaMessage> _messages = [];

  /// Riwayat yang dikirim ke API (hanya role+content, tanpa metadata UI)
  final List<ChatHistoryEntry> _apiHistory = [];

  /// Service yang menghit endpoint Cloudflare
  final ConsultationService _consultationService = ConsultationService();

  /// Image URL aktif (dari parameter awal atau input manual)
  String? _activeImageUrl;

  late String _currentSessionId;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Jika ada gambar awal dari halaman scan
    if (widget.initialImageUrl != null &&
        widget.initialImageUrl!.isNotEmpty) {
      _activeImageUrl = widget.initialImageUrl;
      _imageUrlController.text = widget.initialImageUrl!;
    }

    if (widget.sessionId != null) {
      _currentSessionId = widget.sessionId!;
      final session = ref.read(medgemmaHistoryProvider.notifier).getSession(_currentSessionId);
      if (session != null) {
        _messages.addAll(session.messages);
        _apiHistory.addAll(session.apiHistory);
      }
    } else {
      _currentSessionId = DateTime.now().millisecondsSinceEpoch.toString();
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _textController.dispose();
    _imageUrlController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Send message
  // -------------------------------------------------------------------------
  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    // Ambil image URL yang sedang aktif
    final imageUrl = _imageUrlController.text.trim().isNotEmpty
        ? _imageUrlController.text.trim()
        : _activeImageUrl;

    // Tambah pesan user ke UI
    final userMsg = MedgemmaMessage(
      text: text,
      isUser: true,
      time: _getCurrentTime(),
      imageUrl: imageUrl,
    );

    setState(() {
      _messages.add(userMsg);
      _textController.clear();
      _isAiTyping = true;
      _showImageInput = false;
    });
    _scrollToBottom();
    _saveSession();

    // Simpan ke riwayat API (untuk dikirim sebagai chat_history pada request berikutnya)
    // Catatan: pesan yang BARU saja diketik tidak dimasukkan ke chat_history –
    // ia menjadi user_prompt. Chat history berisi pesan-pesan SEBELUMNYA.
    final historySnapshot = List<ChatHistoryEntry>.from(_apiHistory);

    try {
      final result = await _consultationService.sendConsultation(
        user: 'Patient',
        userPrompt: text,
        chatHistory: historySnapshot,
        imageUrl: imageUrl,
      );

      // Setelah berhasil, masukkan giliran user + AI ke history
      _apiHistory.add(ChatHistoryEntry(role: 'user', content: text));
      _apiHistory.add(ChatHistoryEntry(role: 'assistant', content: result.response));

      if (mounted) {
        setState(() {
          _isAiTyping = false;
          _messages.add(MedgemmaMessage(
            text: result.response,
            isUser: false,
            time: _getCurrentTime(),
          ));
        });
        _scrollToBottom();
        _saveSession();
      }
    } catch (e) {
      // Masukkan pesan user ke history meski gagal agar konteks tidak hilang
      _apiHistory.add(ChatHistoryEntry(role: 'user', content: text));

      if (mounted) {
        setState(() {
          _isAiTyping = false;
          _messages.add(MedgemmaMessage(
            text: 'Maaf, terjadi kesalahan: $e',
            isUser: false,
            time: _getCurrentTime(),
          ));
        });
        _scrollToBottom();
        _saveSession();
      }
    }
  }

  void _saveSession() {
    if (_messages.isEmpty) return;
    final title = _messages.first.text;
    final snippet = _messages.last.text;

    final session = MedgemmaChatSession(
      id: _currentSessionId,
      title: title,
      snippet: snippet,
      messages: List.from(_messages),
      apiHistory: List.from(_apiHistory),
      lastUpdated: DateTime.now(),
    );
    ref.read(medgemmaHistoryProvider.notifier).addOrUpdateSession(session);
  }

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------
  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}';
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

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Banner jika ada gambar aktif
          if (_activeImageUrl != null || _imageUrlController.text.isNotEmpty)
            _buildActiveImageBanner(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: _messages.length + (_isAiTyping ? 1 : 0) + 1,
              itemBuilder: (context, index) {
                if (index == 0) return _buildDateSeparator();
                final msgIndex = index - 1;
                if (msgIndex == _messages.length && _isAiTyping) {
                  return _buildTypingIndicator();
                }
                return _buildMessageBubble(_messages[msgIndex]);
              },
            ),
          ),
          if (_showImageInput) _buildImageUrlInput(),
          _buildBottomInputArea(),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
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
            children: [
              const Text(
                'Lumira AI',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'AI Medical Consultation',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Tombol untuk attach image URL
        IconButton(
          tooltip: 'Lampirkan gambar scan',
          icon: Icon(
            Icons.image_outlined,
            color: _activeImageUrl != null ? const Color(0xFF40B4FF) : Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _showImageInput = !_showImageInput;
            });
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // Banner yang tampil di bawah AppBar saat ada image URL aktif
  Widget _buildActiveImageBanner() {
    final url = _imageUrlController.text.trim().isNotEmpty
        ? _imageUrlController.text.trim()
        : _activeImageUrl ?? '';
    if (url.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      color: const Color(0xFFE0F4FF),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.image, color: Color(0xFF40B4FF), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Gambar aktif: $url',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF0369A1),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.close, size: 16, color: Color(0xFF0369A1)),
            onPressed: () {
              setState(() {
                _activeImageUrl = null;
                _imageUrlController.clear();
              });
            },
          ),
        ],
      ),
    );
  }

  // Input URL gambar yang muncul di atas bottom bar
  Widget _buildImageUrlInput() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          const Icon(Icons.link, color: Colors.grey, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                hintText: 'Paste URL gambar scan / X-ray...',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
              style: const TextStyle(fontSize: 13),
              keyboardType: TextInputType.url,
              onSubmitted: (_) {
                setState(() {
                  _activeImageUrl = _imageUrlController.text.trim();
                  _showImageInput = false;
                });
              },
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _activeImageUrl = _imageUrlController.text.trim();
                _showImageInput = false;
              });
            },
            child: const Text('OK',
                style: TextStyle(
                    color: Color(0xFF40B4FF), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Widgets
  // -------------------------------------------------------------------------
  Widget _buildDateSeparator() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
          'TODAY',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(MedgemmaMessage message) {
    final bubbleContent = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      decoration: BoxDecoration(
        color: message.isUser
            ? const Color(0xFFE5E7EB) // Light gray for User
            : const Color(0xFFC7E8FF), // Light blue for AI
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: message.isUser ? const Radius.circular(16) : Radius.zero,
          bottomRight: message.isUser ? Radius.zero : const Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (message.imageUrl != null && message.imageUrl!.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                message.imageUrl!,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Row(
                  children: [
                    Icon(Icons.broken_image, color: Colors.black54, size: 20),
                    SizedBox(width: 4),
                    Text(
                      'Gambar tidak dapat dimuat',
                      style: TextStyle(color: Colors.black87, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            message.text,
            style: const TextStyle(
              color: Colors.black87, // Black text for both
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          if (message.time.isNotEmpty)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message.time,
                  style: const TextStyle(color: Colors.black54, fontSize: 10),
                ),
              ],
            ),
        ],
      ),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isUser) ...[
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFBAE6FD)),
              ),
              child: const Icon(Icons.smart_toy_outlined,
                  size: 16, color: Color(0xFF0284C7)),
            ),
          ],
          Flexible(child: bubbleContent),
          if (message.isUser) ...[
            const SizedBox(width: 8), // Provide some spacing from right edge if needed
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2FE),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFBAE6FD)),
            ),
            child: const Icon(Icons.smart_toy_outlined,
                size: 16, color: Color(0xFF0284C7)),
          ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFFC7E8FF),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.zero,
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '••• ANALYZING CLINICAL CONTEXT...',
                    style: TextStyle(
                      color: Color(0xFF0284C7),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: AnimatedBuilder(
                      animation: _progressController,
                      builder: (context, child) {
                        return LinearProgressIndicator(
                          value: _progressController.value,
                          minHeight: 8,
                          backgroundColor: Colors.white54,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF0284C7)),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomInputArea() {
    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        left: false,
        right: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12, top: 12, left: 16, right: 16),
          child: Row(
        children: [
          // Tombol lampirkan gambar
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Lampirkan URL gambar scan',
            icon: Icon(
              Icons.attach_file,
              color: _showImageInput
                  ? const Color(0xFF40B4FF)
                  : Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _showImageInput = !_showImageInput;
              });
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _textController,
                onSubmitted: (_) => _sendMessage(),
                decoration: const InputDecoration(
                  hintText: 'Ceritakan gejala Anda...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _isAiTyping ? null : _sendMessage,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF40B4FF),
              disabledBackgroundColor: Colors.grey[300],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 12),
              elevation: 0,
            ),
            child: const Text(
              'Kirim',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
        ),
      ),
    );
  }
}
