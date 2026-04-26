import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CustomPillIndicator extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onIconTapped;

  const CustomPillIndicator({
    super.key,
    required this.currentIndex,
    required this.onIconTapped,
  });

  @override
  Widget build(BuildContext context) {
    // Icons that map to the 4 content pages: Info, Features, Works, Why us.
    final icons = [
      Icons.info_outline_rounded,
      Icons.auto_awesome_outlined, // pen/wand
      Icons.hub_outlined, // nodes/network
      Icons.verified_user_outlined, // check shield
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(icons.length, (index) {
          final isSelected = index == currentIndex;
          return GestureDetector(
            onTap: () => onIconTapped(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: isSelected
                    ? null
                    : Border.all(color: Colors.transparent),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  icons[index],
                  key: ValueKey('icon_$index\_$isSelected'),
                  color: isSelected ? Colors.white : AppColors.primary,
                  size: 24,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
