import 'package:dio/dio.dart';
import 'package:lumira_ai_mobile/features/ai_chatbot/data/models/consultation_model.dart';

/// Service untuk berkomunikasi dengan AI consultation endpoint.
/// 
/// Endpoint  : POST https://lewis-facility-chassis-gsm.trycloudflare.com/consultations
/// Auth      : Bearer XiueX_Lumira+MedWTelU  (static key – bukan token user)
/// Body      : { user, user_prompt, chat_history, image? }
class ConsultationService {
  static const String _baseUrl =
      'https://lewis-facility-chassis-gsm.trycloudflare.com';
  static const String _apiToken = 'XiueX_Lumira+MedWTelU';
  static const String _endpoint = '/consultations';

  late final Dio _dio;

  ConsultationService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 120),
        headers: {
          'Authorization': 'Bearer $_apiToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Log request & response saat debug
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => print('[ConsultationService] $obj'),
    ));
  }

  /// Kirim pesan ke AI dan kembalikan teks balasan.
  ///
  /// [user]        – role pengirim, misal 'Patient'
  /// [userPrompt]  – pesan terbaru dari user
  /// [chatHistory] – riwayat percakapan sebelumnya
  /// [imageUrl]    – URL gambar scan/X-ray (opsional)
  Future<ConsultationResponse> sendConsultation({
    required String user,
    required String userPrompt,
    required List<ChatHistoryEntry> chatHistory,
    String? imageUrl,
  }) async {
    final request = ConsultationRequest(
      user: user,
      userPrompt: userPrompt,
      chatHistory: chatHistory,
      image: imageUrl,
    );

    try {
      // Gunakan dynamic agar tidak ada masalah casting di Flutter Web
      final response = await _dio.post<dynamic>(
        _endpoint,
        data: request.toJson(),
      );

      final rawData = response.data;
      if (rawData == null) {
        throw Exception('Response kosong dari server AI.');
      }

      // Konversi ke Map secara eksplisit
      final Map<String, dynamic> jsonMap = rawData is Map<String, dynamic>
          ? rawData
          : Map<String, dynamic>.from(rawData as Map);

      // ── Ekstrak teks AI secara langsung (tidak melalui fromJson) ──
      String aiText = '';

      // Struktur utama: { status, message, data: { consultation_result } }
      final innerData = jsonMap['data'];
      if (innerData != null && innerData is Map) {
        aiText = (innerData['consultation_result'] as String? ?? '').trim();
      }

      // Fallback jika struktur berbeda
      if (aiText.isEmpty) {
        aiText = jsonMap['response'] as String? ??
            jsonMap['answer'] as String? ??
            jsonMap['text'] as String? ??
            jsonMap['result'] as String? ??
            '';
      }

      print('[ConsultationService] ✅ Parsed AI text (${aiText.length} chars): '
          '${aiText.length > 80 ? '${aiText.substring(0, 80)}...' : aiText}');

      if (aiText.isEmpty) {
        throw Exception('AI tidak mengembalikan teks. Raw: $rawData');
      }

      return ConsultationResponse(
        response: aiText,
        sessionId: jsonMap['session_id'] as String?,
        raw: jsonMap,
      );
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final serverMessage = _extractErrorMessage(e.response?.data);

      if (statusCode == 401 || statusCode == 403) {
        throw Exception('Autentikasi AI gagal (HTTP $statusCode). Hubungi administrator.');
      } else if (statusCode == 422) {
        throw Exception('Data tidak valid: $serverMessage');
      } else if (statusCode != null && statusCode >= 500) {
        throw Exception('Server AI sedang bermasalah (HTTP $statusCode). Coba lagi nanti.');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Koneksi ke server AI timeout. Periksa koneksi internet Anda.');
      } else {
        throw Exception('Gagal menghubungi AI: ${e.message}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan tak terduga: $e');
    }
  }

  String _extractErrorMessage(dynamic responseData) {
    if (responseData is Map) {
      return responseData['message']?.toString() ??
          responseData['detail']?.toString() ??
          responseData['error']?.toString() ??
          'Unknown error';
    }
    return responseData?.toString() ?? 'Unknown error';
  }
}
