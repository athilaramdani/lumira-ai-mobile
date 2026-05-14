import '../repositories/patients_repository.dart';
import '../../data/models/patient_model.dart';

class GetPatientsUseCase {
  final PatientsRepository repository;
  GetPatientsUseCase(this.repository);

  Future<List<PatientModel>> call({int page = 1, int limit = 100}) async {
    return await repository.getPatients(page: page, limit: limit);
  }
}

class GetPatientByIdUseCase {
  final PatientsRepository repository;
  GetPatientByIdUseCase(this.repository);

  Future<PatientModel> call(String id) async {
    return await repository.getPatientById(id);
  }
}

class CreatePatientUseCase {
  final PatientsRepository repository;
  CreatePatientUseCase(this.repository);

  Future<PatientModel> call(Map<String, dynamic> data) async {
    return await repository.createPatient(data);
  }
}

class UpdatePatientUseCase {
  final PatientsRepository repository;
  UpdatePatientUseCase(this.repository);

  Future<PatientModel> call(String id, Map<String, dynamic> data) async {
    return await repository.updatePatient(id, data);
  }
}

class DeletePatientUseCase {
  final PatientsRepository repository;
  DeletePatientUseCase(this.repository);

  Future<void> call(String id) async {
    return await repository.deletePatient(id);
  }
}
