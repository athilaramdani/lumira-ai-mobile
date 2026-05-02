import 'dart:io';
import 'package:dio/dio.dart';
import '../../domain/repositories/medical_records_repository.dart';
import '../datasources/medical_records_remote_data_source.dart';
import '../models/medical_record_model.dart';

class MedicalRecordsRepositoryImpl implements MedicalRecordsRepository {
  final MedicalRecordsRemoteDataSource remoteDataSource;

  MedicalRecordsRepositoryImpl({required this.remoteDataSource});

  Never _handleError(Object error) {
    if (error is DioException) {
      throw Exception(error.response?.data?['message'] ?? error.message);
    }
    throw Exception(error.toString());
  }

  @override
  Future<MedicalRecordModel> uploadMedicalRecord({
    required String patientId,
    required File image,
    void Function(int count, int total)? onProgress,
  }) async {
    try {
      return await remoteDataSource.uploadMedicalRecord(
        patientId: patientId, 
        image: image,
        onProgress: onProgress,
      );
    } catch (e) {
      _handleError(e);
    }
  }

  @override
  Future<void> reviewMedicalRecord({
    required String recordId,
    required String agreement,
    required String note,
    String? doctorDiagnosis,
    File? doctorBrushPath,
  }) async {
    try {
      await remoteDataSource.reviewMedicalRecord(
        recordId: recordId,
        agreement: agreement,
        note: note,
        doctorDiagnosis: doctorDiagnosis,
        doctorBrushPath: doctorBrushPath,
      );
    } catch (e) {
      _handleError(e);
    }
  }

  @override
  Future<void> editReviewMedicalRecord({
    required String recordId,
    required String agreement,
    required String note,
    String? doctorDiagnosis,
    File? doctorBrushPath,
  }) async {
    try {
      await remoteDataSource.editReviewMedicalRecord(
        recordId: recordId,
        agreement: agreement,
        note: note,
        doctorDiagnosis: doctorDiagnosis,
        doctorBrushPath: doctorBrushPath,
      );
    } catch (e) {
      _handleError(e);
    }
  }

  @override
  Future<MedicalRecordModel> reanalyzePatient(String patientId) async {
    try {
      return await remoteDataSource.reanalyzePatient(patientId);
    } catch (e) {
      _handleError(e);
    }
  }
}
