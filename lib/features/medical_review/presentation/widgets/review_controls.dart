import 'package:flutter/material.dart';
import 'package:lumira_ai_mobile/core/theme/app_colors.dart';

enum VisualMode { raw, normalized }

class ReviewControls extends StatelessWidget {
  final VisualMode visualMode;
  final ValueChanged<VisualMode> onVisualModeChanged;

  const ReviewControls({
    super.key,
    required this.visualMode,
    required this.onVisualModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVisualMode(),
        ],
      ),
    );
  }

  Widget _buildVisualMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Visual Mode:',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            GestureDetector(
              onTap: () => onVisualModeChanged(VisualMode.raw),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: visualMode == VisualMode.raw ? AppColors.primary : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Raw Pixels',
                  style: TextStyle(
                    fontSize: 12, 
                    color: visualMode == VisualMode.raw ? Colors.white : Colors.grey.shade700, 
                    fontWeight: visualMode == VisualMode.raw ? FontWeight.w600 : FontWeight.w500
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => onVisualModeChanged(VisualMode.normalized),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: visualMode == VisualMode.normalized ? AppColors.primary : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Normalized',
                  style: TextStyle(
                    fontSize: 12, 
                    color: visualMode == VisualMode.normalized ? Colors.white : Colors.grey.shade700, 
                    fontWeight: visualMode == VisualMode.normalized ? FontWeight.w600 : FontWeight.w500
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '*View smoothed heatmap',
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
            ),
          ],
        )
      ],
    );
  }
}
