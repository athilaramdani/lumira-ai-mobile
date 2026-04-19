import 'package:flutter/material.dart';
import 'package:lumira_ai_mobile/core/theme/app_colors.dart';

class ProfileSettingRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget trailing;
  final bool showDivider;

  const ProfileSettingRow({
    super.key,
    required this.icon,
    required this.title,
    required this.trailing,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Icon(
                icon,
                color: AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              trailing,
            ],
          ),
        ),
        if (showDivider)
          const Divider(
            color: AppColors.border,
            thickness: 1,
            height: 16,
          ),
      ],
    );
  }
}
