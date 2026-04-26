import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../auth/login_page.dart';
import 'presentation/widgets/landing_page1.dart';
import 'presentation/widgets/landing_page2.dart';
import 'presentation/widgets/landing_page3.dart';
import 'presentation/widgets/landing_page4.dart';
import 'presentation/widgets/landing_page5.dart';
import 'presentation/widgets/custom_pill_indicator.dart';
import 'presentation/widgets/pulse_button.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  late final PageController _pageController;
  double _currentPage = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController()
      ..addListener(() {
        setState(() {
          _currentPage = _pageController.page ?? 0.0;
        });
      });
  }

  @override
  void dispose() {
    _pageController.dispose();
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

  void _onIconTapped(int index) {
    _pageController.animateToPage(
      index + 1, // icons index 0 maps to page index 1
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Tampilkan pill dan start button hanya setelah melewati halaman Logo (index 0)
    final bool showBottomNav = _currentPage > 0.5;
    
    // Normalized nav index (0 to 3) for the pill indicator
    int navIndex = (_currentPage - 1.0).clamp(0.0, 3.0).round();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // === PageView ===
          PageView(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            children: [
              // Page 0 — Logo Splash
              const LandingPage1(),

              // Page 1 — Info (Doctor + Text)
              LandingPage2(pageOffset: _currentPage - 1.0),

              // Page 2 — Key Features (AI Analysis & Doctor Review)
              LandingPage3(pageOffset: _currentPage - 2.0),

              // Page 3 — How It Works
              LandingPage4(pageOffset: _currentPage - 3.0),

              // Page 4 — Why Choose Us
              LandingPage5(pageOffset: _currentPage - 4.0),
            ],
          ),

          // === Global "Start Now!" Button & Custom Pill Indicator ===
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 400),
              opacity: showBottomNav ? 1.0 : 0.0,
              child: IgnorePointer(
                ignoring: !showBottomNav,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Start Now Button
                    PulseButton(
                      isCircular: false,
                      onPressed: _navigateToLogin,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Start Now!',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // 4-Icon Pill Indicator
                    CustomPillIndicator(
                      currentIndex: navIndex,
                      onIconTapped: _onIconTapped,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
