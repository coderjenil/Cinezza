import 'package:cinezza/controllers/splash_controller.dart';

import 'package:cinezza/services/user_api_service.dart';
import 'package:cinezza/views/premium/premium_plan_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../services/ad.dart';

class TimeExpiredScreen extends StatefulWidget {
  final User user;
  final VoidCallback onAdWatched;
  final VoidCallback onGoBack;

  const TimeExpiredScreen({
    super.key,
    required this.user,
    required this.onAdWatched,
    required this.onGoBack,
  });

  @override
  State<TimeExpiredScreen> createState() => _TimeExpiredScreenState();
}

class _TimeExpiredScreenState extends State<TimeExpiredScreen> {
  bool _isProcessing = false;
  bool _isLoadingAd = false;

  SplashController splashController = Get.find<SplashController>();

  Future<void> _showRewardedAd() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _isLoadingAd = true;
    });

    await AdService().showRewarded(
      context,
      onReward: (ad, reward) async {
        await _grantBonusTime();
        widget.onAdWatched();
      },
      onComplete: () {
        setState(() {
          _isProcessing = false;
          _isLoadingAd = false;
        });
      },
    );
  }

  Future<void> _grantBonusTime() async {
    try {
      int currentUsage = widget.user.reelsUsage;
      int newUsage =
          currentUsage +
          (splashController.remoteConfigModel.value?.config.reelIncreaseTime ??
              60);

      debugPrint('🎁 Granting bonus: $currentUsage → $newUsage seconds');

      await UserService.updateUserByDeviceId(reelsUsage: newUsage);
    } catch (e) {
      debugPrint('❌ Error granting bonus: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async {
        if (!_isProcessing) widget.onGoBack();
        return false;
      },
      child: Scaffold(
        backgroundColor: isDark
            ? AppColors.darkBackground
            : AppColors.lightBackground,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkPrimary.withOpacity(0.1)
                          : AppColors.lightPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: Icon(
                      Icons.access_time_filled_rounded,
                      color: isDark
                          ? AppColors.darkPrimary
                          : AppColors.lightPrimary,
                      size: 60,
                    ),
                  ),

                  const SizedBox(height: 30),

                  Text(
                    "Time's Up!",
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'Watch an ad to unlock 5 extra minutes.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 40),

                  /// WATCH AD BUTTON
                  Obx(() {
                    bool showAdButton =
                        splashController
                            .remoteConfigModel
                            .value
                            ?.config
                            .isAdsEnable ??
                        false;
                    return !showAdButton
                        ? SizedBox()
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.warning,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              onPressed: _isProcessing ? null : _showRewardedAd,
                              child: _isLoadingAd
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  : const Text(
                                      'Watch Ad (+5 Min)',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          );
                  }),

                  const SizedBox(height: 12),

                  /// UPGRADE BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark
                            ? AppColors.darkPrimary
                            : AppColors.lightPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: _isProcessing
                          ? null
                          : () => Get.to(() => PremiumPlansPage()),
                      icon: const Icon(Icons.star, color: Colors.white),
                      label: const Text(
                        'Upgrade to Premium',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextButton(
                    onPressed: _isProcessing ? null : widget.onGoBack,
                    child: Text(
                      'Go Back',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
