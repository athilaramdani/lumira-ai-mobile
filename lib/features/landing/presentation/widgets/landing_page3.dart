import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class LandingPage3 extends StatefulWidget {
  final double pageOffset;
  const LandingPage3({super.key, required this.pageOffset});

  @override
  State<LandingPage3> createState() => _LandingPage3State();
}

class _LandingPage3State extends State<LandingPage3>
    with TickerProviderStateMixin {
  late final AnimationController _enterController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  
  final PageController _innerPageController = PageController();
  int _currentInnerPage = 0;

  @override
  void initState() {
    super.initState();
    _enterController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));

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
  void didUpdateWidget(covariant LandingPage3 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pageOffset.abs() < 0.5) {
      _enterController.forward();
    }
  }

  @override
  void dispose() {
    _enterController.dispose();
    _innerPageController.dispose();
    super.dispose();
  }

  void _nextInnerSlide() {
    if (_currentInnerPage == 0) {
      _innerPageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _prevInnerSlide() {
    if (_currentInnerPage == 1) {
      _innerPageController.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top Wave Background
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 300,
          child: ClipPath(
            clipper: TopCurveClipper(),
            child: Container(
              color: const Color(0xFFCBEBFA),
            ),
          ),
        ),
        
        SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      const Text(
                        'KEY FEATURES',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Leading-edge technology for better diagnosis',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              // Inner Slider
              SizedBox(
                height: 400,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Big Center Circle Background
                    Container(
                      width: 320,
                      height: 320,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFCBEBFA).withOpacity(0.5),
                      ),
                    ),
                    
                    // Inner PageView
                    PageView(
                      controller: _innerPageController,
                      onPageChanged: (index) {
                        setState(() { _currentInnerPage = index; });
                      },
                      children: [
                        _buildFeatureItem(
                          icon: Icons.memory,
                          title: 'AI Analysis',
                          description: 'Automated mammogram\nimage analysis using deep\nlearning algorithms with\nhigh accuracy for early\nbreast cancer detection.',
                        ),
                        _buildFeatureItem(
                          icon: Icons.medical_services_outlined,
                          title: 'Doctor Review',
                          description: 'AI results are reviewed by\nspecialist doctors to ensure\nan accurate diagnosis and\nappropriate treatment.',
                        ),
                      ],
                    ),

                    // Left/Right Nav Indicators
                    Positioned(
                      left: 16,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios),
                        color: _currentInnerPage == 0 ? Colors.white54 : Colors.white,
                        onPressed: _prevInnerSlide,
                      ),
                    ),
                    Positioned(
                      right: 16,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_forward_ios),
                        color: _currentInnerPage == 1 ? Colors.white54 : Colors.white,
                        onPressed: _nextInnerSlide,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 80, color: Colors.white),
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          description,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class TopCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 80);
    path.quadraticBezierTo(
        size.width / 2, size.height + 40, size.width, size.height - 80);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
