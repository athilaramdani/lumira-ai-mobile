import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../domain/repositories/auth_repository.dart';
import 'models/user_model.dart';

class AuthService implements AuthRepository {
  final Dio _dio = ApiClient().dio;

  /// Returns a map with 'accessToken' and 'refreshToken', or null if failed.
  Future<Map<String, String>?> login(String email, String password) async {
    try {
      final response = await _dio.post(ApiConstants.login, data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        final token = data['accessToken'] ?? data['token'];
        final refreshToken = data['refreshToken'];

        if (token != null) {
          return {
            'accessToken': token,
            if (refreshToken != null) 'refreshToken': refreshToken,
          };
        }
      }
      return null;
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? e.message ?? 'Login failed. Please check your credentials.';
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<UserModel?> getMe() async {
    try {
      final response = await _dio.get(ApiConstants.me);
      if (response.statusCode == 200) {
        final data = Map<String, dynamic>.from(response.data['data'] ?? response.data);
        
        // Extract role from JWT token because backend doesn't send it in /me
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        if (token != null) {
          try {
            final parts = token.split('.');
            if (parts.length == 3) {
              final normalized = base64Url.normalize(parts[1]);
              final decoded = utf8.decode(base64Url.decode(normalized));
              final payload = jsonDecode(decoded);
              data['role'] = payload['role'];
            }
          } catch (e) {
            print('Failed to decode token for role: $e');
          }
        }

        return UserModel.fromJson(data);
      }
      return null;
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? e.message ?? 'Failed to fetch user data.';
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post(ApiConstants.logout);
    } catch (e) {
      // Ignore errors on logout (e.g. if token is already expired)
      print('Logout API call failed or not needed: $e');
    }
  }
}
