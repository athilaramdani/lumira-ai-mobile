import 'package:flutter/material.dart';
import 'package:lumira_ai_mobile/core/theme/app_colors.dart';
import 'package:lumira_ai_mobile/core/constants/app_assets.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/widgets/report_patient_header.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/widgets/report_ai_result_card.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/widgets/report_doctor_note_card.dart';

class ClinicalReportPage extends StatelessWidget {
  const ClinicalReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Clinical Report',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              ReportPatientHeader(
                patientName: 'BOBBY ROJUSIAN',
                patientId: '#USG-99275-Z',
                scanDate: 'Oct 14, 2025',
                verifiedBy: 'Dr. John',
              ),
              SizedBox(height: 24),
              ReportAiResultCard(
                imagePath: AppAssets.medicalScanModel, // Using available asset
                confidenceScore: '98.4%',
                aiResult: 'Benign',
              ),
              SizedBox(height: 16),
              ReportDoctorNoteCard(
                noteText: 'Finding is stable and characteristic of non-malignant tissue. Agree with AI Diagnosis. No immediate follow-up required beyond routine screening.',
                doctorName: 'Dr. John',
                doctorRole: 'Senior Radiologist',
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
