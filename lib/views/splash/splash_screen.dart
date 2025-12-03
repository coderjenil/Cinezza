import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/splash_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../services/payment_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _wordmarkController;
  late AnimationController _progressController;
  late AnimationController _ambientController;

  late SplashController splashController;

  // Solid gradient fallback (always shows, no network dependency)
  bool _imageLoaded = false;

  @override
  void initState() {
    super.initState();

    splashController = Get.put(SplashController());

    // Controllers (UNCHANGED – same logic & durations)
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    _wordmarkController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..forward();

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..forward();

    _ambientController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    )..repeat(reverse: true);

    PaymentService.instance.init();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _wordmarkController.dispose();
    _progressController.dispose();
    _ambientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Stack(
        children: [
          // Background - Gradient first, image optional overlay
          _buildReliableBackdrop(),

          // Ambient Glow
          _buildOptimizedAmbientGlow(),

          // Main Content (brand + progress)
          _buildMainLayout(),

          // Edge Fade
          _buildEdgeFade(),
        ],
      ),
    );
  }

  // ==================== RELIABLE BACKDROP ====================
  Widget _buildReliableBackdrop() {
    return Stack(
      children: [
        // ALWAYS VISIBLE: Gradient fallback (no network dependency)
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [
                  Color(0xFF1a2332),
                  Color(0xFF0f1620),
                  Color(0xFF000000),
                ],
              ),
            ),
          ),
        ),

        // OPTIONAL: Network image overlay (if loads successfully)
        Positioned.fill(
          child: Image.network(
            // Cinematic / theater style BG (copyright-free Unsplash)
            'https://images.unsplash.com/photo-1594908900066-3f47337549d8?w=1400&q=90',
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() => _imageLoaded = true);
                  }
                });
                return child;
              }
              return const SizedBox.shrink();
            },
            errorBuilder: (context, error, stackTrace) {
              return const SizedBox.shrink();
            },
          ),
        ),

        // Deep overlay for readability (always visible)
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.90),
                  Colors.black.withValues(alpha: 0.96),
                  Colors.black.withValues(alpha: 0.98),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==================== OPTIMIZED AMBIENT GLOW ====================
  Widget _buildOptimizedAmbientGlow() {
    return AnimatedBuilder(
      animation: _ambientController,
      builder: (context, child) {
        final glowIntensity = 0.06 + (_ambientController.value * 0.03);

        return Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.7,
                  colors: [
                    AppColors.darkPrimary.withValues(alpha: glowIntensity),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ==================== MAIN LAYOUT (Brand center, progress bottom) ====================
  Widget _buildMainLayout() {
    return SafeArea(
      child: FadeTransition(
        opacity: _fadeController.drive(CurveTween(curve: Curves.easeOut)),
        child: Column(
          children: [
            // Centered brand content
            Expanded(child: Center(child: _buildBrandCard())),

            // Bottom progress (OTT-style)
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: _buildSmoothProgress(),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== GLASS BRAND CARD ====================
  Widget _buildBrandCard() {
    return AnimatedBuilder(
      animation: _wordmarkController,
      builder: (context, child) {
        final fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _wordmarkController,
            curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
          ),
        );

        final scaleAnim = Tween<double>(begin: 0.96, end: 1.0).animate(
          CurvedAnimation(
            parent: _wordmarkController,
            curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack),
          ),
        );

        return FadeTransition(
          opacity: fadeAnim,
          child: Transform.scale(
            scale: scaleAnim.value,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 24,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                      width: 1,
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.04),
                        Colors.white.withValues(alpha: 0.02),
                        Colors.black.withValues(alpha: 0.3),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.7),
                        blurRadius: 30,
                        spreadRadius: 4,
                        offset: const Offset(0, 18),
                      ),
                    ],
                  ),
                  child: _buildSingleLineWordmark(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ==================== SINGLE-LINE WORDMARK ====================
  Widget _buildSingleLineWordmark() {
    final screenWidth = MediaQuery.of(context).size.width;

    final letterSpacingAnim =
        Tween<double>(
          begin: 6.0,
          end: _calculateOptimalLetterSpacing(screenWidth),
        ).animate(
          CurvedAnimation(
            parent: _wordmarkController,
            curve: const Interval(0.2, 0.9, curve: Curves.easeOutCubic),
          ),
        );

    return AnimatedBuilder(
      animation: letterSpacingAnim,
      builder: (context, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: screenWidth - 64, // padding safety
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white,
                      Colors.white.withValues(alpha: 0.88),
                    ],
                  ).createShader(bounds),
                  child: Text(
                    'CINEZZA',
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                    style: TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.w800,
                      letterSpacing: letterSpacingAnim.value,
                      color: Colors.white,
                      height: 1.0,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.6),
                          blurRadius: 32,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Subtle underline accent
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Container(
                    width: 120 * value,
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppColors.darkPrimary.withValues(alpha: 0.7),
                          AppColors.darkAccent.withValues(alpha: 0.9),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // Letter spacing calculation (UNCHANGED logic)
  double _calculateOptimalLetterSpacing(double screenWidth) {
    // CINEZZA = 7 characters
    final baseTextWidth = 7 * 45; // ~315px
    final availableWidth = screenWidth - 64;

    if (availableWidth < baseTextWidth + 140) {
      return 8.0;
    } else if (availableWidth < baseTextWidth + 200) {
      return 16.0;
    } else {
      return 22.0;
    }
  }

  // ==================== SMOOTH PROGRESS ====================
  Widget _buildSmoothProgress() {
    return AnimatedBuilder(
      animation: _progressController,
      builder: (context, child) {
        final fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _progressController,
            curve: const Interval(0.3, 0.9, curve: Curves.easeIn),
          ),
        );

        return FadeTransition(
          opacity: fadeAnim,
          child: GetBuilder<SplashController>(
            builder: (controller) {
              return Container(
                width: 280,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.02),
                      Colors.white.withValues(alpha: 0.04),
                    ],
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: Stack(
                    children: [
                      // Background track
                      Container(
                        height: 3,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),

                      // Active progress
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        height: 3,
                        width: 272 * controller.progress.value,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.darkPrimary,
                              AppColors.darkAccent,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.darkPrimary.withValues(
                                alpha: 0.5,
                              ),
                              blurRadius: 14,
                              spreadRadius: 1.5,
                            ),
                          ],
                        ),
                      ),

                      // Shimmer head
                      if (controller.progress.value > 0.05)
                        Positioned(
                          left:
                              (272 * controller.progress.value).clamp(
                                0.0,
                                272.0,
                              ) -
                              24,
                          child: Container(
                            width: 32,
                            height: 3,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.white.withValues(alpha: 0.4),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ==================== EDGE FADE ====================
  Widget _buildEdgeFade() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.2,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.35),
                Colors.black.withValues(alpha: 0.65),
              ],
              stops: const [0.25, 0.78, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}
