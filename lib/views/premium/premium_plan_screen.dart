import 'dart:math';

import 'package:app/core/theme/app_colors.dart';
import 'package:app/services/user_api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/premium_controller.dart';
import '../../models/premium_plan_model.dart';
import '../../services/payment_service.dart';
import '../../utils/common_dialogs.dart';
import 'premium_success_screen.dart';

class PremiumPlansPage extends StatefulWidget {
  const PremiumPlansPage({super.key});

  @override
  State<PremiumPlansPage> createState() => _PremiumPlansPageState();
}

class _PremiumPlansPageState extends State<PremiumPlansPage>
    with TickerProviderStateMixin {
  final PremiumController controller = Get.find();
  int selectedIndex = 0;
  late AnimationController pulseController;
  late AnimationController shimmerController;
  late AnimationController scaleController;

  @override
  void initState() {
    super.initState();
    fetchPlans();

    pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // Smooth shimmer animation - increased duration for subtlety
    shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();

    scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: 1.0,
    );
  }

  fetchPlans() async {
    try {
      if (controller.premiumPlans.isEmpty) {
        controller.fetchPlans();
      }
    } catch (e) {
      showAlert(context: context, message: e);
    }
  }

  @override
  void dispose() {
    pulseController.dispose();
    shimmerController.dispose();
    scaleController.dispose();
    super.dispose();
  }

  void _showBenefitsModal(
    BuildContext context,
    Color primaryColor,
    Color textColor,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      // isScrollBarVisible: false,
      // FIX 1: Constrain bottom sheet height to prevent overflow
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkCardBackground
              : AppColors.lightCardBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        // FIX 1: Use SingleChildScrollView for overflow protection
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: textColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: AppColors.oceanGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.star_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "All Premium Features",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildBenefitItem(
                  Icons.play_circle_fill_rounded,
                  "Unlimited streaming",
                  "Watch as much as you want, anytime",
                  primaryColor,
                  textColor,
                ),
                _buildBenefitItem(
                  Icons.hd_rounded,
                  "HD & 4K Quality",
                  "Crystal clear picture on all devices",
                  primaryColor,
                  textColor,
                ),
                _buildBenefitItem(
                  Icons.download_for_offline_rounded,
                  "Download & Watch Offline",
                  "Perfect for flights & commutes",
                  primaryColor,
                  textColor,
                ),
                _buildBenefitItem(
                  Icons.devices_rounded,
                  "Multi-Device Access",
                  "TV, laptop, phone, tablet",
                  primaryColor,
                  textColor,
                ),
                _buildBenefitItem(
                  Icons.block_rounded,
                  "Zero Ads Forever",
                  "Uninterrupted entertainment",
                  primaryColor,
                  textColor,
                ),
                _buildBenefitItem(
                  Icons.cancel_rounded,
                  "Cancel Anytime",
                  "No commitments, no questions",
                  primaryColor,
                  textColor,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem(
    IconData icon,
    String title,
    String subtitle,
    Color primaryColor,
    Color textColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: primaryColor, size: 20),
          ),
          const SizedBox(width: 12),
          // FIX 1: Wrap with Flexible to prevent overflow
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor.withValues(alpha: 0.6),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.check_circle, color: primaryColor, size: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;
    final bgColor = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;
    final textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final cardBg = isDark
        ? AppColors.darkCardBackground
        : AppColors.lightCardBackground;

    return Scaffold(
      backgroundColor: bgColor,
      body: Obx(() {
        final plans = controller.premiumPlans.isEmpty
            ? _dummyPlans()
            : controller.premiumPlans;

        if (selectedIndex >= plans.length) {
          selectedIndex = 0;
        }

        final selectedPlan = plans[selectedIndex];

        return SafeArea(
          child: Column(
            children: [
              // HEADER - Compact
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        size: 24,
                        color: textColor,
                      ),
                      onPressed: () => Get.back(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          AppColors.oceanGradient.createShader(bounds),
                      child: const Text(
                        "GO PREMIUM",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),

              // MAIN CONTENT - Expanded to fill remaining space
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // HERO SECTION - Compact
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          AnimatedBuilder(
                            animation: pulseController,
                            builder: (context, child) {
                              return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: AppColors.oceanGradient,
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryColor.withValues(
                                        alpha:
                                            0.3 + (pulseController.value * 0.4),
                                      ),
                                      blurRadius:
                                          20 + (pulseController.value * 15),
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.workspace_premium_rounded,
                                  size: 32,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          ShaderMask(
                            shaderCallback: (bounds) =>
                                AppColors.oceanGradient.createShader(bounds),
                            child: const Text(
                              "Unlock Unlimited\nEntertainment",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1.1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // FIX 1: Wrap quick benefits in Flexible/Expanded to prevent overflow
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: _quickBenefit(
                                  Icons.hd_rounded,
                                  "HD Quality",
                                  textColor,
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 12,
                                color: textColor.withValues(alpha: 0.3),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                              ),
                              Flexible(
                                child: _quickBenefit(
                                  Icons.block_rounded,
                                  "No Ads",
                                  textColor,
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 12,
                                color: textColor.withValues(alpha: 0.3),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                              ),
                              Flexible(
                                child: _quickBenefit(
                                  Icons.download_rounded,
                                  "Offline",
                                  textColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // PLAN CARDS - Horizontal Scrollable
                    SizedBox(
                      height: 170,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: plans.length,
                        physics: const BouncingScrollPhysics(),
                        // padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemBuilder: (context, index) {
                          return _buildCompactPlanCard(
                            plans[index],
                            index == selectedIndex,
                            index,
                            isDark,
                            primaryColor,
                            cardBg,
                            textColor,
                          );
                        },
                      ),
                    ),

                    // KEY BENEFITS - Ultra Compact with Modal Link
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: primaryColor.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 3,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      gradient: AppColors.oceanGradient,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "What You Get",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: textColor,
                                    ),
                                  ),
                                ],
                              ),
                              InkWell(
                                onTap: () => _showBenefitsModal(
                                  context,
                                  primaryColor,
                                  textColor,
                                  isDark,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      "View All",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: primaryColor,
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 12,
                                      color: primaryColor,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _compactBenefit(
                                  Icons.play_circle_fill_rounded,
                                  "Unlimited\nStreaming",
                                  primaryColor,
                                  textColor,
                                ),
                              ),
                              Expanded(
                                child: _compactBenefit(
                                  Icons.hd_rounded,
                                  "HD & 4K\nQuality",
                                  primaryColor,
                                  textColor,
                                ),
                              ),
                              Expanded(
                                child: _compactBenefit(
                                  Icons.download_rounded,
                                  "Download\nOffline",
                                  primaryColor,
                                  textColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // TRUST SIGNALS - Minimal
                    // FIX 1: Wrap in Flexible to prevent overflow
                    Flexible(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: _miniTrustBadge(
                              Icons.verified_user_rounded,
                              "Secure",
                              primaryColor,
                              textColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: _miniTrustBadge(
                              Icons.sync_rounded,
                              "Cancel Anytime",
                              primaryColor,
                              textColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: _miniTrustBadge(
                              Icons.support_agent_rounded,
                              "24/7 Help",
                              primaryColor,
                              textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // BOTTOM CTA - Fixed Height
              _buildBottomCTA(
                selectedPlan,
                primaryColor,
                bgColor,
                textColor,
                isDark,
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _quickBenefit(IconData icon, String text, Color textColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: textColor.withValues(alpha: 0.7)),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor.withValues(alpha: 0.7),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _compactBenefit(
    IconData icon,
    String text,
    Color primaryColor,
    Color textColor,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: primaryColor, size: 18),
        ),
        const SizedBox(height: 6),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: textColor,
            height: 1.2,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _miniTrustBadge(
    IconData icon,
    String text,
    Color primaryColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: primaryColor, size: 12),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // FIX 1 & 2: Fixed plan card with proper constraints and blue color scheme
  Widget _buildCompactPlanCard(
    PlanModel plan,
    bool isSelected,
    int index,
    bool isDark,
    Color primaryColor,
    Color cardBg,
    Color textColor,
  ) {
    final savingsPercent = _calculateSavings(plan);

    return GestureDetector(
      onTap: () => setState(() => selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        width: 130,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: cardBg,
          border: Border.all(
            color: isSelected
                ? primaryColor
                : primaryColor.withValues(alpha: 0.2),
            width: isSelected ? 2.5 : 1,
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: isSelected ? 20 : 8,
              spreadRadius: isSelected ? 2 : 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Badges
            if (savingsPercent > 0)
              Positioned(
                right: -8,
                top: -8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.success.withValues(alpha: 0.4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Text(
                    "SAVE $savingsPercent%",
                    style: const TextStyle(
                      fontSize: 7,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

            if (plan.isMostPopular)
              Positioned(
                right: -8,
                top: -8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppColors.oceanGradient,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.4),
                        blurRadius: 6,
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

            // FIX 1: Use Flexible/Expanded in Column to prevent overflow
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 4),

                // Title - with overflow protection
                Text(
                  plan.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? Colors.amber : textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),

                const SizedBox(height: 8),

                // Price
                Row(
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
                          color: isSelected ? Colors.amber : textColor,
                        ),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        "${plan.price}",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: isSelected ? Colors.amber : textColor,
                          height: 1,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // Duration
                Text(
                  _durationText(plan.durationInDays),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.amber
                        : textColor.withValues(alpha: 0.6),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 6),

                // Per Day
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? primaryColor.withValues(alpha: 0.15)
                        : primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "₹${(plan.price / plan.durationInDays).toStringAsFixed(1)}/day",
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? Colors.amber
                          : textColor.withValues(alpha: 0.7),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const SizedBox(height: 8),

                // // Selected Indicator
                // if (isSelected)
                //   Container(
                //     padding: const EdgeInsets.symmetric(
                //       horizontal: 10,
                //       vertical: 3,
                //     ),
                //     decoration: BoxDecoration(
                //       gradient: AppColors.oceanGradient,
                //       borderRadius: BorderRadius.circular(8),
                //     ),
                //     child: const Text(
                //       "SELECTED",
                //       style: TextStyle(
                //         fontSize: 8,
                //         fontWeight: FontWeight.w900,
                //         color: Colors.white,
                //       ),
                //     ),
                //   )
                // else
                //   const SizedBox(height: 19),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // FIX 1 & 3: Fixed bottom CTA with smooth shimmer animation
  Widget _buildBottomCTA(
    PlanModel selectedPlan,
    Color primaryColor,
    Color bgColor,
    Color textColor,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          top: BorderSide(
            color: primaryColor.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Selected Plan Summary
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withValues(alpha: 0.15),
                  primaryColor.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // FIX 1: Wrap in Flexible to prevent overflow
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.workspace_premium_rounded,
                        color: primaryColor,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          "${selectedPlan.title} • ${_durationText(selectedPlan.durationInDays)}",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppColors.oceanGradient.createShader(bounds),
                  child: Text(
                    "₹${selectedPlan.price}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // FIX 3: Smooth Shimmer CTA Button
          GestureDetector(
            onTapDown: (_) => scaleController.animateTo(0.95),
            onTapUp: (_) => scaleController.animateTo(1.0),
            onTapCancel: () => scaleController.animateTo(1.0),
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
            child: ScaleTransition(
              scale: scaleController,
              child: _buildSmoothShimmerButton(primaryColor, isDark),
            ),
          ),

          const SizedBox(height: 8),

          // Risk Reversal - with overflow protection
          Text(
            "Cancel anytime • Money-back guarantee",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor.withValues(alpha: 0.6),
              fontSize: 11,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // FIX 3: Smooth shimmer animation without reflective artifacts
  Widget _buildSmoothShimmerButton(Color primaryColor, bool isDark) {
    return AnimatedBuilder(
      animation: shimmerController,
      builder: (context, child) {
        return Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.darkPrimary,
                AppColors.darkAccent,
                AppColors.darkPrimary,
              ],
              // Smooth shimmer stops using sine curve for natural motion
              stops: [
                _calculateShimmerStop(0),
                _calculateShimmerStop(0.5),
                _calculateShimmerStop(1.0),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              transform: GradientRotation(shimmerController.value * 2 * pi),
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
              // Subtle inner glow for depth
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.1),
                blurRadius: 5,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.workspace_premium_rounded,
                color: Colors.white,
                size: 24,
              ),
              SizedBox(width: 10),
              Text(
                "Start Premium Now",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // FIX 3: Calculate smooth shimmer stops using easing function
  double _calculateShimmerStop(double base) {
    // Use sine curve for smooth, natural shimmer motion
    final animValue = shimmerController.value;
    final offset = sin(animValue * pi * 2) * 0.3;
    return (base + offset).clamp(0.0, 1.0);
  }

  // UTILITY FUNCTIONS
  int _calculateSavings(PlanModel plan) {
    if (plan.durationInDays == 7) return 0;
    final weeklyPrice = 39.0;
    final weekEquivalent = (plan.durationInDays / 7).ceil();
    final regularPrice = weeklyPrice * weekEquivalent;
    final savings = ((regularPrice - plan.price) / regularPrice * 100).round();
    return savings > 0 ? savings : 0;
  }

  List<PlanModel> _dummyPlans() {
    return [
      PlanModel(
        id: "p1",
        planId: "1",
        title: "Weekly",
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
        title: "Monthly",
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
