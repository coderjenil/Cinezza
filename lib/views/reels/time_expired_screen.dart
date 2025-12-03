// time_expired_screen.dart

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../services/user_api_service.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';

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
  // RewardedAd? _rewardedAd;
  bool _isAdLoading = false;
  bool _isProcessing = false; // Prevent double-tap

  @override
  void initState() {
    super.initState();
    _loadRewardedAd();
  }

  @override
  void dispose() {
    // _rewardedAd?.dispose();
    super.dispose();
  }

  void _loadRewardedAd() {
    if (!mounted) return;

    setState(() => _isAdLoading = true);

    // TODO: Implement real ad loading
    // RewardedAd.load(
    //   adUnitId: 'YOUR_AD_UNIT_ID',
    //   request: const AdRequest(),
    //   rewardedAdLoadCallback: RewardedAdLoadCallback(
    //     onAdLoaded: (ad) {
    //       if (mounted) {
    //         _rewardedAd = ad;
    //         setState(() => _isAdLoading = false);
    //       }
    //     },
    //     onAdFailedToLoad: (error) {
    //       if (mounted) {
    //         setState(() => _isAdLoading = false);
    //         _showErrorDialog();
    //       }
    //     },
    //   ),
    // );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isAdLoading = false);
      }
    });
  }

  void _showRewardedAd() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      // Demo implementation - grant bonus time
      await _grantBonusTime();

      // Call the callback to notify parent
      if (mounted) {
        widget.onAdWatched();
      }
    } catch (e) {
      debugPrint('❌ Error showing rewarded ad: $e');
      if (mounted) {
        setState(() => _isProcessing = false);
        _showErrorDialog();
      }
    }

    // TODO: Uncomment for real ads
    // if (_rewardedAd != null) {
    //   _rewardedAd!.show(
    //     onUserEarnedReward: (ad, reward) async {
    //       await _grantBonusTime();
    //       if (mounted) {
    //         widget.onAdWatched();
    //       }
    //     },
    //   );
    // } else {
    //   setState(() => _isProcessing = false);
    //   _showErrorDialog();
    // }
  }

  Future<void> _grantBonusTime() async {
    try {
      int currentUsage = widget.user.reelsUsage ?? 0;
      int newUsage = currentUsage + 300; // Add 5 minutes

      debugPrint('🎁 Granting bonus: $currentUsage -> $newUsage seconds');
      await UserService.updateUserByDeviceId(reelsUsage: newUsage);
    } catch (e) {
      debugPrint('❌ Error granting bonus time: $e');
      rethrow;
    }
  }

  void _showErrorDialog() {
    if (!mounted) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark
            ? AppColors.darkSurface
            : AppColors.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Ad Not Available',
          style: TextStyle(
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ),
        content: Text(
          'Unable to load ad. Please check your internet connection and try again.',
          style: TextStyle(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextTertiary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark
                  ? AppColors.darkPrimary
                  : AppColors.lightPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              _loadRewardedAd();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async {
        if (!_isProcessing) {
          widget.onGoBack();
        }
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
                    'Time\'s Up!',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your free reels session has ended.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Watch an ad to get 5 more minutes!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.lightTextSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.warning, Color(0xFFF57C00)],
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: (_isAdLoading || _isProcessing)
                          ? null
                          : _showRewardedAd,
                      icon: (_isAdLoading || _isProcessing)
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.play_circle_outline_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                      label: Text(
                        _isProcessing
                            ? 'Processing...'
                            : _isAdLoading
                            ? 'Loading...'
                            : 'Watch Ad (+5 Min)',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: isDark
                          ? AppColors.darkPrimaryGradient
                          : AppColors.lightPrimaryGradient,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: _isProcessing
                          ? null
                          : () {
                              // TODO: Navigate to subscription screen
                            },
                      icon: const Icon(
                        Icons.star_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: const Text(
                        'Upgrade Premium',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: _isProcessing ? null : widget.onGoBack,
                    child: Text(
                      'Go Back',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.lightTextSecondary,
                        fontSize: 14,
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
