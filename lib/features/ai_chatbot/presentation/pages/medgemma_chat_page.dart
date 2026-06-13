import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:lumira_ai_mobile/core/theme/app_colors.dart';
import 'package:lumira_ai_mobile/core/constants/app_assets.dart';
import 'package:lumira_ai_mobile/core/services/cloudinary_service.dart';
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

  Map<String, dynamic> toJson() => {
        'text': text,
        'isUser': isUser,
        'time': time,
        'imageUrl': imageUrl,
      };

  factory MedgemmaMessage.fromJson(Map<String, dynamic> json) =>
      MedgemmaMessage(
        text: json['text'] as String,
        isUser: json['isUser'] as bool,
        time: json['time'] as String,
        imageUrl: json['imageUrl'] as String?,
      );
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

  bool _showImageInput = false;
  late AnimationController _progressController;

  /// Image URL aktif (dari parameter awal atau input manual)
  String? _activeImageUrl;

  /// Image yang dipilih secara lokal (belum di-upload)
  XFile? _selectedImageFile;
  Uint8List? _selectedImageBytes; // Untuk preview instan
  bool _isUploadingToCloudinary = false;

  late String _currentSessionId;

  /// Topik medis utama yang terdeteksi dari percakapan ini.
  String? _detectedMedicalTopic;

  final ImagePicker _picker = ImagePicker();

  // ── Pick image from gallery ──
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        
        // Cek ukuran file – maks 5 MB
        if (bytes.lengthInBytes > 5 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ukuran gambar maksimal 5 MB'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        setState(() {
          _selectedImageFile = image;
          _selectedImageBytes = bytes;
          _activeImageUrl = null;
          _imageUrlController.clear();
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    );

    // Jika ada gambar awal dari halaman scan
    if (widget.initialImageUrl != null &&
        widget.initialImageUrl!.isNotEmpty) {
      _activeImageUrl = widget.initialImageUrl;
      _imageUrlController.text = widget.initialImageUrl!;
    }

    if (widget.sessionId != null) {
      _currentSessionId = widget.sessionId!;
      final session = ref.read(medgemmaHistoryProvider.notifier).getSession(_currentSessionId);
      if (session != null && session.isTyping) {
        final elapsed = DateTime.now().difference(session.lastUpdated);
        final elapsedSeconds = elapsed.inSeconds.toDouble();

        double startValue = (elapsedSeconds / 15.0) * 0.95;
        if (startValue > 0.95) startValue = 0.95;

        _progressController.value = startValue;

        if (startValue < 0.95) {
          final remainingSeconds = 15 - elapsedSeconds.toInt();
          _progressController.animateTo(
            0.95,
            duration: Duration(seconds: remainingSeconds > 0 ? remainingSeconds : 1),
            curve: Curves.easeOutCubic,
          );
        }
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
  static const List<String> _medicalKeywords = [
    'kanker', 'tumor', 'kista', 'mammogram', 'biopsi', 'radiasi',
    'kemoterapi', 'onkologi', 'metastasis', 'stadium', 'payudara',
    'paru', 'hati', 'leher rahim', 'serviks', 'prostat', 'diabetes',
    'hipertensi', 'jantung', 'stroke', 'tbc', 'anemia', 'asma',
    'limfoma', 'leukemia', 'fibroid', 'polip',
  ];

  String? _extractTopic(String text) {
    final lower = text.toLowerCase();
    for (final kw in _medicalKeywords) {
      if (lower.contains(kw)) return kw;
    }
    return null;
  }

  bool _hasExplicitMedicalContext(String text) {
    return _extractTopic(text) != null;
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty && _selectedImageFile == null && _activeImageUrl == null) return;

    String? finalImageUrl = _imageUrlController.text.trim().isNotEmpty
        ? _imageUrlController.text.trim()
        : _activeImageUrl;

    // 1. Jika ada gambar lokal yang dipilih, upload ke Cloudinary dulu
    if (_selectedImageFile != null) {
      setState(() {
        _isUploadingToCloudinary = true;
      });

      try {
        final bytes = await _selectedImageFile!.readAsBytes();
        final url = await CloudinaryService().uploadImage(
          bytes,
          _selectedImageFile!.name,
        );

        if (url != null) {
          finalImageUrl = url;
        } else {
          throw Exception('Gagal mengunggah gambar ke Cloudinary.');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
          );
        }
        setState(() {
          _isUploadingToCloudinary = false;
        });
        return;
      }
    }

    final topicInMessage = _extractTopic(text);
    if (topicInMessage != null) {
      _detectedMedicalTopic = topicInMessage;
    }

    final session = ref.read(medgemmaHistoryProvider.notifier).getSession(_currentSessionId);
    final apiHistory = session?.apiHistory ?? [];

    String enrichedPrompt = text.isEmpty ? 'Analisis gambar ini' : text;
    if (apiHistory.isNotEmpty &&
        !_hasExplicitMedicalContext(enrichedPrompt) &&
        _detectedMedicalTopic != null) {
      enrichedPrompt = '[Konteks: pertanyaan ini masih dalam topik $_detectedMedicalTopic] $enrichedPrompt';
    }

    final userMsg = MedgemmaMessage(
      text: text.isEmpty ? 'Analisis gambar ini' : text,
      isUser: true,
      time: _getCurrentTime(),
      imageUrl: finalImageUrl,
    );

    setState(() {
      _textController.clear();
      _selectedImageFile = null;
      _selectedImageBytes = null;
      _isUploadingToCloudinary = false;
      _showImageInput = false;
      _activeImageUrl = null;
      _imageUrlController.clear();
      _progressController.reset();
      _progressController.animateTo(
        0.95,
        duration: const Duration(seconds: 15),
        curve: Curves.easeOutCubic,
      );
    });

    _scrollToBottom();

    // Call background service
    ref.read(medgemmaHistoryProvider.notifier).sendMessage(
      sessionId: _currentSessionId,
      userMsg: userMsg,
      enrichedPrompt: enrichedPrompt,
      imageUrl: finalImageUrl,
    );
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
    final sessions = ref.watch(medgemmaHistoryProvider);
    final session = sessions.firstWhere(
      (s) => s.id == _currentSessionId,
      orElse: () => MedgemmaChatSession(
        id: _currentSessionId,
        title: '',
        snippet: '',
        messages: [],
        apiHistory: [],
        lastUpdated: DateTime.now(),
      ),
    );

    final messages = session.messages;
    final isAiTyping = session.isTyping;
    final isBusy = isAiTyping || _isUploadingToCloudinary;

    // Listen to changes to scroll
    ref.listen(medgemmaHistoryProvider, (prev, next) {
      final prevSession = prev?.where((s) => s.id == _currentSessionId).firstOrNull;
      final nextSession = next.where((s) => s.id == _currentSessionId).firstOrNull;
      if (prevSession != null && nextSession != null) {
        if (nextSession.messages.length > prevSession.messages.length || nextSession.isTyping != prevSession.isTyping) {
          _scrollToBottom();
        }
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: messages.length + (isBusy ? 1 : 0) + 1,
              itemBuilder: (context, index) {
                if (index == 0) return _buildDateSeparator();
                final msgIndex = index - 1;
                if (msgIndex == messages.length && isBusy) {
                  return _buildTypingIndicator();
                }
                return _buildMessageBubble(messages[msgIndex]);
              },
            ),
          ),
          if (_activeImageUrl != null || _imageUrlController.text.isNotEmpty || _selectedImageFile != null)
            _buildImageInputPreview(),
          if (_showImageInput) _buildImageUrlInput(),
          _buildBottomInputArea(isBusy),
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
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFE3F2FD),
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Image.asset(AppAssets.doctorProfile, fit: BoxFit.contain),
            ),
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
        // Tombol untuk attach image URL (manual)
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

  // Preview Gambar yang akan dikirim (Tampil di atas text input)
  Widget _buildImageInputPreview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Stack(
        children: [
          Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF40B4FF).withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: _selectedImageBytes != null
                ? Image.memory(_selectedImageBytes!, fit: BoxFit.cover)
                : Image.network(
                    _imageUrlController.text.isNotEmpty ? _imageUrlController.text : (_activeImageUrl ?? ''),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[100],
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
            ),
          ),
          Positioned(
            top: -8,
            left: 74,
            child: IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.red),
            ),
            onPressed: () {
              setState(() {
                _activeImageUrl = null;
                _selectedImageFile = null;
                _selectedImageBytes = null;
                _imageUrlController.clear();
              });
            },
          )),
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
                  _selectedImageFile = null;
                  _showImageInput = false;
                });
              },
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _activeImageUrl = _imageUrlController.text.trim();
                _selectedImageFile = null;
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
          MarkdownBody(
            data: message.text,
            styleSheet: MarkdownStyleSheet(
              p: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                height: 1.5,
              ),
              strong: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
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
            const SizedBox(width: 8),
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
              decoration: BoxDecoration(
                color: const Color(0xFFC7E8FF),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.zero,
                  bottomRight: const Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isUploadingToCloudinary
                        ? '••• UPLOADING IMAGE...'
                        : '••• ANALYZING CONTEXT...',
                    style: const TextStyle(
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
                          value: _isUploadingToCloudinary ? null : _progressController.value,
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

  Widget _buildBottomInputArea(bool isBusy) {
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
          // Tombol lampirkan gambar (Foto Icon)
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Unggah gambar scan (maks 5 MB)',
            icon: Icon(
              Icons.image, // Diganti ke foto icon
              color: _selectedImageFile != null
                  ? const Color(0xFF40B4FF)
                  : Colors.grey,
            ),
            onPressed: isBusy ? null : _pickImage,
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
                onSubmitted: (_) => isBusy ? null : _sendMessage(),
                decoration: InputDecoration(
                  hintText: _selectedImageFile != null
                      ? 'Tambahkan keterangan (opsional)...'
                      : 'Ceritakan gejala Anda...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: isBusy ? null : _sendMessage,
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
              'Send',
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
