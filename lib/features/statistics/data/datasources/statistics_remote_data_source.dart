import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/statistic_model.dart';

abstract class StatisticsRemoteDataSource {
  Future<StatisticModel> getDashboardStats();
  Future<Map<String, dynamic>> getDoctorStats();
  Future<List<dynamic>> getActivities();
}

class StatisticsRemoteDataSourceImpl implements StatisticsRemoteDataSource {
  final Dio _dio = ApiClient().dio;

  @override
  Future<StatisticModel> getDashboardStats() async {
    final response = await _dio.get(ApiConstants.statsDashboard);
    return StatisticModel.fromJson(response.data['data'] ?? response.data);
  }

  @override
  Future<Map<String, dynamic>> getDoctorStats() async {
    final response = await _dio.get(ApiConstants.statsDoctor);
    return response.data['data'] ?? response.data;
  }

  @override
  Future<List<dynamic>> getActivities() async {
    final response = await _dio.get(ApiConstants.activities);
    return response.data['data'] ?? [];
  }
}
