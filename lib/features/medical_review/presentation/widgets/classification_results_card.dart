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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            'Classification Results\nBy AI',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
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
    switch (status) {
      case ClassificationStatus.normal:
        color = AppColors.statusNormal;
        break;
      case ClassificationStatus.benign:
        color = AppColors.statusBenign;
        break;
      case ClassificationStatus.malignant:
        color = AppColors.statusMalignant;
        break;
    }

    return GestureDetector(
      onTap: () => onStatusTap?.call(status),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? color : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : color.withOpacity(0.8),
            ),
          ),
        ),
      ),
    );
  }
}
