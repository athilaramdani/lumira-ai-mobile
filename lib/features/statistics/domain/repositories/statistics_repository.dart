import '../../data/models/statistic_model.dart';

abstract class StatisticsRepository {
  Future<StatisticModel> getDashboardStats();
  Future<Map<String, dynamic>> getDoctorStats();
  Future<List<dynamic>> getActivities();
}
