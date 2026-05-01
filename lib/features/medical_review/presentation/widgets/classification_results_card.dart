import 'package:flutter/material.dart';
import 'package:lumira_ai_mobile/core/theme/app_colors.dart';

enum ClassificationStatus { normal, benign, malignant }

class ClassificationResultsCard extends StatelessWidget {
  final ClassificationStatus activeStatus;
  final Function(ClassificationStatus)? onStatusTap;

  const ClassificationResultsCard({
    super.key,
    required this.activeStatus,
    this.onStatusTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Classification Result',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildStatusBadge('Normal', ClassificationStatus.normal),
          const SizedBox(height: 8),
          _buildStatusBadge('Benign', ClassificationStatus.benign),
          const SizedBox(height: 8),
          _buildStatusBadge('Malignant', ClassificationStatus.malignant),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String label, ClassificationStatus status) {
    bool isActive = activeStatus == status;
    Color color;
    Color textColor = Colors.white;
    switch (status) {
      case ClassificationStatus.normal:
        color = AppColors.statusNormal;
        break;
      case ClassificationStatus.benign:
        color = AppColors.statusBenign;
        textColor = AppColors.textPrimary; // Better contrast for yellow
        break;
      case ClassificationStatus.malignant:
        color = AppColors.statusMalignant;
        break;
    }

    return GestureDetector(
      onTap: () => onStatusTap?.call(status),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? color : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: isActive ? null : Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isActive ? textColor : Colors.grey.shade400,
            ),
          ),
        ),
      ),
    );
  }
}
