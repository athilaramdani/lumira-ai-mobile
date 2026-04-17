import '../repositories/healthcheck_repository.dart';

class CheckHealthUseCase {
  final HealthcheckRepository repository;
  CheckHealthUseCase(this.repository);

  Future<Map<String, dynamic>> call() async {
    return await repository.checkHealth();
  }
}
