import 'dart:math';
import 'package:cinezza/controllers/splash_controller.dart';
import 'package:cinezza/core/theme/app_colors.dart';
import 'package:cinezza/services/user_api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/premium_controller.dart';
import '../../models/premium_plan_model.dart';
import '../../services/payment_service.dart';
import '../../utils/dialogs/show_aleart.dart';
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
  late AnimationController highlightController;
  SplashController splashController = Get.find<SplashController>();

  final ScrollController _scrollController = ScrollController();
  bool _hasScrolledToPopular = false;

  @override
  void initState() {
    super.initState();

    pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();

    scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: 1.0,
    );

    highlightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Set initial selected index to popular plan
    _initializeSelectedPlan();

    fetchPlans();
  }

  void _initializeSelectedPlan() {
    if (controller.premiumPlans.isNotEmpty) {
      final popularIndex = controller.premiumPlans.indexWhere(
        (plan) => plan.isMostPopular,
      );
      if (popularIndex != -1) {
        selectedIndex = popularIndex;
      }
    }
  }

  fetchPlans() async {
    try {
      if (controller.premiumPlans.isEmpty) {
        await controller.fetchPlans();
      }

      // Set selected index after plans are loaded
      _initializeSelectedPlan();

      // Schedule scroll after widget is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_hasScrolledToPopular && mounted) {
          _scrollToPopularPlan();
        }
      });
    } catch (e) {
      showAlert(context: context, message: e);
    }
  }

  void _scrollToPopularPlan() {
    final plans = controller.premiumPlans;
    if (plans.isEmpty || _hasScrolledToPopular) return;

    final popularIndex = plans.indexWhere((plan) => plan.isMostPopular);

    if (popularIndex != -1 && _scrollController.hasClients) {
      _hasScrolledToPopular = true;

      // Update selected index
      setState(() {
        selectedIndex = popularIndex;
      });

      // Calculate scroll position
      final cardWidth = 142.0;
      final screenWidth = MediaQuery.of(context).size.width;
      final targetOffset =
          (popularIndex * cardWidth) - (screenWidth / 2) + (cardWidth / 2);

      // Add delay for smooth entry
      Future.delayed(const Duration(milliseconds: 400), () {
        if (_scrollController.hasClients && mounted) {
          _scrollController
              .animateTo(
                targetOffset.clamp(
                  0.0,
                  _scrollController.position.maxScrollExtent,
                ),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutCubic,
              )
              .then((_) {
                // Trigger highlight animation after scroll completes
                if (mounted) {
                  Future.delayed(const Duration(milliseconds: 200), () {
                    if (mounted) {
                      highlightController.forward().then((_) {
                        if (mounted) {
                          highlightController.reverse().then((_) {
                            // Repeat pulse 2 more times
                            if (mounted) {
                              highlightController.forward().then((_) {
                                if (mounted) highlightController.reverse();
                              });
                            }
                          });
                        }
                      });
                    }
                  });
                }
              });
        }
      });
    }
  }

  @override
  void dispose() {
    pulseController.dispose();
    shimmerController.dispose();
    scaleController.dispose();
    highlightController.dispose();
    _scrollController.dispose();
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
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: textColor.withOpacity(0.3),
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
              color: primaryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: primaryColor, size: 20),
          ),
          const SizedBox(width: 12),
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
                    color: textColor.withOpacity(0.6),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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

        if (plans.isNotEmpty && selectedIndex >= plans.length) {
          selectedIndex = 0;
        }

        final selectedPlan = plans.isNotEmpty ? plans[selectedIndex] : null;

        return SafeArea(
          child: Column(
            children: [
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

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
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
                                      color: primaryColor.withOpacity(
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
                                color: textColor.withOpacity(0.3),
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
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(
                      height: 200,
                      child: controller.premiumPlans.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : ClipRect(
                              child: ListView.builder(
                                controller: _scrollController,
                                scrollDirection: Axis.horizontal,
                                itemCount: plans.length,
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
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
                    ),

                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: primaryColor.withOpacity(0.2),
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
                                  Icons.cancel_rounded,
                                  "No Ads",
                                  primaryColor,
                                  textColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

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

              if (selectedPlan != null)
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
        Icon(icon, size: 14, color: textColor.withOpacity(0.7)),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor.withOpacity(0.7),
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
            color: primaryColor.withOpacity(0.15),
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
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
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
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: primaryColor.withOpacity(0.2)),
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

  Widget _buildCompactPlanCard(
    PlanModel plan,
    bool isSelected,
    int index,
    bool isDark,
    Color primaryColor,
    Color cardBg,
    Color textColor,
  ) {
    final perDayCost = (plan.finalPrice / plan.durationInDays).toStringAsFixed(
      1,
    );

    return GestureDetector(
      onTap: () => setState(() => selectedIndex = index),
      child: AnimatedBuilder(
        animation: highlightController,
        builder: (context, child) {
          final shouldPulse =
              plan.isMostPopular &&
              isSelected &&
              highlightController.isAnimating;
          final scale = shouldPulse
              ? 1.0 + (highlightController.value * 0.05)
              : 1.0;

          return Transform.scale(
            scale: scale,
            alignment: Alignment.center,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              width: 130,
              margin: EdgeInsets.symmetric(
                horizontal: 6,
                vertical: shouldPulse ? 8 : 4,
              ),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: cardBg,
                border: Border.all(
                  color: isSelected
                      ? primaryColor
                      : primaryColor.withOpacity(0.2),
                  width: isSelected ? 2.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                    blurRadius: isSelected ? 20 : 8,
                    spreadRadius: isSelected ? 2 : 0,
                    offset: const Offset(0, 4),
                  ),
                  if (shouldPulse)
                    BoxShadow(
                      color: primaryColor.withOpacity(
                        highlightController.value * 0.5,
                      ),
                      blurRadius: 25 + (highlightController.value * 15),
                      spreadRadius: highlightController.value * 4,
                    ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  if (plan.discountPercent > 0 && !plan.isMostPopular)
                    Positioned(
                      right: -8,
                      top: -8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.4),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Text(
                          "SAVE ${plan.discountPercent}%",
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
                              color: primaryColor.withOpacity(0.4),
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

                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(height: 4),

                      Text(
                        plan.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? Colors.amber : textColor,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                if (plan.discountPercent > 0)
                                  Text(
                                    "₹${plan.originalPrice}",
                                    style: TextStyle(
                                      decoration: TextDecoration.lineThrough,
                                      fontSize: 16,
                                      color: textColor.withOpacity(0.5),
                                    ),
                                  ),
                                if (plan.discountPercent > 0)
                                  const SizedBox(height: 2),
                                Text(
                                  "₹${plan.finalPrice.toStringAsFixed(0)}",
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w900,
                                    color: isSelected
                                        ? Colors.amber
                                        : textColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      Text(
                        _durationText(plan.durationInDays),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.amber
                              : textColor.withOpacity(0.6),
                        ),
                      ),

                      const SizedBox(height: 6),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? primaryColor.withOpacity(0.15)
                              : primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "₹$perDayCost/day",
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? Colors.amber
                                : textColor.withOpacity(0.7),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

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
          top: BorderSide(color: primaryColor.withOpacity(0.15), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (selectedPlan.discountPercent > 0)
            Text(
              "🎉 You save ${selectedPlan.discountPercent}%!",
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),

          const SizedBox(height: 10),

          Obx(() {
            return GestureDetector(
              onTapDown: (_) => scaleController.animateTo(0.95),
              onTapUp: (_) => scaleController.animateTo(1.0),
              onTapCancel: () => scaleController.animateTo(1.0),
              onTap: splashController.isPaymentInProgress.value
                  ? () {}
                  : () async {
                      try {
                        splashController.isPaymentInProgress.value = true;
                        await PaymentService.instance.pay(
                          context: context,
                          plan: selectedPlan,
                          razorpayKey:
                              splashController
                                  .remoteConfigModel
                                  .value
                                  ?.config
                                  .rzpId ??
                              "",
                          onPaymentSuccess: () async {
                            await UserService.refreshUserStatus();
                            Get.to(() => PremiumSuccessScreen(selectedPlan));
                          },
                          onPaymentFailed: (err) {
                            debugPrint("Payment Error: $err");
                          },
                        );
                      } catch (e) {
                        showAlert(context: context, message: e);
                      } finally {
                        splashController.isPaymentInProgress.value = false;
                      }
                    },
              child: ScaleTransition(
                scale: scaleController,
                child: _buildSmoothShimmerButton(
                  primaryColor,
                  isDark,
                  selectedPlan,
                ),
              ),
            );
          }),

          const SizedBox(height: 8),

          Text(
            "Cancel anytime",
            textAlign: TextAlign.center,
            style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildSmoothShimmerButton(
    Color primaryColor,
    bool isDark,
    PlanModel plan,
  ) {
    return AnimatedBuilder(
      animation: shimmerController,
      builder: (context, child) {
        return Obx(() {
          final bool isLoading = splashController.isPaymentInProgress.value;

          return IgnorePointer(
            ignoring: isLoading,
            child: Container(
              height: 56,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.darkPrimary,
                    AppColors.darkAccent,
                    AppColors.darkPrimary,
                  ],
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
                    color: primaryColor.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Button Content
                  AnimatedOpacity(
                    opacity: isLoading ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.workspace_premium_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Get for ₹${plan.finalPrice.toStringAsFixed(0)}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Loader
                  if (isLoading)
                    const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  double _calculateShimmerStop(double base) {
    final animValue = shimmerController.value;
    final offset = sin(animValue * pi * 2) * 0.3;
    return (base + offset).clamp(0.0, 1.0);
  }

  List<PlanModel> _dummyPlans() {
    return [];
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
