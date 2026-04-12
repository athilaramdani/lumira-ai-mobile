import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../auth/login_page.dart';
import 'presentation/widgets/landing_page1.dart';
import 'presentation/widgets/landing_page2.dart';
import 'presentation/widgets/landing_page3.dart';
import 'presentation/widgets/landing_page4.dart';
import 'presentation/widgets/landing_page5.dart';
import 'presentation/widgets/animated_dot_indicator.dart';
import 'presentation/widgets/pulse_button.dart';

/// Landing Page utama — Orchestrator
///
/// Mengatur PageView dengan 5 halaman landing,
/// dot indicator animasi, tombol Skip, dan FAB Next dengan pulse/glow.
class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  late final PageController _pageController;

  static const int _totalPages = 5;

  // Current page sebagai double agar dot indicator dan parallax smooth
  double _currentPage = 0.0;

  // Skip button fade-in
  late final AnimationController _skipFadeController;
  late final Animation<double> _skipFadeAnimation;

  @override
  void initState() {
    super.initState();

    _pageController = PageController()
      ..addListener(() {
        setState(() {
          _currentPage = _pageController.page ?? 0.0;
        });
      });

    // Skip button muncul setelah delay 1.5s agar tidak mengganggu logo animation
    _skipFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _skipFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _skipFadeController,
        curve: Curves.easeOut,
      ),
    );

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) _skipFadeController.forward();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _skipFadeController.dispose();
    super.dispose();
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.05),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _goToNextPage() {
    if (_pageController.hasClients) {
      final currentPageIndex = _pageController.page?.round() ?? 0;
      if (currentPageIndex == _totalPages - 1) {
        _navigateToLogin();
      } else {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOutCubic,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // === PageView dengan 5 halaman ===
          PageView(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            children: [
              // Page 1 — Logo (animasi internal)
              const LandingPage1(),

              // Page 2 — Doctor Image (parallax)
              LandingPage2(
                pageOffset: _currentPage - 1.0,
              ),

              // Page 3 — Info (stagger + parallax)
              LandingPage3(
                pageOffset: _currentPage - 2.0,
                onStartPressed: _navigateToLogin,
              ),

              // Page 4 — How It Works
              LandingPage4(
                pageOffset: _currentPage - 3.0,
                onStartPressed: _navigateToLogin,
              ),

              // Page 5 — Why Choose Us
              LandingPage5(
                pageOffset: _currentPage - 4.0,
                onStartPressed: _navigateToLogin,
              ),
            ],
          ),

          // === Skip Button (fade-in delay) ===
          Positioned(
            top: 50,
            right: 20,
            child: FadeTransition(
              opacity: _skipFadeAnimation,
              child: TextButton(
                onPressed: _navigateToLogin,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  backgroundColor: Colors.black.withValues(alpha: 0.05),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          // === Dot Indicator (bottom center) ===
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: AnimatedDotIndicator(
              currentPage: _currentPage,
              pageCount: _totalPages,
            ),
          ),

          // === Next FAB (pulse/glow) ===
          Positioned(
            bottom: 36,
            right: 20,
            child: PulseButton(
              isCircular: true,
              onPressed: _goToNextPage,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return RotationTransition(
                    turns: Tween<double>(begin: 0.5, end: 1.0)
                        .animate(animation),
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                child: _currentPage.round() == _totalPages - 1
                    ? const Icon(Icons.check, key: ValueKey('check'))
                    : const Icon(Icons.arrow_forward,
                        key: ValueKey('arrow')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
