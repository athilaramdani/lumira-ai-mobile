import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/healthcheck_remote_data_source.dart';
import '../../data/repositories/healthcheck_repository_impl.dart';
import '../../domain/repositories/healthcheck_repository.dart';
import '../../domain/usecases/healthcheck_usecases.dart';

// Providers
final healthcheckRemoteDataSourceProvider = Provider<HealthcheckRemoteDataSource>((ref) {
  return HealthcheckRemoteDataSourceImpl();
});

final healthcheckRepositoryProvider = Provider<HealthcheckRepository>((ref) {
  final dataSource = ref.watch(healthcheckRemoteDataSourceProvider);
  return HealthcheckRepositoryImpl(remoteDataSource: dataSource);
});

final checkHealthUseCaseProvider = Provider((ref) {
  return CheckHealthUseCase(ref.watch(healthcheckRepositoryProvider));
});

// State
class HealthcheckState {
  final bool isLoading;
  final String? error;
  final bool isHealthy;

  HealthcheckState({
    this.isLoading = false,
    this.error,
    this.isHealthy = false,
  });

  HealthcheckState copyWith({
    bool? isLoading,
    String? error,
    bool? isHealthy,
  }) {
    return HealthcheckState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isHealthy: isHealthy ?? this.isHealthy,
    );
  }
}

class HealthcheckController extends StateNotifier<HealthcheckState> {
  final CheckHealthUseCase _checkHealth;

  HealthcheckController({required CheckHealthUseCase checkHealth})
      : _checkHealth = checkHealth,
        super(HealthcheckState());

  Future<bool> runHealthcheck() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _checkHealth();
      state = state.copyWith(isLoading: false, isHealthy: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString(), isHealthy: false);
      return false;
    }
  }
}

final healthcheckControllerProvider = StateNotifierProvider<HealthcheckController, HealthcheckState>((ref) {
  return HealthcheckController(
    checkHealth: ref.watch(checkHealthUseCaseProvider),
  );
});
