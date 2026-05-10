import '../../data/models/patient_model.dart';

abstract class PatientsRepository {
  Future<List<PatientModel>> getPatients({int page = 1, int limit = 100});
  Future<PatientModel> getPatientById(String id);
  Future<PatientModel> createPatient(Map<String, dynamic> data);
  Future<PatientModel> updatePatient(String id, Map<String, dynamic> data);
  Future<void> deletePatient(String id);
}
