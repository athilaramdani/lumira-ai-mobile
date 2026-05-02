import 'package:flutter/material.dart';
import 'package:lumira_ai_mobile/core/theme/app_colors.dart';

class MedicalImageCard extends StatelessWidget {
  final String label;
  final String imagePath;
  final Widget? overlay;
  final String? badgeText;
  final bool isNetwork;

  const MedicalImageCard({
    super.key,
    required this.label,
    required this.imagePath,
    this.overlay,
    this.badgeText,
    this.isNetwork = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            children: [
              Positioned.fill(
                child: FittedBox(
                  fit: BoxFit.cover,
                  clipBehavior: Clip.hardEdge,
                  child: SizedBox(
                    width: 500,
                    height: 500,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: isNetwork 
                              ? Image.network(
                                  imagePath,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  imagePath,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        if (overlay != null)
                          Positioned.fill(child: overlay!),
                      ],
                    ),
                  ),
                ),
              ),
              if (badgeText != null)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      badgeText!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
}
