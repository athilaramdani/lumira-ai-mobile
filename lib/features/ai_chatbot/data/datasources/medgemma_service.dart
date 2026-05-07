import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MedgemmaService {
  late GenerativeModel _model;
  late ChatSession _chatSession;

  MedgemmaService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY is not defined in .env file');
    }

    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      systemInstruction: Content.system('You are MedGemma AI, an advanced medical AI assistant created to help patients understand their medical screening results, particularly mammograms. You are professional, empathetic, and knowledgeable. You always clarify that you are an AI and not a substitute for a real doctor, but you provide helpful context about medical terms, standard procedures, and what certain findings (like "increased density" or "benign cysts") typically mean.'),
    );

    _chatSession = _model.startChat();
  }

  Future<String> sendMessage(String message) async {
    try {
      final response = await _chatSession.sendMessage(Content.text(message));
      return response.text ?? 'Maaf, saya tidak dapat merespons saat ini.';
    } catch (e) {
      print('MedGemma AI Error: $e');
      return 'Terjadi kesalahan saat terhubung ke AI. Pastikan API Key Anda sudah benar dan koneksi internet stabil.';
    }
  }
}
