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

  Future<void> call(String recordId, String doctorNotes, String status) async {
    return await repository.reviewMedicalRecord(recordId, doctorNotes, status);
  }
}

class ReanalyzePatientUseCase {
  final MedicalRecordsRepository repository;
  ReanalyzePatientUseCase(this.repository);

  Future<MedicalRecordModel> call(String patientId) async {
    return await repository.reanalyzePatient(patientId);
  }
}
