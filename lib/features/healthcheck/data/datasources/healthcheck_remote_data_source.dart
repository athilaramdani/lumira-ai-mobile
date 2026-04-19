import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';

abstract class HealthcheckRemoteDataSource {
  Future<Map<String, dynamic>> checkHealth();
}

class HealthcheckRemoteDataSourceImpl implements HealthcheckRemoteDataSource {
  final Dio _dio = ApiClient().dio;

  @override
  Future<Map<String, dynamic>> checkHealth() async {
    final response = await _dio.get(ApiConstants.health);
    return response.data;
  }
}
