import 'package:flutter/material.dart';
import 'package:lumira_ai_mobile/core/theme/app_colors.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTabSelected;

  const CustomBottomNav({
    super.key,
    this.currentIndex = 0,
    this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.bar_chart_rounded, // Stats icon
                label: 'Stats',
                isActive: currentIndex == 0,
                onTap: () {
                  if (onTabSelected != null) onTabSelected!(0);
                },
              ),
              _buildNavItem(
                icon: Icons.auto_awesome, // Sparkles icon
                label: 'Consult AI',
                isActive: currentIndex == 1,
                onTap: () {
                  if (onTabSelected != null) onTabSelected!(1);
                },
              ),
              _buildNavItem(
                icon: Icons.history, // History icon
                label: 'History',
                isActive: currentIndex == 2,
                onTap: () {
                  if (onTabSelected != null) onTabSelected!(2);
                },
              ),
              _buildNavItem(
                icon: Icons.person, // Profile icon
                label: 'Profile',
                isActive: currentIndex == 3,
                onTap: () {
                  if (onTabSelected != null) onTabSelected!(3);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: isActive
            ? BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : AppColors.textPrimary,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : AppColors.textPrimary,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
