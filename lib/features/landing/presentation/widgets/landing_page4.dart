import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'pulse_button.dart';

/// Landing Page 4 — "HOW IT WORKS"
///
/// Menampilkan 4 langkah proses:
/// 1. Image Upload → 2. AI Analysis → 3. Doctor Review → 4. Treatment Plan
/// Dengan numbered circle alternating left/right dan staggered animation.
class LandingPage4 extends StatefulWidget {
  final double pageOffset;
  final VoidCallback onStartPressed;

  const LandingPage4({
    super.key,
    required this.pageOffset,
    required this.onStartPressed,
  });

  @override
  State<LandingPage4> createState() => _LandingPage4State();
}

class _LandingPage4State extends State<LandingPage4>
    with TickerProviderStateMixin {
  late final AnimationController _enterController;

  late final Animation<double> _headerFadeAnimation;
  late final Animation<Offset> _headerSlideAnimation;
  late final List<Animation<double>> _stepFadeAnimations;
  late final List<Animation<Offset>> _stepSlideAnimations;
  late final Animation<double> _buttonFadeAnimation;

  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();

    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Header (0.0 → 0.2)
    _headerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _enterController,
        curve: const Interval(0.0, 0.2, curve: Curves.easeOutCubic),
      ),
    );
    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _enterController,
        curve: const Interval(0.0, 0.2, curve: Curves.easeOutCubic),
      ),
    );

    // 4 steps staggered (each gets 0.15 of total, spaced 0.12 apart)
    _stepFadeAnimations = [];
    _stepSlideAnimations = [];
    for (int i = 0; i < 4; i++) {
      final start = 0.15 + (i * 0.15);
      final end = (start + 0.2).clamp(0.0, 1.0);

      _stepFadeAnimations.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _enterController,
            curve: Interval(start, end, curve: Curves.easeOutCubic),
          ),
        ),
      );
      _stepSlideAnimations.add(
        Tween<Offset>(
          begin: Offset(i.isEven ? -0.3 : 0.3, 0.0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _enterController,
            curve: Interval(start, end, curve: Curves.easeOutCubic),
          ),
        ),
      );
    }

    // Button (0.85 → 1.0)
    _buttonFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _enterController,
        curve: const Interval(0.85, 1.0, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant LandingPage4 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_hasAnimated && widget.pageOffset.abs() < 0.5) {
      _hasAnimated = true;
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
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: _enterController,
      builder: (context, _) {
        return Stack(
          children: [
            // Background decorative circle di bawah
            Positioned(
              bottom: -120,
              left: -60,
              right: -60,
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryLightest.withValues(alpha: 0.5),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.04),

                  // Header — HOW IT WORKS
                  SlideTransition(
                    position: _headerSlideAnimation,
                    child: FadeTransition(
                      opacity: _headerFadeAnimation,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLightest,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'HOW IT WORKS',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'A simple process for an accurate diagnosis',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.primary.withValues(alpha: 0.7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: size.height * 0.03),

                  // Steps
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStep(
                            index: 0,
                            number: '1',
                            title: 'Image Upload',
                            description:
                                'The admin uploads the patient\'s mammogram image to the system',
                            isLeft: true,
                          ),
                          _buildStep(
                            index: 1,
                            number: '2',
                            title: 'AI Analysis',
                            description:
                                'The AI analyzes the image and predicts the cancer stage',
                            isLeft: false,
                          ),
                          _buildStep(
                            index: 2,
                            number: '3',
                            title: 'Doctor Review',
                            description:
                                'The doctor reviews the AI results and provides a final diagnosis',
                            isLeft: true,
                          ),
                          _buildStep(
                            index: 3,
                            number: '4',
                            title: 'Treatment Plan',
                            description:
                                'The doctor provides appropriate treatment recommendations',
                            isLeft: false,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Start Now button
                  Padding(
                    padding: const EdgeInsets.only(bottom: 80),
                    child: FadeTransition(
                      opacity: _buttonFadeAnimation,
                      child: PulseButton(
                        onPressed: widget.onStartPressed,
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Start Now!',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 12),
                            Icon(Icons.arrow_forward_ios, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStep({
    required int index,
    required String number,
    required String title,
    required String description,
    required bool isLeft,
  }) {
    final content = Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primaryLightest,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );

    final numberCircle = Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primaryLightest,
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      child: Center(
        child: Text(
          number,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
      ),
    );

    return SlideTransition(
      position: _stepSlideAnimations[index],
      child: FadeTransition(
        opacity: _stepFadeAnimations[index],
        child: Row(
          children: isLeft
              ? [content, const SizedBox(width: 12), numberCircle]
              : [numberCircle, const SizedBox(width: 12), content],
        ),
      ),
    );
  }
}
