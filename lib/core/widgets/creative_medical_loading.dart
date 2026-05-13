import 'package:flutter/material.dart';

class CreativeMedicalLoading extends StatefulWidget {
  final String text;
  const CreativeMedicalLoading({super.key, this.text = 'Loading'});

  @override
  State<CreativeMedicalLoading> createState() => _CreativeMedicalLoadingState();
}

class _CreativeMedicalLoadingState extends State<CreativeMedicalLoading>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late AnimationController _rotateController;

  @override
  void initState() {
    super.initState();
    // Pulsing heartbeat effect
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Rotating outer ring effect
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 90,
          height: 90,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer rotating ring
              AnimatedBuilder(
                animation: _rotateController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotateController.value * 2 * 3.14159,
                    child: SizedBox(
                      width: 90,
                      height: 90,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          const Color(0xFF40B4FF).withOpacity(0.4),
                        ),
                        strokeWidth: 2,
                      ),
                    ),
                  );
                },
              ),
              // Inner rotating solid ring (reverse)
              AnimatedBuilder(
                animation: _rotateController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: -_rotateController.value * 2 * 3.14159,
                    child: SizedBox(
                      width: 65,
                      height: 65,
                      child: CircularProgressIndicator(
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF40B4FF),
                        ),
                        strokeWidth: 3,
                      ),
                    ),
                  );
                },
              ),
              // Pulsating Heart inside
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: const Color(0xFF40B4FF).withOpacity(0.15),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF40B4FF).withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: _scaleAnimation.value * 5,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.favorite,
                          color: Color(0xFF40B4FF),
                          size: 26,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        // Loading text with slight fade
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Opacity(
              opacity: 0.6 + (_pulseController.value * 0.4),
              child: Text(
                widget.text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0369A1), // Darker medical blue
                  letterSpacing: 1.5,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
