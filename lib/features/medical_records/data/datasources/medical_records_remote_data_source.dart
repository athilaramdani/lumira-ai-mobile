import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/medical_record_model.dart';

abstract class MedicalRecordsRemoteDataSource {
  Future<MedicalRecordModel> uploadMedicalRecord({
    required String patientId,
    required File image,
    void Function(int count, int total)? onProgress,
  });
  
  Future<void> reviewMedicalRecord({
    required String recordId,
    required String agreement,
    required String note,
    String? doctorDiagnosis,
    File? doctorBrushPath,
  });

  Future<void> editReviewMedicalRecord({
    required String recordId,
    required String agreement,
    required String note,
    String? doctorDiagnosis,
    File? doctorBrushPath,
  });
  
  Future<MedicalRecordModel> reanalyzePatient(String patientId);
}

class MedicalRecordsRemoteDataSourceImpl implements MedicalRecordsRemoteDataSource {
  final Dio _dio = ApiClient().dio;

  @override
  Future<MedicalRecordModel> uploadMedicalRecord({
    required String patientId,
    required File image,
    void Function(int count, int total)? onProgress,
  }) async {
    String fileName = image.path.split('/').last;
    
    FormData formData = FormData.fromMap({
      "patient_id": patientId,
      "image": await MultipartFile.fromFile(image.path, filename: fileName),
    });

    final response = await _dio.post(
      ApiConstants.uploadMedicalRecord,
      data: formData,
      onSendProgress: onProgress,
    );
    
    final data = response.data['data'] ?? response.data;
    return MedicalRecordModel.fromJson(data);
  }

  Future<FormData> _buildReviewFormData({
    required String agreement,
    required String note,
    String? doctorDiagnosis,
    File? doctorBrushPath,
  }) async {
    final map = <String, dynamic>{
      "agreement": agreement,
      "note": note,
    };
    if (doctorDiagnosis != null) {
      map["doctorDiagnosis"] = doctorDiagnosis;
    }
    FormData formData = FormData.fromMap(map);
    if (doctorBrushPath != null) {
      String fileName = doctorBrushPath.path.split('/').last;
      formData.files.add(MapEntry(
        "doctorBrushPath",
        await MultipartFile.fromFile(doctorBrushPath.path, filename: fileName),
      ));
    }
    return formData;
  }

  @override
  Future<void> reviewMedicalRecord({
    required String recordId,
    required String agreement,
    required String note,
    String? doctorDiagnosis,
    File? doctorBrushPath,
  }) async {
    final formData = await _buildReviewFormData(
      agreement: agreement,
      note: note,
      doctorDiagnosis: doctorDiagnosis,
      doctorBrushPath: doctorBrushPath,
    );
    await _dio.post(
      ApiConstants.reviewMedicalRecord(recordId),
      data: formData,
    );
  }

  @override
  Future<void> editReviewMedicalRecord({
    required String recordId,
    required String agreement,
    required String note,
    String? doctorDiagnosis,
    File? doctorBrushPath,
  }) async {
    final formData = await _buildReviewFormData(
      agreement: agreement,
      note: note,
      doctorDiagnosis: doctorDiagnosis,
      doctorBrushPath: doctorBrushPath,
    );
    await _dio.patch(
      ApiConstants.reviewMedicalRecord(recordId),
      data: formData,
    );
  }

  @override
  Future<MedicalRecordModel> reanalyzePatient(String patientId) async {
    final response = await _dio.post(ApiConstants.reanalyzePatient(patientId));
    final data = response.data['data'] ?? response.data;
    return MedicalRecordModel.fromJson(data);
  }
}
