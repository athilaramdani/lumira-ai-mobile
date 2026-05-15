import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late final Dio dio;

  // Read BASE_URL from .env file or fallback
  static final String _baseUrl = dotenv.env['BASE_URL'] ?? ApiConstants.baseUrl;

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // 1. Auth Interceptor (Must be first to add headers)
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        } catch (e) {
          debugPrint('[API Request] Error getting token: $e');
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          final prefs = await SharedPreferences.getInstance();
          final refreshToken = prefs.getString('refresh_token');

          if (refreshToken != null) {
            try {
              final refreshDio = Dio(BaseOptions(baseUrl: _baseUrl));
              final response = await refreshDio.post(
                ApiConstants.refresh,
                data: {'refreshToken': refreshToken},
              );

              if (response.statusCode == 200 || response.statusCode == 201) {
                final data = response.data['data'] ?? response.data;
                final newToken = data['accessToken'] ?? data['token'];

                if (newToken != null) {
                  await prefs.setString('auth_token', newToken);
                  e.requestOptions.headers['Authorization'] = 'Bearer $newToken';
                  final retryResponse = await dio.fetch(e.requestOptions);
                  return handler.resolve(retryResponse);
                }
              }
            } catch (refreshErr) {
              await prefs.remove('auth_token');
              await prefs.remove('refresh_token');
            }
          } else {
             await prefs.remove('auth_token');
          }
        }
        return handler.next(e);
      },
    ));

    // 2. Log Interceptor
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => debugPrint(obj.toString()),
    ));
  }
}
