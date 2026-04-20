import 'package:flutter/material.dart';
import 'package:lumira_ai_mobile/core/theme/app_colors.dart';
import 'package:lumira_ai_mobile/core/constants/app_assets.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/widgets/doctor_header.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/widgets/doctor_bottom_nav_bar.dart';
import 'package:lumira_ai_mobile/features/medical_review/presentation/widgets/medical_image_card.dart';
import 'package:lumira_ai_mobile/features/medical_review/presentation/widgets/review_controls.dart';
import 'package:lumira_ai_mobile/features/medical_review/presentation/widgets/result_by_doctor_card.dart';
import 'package:lumira_ai_mobile/features/medical_review/presentation/widgets/classification_results_card.dart';

import 'package:lumira_ai_mobile/features/medical_review/presentation/widgets/doctor_diagnosis_card.dart';
import 'package:google_fonts/google_fonts.dart';

class MedicalReviewSummaryPage extends StatefulWidget {
  final ClassificationStatus aiResult;

  const MedicalReviewSummaryPage({
    super.key,
    this.aiResult = ClassificationStatus.benign,
  });

  @override
  State<MedicalReviewSummaryPage> createState() => _MedicalReviewSummaryPageState();
}

class _MedicalReviewSummaryPageState extends State<MedicalReviewSummaryPage> {
  @override
  Widget build(BuildContext context) {
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
            const DoctorHeader(doctorName: 'Anne'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 20),
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
                    const ReviewControls(
                      gradCamValue: false,
                      sliderValue: 0.5,
                      onGradCamChanged: _emptyOnGradCamChanged,
                      onSliderChanged: _emptyOnSliderChanged,
                    ),
                    const SizedBox(height: 10),
                    _buildSaveButton(),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const ResultByDoctorCard(
                            imagePath: AppAssets.medicalScanBrush,
                            note: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam eget ipsum ex. Aliquam felis elit, ornare eget libero et, maximus sollicitudin tortor.",
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Classification Result By AI',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildAIResultBadge(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: DoctorBottomNavBar(
        currentIndex: 2,
        onTap: (index) {},
      ),
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

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: SizedBox(
        width: double.infinity,
        height: 40,
        child: ElevatedButton(
          onPressed: () => _showSaveDialog(context),
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

  void _showSaveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Data Saved',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    strokeWidth: 6,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    backgroundColor: AppColors.primary.withOpacity(0.2),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    // Otomatis tutup setelah 2 detik untuk demo
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pop(); // Tutup dialog
        Navigator.of(context).pop(); // Kembali dari Summary ke Review
        Navigator.of(context).pop(); // Kembali dari Review ke Dashboard
      }
    });
  }

  Widget _buildAIResultBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.statusUnknown,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Text(
        'Benign',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  static void _emptyOnGradCamChanged(bool? value) {}
  static void _emptyOnSliderChanged(double value) {}
}
