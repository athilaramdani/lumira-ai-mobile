import 'dart:io';
import '../repositories/medical_records_repository.dart';
import '../../data/models/medical_record_model.dart';

class UploadMedicalRecordUseCase {
  final MedicalRecordsRepository repository;
  UploadMedicalRecordUseCase(this.repository);

  Future<MedicalRecordModel> call({
    required String patientId,
    required File image,
    void Function(int, int)? onProgress,
  }) async {
    return await repository.uploadMedicalRecord(
      patientId: patientId,
      image: image,
      onProgress: onProgress,
    );
  }
}

class ReviewMedicalRecordUseCase {
  final MedicalRecordsRepository repository;
  ReviewMedicalRecordUseCase(this.repository);

  Future<void> call({
    required String recordId,
    required String agreement,
    required String note,
    String? doctorDiagnosis,
    File? doctorBrushPath,
  }) async {
    return await repository.reviewMedicalRecord(
      recordId: recordId,
      agreement: agreement,
      note: note,
      doctorDiagnosis: doctorDiagnosis,
      doctorBrushPath: doctorBrushPath,
    );
  }
}

class EditReviewMedicalRecordUseCase {
  final MedicalRecordsRepository repository;
  EditReviewMedicalRecordUseCase(this.repository);

  Future<void> call({
    required String recordId,
    required String agreement,
    required String note,
    String? doctorDiagnosis,
    File? doctorBrushPath,
  }) async {
    return await repository.editReviewMedicalRecord(
      recordId: recordId,
      agreement: agreement,
      note: note,
      doctorDiagnosis: doctorDiagnosis,
      doctorBrushPath: doctorBrushPath,
    );
  }
}

class ReanalyzePatientUseCase {
  final MedicalRecordsRepository repository;
  ReanalyzePatientUseCase(this.repository);

  Future<MedicalRecordModel> call(String patientId) async {
    return await repository.reanalyzePatient(patientId);
  }
}
