import 'dart:math';
import 'dart:ui';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/services/user_api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/premium_controller.dart';
import '../../models/premium_plan_model.dart';
import '../../services/payment_service.dart';
import '../../utils/common_dialogs.dart';
import '../../widgets/gold_button.dart';
import 'premium_success_screen.dart';

class PremiumPlansPage extends StatefulWidget {
  const PremiumPlansPage({super.key});

  @override
  State<PremiumPlansPage> createState() => _PremiumPlansPageState();
}

class _PremiumPlansPageState extends State<PremiumPlansPage>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController(viewportFraction: 0.82);
  final PremiumController controller = Get.find<PremiumController>();

  int currentIndex = 0;
  late AnimationController shineController;

  @override
  void initState() {
    super.initState();
    fetchPlans();
    shineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  fetchPlans() async {
    try {
      if (controller.premiumPlans.isEmpty) {
        controller.fetchPlans();
      }
    } catch (e) {
      showAlert(context: context, message: e);
    } finally {}
  }

  @override
  void dispose() {
    shineController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Premium Plans",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Get.back(),
        ),
      ),

      body: Obx(() {
        final plans = controller.premiumPlans.isEmpty
            ? _dummyPlans()
            : controller.premiumPlans;

        return Column(
          children: [
            const SizedBox(height: 20),

            /// 🔥 PLAN CARDS
            Expanded(
              child: AnimatedBuilder(
                animation: shineController,
                builder: (_, __) {
                  return PageView.builder(
                    controller: _pageController,
                    itemCount: plans.length,
                    onPageChanged: (i) => setState(() => currentIndex = i),
                    itemBuilder: (_, index) {
                      return buildPremiumCard(
                        plans[index],
                        index == currentIndex,
                        shineController.value,
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            /// 🔘 Page Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                plans.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 6,
                  width: currentIndex == i ? 18 : 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: currentIndex == i ? Colors.white : Colors.grey,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        );
      }),
    );
  }

  /// ---------- PREMIUM PRICING CARD ----------
  Widget buildPremiumCard(PlanModel plan, bool isActive, double shimmer) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 350),
      scale: isActive ? 1 : 0.90,
      curve: Curves.fastOutSlowIn,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        padding: const EdgeInsets.all(22),
        margin: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            width: isActive ? 1.7 : 1.1,
            color: isActive ? Colors.amberAccent : Colors.white24,
          ),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(isActive ? 0.09 : 0.04),
              Colors.black.withOpacity(0.20),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.darkPrimary.withOpacity(0.38),
                    blurRadius: 30,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),

        child: Stack(
          clipBehavior: Clip.none,
          children: [
            /// ✨ Shine Sweep Animation
            Positioned.fill(
              child: Opacity(
                opacity: isActive ? 0.22 : 0.06,
                child: Transform.translate(
                  offset: Offset(shimmer * 200 - 100, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.white.withOpacity(0.45),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            /// 🏷 Metallic Ribbon
            if (plan.isMostPopular)
              Positioned(
                right: -28,
                top: -18,
                child: Transform.rotate(
                  angle: pi / 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFE08C), Color(0xFFD4A441)],
                      ),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const Text(
                      "BEST CHOICE",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        fontSize: 11,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ),
              ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 6),

                Text(
                  plan.title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 4),
                const Text(
                  "SUBSCRIPTION",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),

                const SizedBox(height: 18),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _durationText(plan.durationInDays),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text("•", style: TextStyle(color: Colors.white54)),
                    const SizedBox(width: 8),
                    Text(
                      "₹${plan.price}",
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                Text(
                  "Watch without limits",
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.white.withOpacity(0.65),
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 20),
                Divider(color: Colors.white24),

                const SizedBox(height: 18),
                _bullet("Trusted by millions worldwide"),
                _bullet("Instant access after upgrade"),
                _bullet("Refund available within 24 hours"),

                const SizedBox(height: 18),
                Divider(color: Colors.white12),

                const SizedBox(height: 22),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.lock, color: Colors.white70, size: 18),
                    SizedBox(width: 6),
                    Text(
                      "Secure Payment",
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),

                const SizedBox(height: 26),

                /// ⭐ Gold CTA Button
                AnimatedScale(
                  duration: const Duration(milliseconds: 500),
                  scale: isActive ? 1.07 : 0.92,
                  curve: Curves.easeOutBack,
                  child: GoldButton(
                    text: "Unlock Premium",
                    onTap: () async {
                      await PaymentService.instance.pay(
                        context: context,
                        plan: plan,
                        razorpayKey: "rzp_test_1DP5mmOlF5G5ag",
                        onPaymentSuccess: () async {
                          await UserService.updateUserByDeviceId(
                            activePlan: plan.planId,
                            planActive: true,
                            planExpiryDate: DateTime.now()
                                .add(Duration(days: plan.durationInDays))
                                .toIso8601String(),
                          );

                          // Navigate to success animation screen
                          Get.to(() => PremiumSuccessScreen(plan));
                        },
                        onPaymentFailed: (err) {
                          debugPrint("Payment Error: $err");
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 18),

                InkWell(
                  onTap: () {},
                  child: Text(
                    "Need help?\nContact support",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.greenAccent.shade400,
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// --- BULLET ITEM STYLE ---
  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- UTILITIES ----------------

  List<PlanModel> _dummyPlans() {
    return [
      PlanModel(
        id: "p1",
        planId: "1",
        title: "Mini Pass",
        description: "",
        price: 39,
        currency: "INR",
        durationInDays: 7,
        isMostPopular: false,
        isActive: true,
        displayOrder: 1,
        features: [],
        discountPercent: 0,
        originalPrice: null,
        color: "",
        totalPurchases: 0,
        revenue: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      PlanModel(
        id: "p2",
        planId: "2",
        title: "Monthly Pass",
        description: "",
        price: 99,
        currency: "INR",
        durationInDays: 30,
        isMostPopular: true,
        isActive: true,
        displayOrder: 2,
        features: [],
        discountPercent: 0,
        originalPrice: null,
        color: "",
        totalPurchases: 0,
        revenue: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      PlanModel(
        id: "p3",
        planId: "3",
        title: "6 Months",
        description: "",
        price: 270,
        currency: "INR",
        durationInDays: 180,
        isMostPopular: false,
        isActive: true,
        displayOrder: 3,
        features: [],
        discountPercent: 0,
        originalPrice: null,
        color: "",
        totalPurchases: 0,
        revenue: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  String _durationText(int days) {
    if (days == 7) return "7 Days";
    if (days == 30) return "1 Month";
    if (days == 90) return "3 Months";
    if (days == 180) return "6 Months";
    if (days == 365) return "1 Year";
    return "$days Days";
  }
}
