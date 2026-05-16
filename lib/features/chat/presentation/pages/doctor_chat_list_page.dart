import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/custom_search_bar.dart';
import 'chat_page.dart';
import '../../../patients/presentation/controllers/patients_controller.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../../core/widgets/creative_medical_loading.dart';

class DoctorChatListPage extends ConsumerStatefulWidget {
  const DoctorChatListPage({super.key});

  @override
  ConsumerState<DoctorChatListPage> createState() => _DoctorChatListPageState();
}

class _DoctorChatListPageState extends ConsumerState<DoctorChatListPage> {
  String _searchQuery = '';
  List<Map<String, dynamic>> _doctors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDoctors();
    });
  }

  Future<void> _fetchDoctors() async {
    try {
      final authState = ref.read(authControllerProvider);
      final userEmail = authState.user?.email;
      final userId = authState.user?.id;

      Map<String, Map<String, dynamic>> uniqueDoctors = {};

      if (userId != null) {
        // Coba ambil data pasien secara spesifik dari backend
        final currentPatient = await ref.read(patientsControllerProvider.notifier).getPatientById(userId);
        
        if (currentPatient != null && currentPatient.medicalRecords != null) {
          for (var record in currentPatient.medicalRecords!) {
            if (record.doctor != null) {
              final docId = record.doctor!['id']?.toString() ?? '';
              if (docId.isNotEmpty && !uniqueDoctors.containsKey(docId)) {
                uniqueDoctors[docId] = {
                  'name': record.doctor!['name'] ?? 'Dokter',
                  'id': docId,
                  'specialty': 'Spesialis',
                  'isOnline': record.doctor!['status']?.toString().toLowerCase() == 'active',
                  'medicalRecordId': record.id ?? '',
                };
              }
            }
          }
        }
      }

      // Fallback jika ambil spesifik tidak berhasil, cari dari list patient
      if (uniqueDoctors.isEmpty) {
        await ref.read(patientsControllerProvider.notifier).fetchPatients();
        final patientsState = ref.read(patientsControllerProvider);

        if (userEmail != null || userId != null) {
          final currentPatient = patientsState.patients.where((p) => 
            (userEmail != null && p.email == userEmail) || 
            (userId != null && p.id == userId)
          ).firstOrNull;

          if (currentPatient != null && currentPatient.medicalRecords != null) {
            for (var record in currentPatient.medicalRecords!) {
              if (record.doctor != null) {
                final docId = record.doctor!['id']?.toString() ?? '';
                if (docId.isNotEmpty && !uniqueDoctors.containsKey(docId)) {
                  uniqueDoctors[docId] = {
                    'name': record.doctor!['name'] ?? 'Dokter',
                    'id': docId,
                    'specialty': 'Spesialis',
                    'isOnline': record.doctor!['status']?.toString().toLowerCase() == 'active',
                    'medicalRecordId': record.id ?? '',
                  };
                }
              }
            }
          }
        }
      }

      // Removed dummy data injection to match real backend data.

      if (mounted) {
        setState(() {
          _doctors = uniqueDoctors.values.toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredDoctors = _doctors.where((doc) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      final name = doc['name']?.toLowerCase() ?? '';
      final id = doc['id']?.toLowerCase() ?? '';
      return name.contains(query) || id.contains(query);
    }).toList();

    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: GoogleFonts.openSansTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Text(
            'Chat List',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          centerTitle: false,
        ),
        body: Column(
          children: [
            CustomSearchBar(
              hintText: 'Search Doctor...',
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: CreativeMedicalLoading(text: 'Loading chat list...'),
                      ),
                    )
                  : filteredDoctors.isEmpty
                      ? const Center(child: Text('Belum ada dokter yang menangani Anda.'))
                      : ListView.builder(
                          itemCount: filteredDoctors.length,
                          itemBuilder: (context, index) {
                            final doctor = filteredDoctors[index];
                            return _buildChatListItem(
                              context,
                              name: doctor['name'],
                              id: doctor['id'],
                              message: 'Ketuk untuk mulai chat',
                              time: '',
                              isOnline: doctor['isOnline'] ?? false,
                              medicalRecordId: doctor['medicalRecordId'] ?? '',
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatListItem(
    BuildContext context, {
    required String name,
    required String id,
    required String message,
    required String time,
    required bool isOnline,
    required String medicalRecordId,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Navigates to actual chat room.
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                doctorId: id,
                doctorName: name,
                medicalRecordId: medicalRecordId,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
          ),
          child: Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFE3F2FD),
                      border: Border.all(color: Colors.blue.shade100, width: 2),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        AppAssets.doctor,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if (isOnline)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'ID: $id',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                        ),
                        const Spacer(),
                        if (time.isNotEmpty)
                          Text(
                            time,
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      message,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
