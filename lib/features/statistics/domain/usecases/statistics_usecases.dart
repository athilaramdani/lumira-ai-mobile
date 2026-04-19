import '../repositories/statistics_repository.dart';
import '../../data/models/statistic_model.dart';

class GetDashboardStatsUseCase {
  final StatisticsRepository repository;
  GetDashboardStatsUseCase(this.repository);

  Future<StatisticModel> call() async {
    return await repository.getDashboardStats();
  }
}

class GetDoctorStatsUseCase {
  final StatisticsRepository repository;
  GetDoctorStatsUseCase(this.repository);

  Future<Map<String, dynamic>> call() async {
    return await repository.getDoctorStats();
  }
}

class GetActivitiesUseCase {
  final StatisticsRepository repository;
  GetActivitiesUseCase(this.repository);

  Future<List<dynamic>> call() async {
    return await repository.getActivities();
  }
}
