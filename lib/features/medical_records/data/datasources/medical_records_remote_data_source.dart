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
    File? heatmapImage,
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

  @override
  Future<void> reviewMedicalRecord({
    required String recordId,
    required String agreement,
    required String note,
    File? heatmapImage,
  }) async {
    FormData formData = FormData.fromMap({
      "agreement": agreement,
      "note": note,
    });

    if (heatmapImage != null) {
      String fileName = heatmapImage.path.split('/').last;
      formData.files.add(MapEntry(
        "heatmapImage",
        await MultipartFile.fromFile(heatmapImage.path, filename: fileName),
      ));
    }

    await _dio.post(
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
