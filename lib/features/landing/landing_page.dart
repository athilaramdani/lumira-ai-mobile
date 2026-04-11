import 'package:flutter/material.dart';
import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../auth/login_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            children: [
              _buildPage1(),
              _buildPage2(),
              _buildPage3(),
            ],
          ),
          // Optional: Add a skip button or dots here if desired later
        ],
      ),
    );
  }

  Widget _buildPage1() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(AppAssets.logo, width: 140),
          const SizedBox(height: 24),
          const Text(
            'Lumira AI',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage2() {
    return Stack(
      children: [
        // Background semi-circle
        Positioned(
          bottom: -200,
          left: -100,
          right: -100,
          child: Container(
            height: 600,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryLighter,
            ),
          ),
        ),
        // Content
        SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 80),
              Center(
                child: Image.asset(AppAssets.logo, width: 120),
              ),
              const Spacer(),
              // Doctor image
              Expanded(
                flex: 8,
                child: Center(
                  child: Image.asset(
                    AppAssets.doctor,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPage3() {
    return Stack(
      children: [
        // Wave background
        Positioned.fill(
          child: ClipPath(
            clipper: WaveClipper(),
            child: Container(
              color: AppColors.primaryLighter,
            ),
          ),
        ),
        // Doctor Image
        Positioned(
          bottom: 0,
          right: -40,
          child: Image.asset(
            AppAssets.doctor,
            height: 500,
            fit: BoxFit.contain,
          ),
        ),
        // Content
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
                    // Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    const SizedBox(height: 24),
                    // Title
                    const Text(
                      'Early Detection of\nBreast Cancer with\nAI Technology',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Description
                    const SizedBox(
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
                  ],
                ),
              ),
              const Spacer(),
              // Button
              Padding(
                padding: const EdgeInsets.only(left: 32.0, bottom: 60.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
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
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height * 0.55);
    
    var firstControlPoint = Offset(size.width * 0.25, size.height * 0.65);
    var firstEndPoint = Offset(size.width * 0.5, size.height * 0.52);
    
    var secondControlPoint = Offset(size.width * 0.75, size.height * 0.38);
    var secondEndPoint = Offset(size.width, size.height * 0.45);

    path.quadraticBezierTo(
      firstControlPoint.dx, firstControlPoint.dy, 
      firstEndPoint.dx, firstEndPoint.dy
    );
    path.quadraticBezierTo(
      secondControlPoint.dx, secondControlPoint.dy, 
      secondEndPoint.dx, secondEndPoint.dy
    );
    
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
