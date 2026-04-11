import 'package:dio/dio.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late final Dio dio;

  // Sesuaikan constant ini jika ingin pindah ke server lokal/production
  static const String _baseUrl = 'http://10.0.2.2:8000'; // Gunakan 10.0.2.2 untuk emulator Android, localhost untuk iOS/Web, atau 'https://api.lumira.ai' untuk Production

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }
}

