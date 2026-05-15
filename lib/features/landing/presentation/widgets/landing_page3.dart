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
    final isAi = _currentInnerPage == 0;
    final baseColor = isAi ? Colors.white : AppColors.primaryLighter;
    final accentColor = isAi ? AppColors.primaryLighter : Colors.white;
    final primaryTextColor = isAi ? Colors.white : AppColors.primary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: baseColor,
      child: Stack(
        children: [
          // Top Wave Background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 300,
            child: ClipPath(
              clipper: TopCurveClipper(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                color: accentColor,
              ),
            ),
          ),
          
          // Bottom Wave Background
          Positioned(
            bottom: -50,
            left: -50,
            right: -50,
            height: 250,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: accentColor,
                shape: BoxShape.circle,
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
                        Text(
                          'KEY FEATURES',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: primaryTextColor,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Leading-edge technology for better diagnosis',
                          style: TextStyle(
                            fontSize: 12,
                            color: primaryTextColor.withOpacity(0.9),
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
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 320,
                        height: 320,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accentColor,
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
                            textColor: Colors.white,
                          ),
                          _buildFeatureItem(
                            icon: Icons.medical_services_outlined,
                            title: 'Doctor Review',
                            description: 'AI results are reviewed by\nspecialist doctors to ensure\nan accurate diagnosis and\nappropriate treatment.',
                            textColor: AppColors.primary,
                          ),
                        ],
                      ),

                      // Left/Right Nav Indicators
                      Positioned(
                        left: 16,
                        child: _buildArrowButton(
                          icon: Icons.arrow_back_ios_new,
                          isActive: _currentInnerPage > 0,
                          onPressed: _prevInnerSlide,
                        ),
                      ),
                      Positioned(
                        right: 16,
                        child: _buildArrowButton(
                          icon: Icons.arrow_forward_ios,
                          isActive: _currentInnerPage < 1,
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
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required Color textColor,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 80, color: textColor),
        const SizedBox(height: 16),
        Text(
          title,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          description,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: textColor,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildArrowButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    final bgColor = isActive ? AppColors.primary : AppColors.primary.withOpacity(0.3);
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          boxShadow: [
            if (isActive)
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
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
