import 'dart:io';
import '../../data/models/medical_record_model.dart';

abstract class MedicalRecordsRepository {
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
