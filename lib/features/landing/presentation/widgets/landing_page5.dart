import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'pulse_button.dart';

/// Landing Page 5 — "WHY CHOOSE US?"
///
/// Pink-themed halaman terakhir dengan 3 benefit card:
/// 1. More Accurate Early Detection
/// 2. Faster Diagnosis
/// 3. Doctor & AI Collaboration
/// Masing-masing dengan checkmark icon.
class LandingPage5 extends StatefulWidget {
  final double pageOffset;
  final VoidCallback onStartPressed;

  const LandingPage5({
    super.key,
    required this.pageOffset,
    required this.onStartPressed,
  });

  @override
  State<LandingPage5> createState() => _LandingPage5State();
}

class _LandingPage5State extends State<LandingPage5>
    with TickerProviderStateMixin {
  late final AnimationController _enterController;

  late final Animation<double> _headerFadeAnimation;
  late final Animation<double> _headerScaleAnimation;
  late final List<Animation<double>> _cardFadeAnimations;
  late final List<Animation<Offset>> _cardSlideAnimations;
  late final Animation<double> _buttonFadeAnimation;

  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();

    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // Header (0.0 → 0.25)
    _headerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _enterController,
        curve: const Interval(0.0, 0.25, curve: Curves.easeOutCubic),
      ),
    );
    _headerScaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _enterController,
        curve: const Interval(0.0, 0.25, curve: Curves.elasticOut),
      ),
    );

    // 3 benefit cards staggered
    _cardFadeAnimations = [];
    _cardSlideAnimations = [];
    for (int i = 0; i < 3; i++) {
      final start = 0.2 + (i * 0.18);
      final end = (start + 0.25).clamp(0.0, 1.0);

      _cardFadeAnimations.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _enterController,
            curve: Interval(start, end, curve: Curves.easeOutCubic),
          ),
        ),
      );
      _cardSlideAnimations.add(
        Tween<Offset>(
          begin: Offset(i.isEven ? -0.4 : 0.4, 0.0),
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
  void didUpdateWidget(covariant LandingPage5 oldWidget) {
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
            // Pink background — full page
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.accentPinkBg.withOpacity(0.7),
                      AppColors.accentPinkLight,
                      Colors.white,
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.03),

                  // Header — WHY CHOOSE US?
                  FadeTransition(
                    opacity: _headerFadeAnimation,
                    child: Transform.scale(
                      scale: _headerScaleAnimation.value,
                      child: Column(
                        children: [
                          // Brain icon
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.psychology,
                              size: 40,
                              color: AppColors.accentPink,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'WHY CHOOSE',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: AppColors.accentPink,
                              letterSpacing: 2.0,
                            ),
                          ),
                          const Text(
                            'US?',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: AppColors.accentPink,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: size.height * 0.04),

                  // Benefit cards
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildBenefitCard(
                            index: 0,
                            title: 'More Accurate Early Detection',
                            description:
                                'AI helps detect signs of cancer that the human eye might miss',
                            isCheckLeft: true,
                          ),
                          SizedBox(height: size.height * 0.02),
                          _buildBenefitCard(
                            index: 1,
                            title: 'Faster Diagnosis',
                            description:
                                'Automated analysis saves time for faster treatment',
                            isCheckLeft: false,
                          ),
                          SizedBox(height: size.height * 0.02),
                          _buildBenefitCard(
                            index: 2,
                            title: 'Doctor & AI Collaboration',
                            description:
                                'Combining doctor expertise and AI intelligence for optimal results',
                            isCheckLeft: true,
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

  Widget _buildBenefitCard({
    required int index,
    required String title,
    required String description,
    required bool isCheckLeft,
  }) {
    final checkIcon = Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.accentPink,
      ),
      child: const Icon(
        Icons.check,
        color: Colors.white,
        size: 20,
      ),
    );

    final textContent = Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary.withOpacity(0.8),
              height: 1.3,
            ),
          ),
        ],
      ),
    );

    return SlideTransition(
      position: _cardSlideAnimations[index],
      child: FadeTransition(
        opacity: _cardFadeAnimations[index],
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentPink.withOpacity(0.12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: isCheckLeft
                ? [checkIcon, const SizedBox(width: 14), textContent]
                : [textContent, const SizedBox(width: 14), checkIcon],
          ),
        ),
      ),
    );
  }
}
