import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/statistics_remote_data_source.dart';
import '../../data/repositories/statistics_repository_impl.dart';
import '../../domain/repositories/statistics_repository.dart';
import '../../domain/usecases/statistics_usecases.dart';
import '../../data/models/statistic_model.dart';

// Providers
final statisticsRemoteDataSourceProvider = Provider<StatisticsRemoteDataSource>((ref) {
  return StatisticsRemoteDataSourceImpl();
});

final statisticsRepositoryProvider = Provider<StatisticsRepository>((ref) {
  final dataSource = ref.watch(statisticsRemoteDataSourceProvider);
  return StatisticsRepositoryImpl(remoteDataSource: dataSource);
});

final getDashboardStatsUseCaseProvider = Provider((ref) {
  return GetDashboardStatsUseCase(ref.watch(statisticsRepositoryProvider));
});

final getDoctorStatsUseCaseProvider = Provider((ref) {
  return GetDoctorStatsUseCase(ref.watch(statisticsRepositoryProvider));
});

final getActivitiesUseCaseProvider = Provider((ref) {
  return GetActivitiesUseCase(ref.watch(statisticsRepositoryProvider));
});

// State
class StatisticsState {
  final bool isLoading;
  final String? error;
  final StatisticModel? stats;
  final Map<String, dynamic>? doctorStats;
  final List<dynamic> activities;

  StatisticsState({
    this.isLoading = false,
    this.error,
    this.stats,
    this.doctorStats,
    this.activities = const [],
  });

  StatisticsState copyWith({
    bool? isLoading,
    String? error,
    StatisticModel? stats,
    Map<String, dynamic>? doctorStats,
    List<dynamic>? activities,
  }) {
    return StatisticsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      stats: stats ?? this.stats,
      doctorStats: doctorStats ?? this.doctorStats,
      activities: activities ?? this.activities,
    );
  }
}

class StatisticsController extends StateNotifier<StatisticsState> {
  final GetDashboardStatsUseCase _getDashboardStats;
  final GetDoctorStatsUseCase _getDoctorStats;
  final GetActivitiesUseCase _getActivities;

  StatisticsController({
    required GetDashboardStatsUseCase getDashboardStats,
    required GetDoctorStatsUseCase getDoctorStats,
    required GetActivitiesUseCase getActivities,
  })  : _getDashboardStats = getDashboardStats,
        _getDoctorStats = getDoctorStats,
        _getActivities = getActivities,
        super(StatisticsState());

  Future<void> fetchDashboardStats() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final stats = await _getDashboardStats();
      state = state.copyWith(isLoading: false, stats: stats);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchDoctorStats() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final doctorStats = await _getDoctorStats();
      state = state.copyWith(isLoading: false, doctorStats: doctorStats);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchActivities() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final activities = await _getActivities();
      state = state.copyWith(isLoading: false, activities: activities);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final statisticsControllerProvider = StateNotifierProvider<StatisticsController, StatisticsState>((ref) {
  return StatisticsController(
    getDashboardStats: ref.watch(getDashboardStatsUseCaseProvider),
    getDoctorStats: ref.watch(getDoctorStatsUseCaseProvider),
    getActivities: ref.watch(getActivitiesUseCaseProvider),
  );
});
