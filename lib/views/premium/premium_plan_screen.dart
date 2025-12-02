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
  final PremiumController controller = Get.find();
  int selectedIndex = 0;
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final cardBg = isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Premium Plans",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: textColor),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, size: 18, color: textColor),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        final plans = controller.premiumPlans.isEmpty
            ? _dummyPlans()
            : controller.premiumPlans;

        if (selectedIndex >= plans.length) {
          selectedIndex = 0;
        }

        final selectedPlan = plans[selectedIndex];

        return Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: List.generate(plans.length, (index) {
                        return _buildPlanCard(
                          plans[index],
                          index == selectedIndex,
                          index,
                          isDark,
                          primaryColor,
                          cardBg,
                          textColor,
                        );
                      }),
                    ),

                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: primaryColor.withValues(alpha: 0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 4,
                                height: 16,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [primaryColor, primaryColor.withValues(alpha: 0.5)],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "What You'll Get:",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _bullet("Unlimited streaming", primaryColor, textColor),
                          _bullet("No ads • HD quality", primaryColor, textColor),
                          _bullet("Download & watch offline", primaryColor, textColor),
                          _bullet("Watch on any device", primaryColor, textColor),
                          _bullet("Cancel anytime", primaryColor, textColor),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Trust badge - SAME HEIGHT
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            primaryColor.withValues(alpha: 0.15),
                            primaryColor.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: primaryColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified_user, color: primaryColor, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            "Secure Payment",
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            /// BOTTOM BUTTON - SAME HEIGHT
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: BoxDecoration(
                color: bgColor,
                border: Border(
                  top: BorderSide(
                    color: primaryColor.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 48,
                      child: GoldButton(
                        text: "Unlock Premium",
                        onTap: () async {
                          await PaymentService.instance.pay(
                            context: context,
                            plan: selectedPlan,
                            razorpayKey: "rzp_test_1DP5mmOlF5G5ag",
                            onPaymentSuccess: () async {
                              await UserService.updateUserByDeviceId(
                                activePlan: selectedPlan.planId,
                                planActive: true,
                                planExpiryDate: DateTime.now()
                                    .add(Duration(days: selectedPlan.durationInDays))
                                    .toIso8601String(),
                              );
                              Get.to(() => PremiumSuccessScreen(selectedPlan));
                            },
                            onPaymentFailed: (err) {
                              debugPrint("Payment Error: $err");
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () {},
                      child: Text(
                        "Need help? Contact support",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  /// ATTRACTIVE PLAN CARD - SAME DIMENSIONS
  Widget _buildPlanCard(
      PlanModel plan,
      bool isSelected,
      int index,
      bool isDark,
      Color primaryColor,
      Color cardBg,
      Color textColor,
      ) {
    return GestureDetector(
      onTap: () => setState(() => selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: (MediaQuery.of(context).size.width - 42) / 2,
        padding: const EdgeInsets.all(12),
        height: 130,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: cardBg,
          border: Border.all(
            color: isSelected ? primaryColor : primaryColor.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
          gradient: isSelected
              ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cardBg,
              // primaryColor.withValues(alpha: 0.1),
              cardBg,
            ],
          )
              : null,
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? primaryColor.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: isSelected ? 15 : 8,
              spreadRadius: isSelected ? 1 : 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Popular badge
            if (plan.isMostPopular)
              Positioned(
                right: -6,
                top: -6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, primaryColor.withValues(alpha: 0.7)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Text(
                    "POPULAR",
                    style: TextStyle(
                      fontSize: 7,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 4),
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors:
                    // isSelected
                    //     ? [primaryColor, primaryColor.withValues(alpha: 0.7)]
                    //     :
                    [textColor, textColor],
                  ).createShader(bounds),
                  child: Text(
                    plan.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors:
                    // isSelected
                    //     ? [primaryColor, primaryColor.withValues(alpha: 0.6)]
                    //     :
                    [textColor, textColor.withValues(alpha: 0.7)],
                  ).createShader(bounds),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(
                          "₹",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Text(
                        "${plan.price}",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor, primaryColor.withValues(alpha: 0.8)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Text(
                      "SELECTED",
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  )
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// BULLET - SAME HEIGHT
  Widget _bullet(String text, Color primaryColor, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, primaryColor.withValues(alpha: 0.7)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 12,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: textColor),
            ),
          ),
        ],
      ),
    );
  }

  // UTILITIES
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
