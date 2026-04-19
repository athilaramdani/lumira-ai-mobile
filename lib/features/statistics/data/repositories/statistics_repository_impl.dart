import 'package:dio/dio.dart';
import '../../domain/repositories/statistics_repository.dart';
import '../datasources/statistics_remote_data_source.dart';
import '../models/statistic_model.dart';

class StatisticsRepositoryImpl implements StatisticsRepository {
  final StatisticsRemoteDataSource remoteDataSource;

  StatisticsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<StatisticModel> getDashboardStats() async {
    try {
      return await remoteDataSource.getDashboardStats();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load statistics');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getDoctorStats() async {
    try {
      return await remoteDataSource.getDoctorStats();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load doctor stats');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  @override
  Future<List<dynamic>> getActivities() async {
    try {
      return await remoteDataSource.getActivities();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load activities');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
