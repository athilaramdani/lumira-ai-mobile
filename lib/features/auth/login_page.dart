import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';
import 'presentation/controllers/auth_controller.dart';
import '../dashboard/presentation/pages/doctor_dashboard_page.dart';
import '../dashboard/presentation/pages/dashboard_page.dart';

/// Login Page — Sesuai desain Figma
///
/// Features:
/// - Doctor image di atas dengan gradient background
/// - Form email + password dengan validasi inline
/// - Loading state dengan overlay & spinner via Riverpod
/// - Success state dengan checkmark overlay via Riverpod
/// - Staggered fade-in animations
/// - Responsive layout dengan MediaQuery
/// - Keyboard handling (auto-scroll)
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // --- Animasi masuk ---
  late final AnimationController _enterController;
  late final Animation<double> _doctorFadeAnimation;
  late final Animation<Offset> _doctorSlideAnimation;
  late final Animation<double> _emailFadeAnimation;
  late final Animation<Offset> _emailSlideAnimation;
  late final Animation<double> _passwordFadeAnimation;
  late final Animation<Offset> _passwordSlideAnimation;
  late final Animation<double> _buttonFadeAnimation;
  late final Animation<Offset> _buttonSlideAnimation;

  // --- Loading overlay animation ---
  late final AnimationController _loadingOverlayController;
  late final Animation<double> _overlayFadeAnimation;

  @override
  void initState() {
    super.initState();

    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    // Doctor image (0.0 → 0.4) — slide from top + fade
    _doctorFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _enterController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );
    _doctorSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _enterController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
      ),
    );

    // Email field (0.2 → 0.5)
    _emailFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _enterController,
        curve: const Interval(0.2, 0.5, curve: Curves.easeOutCubic),
      ),
    );
    _emailSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _enterController,
        curve: const Interval(0.2, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    // Password field (0.35 → 0.65)
    _passwordFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _enterController,
        curve: const Interval(0.35, 0.65, curve: Curves.easeOutCubic),
      ),
    );
    _passwordSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _enterController,
        curve: const Interval(0.35, 0.65, curve: Curves.easeOutCubic),
      ),
    );

    // Login button (0.5 → 0.8)
    _buttonFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _enterController,
        curve: const Interval(0.5, 0.8, curve: Curves.easeOutCubic),
      ),
    );
    _buttonSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _enterController,
        curve: const Interval(0.5, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    // Loading overlay
    _loadingOverlayController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _overlayFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _loadingOverlayController,
        curve: Curves.easeOut,
      ),
    );

    // Mulai animasi masuk
    _enterController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _enterController.dispose();
    _loadingOverlayController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email wajib diisi';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password wajib diisi';
    }
    if (value.length < 8) {
      return 'Password minimal 8 karakter';
    }
    return null;
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    // Trigger login via Riverpod controller
    await ref.read(authControllerProvider.notifier).login(
      _emailController.text,
      _passwordController.text,
    );
  }

  InputDecoration _buildInputDecoration({
    required String label,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: AppColors.primary,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      errorStyle: const TextStyle(
        fontSize: 11,
        color: AppColors.error,
        height: 0.8,
      ),
      suffixIcon: suffixIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bool isKeyboardOpen = bottomInset > 0;
    final topImageHeight = size.height * 0.38;

    // Listen to Auth State
    ref.listen(authControllerProvider, (previous, next) {
      if (next.isLoading) {
        _loadingOverlayController.forward();
      } else if (next.error != null) {
        _loadingOverlayController.reverse();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
          ),
        );
      } else if (next.isSuccess) {
        // Overlay sudah muncul karena isLoading sebelumnya true
        // Tunggu sebentar untuk sukses animation lalu pindah halaman
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            _loadingOverlayController.reverse();
            
            final role = next.user?.role;
            if (role == 'patient' || role == 'Patient') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const DashboardPage()),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const DoctorDashboardPage()),
              );
            }
          }
        });
      }
    });

    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Main content
          AnimatedBuilder(
            animation: _enterController,
            builder: (context, _) {
              return SingleChildScrollView(
                physics: isKeyboardOpen
                    ? const AlwaysScrollableScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: size.height,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // === Top Section: Doctor Image ===
                        SlideTransition(
                          position: _doctorSlideAnimation,
                          child: FadeTransition(
                            opacity: _doctorFadeAnimation,
                            child: Container(
                              height: topImageHeight,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primaryLightest,
                                    Colors.white,
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              child: SafeArea(
                                bottom: false,
                                child: Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    // Back button
                                    Positioned(
                                      top: 0,
                                      left: 10,
                                      child: Container(
                                        margin: const EdgeInsets.only(top: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.arrow_back_ios_new,
                                            color: AppColors.primary,
                                            size: 20,
                                          ),
                                          onPressed: () => Navigator.pop(context),
                                        ),
                                      ),
                                    ),
                                    // Doctor image
                                    Positioned(
                                      bottom: 0,
                                      child: Image.asset(
                                        AppAssets.doctor,
                                        height: topImageHeight * 0.85,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // === Form Section ===
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  SizedBox(height: size.height * 0.03),

                                  // Email Field
                                  SlideTransition(
                                    position: _emailSlideAnimation,
                                    child: FadeTransition(
                                      opacity: _emailFadeAnimation,
                                      child: TextFormField(
                                        controller: _emailController,
                                        keyboardType: TextInputType.emailAddress,
                                        textInputAction: TextInputAction.next,
                                        enabled: !authState.isLoading,
                                        validator: _validateEmail,
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        decoration: _buildInputDecoration(
                                          label: 'Email',
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: size.height * 0.025),

                                  // Password Field
                                  SlideTransition(
                                    position: _passwordSlideAnimation,
                                    child: FadeTransition(
                                      opacity: _passwordFadeAnimation,
                                      child: TextFormField(
                                        controller: _passwordController,
                                        obscureText: _obscurePassword,
                                        textInputAction: TextInputAction.done,
                                        enabled: !authState.isLoading,
                                        validator: _validatePassword,
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        onFieldSubmitted: (_) => _handleLogin(),
                                        decoration: _buildInputDecoration(
                                          label: 'Password',
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _obscurePassword
                                                  ? Icons.visibility_outlined
                                                  : Icons.visibility_off_outlined,
                                              color: AppColors.primary,
                                              size: 20,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _obscurePassword = !_obscurePassword;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  const Spacer(),

                                  // Login Button
                                  SlideTransition(
                                    position: _buttonSlideAnimation,
                                    child: FadeTransition(
                                      opacity: _buttonFadeAnimation,
                                      child: SizedBox(
                                        height: 50,
                                        child: ElevatedButton(
                                          onPressed: authState.isLoading ? null : _handleLogin,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primary,
                                            foregroundColor: Colors.white,
                                            disabledBackgroundColor:
                                                AppColors.primary.withOpacity(0.6),
                                            disabledForegroundColor: Colors.white70,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 14),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                            ),
                                            elevation: 0,
                                          ),
                                          child: const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Login',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Icon(Icons.arrow_forward_ios,
                                                  size: 14),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),


                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // === Loading / Success Overlay ===
          AnimatedBuilder(
            animation: _loadingOverlayController,
            builder: (context, _) {
              if (_loadingOverlayController.value == 0 && !authState.isLoading && !authState.isSuccess) {
                return const SizedBox.shrink();
              }
              return Opacity(
                opacity: _overlayFadeAnimation.value,
                child: Container(
                  color: Colors.white.withOpacity(0.85),
                  child: Center(
                    child: authState.isSuccess
                        ? _buildSuccessOverlay()
                        : _buildLoadingOverlay(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.15),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Loading',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessOverlay() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.success.withOpacity(0.2),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "You're Log in",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
