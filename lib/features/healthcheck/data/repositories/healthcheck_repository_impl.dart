import 'package:dio/dio.dart';
import '../../domain/repositories/healthcheck_repository.dart';
import '../datasources/healthcheck_remote_data_source.dart';

class HealthcheckRepositoryImpl implements HealthcheckRepository {
  final HealthcheckRemoteDataSource remoteDataSource;

  HealthcheckRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Map<String, dynamic>> checkHealth() async {
    try {
      return await remoteDataSource.checkHealth();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to check health');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
