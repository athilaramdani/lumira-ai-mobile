import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/medical_records_remote_data_source.dart';
import '../../data/repositories/medical_records_repository_impl.dart';
import '../../domain/repositories/medical_records_repository.dart';
import '../../domain/usecases/medical_records_usecases.dart';
import '../../data/models/medical_record_model.dart';

// Providers
final medicalRecordsRemoteDataSourceProvider = Provider<MedicalRecordsRemoteDataSource>((ref) {
  return MedicalRecordsRemoteDataSourceImpl();
});

final medicalRecordsRepositoryProvider = Provider<MedicalRecordsRepository>((ref) {
  final dataSource = ref.watch(medicalRecordsRemoteDataSourceProvider);
  return MedicalRecordsRepositoryImpl(remoteDataSource: dataSource);
});

final uploadMedicalRecordUseCaseProvider = Provider((ref) => UploadMedicalRecordUseCase(ref.watch(medicalRecordsRepositoryProvider)));
final reviewMedicalRecordUseCaseProvider = Provider((ref) => ReviewMedicalRecordUseCase(ref.watch(medicalRecordsRepositoryProvider)));
final editReviewMedicalRecordUseCaseProvider = Provider((ref) => EditReviewMedicalRecordUseCase(ref.watch(medicalRecordsRepositoryProvider)));
final reanalyzePatientUseCaseProvider = Provider((ref) => ReanalyzePatientUseCase(ref.watch(medicalRecordsRepositoryProvider)));

// State
class MedicalRecordsState {
  final bool isLoading;
  final String? error;
  final MedicalRecordModel? currentRecord;
  final double uploadProgress;

  MedicalRecordsState({
    this.isLoading = false,
    this.error,
    this.currentRecord,
    this.uploadProgress = 0.0,
  });

  MedicalRecordsState copyWith({
    bool? isLoading,
    String? error,
    MedicalRecordModel? currentRecord,
    double? uploadProgress,
  }) {
    return MedicalRecordsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentRecord: currentRecord ?? this.currentRecord,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }
}

class MedicalRecordsController extends StateNotifier<MedicalRecordsState> {
  final UploadMedicalRecordUseCase _uploadMedicalRecord;
  final ReviewMedicalRecordUseCase _reviewMedicalRecord;
  final EditReviewMedicalRecordUseCase _editReviewMedicalRecord;
  final ReanalyzePatientUseCase _reanalyzePatient;

  MedicalRecordsController({
    required UploadMedicalRecordUseCase uploadMedicalRecord,
    required ReviewMedicalRecordUseCase reviewMedicalRecord,
    required EditReviewMedicalRecordUseCase editReviewMedicalRecord,
    required ReanalyzePatientUseCase reanalyzePatient,
  })  : _uploadMedicalRecord = uploadMedicalRecord,
        _reviewMedicalRecord = reviewMedicalRecord,
        _editReviewMedicalRecord = editReviewMedicalRecord,
        _reanalyzePatient = reanalyzePatient,
        super(MedicalRecordsState());

  Future<bool> uploadMedicalRecord({
    required String patientId,
    required File image,
  }) async {
    state = state.copyWith(isLoading: true, error: null, uploadProgress: 0.0);
    try {
      final record = await _uploadMedicalRecord(
        patientId: patientId,
        image: image,
        onProgress: (count, total) {
          state = state.copyWith(uploadProgress: count / total);
        },
      );
      state = state.copyWith(isLoading: false, currentRecord: record);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// POST - submit new review (when status is "Review Needed")
  Future<bool> reviewMedicalRecord({
    required String recordId,
    required String agreement,
    required String note,
    String? doctorDiagnosis,
    File? doctorBrushPath,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _reviewMedicalRecord(
        recordId: recordId,
        agreement: agreement,
        note: note,
        doctorDiagnosis: doctorDiagnosis,
        doctorBrushPath: doctorBrushPath,
      );
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// PATCH - edit existing review (when status is "Done")
  Future<bool> editReviewMedicalRecord({
    required String recordId,
    required String agreement,
    required String note,
    String? doctorDiagnosis,
    File? doctorBrushPath,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _editReviewMedicalRecord(
        recordId: recordId,
        agreement: agreement,
        note: note,
        doctorDiagnosis: doctorDiagnosis,
        doctorBrushPath: doctorBrushPath,
      );
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> reanalyzePatient(String patientId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final record = await _reanalyzePatient(patientId);
      state = state.copyWith(isLoading: false, currentRecord: record);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final medicalRecordsControllerProvider = StateNotifierProvider<MedicalRecordsController, MedicalRecordsState>((ref) {
  return MedicalRecordsController(
    uploadMedicalRecord: ref.watch(uploadMedicalRecordUseCaseProvider),
    reviewMedicalRecord: ref.watch(reviewMedicalRecordUseCaseProvider),
    editReviewMedicalRecord: ref.watch(editReviewMedicalRecordUseCaseProvider),
    reanalyzePatient: ref.watch(reanalyzePatientUseCaseProvider),
  );
});
