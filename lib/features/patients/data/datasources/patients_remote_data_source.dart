import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/patient_model.dart';

abstract class PatientsRemoteDataSource {
  Future<List<PatientModel>> getPatients();
  Future<PatientModel> getPatientById(String id);
  Future<PatientModel> createPatient(Map<String, dynamic> data);
  Future<PatientModel> updatePatient(String id, Map<String, dynamic> data);
  Future<void> deletePatient(String id);
}

class PatientsRemoteDataSourceImpl implements PatientsRemoteDataSource {
  final Dio _dio = ApiClient().dio;

  @override
  Future<List<PatientModel>> getPatients() async {
    final response = await _dio.get(ApiConstants.patients);
    final data = response.data['data'] as List;
    return data.map((json) => PatientModel.fromJson(json)).toList();
  }

  @override
  Future<PatientModel> getPatientById(String id) async {
    final response = await _dio.get('${ApiConstants.patients}/$id');
    return PatientModel.fromJson(response.data['data']);
  }

  @override
  Future<PatientModel> createPatient(Map<String, dynamic> data) async {
    final response = await _dio.post(ApiConstants.patients, data: data);
    return PatientModel.fromJson(response.data['data']);
  }

  @override
  Future<PatientModel> updatePatient(String id, Map<String, dynamic> data) async {
    final response = await _dio.patch('${ApiConstants.patients}/$id', data: data); // or PUT
    return PatientModel.fromJson(response.data['data']);
  }

  @override
  Future<void> deletePatient(String id) async {
    await _dio.delete('${ApiConstants.patients}/$id');
  }
}
