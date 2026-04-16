import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';

/// Landing Page 2 — Doctor Image dengan background semi-circle
///
/// Animasi:
/// 1. Parallax doctor image (bergerak lebih lambat saat swipe)
/// 2. Fade-in logo di bagian atas
/// 3. Scale-in semi-circle background
class LandingPage2 extends StatefulWidget {
  /// Offset halaman dari PageController, digunakan untuk parallax.
  /// Nilai 0.0 = halaman tepat di tengah.
  final double pageOffset;

  const LandingPage2({
    super.key,
    required this.pageOffset,
  });

  @override
  State<LandingPage2> createState() => _LandingPage2State();
}

class _LandingPage2State extends State<LandingPage2>
    with TickerProviderStateMixin {
  late final AnimationController _enterController;
  late final Animation<double> _logoFadeAnimation;
  late final Animation<double> _circleScaleAnimation;
  late final Animation<double> _doctorFadeAnimation;

  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();

    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _enterController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _circleScaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _enterController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _doctorFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _enterController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant LandingPage2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Trigger animasi saat halaman hampir terlihat (offset mendekati 0)
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
    // Parallax factor — doctor bergerak 40% lebih lambat dari page
    final double parallaxOffset = widget.pageOffset * 80;

    return AnimatedBuilder(
      animation: _enterController,
      builder: (context, _) {
        return Stack(
          children: [
            // Background semi-circle — scale-in animation
            Positioned(
              bottom: -200,
              left: -100,
              right: -100,
              child: Transform.scale(
                scale: _circleScaleAnimation.value,
                child: Container(
                  height: 600,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryLighter.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),
            // Content
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 80),
                  // Logo — fade-in
                  FadeTransition(
                    opacity: _logoFadeAnimation,
                    child: Center(
                      child: Image.asset(AppAssets.logo, width: 120),
                    ),
                  ),
                  const Spacer(),
                  // Doctor image — parallax + fade
                  Expanded(
                    flex: 8,
                    child: FadeTransition(
                      opacity: _doctorFadeAnimation,
                      child: Transform.translate(
                        offset: Offset(parallaxOffset, 0),
                        child: Center(
                          child: Image.asset(
                            AppAssets.doctor,
                            fit: BoxFit.contain,
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
