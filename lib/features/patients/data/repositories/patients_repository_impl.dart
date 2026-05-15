import 'package:dio/dio.dart';
import '../../domain/repositories/patients_repository.dart';
import '../datasources/patients_remote_data_source.dart';
import '../models/patient_model.dart';

class PatientsRepositoryImpl implements PatientsRepository {
  final PatientsRemoteDataSource remoteDataSource;

  PatientsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<PatientModel>> getPatients({int page = 1, int limit = 100}) async {
    try {
      return await remoteDataSource.getPatients(page: page, limit: limit);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load patients');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  @override
  Future<PatientModel> getPatientById(String id) async {
    try {
      return await remoteDataSource.getPatientById(id);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to get patient');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  @override
  Future<PatientModel> createPatient(Map<String, dynamic> data) async {
    try {
      return await remoteDataSource.createPatient(data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to create patient');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  @override
  Future<PatientModel> updatePatient(String id, Map<String, dynamic> data) async {
    try {
      return await remoteDataSource.updatePatient(id, data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to update patient');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  @override
  Future<void> deletePatient(String id) async {
    try {
      await remoteDataSource.deletePatient(id);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to delete patient');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
