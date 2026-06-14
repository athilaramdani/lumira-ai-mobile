import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:lumira_ai_mobile/features/ai_chatbot/data/models/consultation_model.dart';

/// Service untuk berkomunikasi dengan AI consultation endpoint via SSE Streaming.
///
/// Endpoint  : POST https://<host>/consultations/stream
/// Auth      : Bearer XiueX_Lumira+MedWTelU  (static key – bukan token user)
/// Body      : { user, user_prompt, chat_history, image? }
///
/// Response  : Server-Sent Events (SSE)
///   data: {"token": "..."}                        — setiap token yang digenerate
///   event: done\ndata: {"status":"done","profiling":{...}}  — selesai
///   event: error\ndata: {"error":"...","message":"..."}     — jika terjadi error
class ConsultationService {
  /// Fallback URL jika MEDGEMMA_BASE_URL tidak diset di .env
  static const String _defaultBaseUrl =
      'https://tablet-pending-byte-julian.trycloudflare.com';

  static const String _apiToken = 'XiueX_Lumira+MedWTelU';
  static const String _streamEndpoint = '/consultations/stream';

  String get _baseUrl {
    return dotenv.env['MEDGEMMA_BASE_URL']?.trim().isNotEmpty == true
        ? dotenv.env['MEDGEMMA_BASE_URL']!.trim()
        : dotenv.env['BASE_URL']?.trim().isNotEmpty == true
            ? dotenv.env['BASE_URL']!.trim()
            : _defaultBaseUrl;
  }

  /// Stream token SSE dari AI.
  ///
  /// Mengembalikan [Stream<String>] yang menghasilkan teks secara incremental.
  /// Stream selesai ketika event `done` diterima dari server.
  /// Stream error ketika event `error` diterima atau koneksi gagal.
  ///
  /// [user]        – role pengirim, misal 'Patient'
  /// [userPrompt]  – pesan terbaru dari user
  /// [chatHistory] – riwayat percakapan sebelumnya
  /// [imageUrl]    – URL gambar scan/X-ray (opsional)
  Stream<String> streamConsultation({
    required String user,
    required String userPrompt,
    required List<ChatHistoryEntry> chatHistory,
    String? imageUrl,
  }) async* {
    final request = ConsultationRequest(
      user: user,
      userPrompt: userPrompt,
      chatHistory: chatHistory,
      image: imageUrl,
    );

    final uri = Uri.parse('$_baseUrl$_streamEndpoint');
    final body = jsonEncode(request.toJson());

    print('[ConsultationService] 🔄 Streaming request ke: $uri');

    http.Client? client;
    try {
      client = http.Client();
      final httpRequest = http.Request('POST', uri);
      httpRequest.headers.addAll({
        'Authorization': 'Bearer $_apiToken',
        'Content-Type': 'application/json',
        'Accept': 'text/event-stream',
        'Cache-Control': 'no-cache',
      });
      httpRequest.body = body;

      final streamedResponse = await client.send(httpRequest).timeout(
        const Duration(seconds: 60),
        onTimeout: () => throw TimeoutException(
          'Koneksi ke server AI timeout setelah 60 detik.',
        ),
      );

      if (streamedResponse.statusCode != 200) {
        final responseBody = await streamedResponse.stream.bytesToString();
        throw _parseHttpError(streamedResponse.statusCode, responseBody);
      }

      print('[ConsultationService] ✅ SSE connection established (HTTP ${streamedResponse.statusCode})');

      // Buffer untuk menampung data SSE yang belum lengkap antar chunk
      final StringBuffer buffer = StringBuffer();

      await for (final chunk in streamedResponse.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())) {
        buffer.write(chunk);
        buffer.write('\n');

        final bufferContent = buffer.toString();
        // SSE message diakhiri dengan dua newline berturut-turut
        if (bufferContent.endsWith('\n\n') ||
            bufferContent.contains('\n\n')) {
          final rawMessages = bufferContent.split('\n\n');
          // Process semua message yang sudah lengkap, kecuali fragmen terakhir
          for (int i = 0; i < rawMessages.length - 1; i++) {
            final msg = rawMessages[i].trim();
            if (msg.isEmpty) continue;

            final result = _parseSseMessage(msg);
            if (result == null) continue;

            if (result.isError) {
              throw Exception(result.errorMessage);
            }
            if (result.isDone) {
              print('[ConsultationService] ✅ Stream selesai. Profiling: ${result.profiling}');
              return; // Stream selesai
            }
            if (result.token != null && result.token!.isNotEmpty) {
              yield result.token!;
            }
          }

          // Simpan fragmen terakhir yang belum lengkap ke buffer baru
          buffer.clear();
          if (rawMessages.last.isNotEmpty) {
            buffer.write(rawMessages.last);
          }
        }
      }
    } on TimeoutException catch (e) {
      throw Exception('Koneksi ke server AI timeout. Periksa koneksi internet Anda. ($e)');
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('Terjadi kesalahan tak terduga saat streaming: $e');
    } finally {
      client?.close();
    }
  }

  /// Parse satu SSE message (bisa berisi satu atau beberapa field: event, data)
  _SseResult? _parseSseMessage(String rawMessage) {
    String? eventType;
    String? dataLine;

    for (final line in rawMessage.split('\n')) {
      if (line.startsWith('event:')) {
        eventType = line.substring('event:'.length).trim();
      } else if (line.startsWith('data:')) {
        dataLine = line.substring('data:'.length).trim();
      }
    }

    if (dataLine == null || dataLine.isEmpty) return null;

    try {
      final json = jsonDecode(dataLine) as Map<String, dynamic>;

      if (eventType == 'error') {
        final message = json['message']?.toString() ?? json['error']?.toString() ?? 'Unknown error';
        return _SseResult.error(message);
      }

      if (eventType == 'done') {
        return _SseResult.done(json['profiling'] as Map<String, dynamic>?);
      }

      // Token normal (tidak ada event type, atau event type tidak diketahui)
      final token = json['token'] as String?;
      if (token != null) {
        return _SseResult.token(token);
      }
    } catch (e) {
      print('[ConsultationService] ⚠️ Gagal parse SSE data: $dataLine ($e)');
    }
    return null;
  }

  Exception _parseHttpError(int statusCode, String body) {
    String message = 'Unknown error';
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      message = json['message']?.toString() ??
          json['detail']?.toString() ??
          json['error']?.toString() ??
          body;
    } catch (_) {
      message = body.isNotEmpty ? body : 'HTTP $statusCode';
    }

    if (statusCode == 401 || statusCode == 403) {
      return Exception('Autentikasi AI gagal (HTTP $statusCode). Hubungi administrator.');
    } else if (statusCode == 422) {
      return Exception('Data tidak valid: $message');
    } else if (statusCode >= 500) {
      return Exception('Server AI sedang bermasalah (HTTP $statusCode). Coba lagi nanti.');
    }
    return Exception('Gagal menghubungi AI (HTTP $statusCode): $message');
  }

  /// Hapus baris duplikat yang berurutan – gejala model looping.
  String removeDuplicateLines(String text) {
    final lines = text.split('\n');
    final result = <String>[];
    String? prevNormalized;

    for (final line in lines) {
      final normalized = line
          .replaceFirst(RegExp(r'^\s*(\d+\.|[-*•])\s*'), '')
          .trim()
          .toLowerCase();

      if (normalized.isEmpty) {
        result.add(line);
        prevNormalized = null;
        continue;
      }

      if (normalized != prevNormalized) {
        result.add(line);
        prevNormalized = normalized;
      }
    }

    return result.join('\n');
  }

  /// Bersihkan teks dari thought process dan duplikasi
  String cleanAiText(String text) {
    // Hapus blok thought process
    text = text.replaceAll(
        RegExp(r'<unused94>thought[\s\S]*?(?:</unused94>|<unused94>|$)'), '');
    text = text.replaceAll(RegExp(r'<think>[\s\S]*?(?:</think>|$)'), '');
    text = text.trim();

    // Hapus duplikasi baris
    text = removeDuplicateLines(text);
    return text.trim();
  }
}

/// Representasi internal satu SSE message yang telah diparsing.
class _SseResult {
  final String? token;
  final bool isDone;
  final bool isError;
  final String? errorMessage;
  final Map<String, dynamic>? profiling;

  const _SseResult._({
    this.token,
    this.isDone = false,
    this.isError = false,
    this.errorMessage,
    this.profiling,
  });

  factory _SseResult.token(String token) => _SseResult._(token: token);
  factory _SseResult.done(Map<String, dynamic>? profiling) =>
      _SseResult._(isDone: true, profiling: profiling);
  factory _SseResult.error(String message) =>
      _SseResult._(isError: true, errorMessage: message);
}
