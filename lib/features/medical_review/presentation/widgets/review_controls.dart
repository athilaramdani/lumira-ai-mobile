import 'package:flutter/material.dart';
import 'package:lumira_ai_mobile/core/theme/app_colors.dart';

class ReviewControls extends StatelessWidget {
  final bool gradCamValue;
  final double sliderValue;
  final ValueChanged<bool?> onGradCamChanged;
  final ValueChanged<double> onSliderChanged;

  const ReviewControls({
    super.key,
    required this.gradCamValue,
    required this.sliderValue,
    required this.onGradCamChanged,
    required this.onSliderChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Row(
        children: [
          Transform.scale(
            scale: 0.9,
            child: Checkbox(
              value: gradCamValue,
              onChanged: onGradCamChanged,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const Text(
            'Grad-Cam',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4.0,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 16.0),
                activeTrackColor: AppColors.primary.withOpacity(0.5),
                inactiveTrackColor: Colors.grey.shade300,
                thumbColor: AppColors.primary,
              ),
              child: Slider(
                value: sliderValue,
                onChanged: gradCamValue ? onSliderChanged : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
