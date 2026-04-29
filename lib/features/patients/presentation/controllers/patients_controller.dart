import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/patients_remote_data_source.dart';
import '../../data/repositories/patients_repository_impl.dart';
import '../../domain/repositories/patients_repository.dart';
import '../../domain/usecases/patients_usecases.dart';
import '../../data/models/patient_model.dart';

// Providers
final patientsRemoteDataSourceProvider = Provider<PatientsRemoteDataSource>((ref) {
  return PatientsRemoteDataSourceImpl();
});

final patientsRepositoryProvider = Provider<PatientsRepository>((ref) {
  final dataSource = ref.watch(patientsRemoteDataSourceProvider);
  return PatientsRepositoryImpl(remoteDataSource: dataSource);
});

final getPatientsUseCaseProvider = Provider((ref) => GetPatientsUseCase(ref.watch(patientsRepositoryProvider)));
final getPatientByIdUseCaseProvider = Provider((ref) => GetPatientByIdUseCase(ref.watch(patientsRepositoryProvider)));
final createPatientUseCaseProvider = Provider((ref) => CreatePatientUseCase(ref.watch(patientsRepositoryProvider)));
final updatePatientUseCaseProvider = Provider((ref) => UpdatePatientUseCase(ref.watch(patientsRepositoryProvider)));
final deletePatientUseCaseProvider = Provider((ref) => DeletePatientUseCase(ref.watch(patientsRepositoryProvider)));

// State
class PatientsState {
  final bool isLoading;
  final String? error;
  final List<PatientModel> patients;

  PatientsState({
    this.isLoading = false,
    this.error,
    this.patients = const [],
  });

  PatientsState copyWith({
    bool? isLoading,
    String? error,
    List<PatientModel>? patients,
  }) {
    return PatientsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      patients: patients ?? this.patients,
    );
  }
}

class PatientsController extends StateNotifier<PatientsState> {
  final GetPatientsUseCase _getPatients;
  final GetPatientByIdUseCase _getPatientById;
  final CreatePatientUseCase _createPatient;
  final UpdatePatientUseCase _updatePatient;
  final DeletePatientUseCase _deletePatient;

  PatientsController({
    required GetPatientsUseCase getPatients,
    required GetPatientByIdUseCase getPatientById,
    required CreatePatientUseCase createPatient,
    required UpdatePatientUseCase updatePatient,
    required DeletePatientUseCase deletePatient,
  })  : _getPatients = getPatients,
        _getPatientById = getPatientById,
        _createPatient = createPatient,
        _updatePatient = updatePatient,
        _deletePatient = deletePatient,
        super(PatientsState());

  Future<void> fetchPatients() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final patients = await _getPatients();
      state = state.copyWith(isLoading: false, patients: patients);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<PatientModel?> getPatientById(String id) async {
    try {
      return await _getPatientById(id);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<bool> createPatient(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final newPatient = await _createPatient(data);
      state = state.copyWith(
        isLoading: false,
        patients: [...state.patients, newPatient],
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updatePatient(String id, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updatedPatient = await _updatePatient(id, data);
      state = state.copyWith(
        isLoading: false,
        patients: state.patients.map((p) => p.id.toString() == id ? updatedPatient : p).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> deletePatient(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _deletePatient(id);
      state = state.copyWith(
        isLoading: false,
        patients: state.patients.where((p) => p.id.toString() != id).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final patientsControllerProvider = StateNotifierProvider<PatientsController, PatientsState>((ref) {
  return PatientsController(
    getPatients: ref.watch(getPatientsUseCaseProvider),
    getPatientById: ref.watch(getPatientByIdUseCaseProvider),
    createPatient: ref.watch(createPatientUseCaseProvider),
    updatePatient: ref.watch(updatePatientUseCaseProvider),
    deletePatient: ref.watch(deletePatientUseCaseProvider),
  );
});

final patientDetailProvider = FutureProvider.family<PatientModel?, String>((ref, id) {
  return ref.watch(patientsControllerProvider.notifier).getPatientById(id);
});
