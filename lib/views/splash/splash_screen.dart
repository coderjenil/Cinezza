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
  late AnimationController _morphController;
  late AnimationController _floatController;
  late AnimationController _spinController;
  late AnimationController _glowController;
  late AnimationController _waveController;

  late SplashController splashController;

  @override
  void initState() {
    super.initState();

    splashController = Get.put(SplashController());

    _morphController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..forward();

    _floatController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat(reverse: true);

    _spinController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _waveController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    PaymentService.instance.init();
  }

  @override
  void dispose() {
    _morphController.dispose();
    _floatController.dispose();
    _spinController.dispose();
    _glowController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0a0e27), Color(0xFF1a1f3a), Color(0xFF2d3561)],
          ),
        ),
        child: Stack(
          children: [
            // Animated mesh background
            _buildMeshBackground(),

            // Floating glass cards
            _buildFloatingCards(),

            // Main content
            SafeArea(
              child: Column(
                children: [
                  Spacer(flex: 2),

                  // Logo section
                  _buildLogoSection(),

                  SizedBox(height: 60),

                  // Text section
                  _buildTextSection(),

                  Spacer(flex: 2),

                  // Progress section
                  _buildProgressSection(),

                  SizedBox(height: 60),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeshBackground() {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: MeshGradientPainter(_waveController.value),
        );
      },
    );
  }

  Widget _buildFloatingCards() {
    return Stack(
      children: List.generate(5, (index) {
        return AnimatedBuilder(
          animation: _floatController,
          builder: (context, child) {
            final offset =
                sin(_floatController.value * 2 * pi + (index * 1.2)) * 20;
            return Positioned(
              top: 100 + (index * 120.0) + offset,
              right: -100 + (index % 2 == 0 ? 50 : -50),
              child: Transform.rotate(
                angle: (index * 0.3) + (_spinController.value * 0.5),
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.1),
                        Colors.purple.withValues(alpha: 0.05),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildLogoSection() {
    return AnimatedBuilder(
      animation: _morphController,
      builder: (context, child) {
        final scaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _morphController,
            curve: Interval(0.0, 0.6, curve: Curves.elasticOut),
          ),
        );

        final fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _morphController,
            curve: Interval(0.0, 0.4, curve: Curves.easeIn),
          ),
        );

        return Transform.scale(
          scale: scaleAnim.value,
          child: Opacity(
            opacity: fadeAnim.value,
            child: AnimatedBuilder(
              animation: _floatController,
              builder: (context, child) {
                final floatOffset = sin(_floatController.value * 2 * pi) * 15;
                return Transform.translate(
                  offset: Offset(0, floatOffset),
                  child: _buildGlassmorphicLogo(),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildGlassmorphicLogo() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer glow
        AnimatedBuilder(
          animation: _glowController,
          builder: (context, child) {
            return Container(
              width: 220 + (_glowController.value * 40),
              height: 220 + (_glowController.value * 40),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 80 + (_glowController.value * 40),
                    spreadRadius: 20,
                  ),
                ],
              ),
            );
          },
        ),

        // Glass morphic container
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.2),
                Colors.white.withValues(alpha: 0.1),
              ],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.5),
                blurRadius: 60,
                spreadRadius: 10,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Rotating border
                    AnimatedBuilder(
                      animation: _spinController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _spinController.value * 2 * pi,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: CustomPaint(
                              size: Size(200, 200),
                              painter: SpinningBorderPainter(),
                            ),
                          ),
                        );
                      },
                    ),

                    // Play icon
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withValues(alpha: 0.8),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.5),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.play_arrow_rounded,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
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

  Widget _buildTextSection() {
    return AnimatedBuilder(
      animation: _morphController,
      builder: (context, child) {
        final slideAnim = Tween<Offset>(begin: Offset(0, 0.5), end: Offset.zero)
            .animate(
              CurvedAnimation(
                parent: _morphController,
                curve: Interval(0.3, 0.8, curve: Curves.easeOut),
              ),
            );

        final fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _morphController,
            curve: Interval(0.3, 0.8, curve: Curves.easeIn),
          ),
        );

        return SlideTransition(
          position: slideAnim,
          child: FadeTransition(
            opacity: fadeAnim,
            child: Column(
              children: [
                // Main title
                Stack(
                  children: [
                    // Outline text
                    Text(
                      'CINEZA',
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w900,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 2
                          ..color = AppColors.primary.withValues(alpha: 0.5),
                        letterSpacing: 16,
                      ),
                    ),
                    // Fill text
                    Text(
                      'CINEZA',
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w900,
                        foreground: Paint()
                          ..shader = LinearGradient(
                            colors: [
                              Colors.white,
                              Colors.white.withValues(alpha: 0.8),
                            ],
                          ).createShader(Rect.fromLTWH(0, 0, 300, 70)),
                        letterSpacing: 16,
                        shadows: [
                          Shadow(
                            color: AppColors.primary.withValues(alpha: 0.5),
                            blurRadius: 30,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20),

                // Subtitle
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.1),
                        Colors.white.withValues(alpha: 0.05),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Text(
                        'Ultimate Streaming Experience',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.9),
                          letterSpacing: 3,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressSection() {
    return AnimatedBuilder(
      animation: _morphController,
      builder: (context, child) {
        final fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _morphController,
            curve: Interval(0.5, 1.0, curve: Curves.easeIn),
          ),
        );

        return FadeTransition(
          opacity: fadeAnim,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 40),
            padding: EdgeInsets.all(30),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.1),
                  Colors.white.withValues(alpha: 0.05),
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Column(
                  children: [
                    // Progress bar - Using GetBuilder instead of Obx
                    GetBuilder<SplashController>(
                      builder: (controller) {
                        return Stack(
                          children: [
                            Container(
                              height: 6,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              height: 6,
                              width:
                                  (MediaQuery.of(context).size.width - 140) *
                                  controller.progress.value,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary.withValues(alpha: 0.7),
                                    AppColors.primary,
                                    Colors.white,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.5,
                                    ),
                                    blurRadius: 15,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    SizedBox(height: 25),

                    // Loading message
                    GetBuilder<SplashController>(
                      builder: (controller) {
                        return AnimatedSwitcher(
                          duration: Duration(milliseconds: 400),
                          child: Text(
                            controller.loadingMessage.value,
                            key: ValueKey(controller.loadingMessage.value),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.8),
                              letterSpacing: 2,
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 15),

                    // Percentage
                    GetBuilder<SplashController>(
                      builder: (controller) {
                        return Text(
                          '${(controller.progress.value * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 24,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Mesh gradient painter
class MeshGradientPainter extends CustomPainter {
  final double animation;

  MeshGradientPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 3; i++) {
      final offset = sin(animation * 2 * pi + i) * 100;
      paint.shader = RadialGradient(
        center: Alignment(-0.5 + (i * 0.5), -0.5 + offset / size.height),
        radius: 1.5,
        colors: [AppColors.primary.withValues(alpha: 0.05), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Spinning border painter
class SpinningBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = SweepGradient(
        colors: [
          Colors.white.withValues(alpha: 0.8),
          Colors.transparent,
          Colors.transparent,
          Colors.white.withValues(alpha: 0.8),
        ],
        stops: [0.0, 0.2, 0.8, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2 - 10,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
