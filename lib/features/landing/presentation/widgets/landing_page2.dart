import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';

class LandingPage2 extends StatefulWidget {
  final double pageOffset;
  const LandingPage2({super.key, required this.pageOffset});

  @override
  State<LandingPage2> createState() => _LandingPage2State();
}

class _LandingPage2State extends State<LandingPage2>
    with TickerProviderStateMixin {
  late final AnimationController _enterController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

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
  void didUpdateWidget(covariant LandingPage2 oldWidget) {
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
    final parallaxOffset = widget.pageOffset * 100;

    return Stack(
      children: [
        // Blue background that curves at bottom left
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF8FD6F8), Color(0xFFCBEBFA)], // approximates light blue from image
              ),
            ),
          ),
        ),
        // White bottom curve
        Positioned(
          bottom: -150,
          left: -100,
          right: -100,
          child: Container(
            height: 350,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
        
        SafeArea(
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge "Powered By AI"
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.memory, color: AppColors.primary, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Powered By AI',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Title
                    const Text(
                      'Early Detection of\nBreast Cancer with\nAI Technology',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Subtitle
                    const SizedBox(
                      width: 250,
                      child: Text(
                        'An AI-based mammogram analysis system that helps doctors provide more accurate and faster diagnoses for breast cancer treatment.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Parallax Doctor Image
        Positioned(
          bottom: 120, // space for pill/button
          right: -20,
          left: 50, // offset slightly
          child: Transform.translate(
            offset: Offset(parallaxOffset, 0),
            child: Opacity(
              opacity: (1 - widget.pageOffset.abs()).clamp(0.0, 1.0),
              child: Image.asset(
                AppAssets.doctor,
                height: 450,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
