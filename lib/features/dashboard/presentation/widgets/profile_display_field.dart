import 'package:flutter/material.dart';
import 'package:lumira_ai_mobile/core/theme/app_colors.dart';

class ProfileDisplayField extends StatelessWidget {
  final String label;
  final String value;
  final bool isMultiLine;
  final bool showLabel;

  const ProfileDisplayField({
    super.key,
    required this.label,
    required this.value,
    this.isMultiLine = false,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel) ...[
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
        ],
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.background, // Light gray
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            textAlign: isMultiLine ? TextAlign.center : TextAlign.left,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
