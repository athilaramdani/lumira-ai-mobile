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

class MedicalReviewPage extends StatefulWidget {
  const MedicalReviewPage({super.key});

  @override
  State<MedicalReviewPage> createState() => _MedicalReviewPageState();
}

class _MedicalReviewPageState extends State<MedicalReviewPage> {
  bool _gradCam = false;
  double _transparency = 0.5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const DoctorHeader(doctorName: 'Anne'),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      'Welcome Dr Anne!',
                      style: TextStyle(
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
        currentIndex: 2, // Assuming Medical Review is under Category/Grid
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        },
      ),
    );
  }

  Widget _buildImageSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: const [
          Expanded(
            child: MedicalImageCard(
              label: 'Model Output',
              imagePath: AppAssets.medicalScanModel,
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: MedicalImageCard(
              label: 'Brush',
              imagePath: AppAssets.medicalScanBrush,
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
                  id: 'P001',
                  name: 'Bachtiar',
                  phone: '08123456789',
                ),
                SizedBox(height: 15),
                ClassificationResultsCard(
                  activeStatus: ClassificationStatus.normal,
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
