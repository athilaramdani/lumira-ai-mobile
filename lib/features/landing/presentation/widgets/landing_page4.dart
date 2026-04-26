import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class LandingPage4 extends StatefulWidget {
  final double pageOffset;
  const LandingPage4({super.key, required this.pageOffset});

  @override
  State<LandingPage4> createState() => _LandingPage4State();
}

class _LandingPage4State extends State<LandingPage4>
    with TickerProviderStateMixin {
  late final AnimationController _enterController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _enterController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _enterController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(
      CurvedAnimation(
        parent: _enterController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant LandingPage4 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pageOffset.abs() < 0.5) {
      _enterController.forward();
    }
  }

  @override
  void dispose() {
    _enterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SafeArea(
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'HOW IT WORKS',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'A simple process for an accurate diagnosis',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // The zigzag list
                  _buildStepRow(
                    step: '1',
                    title: 'Image Upload',
                    description: 'The admin uploads the patient\'s\nmammogram image to the system',
                    isLightBlue: true, // Left-aligned number
                  ),
                  _buildStepRow(
                    step: '2',
                    title: 'AI Analysis',
                    description: 'The AI analyzes the image and\npredicts the cancer stage',
                    isLightBlue: false, // Right-aligned number
                  ),
                  _buildStepRow(
                    step: '3',
                    title: 'Doctor Review',
                    description: 'The doctor reviews the AI results\nand provides a final diagnosis',
                    isLightBlue: true,
                  ),
                  _buildStepRow(
                    step: '4',
                    title: 'Treatment Plan',
                    description: 'The doctor provides appropriate\ntreatment recommendations',
                    isLightBlue: false,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepRow({
    required String step,
    required String title,
    required String description,
    required bool isLightBlue,
  }) {
    final bgColor = isLightBlue ? const Color(0xFFCBEBFA) : Colors.white;
    final textColor = isLightBlue ? Colors.white : AppColors.primary;
    final circleColor = isLightBlue ? Colors.white : AppColors.primary;
    final numberColor = isLightBlue ? const Color(0xFFCBEBFA) : Colors.white;

    // Based on the image, the text alignment switches
    final numberWidget = Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: circleColor,
      ),
      alignment: Alignment.center,
      child: Text(
        step,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: numberColor,
        ),
      ),
    );

    final textWidget = Column(
      crossAxisAlignment: isLightBlue ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          textAlign: isLightBlue ? TextAlign.left : TextAlign.right,
          style: TextStyle(
            fontSize: 12,
            color: textColor.withOpacity(0.9),
          ),
        ),
      ],
    );

    return Container(
      color: bgColor,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: isLightBlue
            ? [numberWidget, textWidget]
            : [textWidget, numberWidget],
      ),
    );
  }
}
