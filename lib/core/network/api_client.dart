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

    // 1. Auth Interceptor
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          // Always attach token if we have one — server decides if it's valid
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        } catch (e) {
          debugPrint('[API] Error attaching token: $e');
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        // Only attempt token refresh on 401 Unauthorized
        if (e.response?.statusCode == 401) {
          debugPrint('[API] Got 401 — attempting token refresh...');
          final prefs = await SharedPreferences.getInstance();
          final refreshToken = prefs.getString('refresh_token');

          if (refreshToken != null && refreshToken.isNotEmpty) {
            try {
              final refreshDio = Dio(BaseOptions(baseUrl: _baseUrl));
              final response = await refreshDio.post(
                ApiConstants.refresh,
                data: {'refreshToken': refreshToken},
              );

              if (response.statusCode == 200 || response.statusCode == 201) {
                final data = response.data['data'] ?? response.data;
                final newToken = data['accessToken'] ?? data['token'];
                final newRefresh = data['refreshToken'];

                if (newToken != null) {
                  // Save new tokens
                  await prefs.setString('auth_token', newToken);
                  if (newRefresh != null) {
                    await prefs.setString('refresh_token', newRefresh);
                  }
                  // Retry original request with new token
                  e.requestOptions.headers['Authorization'] = 'Bearer $newToken';
                  debugPrint('[API] Token refreshed — retrying request...');
                  final retryResponse = await dio.fetch(e.requestOptions);
                  return handler.resolve(retryResponse);
                }
              }
            } catch (refreshErr) {
              debugPrint('[API] Refresh also failed: $refreshErr');
            }
          }

          // All refresh attempts failed — clear credentials so user must re-login
          debugPrint('[API] Clearing credentials — user must re-login.');
          await prefs.remove('auth_token');
          await prefs.remove('refresh_token');
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
