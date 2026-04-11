import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class AuthService {
  final Dio _dio = ApiClient().dio;

  Future<String?> login(String email, String password) async {
    try {
      final response = await _dio.post('/api/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        // TODO: Sesuaikan key respons sesuai json response backend Anda (misal 'token', 'data.token')
        final token = response.data['token'] ?? response.data['data']?['token'];
        return token;
      }
      return null;
    } on DioException catch (e) {
      // Mengambil pesan error dari backend jika ada, atau default pesan
      final errorMessage = e.response?.data?['message'] ?? e.message ?? 'Login failed. Please check your credentials.';
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
