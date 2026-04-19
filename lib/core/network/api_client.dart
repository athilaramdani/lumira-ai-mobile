import 'package:dio/dio.dart';
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
      logPrint: (obj) => print(obj.toString()),
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          // Attempt to refresh token
          final prefs = await SharedPreferences.getInstance();
          final refreshToken = prefs.getString('refresh_token');

          if (refreshToken != null) {
            try {
              // Call refresh endpoint using a new Dio instance to avoid interceptor loop
              final refreshDio = Dio(BaseOptions(baseUrl: _baseUrl));
              final response = await refreshDio.post(
                ApiConstants.refresh,
                data: {'refreshToken': refreshToken},
              );

              if (response.statusCode == 200 || response.statusCode == 201) {
                final newToken = response.data['data']?['accessToken'] ??
                                 response.data['accessToken'] ?? 
                                 response.data['token'];

                if (newToken != null) {
                  await prefs.setString('auth_token', newToken);

                  // Update the request with the new token
                  e.requestOptions.headers['Authorization'] = 'Bearer $newToken';

                  // Retry the request
                  final retryResponse = await dio.fetch(e.requestOptions);
                  return handler.resolve(retryResponse);
                }
              }
            } catch (refreshErr) {
              // Refresh failed, clear tokens and let the 401 error pass through to be handled by UI
              await prefs.remove('auth_token');
              await prefs.remove('refresh_token');
            }
          } else {
             // No refresh token available, clear any stale auth_token
             await prefs.remove('auth_token');
          }
        }
        return handler.next(e);
      },
    ));
  }
}
