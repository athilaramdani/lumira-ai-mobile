import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import 'wave_clipper.dart';
import 'pulse_button.dart';

/// Landing Page 3 — Halaman utama info dengan wave background
///
/// Animasi:
/// 1. Parallax doctor image
/// 2. Staggered fade-in + slide-up (Badge → Title → Description)
/// 3. Animated "Start Now!" button dengan pulse/glow
/// 4. Wave background opacity reveal
class LandingPage3 extends StatefulWidget {
  /// Offset halaman dari PageController, digunakan untuk parallax.
  final double pageOffset;

  /// Callback saat tombol "Start Now!" ditekan
  final VoidCallback onStartPressed;

  const LandingPage3({
    super.key,
    required this.pageOffset,
    required this.onStartPressed,
  });

  @override
  State<LandingPage3> createState() => _LandingPage3State();
}

class _LandingPage3State extends State<LandingPage3>
    with TickerProviderStateMixin {
  late final AnimationController _enterController;

  // Stagger animations
  late final Animation<double> _waveFadeAnimation;
  late final Animation<double> _badgeFadeAnimation;
  late final Animation<Offset> _badgeSlideAnimation;
  late final Animation<double> _titleFadeAnimation;
  late final Animation<Offset> _titleSlideAnimation;
  late final Animation<double> _descFadeAnimation;
  late final Animation<Offset> _descSlideAnimation;
  late final Animation<double> _buttonFadeAnimation;
  late final Animation<Offset> _buttonSlideAnimation;

  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();

    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    // Wave background opacity (0.0 → 0.3 interval)
    _waveFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _enterController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    // Badge (0.1 → 0.4)
    _badgeFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _enterController,
        curve: const Interval(0.1, 0.4, curve: Curves.easeOutCubic),
      ),
    );
    _badgeSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _enterController,
        curve: const Interval(0.1, 0.4, curve: Curves.easeOutCubic),
      ),
    );

    // Title (0.25 → 0.55)
    _titleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _enterController,
        curve: const Interval(0.25, 0.55, curve: Curves.easeOutCubic),
      ),
    );
    _titleSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _enterController,
        curve: const Interval(0.25, 0.55, curve: Curves.easeOutCubic),
      ),
    );

    // Description (0.4 → 0.7)
    _descFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _enterController,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOutCubic),
      ),
    );
    _descSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _enterController,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    // Button (0.6 → 0.9)
    _buttonFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _enterController,
        curve: const Interval(0.6, 0.9, curve: Curves.easeOutCubic),
      ),
    );
    _buttonSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _enterController,
        curve: const Interval(0.6, 0.9, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant LandingPage3 oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Trigger animasi saat halaman hampir terlihat
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
    // Parallax — doctor bergerak lebih lambat
    final double parallaxOffset = widget.pageOffset * 60;

    return AnimatedBuilder(
      animation: _enterController,
      builder: (context, _) {
        return Stack(
          children: [
            // Wave background — fade reveal
            Positioned.fill(
              child: Opacity(
                opacity: _waveFadeAnimation.value,
                child: ClipPath(
                  clipper: WaveClipper(),
                  child: Container(
                    color: AppColors.primaryLighter,
                  ),
                ),
              ),
            ),

            // Doctor Image — parallax
            Positioned(
              bottom: 0,
              right: -40,
              child: Opacity(
                opacity: _waveFadeAnimation.value,
                child: Transform.translate(
                  offset: Offset(parallaxOffset, 0),
                  child: Image.asset(
                    AppAssets.doctor,
                    height: 500,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            // Content — staggered fade-in + slide-up
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Badge — fade + slide
                        SlideTransition(
                          position: _badgeSlideAnimation,
                          child: FadeTransition(
                            opacity: _badgeFadeAnimation,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.memory, color: Colors.white, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'Powered By AI',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Title — fade + slide
                        SlideTransition(
                          position: _titleSlideAnimation,
                          child: FadeTransition(
                            opacity: _titleFadeAnimation,
                            child: const Text(
                              'Early Detection of\nBreast Cancer with\nAI Technology',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Description — fade + slide
                        SlideTransition(
                          position: _descSlideAnimation,
                          child: FadeTransition(
                            opacity: _descFadeAnimation,
                            child: const SizedBox(
                              width: 260,
                              child: Text(
                                'An AI-based mammogram analysis system that helps doctors provide more accurate and faster diagnoses for breast cancer treatment.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Button — fade + slide + pulse/glow
                  Padding(
                    padding: const EdgeInsets.only(left: 32.0, bottom: 60.0),
                    child: SlideTransition(
                      position: _buttonSlideAnimation,
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
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
