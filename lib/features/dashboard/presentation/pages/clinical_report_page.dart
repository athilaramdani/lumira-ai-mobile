import 'package:flutter/material.dart';
import 'package:lumira_ai_mobile/core/theme/app_colors.dart';
import 'package:lumira_ai_mobile/core/constants/app_assets.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/widgets/report_patient_header.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/widgets/report_ai_result_card.dart';
import 'package:lumira_ai_mobile/features/dashboard/presentation/widgets/report_doctor_note_card.dart';

class ClinicalReportPage extends StatelessWidget {
  final String patientName;
  final String patientId;
  final String scanDate;
  final String verifiedBy;
  final String imagePath;
  final String confidenceScore;
  final String aiResult;
  final String noteText;
  final String doctorRole;

  const ClinicalReportPage({
    super.key,
    required this.patientName,
    required this.patientId,
    required this.scanDate,
    required this.verifiedBy,
    required this.imagePath,
    required this.confidenceScore,
    required this.aiResult,
    required this.noteText,
    this.doctorRole = 'Radiologist',
  });

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
            children: [
              ReportPatientHeader(
                patientName: patientName,
                patientId: patientId,
                scanDate: scanDate,
                verifiedBy: verifiedBy,
              ),
              const SizedBox(height: 24),
              ReportAiResultCard(
                imagePath: imagePath,
                confidenceScore: confidenceScore,
                aiResult: aiResult,
              ),
              const SizedBox(height: 16),
              ReportDoctorNoteCard(
                noteText: noteText,
                doctorName: verifiedBy,
                doctorRole: doctorRole,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
