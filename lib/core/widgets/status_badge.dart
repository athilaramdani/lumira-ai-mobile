import 'package:flutter/material.dart';
import 'package:lumira_ai_mobile/core/theme/app_colors.dart';

enum ScanStatus {
  pending,
  inReview,
  done,
}

class StatusBadge extends StatelessWidget {
  final ScanStatus status;

  const StatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    IconData? icon;
    String text;

    switch (status) {
      case ScanStatus.pending:
        backgroundColor = AppColors.pendingLight;
        textColor = AppColors.pending;
        icon = Icons.more_horiz;
        text = 'Pending';
        break;
      case ScanStatus.inReview:
        backgroundColor = AppColors.warningLight;
        textColor = AppColors.warning;
        icon = Icons.visibility;
        text = 'In Review';
        break;
      case ScanStatus.done:
        backgroundColor = AppColors.success;
        textColor = Colors.white;
        icon = Icons.check_circle;
        text = 'Done';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: textColor,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
