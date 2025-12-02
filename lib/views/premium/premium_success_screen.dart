import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/premium_plan_model.dart';

class PremiumSuccessScreen extends StatefulWidget {
  final PlanModel plan;
  const PremiumSuccessScreen(this.plan, {super.key});

  @override
  State<PremiumSuccessScreen> createState() => _PremiumSuccessScreenState();
}

class _PremiumSuccessScreenState extends State<PremiumSuccessScreen>
    with TickerProviderStateMixin {
  late ConfettiController _confetti;
  late AnimationController _popController;
  late AnimationController _pulseController;
  late AnimationController _sparkleRotation;

  @override
  void initState() {
    super.initState();

    _confetti = ConfettiController(duration: const Duration(seconds: 2))
      ..play();

    /// POP (Entrance "boom")
    _popController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();

    /// PULSE Glow Loop
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
      lowerBound: 0.85,
      upperBound: 1.10,
    )..repeat(reverse: true);

    /// Sparkle Rotation
    _sparkleRotation = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    Future.delayed(const Duration(seconds: 3), () {
      Get.close(2);
    });
  }

  @override
  void dispose() {
    _confetti.dispose();
    _popController.dispose();
    _pulseController.dispose();
    _sparkleRotation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curve = CurvedAnimation(
      parent: _popController,
      curve: Curves.elasticOut,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0E),
      body: Stack(
        alignment: Alignment.center,
        children: [
          /// 🎉 Confetti Layer
          ConfettiWidget(
            confettiController: _confetti,
            blastDirectionality: BlastDirectionality.explosive,
            numberOfParticles: 35,
            minBlastForce: 8,
            maxBlastForce: 18,
            colors: const [
              Colors.white,
              Colors.amber,
              Color(0xFFFFE08C),
              Color(0xFFD4A441),
            ],
          ),

          /// ✨ Animated Success Badge
          AnimatedBuilder(
            animation: _sparkleRotation,
            builder: (_, child) {
              return Transform.rotate(
                angle: _sparkleRotation.value * 2 * pi,
                child: Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.amber.withOpacity(0.9),
                        Colors.amber.withOpacity(0.3),
                        Colors.transparent,
                      ],
                      stops: const [0.3, 0.6, 1.0],
                    ),
                  ),
                ),
              );
            },
          ),

          /// Main Icon (POP + PULSE combo)
          ScaleTransition(
            scale: curve,
            child: ScaleTransition(
              scale: _pulseController,
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD54F), Color(0xFFC8A94E)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.55),
                      blurRadius: 50,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 65,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          /// Text + Layout
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.22,
            child: Column(
              children: [
                const SizedBox(height: 24),
                const Text(
                  "Premium Activated",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.plan.title,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
