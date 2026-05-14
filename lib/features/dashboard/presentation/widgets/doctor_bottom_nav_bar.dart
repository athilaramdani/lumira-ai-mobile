import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class DoctorBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const DoctorBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Container(
      padding: EdgeInsets.only(bottom: bottomPadding),
      height: 80 + bottomPadding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.home, 0, isCircle: false),
          _buildNavItem(Icons.person_outline, 1, isCircle: true),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, {required bool isCircle, bool noHighlight = false}) {
    bool isActive = index == currentIndex;
    
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: (isActive && !noHighlight) ? Colors.blue.shade100.withOpacity(0.5) : Colors.transparent,
          shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: !isCircle ? BorderRadius.circular(12) : null,
          border: (isActive && !noHighlight) ? Border.all(color: Colors.blue.shade300, width: 2) : null,
        ),
        child: Icon(
          icon,
          size: 28,
          color: isActive ? Colors.blue : Colors.grey.shade400,
        ),
      ),
    );
  }
}
