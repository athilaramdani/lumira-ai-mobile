import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Widget reusable untuk animated dot indicator.
/// Dot aktif membesar dan berubah warna primary secara smooth
/// berdasarkan posisi PageController (double currentPage).
class AnimatedDotIndicator extends StatelessWidget {
  final double currentPage;
  final int pageCount;
  final Color activeColor;
  final Color inactiveColor;
  final double activeDotWidth;
  final double dotSize;
  final double spacing;

  const AnimatedDotIndicator({
    super.key,
    required this.currentPage,
    required this.pageCount,
    this.activeColor = AppColors.primary,
    this.inactiveColor = const Color(0xFFD1D5DB),
    this.activeDotWidth = 28.0,
    this.dotSize = 10.0,
    this.spacing = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pageCount, (index) {
        // Hitung faktor interpolasi berdasarkan jarak ke halaman saat ini
        final double distance = (currentPage - index).abs();
        final double factor = (1.0 - distance).clamp(0.0, 1.0);

        // Interpolasi warna dari inactive → active
        final Color dotColor = Color.lerp(inactiveColor, activeColor, factor)!;

        // Interpolasi ukuran: dot aktif lebih lebar (pill shape)
        final double width = dotSize + (activeDotWidth - dotSize) * factor;
        final double height = dotSize;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          margin: EdgeInsets.symmetric(horizontal: spacing / 2),
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: dotColor,
            borderRadius: BorderRadius.circular(height / 2),
            boxShadow: factor > 0.5
                ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.3 * factor),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }
}
