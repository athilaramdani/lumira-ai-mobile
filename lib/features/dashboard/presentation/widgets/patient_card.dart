import 'package:flutter/material.dart';
import 'package:lumira_ai_mobile/features/medical_review/presentation/pages/medical_review_page.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_assets.dart';

enum AIResult { normal, benign, malignant, unknown }

enum ImageStatus { yes, missing }

class PatientCard extends StatelessWidget {
  final String patientName;
  final String patientId;
  final String? recordId;
  final AIResult aiResult;
  final ImageStatus imageStatus;
  final String actionLabel;
  final Color actionColor;
  final String phone;
  final String? rawImage;
  final String? gradCamImage;
  final String? initialDoctorDiagnosis;
  final String? initialDoctorNote;
  final String? initialAgreement;

  const PatientCard({
    super.key,
    required this.patientName,
    required this.patientId,
    this.recordId,
    required this.aiResult,
    required this.imageStatus,
    required this.actionLabel,
    required this.actionColor,
    required this.phone,
    this.rawImage,
    this.gradCamImage,
    this.initialDoctorDiagnosis,
    this.initialDoctorNote,
    this.initialAgreement,
  });

  Color _getAIResultColor() {
    switch (aiResult) {
      case AIResult.normal:
        return AppColors.statusNormal;
      case AIResult.benign:
        return AppColors.statusBenign;
      case AIResult.malignant:
        return AppColors.statusMalignant;
      default:
        return AppColors.statusUnknown;
    }
  }

  String _getAIResultText() {
    switch (aiResult) {
      case AIResult.normal:
        return 'Normal';
      case AIResult.benign:
        return 'Benign';
      case AIResult.malignant:
        return 'Malignant';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE3F2FD),
                  border: Border.all(color: Colors.blue.shade100, width: 2),
                ),
                child: ClipOval(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Image.asset(
                      AppAssets.patientProfile,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            patientName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'ID: $patientId',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        children: [
                          const TextSpan(text: 'AI Result:  '),
                          TextSpan(
                            text: _getAIResultText(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _getAIResultColor(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text(
                          'Image: ',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                        Text(
                          imageStatus == ImageStatus.yes ? 'Yes' : 'Missing',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.statusNormal,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Icon(
                          imageStatus == ImageStatus.yes
                              ? Icons.check_circle
                              : Icons.warning,
                          size: 16,
                          color: AppColors.statusNormal,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              height: 32,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MedicalReviewPage(
                        patientId: patientId,
                        recordId: recordId,
                        patientName: patientName,
                        aiResult: aiResult,
                        phone: phone,
                        rawImage: rawImage,
                        gradCamImage: gradCamImage,
                        isDone: actionLabel == 'Done',
                        initialDoctorDiagnosis: initialDoctorDiagnosis,
                        initialDoctorNote: initialDoctorNote,
                        initialAgreement: initialAgreement,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: actionColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  actionLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
