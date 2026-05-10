import 'package:flutter/material.dart';
import 'package:lumira_ai_mobile/core/theme/app_colors.dart';

class ProfileTextField extends StatelessWidget {
  final String label;
  final String initialValue;
  final bool isMultiLine;
  final ValueChanged<String>? onChanged;

  const ProfileTextField({
    super.key,
    required this.label,
    required this.initialValue,
    this.isMultiLine = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
        ],
        TextFormField(
          initialValue: initialValue,
          onChanged: onChanged,
          maxLines: isMultiLine ? 3 : 1,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            height: 1.5,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.background,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
