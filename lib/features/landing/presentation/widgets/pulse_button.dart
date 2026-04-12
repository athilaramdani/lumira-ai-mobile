import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Widget reusable untuk tombol dengan efek pulse/glow.
/// Tombol berdenyut halus untuk menarik perhatian pengguna.
/// Menggunakan AnimationController internal yang repeat reverse.
class PulseButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color backgroundColor;
  final Color glowColor;
  final double minScale;
  final double maxScale;
  final Duration pulseDuration;
  final EdgeInsetsGeometry? padding;
  final ShapeBorder? shape;
  final bool isCircular;

  const PulseButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.backgroundColor = AppColors.primary,
    this.glowColor = AppColors.primary,
    this.minScale = 1.0,
    this.maxScale = 1.08,
    this.pulseDuration = const Duration(milliseconds: 1500),
    this.padding,
    this.shape,
    this.isCircular = false,
  });

  @override
  State<PulseButton> createState() => _PulseButtonState();
}

class _PulseButtonState extends State<PulseButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: widget.pulseDuration,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.15,
      end: 0.45,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              shape: widget.isCircular ? BoxShape.circle : BoxShape.rectangle,
              borderRadius: widget.isCircular ? null : BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: widget.glowColor.withValues(alpha: _glowAnimation.value),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: widget.isCircular
          ? FloatingActionButton(
              onPressed: widget.onPressed,
              backgroundColor: widget.backgroundColor,
              foregroundColor: Colors.white,
              elevation: 4,
              child: widget.child,
            )
          : ElevatedButton(
              onPressed: widget.onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.backgroundColor,
                foregroundColor: Colors.white,
                padding: widget.padding ??
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: widget.shape as OutlinedBorder? ??
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                elevation: 0,
              ),
              child: widget.child,
            ),
    );
  }
}
