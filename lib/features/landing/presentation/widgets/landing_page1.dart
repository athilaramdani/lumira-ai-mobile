import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';

/// Landing Page 1 — Logo Screen
///
/// Animasi:
/// 1. Scale-in logo dengan Curves.elasticOut
/// 2. Fade-in + slide-up teks "Lumira AI"
/// 3. Subtle floating/breathing pada logo setelah animasi awal selesai
class LandingPage1 extends StatefulWidget {
  const LandingPage1({super.key});

  @override
  State<LandingPage1> createState() => _LandingPage1State();
}

class _LandingPage1State extends State<LandingPage1>
    with TickerProviderStateMixin {
  // --- Scale-in Logo ---
  late final AnimationController _logoScaleController;
  late final Animation<double> _logoScaleAnimation;

  // --- Fade-in + Slide-up Text ---
  late final AnimationController _textController;
  late final Animation<double> _textFadeAnimation;
  late final Animation<Offset> _textSlideAnimation;

  // --- Subtle floating logo (setelah initial anim) ---
  late final AnimationController _floatController;
  late final Animation<double> _floatAnimation;

  // --- Subtitle fade ---
  late final AnimationController _subtitleController;
  late final Animation<double> _subtitleFadeAnimation;
  late final Animation<Offset> _subtitleSlideAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Logo scale-in (elasticOut — bouncy feel)
    _logoScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoScaleController,
        curve: Curves.elasticOut,
      ),
    );

    // 2. Text fade-in + slide-up
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOutCubic,
      ),
    );
    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOutCubic,
      ),
    );

    // 3. Subtitle (tagline) fade-in + slide-up
    _subtitleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _subtitleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _subtitleController,
        curve: Curves.easeOutCubic,
      ),
    );
    _subtitleSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _subtitleController,
        curve: Curves.easeOutCubic,
      ),
    );

    // 4. Subtle floating animation (loop)
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _floatAnimation = Tween<double>(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(
        parent: _floatController,
        curve: Curves.easeInOut,
      ),
    );

    // Mulai sequence animasi
    _startAnimationSequence();
  }

  Future<void> _startAnimationSequence() async {
    // Logo scale-in langsung mulai
    _logoScaleController.forward();

    // Tunggu 800ms, lalu teks muncul
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    _textController.forward();

    // Tunggu 400ms lagi, subtitle muncul
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    _subtitleController.forward();

    // Tunggu text selesai, mulai floating loop
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    _floatController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _logoScaleController.dispose();
    _textController.dispose();
    _subtitleController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated Logo — Scale-in + floating
          AnimatedBuilder(
            animation: Listenable.merge([_logoScaleController, _floatController]),
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _floatAnimation.value),
                child: Transform.scale(
                  scale: _logoScaleAnimation.value,
                  child: child,
                ),
              );
            },
            child: Image.asset(AppAssets.logo, width: 140),
          ),

          const SizedBox(height: 24),

          // Animated Text — Fade + Slide
          SlideTransition(
            position: _textSlideAnimation,
            child: FadeTransition(
              opacity: _textFadeAnimation,
              child: const Text(
                'Lumira AI',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Animated Subtitle — Fade + Slide (staggered)
          SlideTransition(
            position: _subtitleSlideAnimation,
            child: FadeTransition(
              opacity: _subtitleFadeAnimation,
              child: Text(
                'AI-Powered Breast Cancer Detection',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary.withValues(alpha: 0.8),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
