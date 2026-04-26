import 'package:flutter/material.dart';
import 'package:lumira_ai_mobile/core/theme/app_colors.dart';
import 'package:lumira_ai_mobile/core/constants/app_assets.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/widgets/doctor_header.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/widgets/doctor_bottom_nav_bar.dart';
import 'package:lumira_ai_mobile/features/medical_review/presentation/widgets/medical_image_card.dart';
import 'package:lumira_ai_mobile/features/medical_review/presentation/widgets/review_controls.dart';
import 'package:lumira_ai_mobile/features/medical_review/presentation/widgets/patient_info_card.dart';
import 'package:lumira_ai_mobile/features/medical_review/presentation/widgets/classification_results_card.dart';
import 'package:lumira_ai_mobile/features/medical_review/presentation/widgets/doctor_diagnosis_card.dart';
import 'medical_review_summary_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/widgets/patient_card.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/pages/doctor_dashboard_page.dart';

class MedicalReviewPage extends ConsumerStatefulWidget {
  final String patientId;
  final String patientName;
  final AIResult aiResult;

  const MedicalReviewPage({
    super.key,
    required this.patientId,
    required this.patientName,
    required this.aiResult,
  });

  @override
  ConsumerState<MedicalReviewPage> createState() => _MedicalReviewPageState();
}

class _MedicalReviewPageState extends ConsumerState<MedicalReviewPage> {
  bool _gradCam = false;
  double _transparency = 0.5;

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(dashboardNavIndexProvider);
    final authState = ref.watch(authControllerProvider);
    final doctorName = authState.user?.name ?? 'Doctor';

    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: GoogleFonts.openSansTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
        child: Column(
          children: [
            DoctorHeader(doctorName: doctorName),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      'Welcome Dr $doctorName!',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildImageSection(),
                    ReviewControls(
                      gradCamValue: _gradCam,
                      sliderValue: _transparency,
                      onGradCamChanged: (val) => setState(() => _gradCam = val!),
                      onSliderChanged: (val) => setState(() => _transparency = val),
                    ),
                    const SizedBox(height: 10),
                    _buildActionButtons(),
                    const SizedBox(height: 20),
                    _buildDiagnosisGrid(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: DoctorBottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) {
          ref.read(dashboardNavIndexProvider.notifier).state = index;
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      ),
      ),
    );
  }

  ClassificationStatus _mapToClassificationStatus(AIResult aiResult) {
    switch (aiResult) {
      case AIResult.malignant:
        return ClassificationStatus.malignant;
      case AIResult.benign:
        return ClassificationStatus.benign;
      case AIResult.normal:
      case AIResult.unknown:
      default:
        return ClassificationStatus.normal;
    }
  }

  Widget _buildImageSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          Expanded(
            child: MedicalImageCard(
              label: 'Model Output (${widget.patientId.substring(0, 4)})',
              imagePath: AppAssets.medicalScan,
              overlay: _gradCam
                  ? Opacity(
                      opacity: _transparency,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          AppAssets.medicalScanModel,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: MedicalImageCard(
              label: 'Brush (${widget.patientId.substring(0, 4)})',
              imagePath: AppAssets.medicalScan,
              overlay: _gradCam
                  ? Opacity(
                      opacity: _transparency,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          AppAssets.medicalScanBrush,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: SizedBox(
        width: double.infinity,
        height: 40,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Save',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDiagnosisGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(
            flex: 5,
            child: DoctorDiagnosisCard(),
          ),
          const SizedBox(width: 15),
          Expanded(
            flex: 4,
            child: Column(
              children: [
                PatientInfoCard(
                  id: widget.patientId,
                  name: widget.patientName,
                  phone: '08123456789',
                ),
                SizedBox(height: 15),
                ClassificationResultsCard(
                  activeStatus: _mapToClassificationStatus(widget.aiResult),
                  onStatusTap: (status) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MedicalReviewSummaryPage(aiResult: status),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
