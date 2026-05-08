import 'package:flutter/material.dart';
import 'package:lumira_ai_mobile/core/theme/app_colors.dart';
import 'package:lumira_ai_mobile/core/constants/app_assets.dart';
import 'package:lumira_ai_mobile/core/widgets/status_badge.dart';
import 'package:lumira_ai_mobile/features/chat/presentation/pages/chat_page.dart';

class ScanCard extends StatelessWidget {
  final String scanId;
  final ScanStatus status;
  final String? patientName;
  final String? waitTime;
  final String? queuePosition;
  final String? doctorName;
  final String? verifiedDate;
  final String? verifiedTime;
  final String? result;
  final bool isPatientView;

  const ScanCard({
    super.key,
    required this.scanId,
    required this.status,
    this.patientName,
    this.waitTime,
    this.queuePosition,
    this.doctorName,
    this.verifiedDate,
    this.verifiedTime,
    this.result,
    this.isPatientView = false,
  });

  Color _getAIResultColor(String? resultText) {
    final label = resultText?.toLowerCase() ?? '';
    if (label.contains('malignant')) return AppColors.statusMalignant;
    if (label.contains('benign')) return AppColors.statusBenign;
    if (label.contains('normal')) return AppColors.statusNormal;
    return AppColors.statusUnknown;
  }

  @override
  Widget build(BuildContext context) {
    // If status is DONE, use the style requested by user (matching Doctor's PatientCard)
    if (status == ScanStatus.done) {
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
                // 1. Profile Picture
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blue.shade100, width: 2),
                    image: const DecorationImage(
                      image: AssetImage(AppAssets.doctorProfile),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                // 2. Info Section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            patientName ?? 'User',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'ID: $scanId',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // AI Result
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          children: [
                            const TextSpan(text: 'AI Result:  '),
                            TextSpan(
                              text: result ?? 'Unknown',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _getAIResultColor(result),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Image Status
                      Row(
                        children: [
                          const Text(
                            'Image: ',
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                          const Text(
                            'Yes',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.statusNormal,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Icon(
                            Icons.check_circle,
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
            // 3. Action Button
            Align(
              alignment: Alignment.centerRight,
              child: isPatientView
                  ? ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatPage(
                              doctorName: doctorName,
                              medicalRecordId: scanId,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.email_outlined, size: 16, color: Colors.white),
                      label: const Text(
                        'Chat',
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.btnDone,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      );
    }

    // Default layout for other statuses
    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 20, right: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Scan ID',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    scanId,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              StatusBadge(status: status),
            ],
          ),
          const SizedBox(height: 20),
          if (status == ScanStatus.inReview) ...[
            _buildInReviewBody(),
          ] else if (status == ScanStatus.pending) ...[
            _buildPendingBody(),
          ],
          const SizedBox(height: 20),
          _buildActionButtons(context),
        ],
      ),
    );
  }



  Widget _buildInReviewBody() {
    return Row(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.image,
            size: 32,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  patientName ?? 'Patient',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(Icons.schedule, color: AppColors.primary, size: 20),
                SizedBox(width: 8),
                Text(
                  '~4 hours remaining',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        )
      ],
    );
  }

  Widget _buildPendingBody() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Estimation wait time',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  waitTime ?? '01:39:45',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Queue Position',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  queuePosition ?? '3',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (status == ScanStatus.pending) {
      return const SizedBox.shrink();
    }

    if (status == ScanStatus.inReview) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatPage(
                    doctorName: doctorName,
                    medicalRecordId: scanId,
                  )),
                );
              },
              icon: const Icon(Icons.chat_bubble_outline, size: 18),
              label: const Text(
                'Chat with Doctor',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}
