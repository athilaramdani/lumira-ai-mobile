import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';

class LandingPage5 extends StatefulWidget {
  final double pageOffset;
  const LandingPage5({super.key, required this.pageOffset});

  @override
  State<LandingPage5> createState() => _LandingPage5State();
}

class _LandingPage5State extends State<LandingPage5>
    with TickerProviderStateMixin {
  late final AnimationController _enterController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _enterController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));

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
  void didUpdateWidget(covariant LandingPage5 oldWidget) {
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
    const pinkColor = Color(0xFFF18CC2); // Approximated from image
    
    return Stack(
      children: [
        // Pink Background shape
        Positioned(
          top: 150,
          left: 0,
          right: 0,
          bottom: 120, // space for pill
          child: Container(
            decoration: const BoxDecoration(
              color: pinkColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.elliptical(200, 60),
                topRight: Radius.elliptical(200, 60),
                bottomLeft: Radius.elliptical(200, 40),
                bottomRight: Radius.elliptical(200, 40),
              ),
            ),
          ),
        ),
        
        SafeArea(
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Header row: Logo + Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(AppAssets.logo, width: 60),
                        const SizedBox(width: 16),
                        const Text(
                          'WHY CHOOSE\nUS?',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: pinkColor,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 80), // spacer to reach pink area

                    // List elements
                    _buildReasonCard(
                      title: 'More Accurate Early Detection',
                      description: 'AI helps detect signs of cancer that the\nhuman eye might miss',
                      isCheckmarkLeft: true,
                      pinkColor: pinkColor,
                    ),
                    const SizedBox(height: 16),
                    _buildReasonCard(
                      title: 'Faster Diagnosis',
                      description: 'Automated analysis saves time for\nfaster treatment',
                      isCheckmarkLeft: false,
                      pinkColor: pinkColor,
                    ),
                    const SizedBox(height: 16),
                    _buildReasonCard(
                      title: 'Doctor & AI Collaboration',
                      description: 'Combining doctor expertise and AI\nIntelligence for optimal results',
                      isCheckmarkLeft: true,
                      pinkColor: pinkColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReasonCard({
    required String title,
    required String description,
    required bool isCheckmarkLeft,
    required Color pinkColor,
  }) {
    final checkmark = Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: pinkColor,
      ),
      child: const Icon(Icons.check, color: Colors.white, size: 20),
    );

    final textColumn = Expanded(
      child: Column(
        crossAxisAlignment: isCheckmarkLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: pinkColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            textAlign: isCheckmarkLeft ? TextAlign.left : TextAlign.right,
            style: TextStyle(
              fontSize: 10,
              color: pinkColor.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: isCheckmarkLeft
            ? [checkmark, const SizedBox(width: 12), textColumn]
            : [textColumn, const SizedBox(width: 12), checkmark],
      ),
    );
  }
}
