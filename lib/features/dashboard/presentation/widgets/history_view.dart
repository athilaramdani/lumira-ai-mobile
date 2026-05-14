import 'package:flutter/material.dart';
import 'package:lumira_ai_mobile/core/theme/app_colors.dart';
import 'package:lumira_ai_mobile/core/constants/app_assets.dart';
import 'package:lumira_ai_mobile/features/chat/presentation/pages/chat_page.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/pages/clinical_report_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../patients/presentation/controllers/patients_controller.dart';

class HistoryView extends ConsumerWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final userId = authState.user?.id;
    
    // Fetch patient data based on logged in user ID
    final patientAsync = userId != null 
        ? ref.watch(patientDetailProvider(userId))
        : const AsyncValue.loading();

    return patientAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (patient) {
        final medicalRecords = patient?.medicalRecords ?? [];

        final List<Widget> dynamicDiagnosisCards = medicalRecords.isEmpty
            ? [const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Text('No historical records found.'))]
            : medicalRecords.map((record) {
                return _buildDiagnosisCard(
                  context,
                  id: record.id?.toString() ?? '#USG-???',
                  title: 'Medical Scan',
                  date: record.createdAt?.toString() ?? 'Recent',
                  result: record.resultLabel?.toString().toUpperCase() ?? 'UNKNOWN',
                  icon: Icons.medical_services_outlined,
                  doctorId: record.doctor != null ? record.doctor!['id']?.toString() ?? '' : '',
                  doctorName: record.doctor != null ? record.doctor!['name']?.toString() ?? 'Dokter' : 'Dokter',
                  medicalRecordId: record.id?.toString() ?? '',
                  record: record,
                  patient: patient,
                );
              }).whereType<Widget>().toList();

        // Chat cards logic (previous consultations if any exist in the backend)
        final List<Widget> dynamicChatCards = []; // You can implement fetching previous chat history here if needed

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Riwayat Diagnosis Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text(
                    'Riwayat Diagnosis',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'ARCHIVAL RECORDS',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Diagnosis Cards
              ...dynamicDiagnosisCards,

              const SizedBox(height: 32),

              // Only show Chat Section if patient has at least one medical record
              // User requested to move chat exclusively to Chat List, so we don't render it here anymore.
              // if (medicalRecords.isNotEmpty) ...[
              //   ... Chat Dokter Header & Chat Card ...
              // ] else ...[
              //   ... Empty state for Chat ...
              // ],

              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDiagnosisCard(
    BuildContext context, {
    required String id,
    required String title,
    required String date,
    required String result,
    required IconData icon,
    required String doctorId,
    required String doctorName,
    required String medicalRecordId,
    required dynamic record,
    required dynamic patient,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ID: $id',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                icon,
                color: const Color(0xFF82CFFF),
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Date Performed',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              Text(
                date,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Primary Result',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF40B4FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  result,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Normalize AI result label and confidence
                String normalizedLabel = record.resultLabel ?? 'Unknown';
                String confidenceStr = '-';

                // If the label looks like a JSON or has underscores, clean it up
                normalizedLabel = normalizedLabel
                    .replaceAll('_', ' ')
                    .split(' ')
                    .map((s) => s.isEmpty ? '' : s[0].toUpperCase() + s.substring(1))
                    .join(' ');
                
                if (record.resultConfidence != null) {
                  final confVal = record.resultConfidence!;
                  final pct = confVal > 1 ? confVal : confVal * 100;
                  confidenceStr = '${pct.toStringAsFixed(2)}%';
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ClinicalReportPage(
                      patientName: patient?.name ?? 'Patient',
                      patientId: patient?.id ?? id,
                      scanDate: date,
                      verifiedBy: doctorName,
                      imagePath: record.gradcamImageUrl ?? record.imageUrl ?? AppAssets.medicalScanModel,
                      confidenceScore: confidenceStr,
                      aiResult: normalizedLabel,
                      noteText: record.doctorNotes ?? 'No notes provided.',
                      doctorRole: 'Senior Radiologist',
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0EA5E9),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                'View Full Report',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                _navigateToChat(context, doctorName: doctorName, doctorId: doctorId, medicalRecordId: medicalRecordId);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0EA5E9),
                side: const BorderSide(color: Color(0xFF0EA5E9)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Chat with Doctor',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorChatCard(
    BuildContext context, {
    required String doctorName,
    required String role,
    required String relatedId,
    required String date,
    required String doctorId,
    required String medicalRecordId,
  }) {
    return GestureDetector(
      onTap: () => _navigateToChat(context, doctorName: doctorName, doctorId: doctorId, medicalRecordId: medicalRecordId),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFF40B4FF).withOpacity(0.1),
              backgroundImage: const AssetImage(AppAssets.doctor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctorName,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    role,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Related to: $relatedId',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Icon(Icons.chevron_right, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  date,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Active chat card — always visible so patient can always open chat
  Widget _buildActiveChatCard(BuildContext context, {required String doctorId, required String doctorName, required String medicalRecordId}) {
    return GestureDetector(
      onTap: () => _navigateToChat(context, doctorName: doctorName, doctorId: doctorId, medicalRecordId: medicalRecordId),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF40B4FF), Color(0xFF0EA5E9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF40B4FF).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.2),
                border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Konsultasi dengan Dokter',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.circle, color: Color(0xFF86EFAC), size: 8),
                      SizedBox(width: 4),
                      Text(
                        'Chat Real-time aktif',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.chat, color: Colors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToChat(BuildContext context, {required String doctorName, required String doctorId, required String medicalRecordId}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatPage(doctorName: doctorName, doctorId: doctorId, medicalRecordId: medicalRecordId),
      ),
    );
  }
}
