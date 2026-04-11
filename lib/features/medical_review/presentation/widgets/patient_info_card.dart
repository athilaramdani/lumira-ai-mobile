import 'package:flutter/material.dart';
import 'package:lumira_ai_mobile/core/theme/app_colors.dart';

class PatientInfoCard extends StatelessWidget {
  final String id;
  final String name;
  final String phone;

  const PatientInfoCard({
    super.key,
    required this.id,
    required this.name,
    required this.phone,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('ID', id),
          const SizedBox(height: 8),
          _buildInfoRow('Name', name),
          const SizedBox(height: 8),
          _buildInfoRow('Phone', phone),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        children: [
          TextSpan(text: '$label : ', style: const TextStyle(fontWeight: FontWeight.w400)),
          TextSpan(
            text: value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
