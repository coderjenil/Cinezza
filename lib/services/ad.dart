import 'dart:async';
import 'dart:io';
import 'package:app/controllers/splash_controller.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';

import '../widgets/banner_ad_widget.dart';
class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  static bool Function()? isUserPremium;

  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  RewardedInterstitialAd? _rewardedInterstitialAd;
  AppOpenAd? _appOpenAd;
  NativeAd? _nativeAd;
  static int _tapCount = 0;

  static bool isInterstitialAdLoaded = false;
  static bool isRewardedAdLoaded = false;
  static bool isRewardedInterstitialAdLoaded = false;
  static bool isAppOpenAdLoaded = false;
  static bool isNativeAdLoaded = false;

  // In-memory counter (resets when app is closed)
  int _videoPlayCounter = 0;
  int _adDelayCount = 1; // Delay count from config

  // Dynamic Ad Unit IDs from Realtime Database
  static String get bannerAdUnitId {
    try {
     SplashController splashController =  Get.find<SplashController>();
      debugPrint("banner ad id ${splashController.remoteConfigModel.value?.config?.adIds?.banner??''}");
      return splashController.remoteConfigModel.value?.config?.adIds?.banner??'';
    } catch (e) {
      print('⚠️ Error getting banner ad ID: $e');
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/6300978111'
          : 'ca-app-pub-3940256099942544/2934735716';
    }
  }

  static String get interstitialAdUnitId {
    try {
      SplashController splashController =  Get.find<SplashController>();
      return splashController.remoteConfigModel.value?.config?.adIds?.interstitial??'';
    } catch (e) {
      print('⚠️ Error getting interstitial ad ID: $e');
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/1033173712'
          : 'ca-app-pub-3940256099942544/4411468910';
    }
  }

  static String get rewardedAdUnitId {
    try {
      SplashController splashController =  Get.find<SplashController>();
      return splashController.remoteConfigModel.value?.config?.adIds?.rewarded??'';
    } catch (e) {
      print('⚠️ Error getting rewarded ad ID: $e');
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/5224354917'
          : 'ca-app-pub-3940256099942544/1712485313';
    }
  }

  static String get appOpenAdUnitId {
    try {
      SplashController splashController =  Get.find<SplashController>();
      return splashController.remoteConfigModel.value?.config?.adIds?.appOpen??'';
    } catch (e) {
      print('⚠️ Error getting app open ad ID: $e');
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/9257395921'
          : 'ca-app-pub-3940256099942544/5575463023';
    }
  }

  static String get nativeAdUnitId {
    try {
      SplashController splashController =  Get.find<SplashController>();
      return splashController.remoteConfigModel.value?.config?.adIds?.appOpen??'';
    } catch (e) {
      print('⚠️ Error getting native ad ID: $e');
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/2247696110'
          : 'ca-app-pub-3940256099942544/3986624511';
    }
  }

  Widget getBannerAdWidget({bool forceShow = false}) {
    if (forceShow) {
      return BannerAdWidget(forceShow: true);
    }
    if (_isPremium()) return const SizedBox.shrink();
    return BannerAdWidget(forceShow: false);
  }

  /// Set the delay count for ad display
  /// delayCount = 0: Show ad on every click (1, 2, 3, 4, 5...)
  /// delayCount = 1: Show ad on 1st, skip 2nd, show 3rd, skip 4th... (1, 3, 5, 7...)
  /// delayCount = 2: Show ad on 1st, skip 2nd & 3rd, show 4th... (1, 4, 7, 10...)
  /// delayCount = 3: Show ad on 1st, skip 2nd, 3rd & 4th, show 5th... (1, 5, 9, 13...)
  void setAdDelayCount(int delayCount) {
    _adDelayCount = delayCount;
    print('🎯 Ad delay count set to $_adDelayCount');
  }

  int getAdDelayCount() => _adDelayCount;

  /// Reset the counter to 0
  void resetAdCounter() {
    _videoPlayCounter = 0;
    print('🔄 Ad counter reset to 0');
  }

  /// Get the current counter value
  int getCurrentCounter() {
    return _videoPlayCounter;
  }

  /// Determines if ad should be shown based on delay count
  ///
  /// delayCount = 0: Show ad on every click
  ///   Pattern: 1✅, 2✅, 3✅, 4✅, 5✅...
  ///
  /// delayCount = 1: Show ad, skip 1, show ad, skip 1...
  ///   Pattern: 1✅, 2❌, 3✅, 4❌, 5✅, 6❌, 7✅...
  ///
  /// delayCount = 2: Show ad, skip 2, show ad, skip 2...
  ///   Pattern: 1✅, 2❌, 3❌, 4✅, 5❌, 6❌, 7✅, 8❌, 9❌, 10✅...
  ///
  /// delayCount = 3: Show ad, skip 3, show ad, skip 3...
  ///   Pattern: 1✅, 2❌, 3❌, 4❌, 5✅, 6❌, 7❌, 8❌, 9✅...
  bool _shouldShowAdBasedOnDelay() {
    if (_adDelayCount == 0) {
      // Show ad on every click
      return true;
    } else {
      // Formula: (counter - 1) % (delayCount + 1) == 0
      // This creates pattern: show, skip N times, show, skip N times...
      return ((_videoPlayCounter - 1) % (_adDelayCount + 1)) == 0;
    }
  }

  /// Main method to show interstitial ad with counter and delay logic
  /// [forceAd] - If true, shows ad immediately regardless of counter/delay
  /// [forceShow] - If true, bypasses premium check
  /// [onComplete] - Callback executed after ad completes or skips
  Future<void> showInterstitialAdWithCounter(
    BuildContext context, {
    required VoidCallback onComplete,
    Duration timeout = const Duration(seconds: 5),
    bool forceShow = false,
    bool forceAd = false, // Force ad to show, ignoring counter logic
  }) async {
    // If forceAd is true, show ad immediately without checking anything
    if (forceAd) {
      print('🚀 Force ad enabled - showing ad immediately');
      await _showInterstitialAdWithLoadingInternal(
        context,
        onComplete: onComplete,
        timeout: timeout,
      );
      return;
    }

    // Check premium status
    if (!forceShow && _isPremium()) {
      print('👑 User is premium - skipping ad');
      onComplete();
      return;
    }

    // Increment counter
    _videoPlayCounter++;

    print('📊 Counter: $_videoPlayCounter | Delay: $_adDelayCount');

    // Check if we should show the ad based on delay logic
    bool shouldShowAd = _shouldShowAdBasedOnDelay();

    if (shouldShowAd) {
      print('✅ Showing interstitial ad (Counter: $_videoPlayCounter)');
      await _showInterstitialAdWithLoadingInternal(
        context,
        onComplete: onComplete,
        timeout: timeout,
      );
    } else {
      print('⏭️ Skipping ad (Counter: $_videoPlayCounter)');
      onComplete();
    }
  }

  /// Show interstitial ad with loading dialog (without counter logic)
  /// [forceAd] - If true, shows ad immediately
  /// [forceShow] - If true, bypasses premium check
  Future<void> showInterstitialAdWithLoading(
    BuildContext context, {
    required VoidCallback onComplete,
    Duration timeout = const Duration(seconds: 5),
    bool forceShow = false,
    bool forceAd = false,
  }) async {
    // If forceAd is true, show ad immediately
    if (forceAd) {
      print('🚀 Force ad enabled - showing ad immediately');
      await _showInterstitialAdWithLoadingInternal(
        context,
        onComplete: onComplete,
        timeout: timeout,
      );
      return;
    }

    if (!forceShow && _isPremium()) {
      print('👑 User is premium - skipping ad');
      onComplete();
      return;
    }

    await _showInterstitialAdWithLoadingInternal(
      context,
      onComplete: onComplete,
      timeout: timeout,
    );
  }

  /// Internal method to actually load and show the interstitial ad
  Future<void> _showInterstitialAdWithLoadingInternal(
    BuildContext context, {
    required VoidCallback onComplete,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    bool isDialogOpen = true;
    bool hasCompletedCallback = false;

    _showLoadingDialog(context);

    void completeAndClose() {
      if (!hasCompletedCallback) {
        hasCompletedCallback = true;
        if (isDialogOpen) {
          _closeLoadingDialog(context);
          isDialogOpen = false;
        }
        onComplete();
      }
    }

    Timer timeoutTimer = Timer(timeout, () {
      print('⏱️ Ad loading timed out');
      completeAndClose();
    });

    try {
      await InterstitialAd.load(
        adUnitId: "ca-app-pub-3940256099942544/1033173712",
        // adUnitId: interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            timeoutTimer.cancel();
            _interstitialAd = ad;
            isInterstitialAdLoaded = true;

            _interstitialAd!.fullScreenContentCallback =
                FullScreenContentCallback(
                  onAdShowedFullScreenContent: (ad) {
                    print('📺 Interstitial ad showed');
                  },
                  onAdDismissedFullScreenContent: (ad) {
                    print('❌ Interstitial ad dismissed');
                    ad.dispose();
                    _interstitialAd = null;
                    isInterstitialAdLoaded = false;
                    completeAndClose();
                  },
                  onAdFailedToShowFullScreenContent: (ad, error) {
                    print('⚠️ Interstitial ad failed to show: $error');
                    ad.dispose();
                    _interstitialAd = null;
                    isInterstitialAdLoaded = false;
                    completeAndClose();
                  },
                );

            if (isDialogOpen) {
              _closeLoadingDialog(context);
              isDialogOpen = false;
            }
            _interstitialAd!.show();
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('⚠️ Interstitial ad failed to load: $error');
            timeoutTimer.cancel();
            _interstitialAd = null;
            isInterstitialAdLoaded = false;
            completeAndClose();
          },
        ),
      );
    } catch (e) {
      print('❌ Exception while loading ad: $e');
      timeoutTimer.cancel();
      completeAndClose();
    }
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF2979FF).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    color: Color(0xFF2979FF),
                    strokeWidth: 3,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Loading...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Please wait',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _closeLoadingDialog(BuildContext context) {
    try {
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    } catch (e) {
      print('❌ Error closing loading dialog: $e');
    }
  }

  void loadRewardedAd({
    VoidCallback? onAdLoaded,
    Function(LoadAdError)? onAdFailedToLoad,
    bool forceShow = false,
  }) {
    if (!forceShow && _isPremium()) return;

    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          isRewardedAdLoaded = true;
          print('🎁 Rewarded Ad loaded');

          _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _rewardedAd = null;
              isRewardedAdLoaded = false;
              loadRewardedAd(forceShow: forceShow);
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              print('⚠️ Rewarded Ad failed to show: $error');
              ad.dispose();
              _rewardedAd = null;
              isRewardedAdLoaded = false;
            },
          );

          if (onAdLoaded != null) onAdLoaded();
        },
        onAdFailedToLoad: (error) {
          print('⚠️ Rewarded Ad failed to load: $error');
          isRewardedAdLoaded = false;
          if (onAdFailedToLoad != null) onAdFailedToLoad(error);
        },
      ),
    );
  }

  void showRewardedAd({
    required Function(AdWithoutView, RewardItem) onUserEarnedReward,
    bool forceShow = false,
  }) {
    if (!forceShow && _isPremium()) return;

    if (isRewardedAdLoaded && _rewardedAd != null) {
      _rewardedAd!.show(onUserEarnedReward: onUserEarnedReward);
    } else {
      print('⚠️ Rewarded Ad is not ready yet');
      loadRewardedAd(forceShow: forceShow);
    }
  }

  void loadAppOpenAd({
    VoidCallback? onAdLoaded,
    Function(LoadAdError)? onAdFailedToLoad,
  }) {
    if (_isPremium()) return;

    AppOpenAd.load(
      adUnitId: appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          isAppOpenAdLoaded = true;
          print('🚪 App Open Ad loaded');

          _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _appOpenAd = null;
              isAppOpenAdLoaded = false;
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              print('⚠️ App Open Ad failed to show: $error');
              ad.dispose();
              _appOpenAd = null;
              isAppOpenAdLoaded = false;
            },
          );

          if (onAdLoaded != null) onAdLoaded();
        },
        onAdFailedToLoad: (error) {
          print('⚠️ App Open Ad failed to load: $error');
          isAppOpenAdLoaded = false;
          if (onAdFailedToLoad != null) onAdFailedToLoad(error);
        },
      ),
    );
  }

  void showAppOpenAd() {
    if (_isPremium()) return;

    if (isAppOpenAdLoaded && _appOpenAd != null) {
      _appOpenAd!.show();
    } else {
      print('⚠️ App Open Ad is not ready yet');
      loadAppOpenAd();
    }
  }

  void loadNativeAd({
    VoidCallback? onAdLoaded,
    Function(LoadAdError)? onAdFailedToLoad,
  }) {
    if (_isPremium()) return;

    _nativeAd = NativeAd(
      adUnitId: nativeAdUnitId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          isNativeAdLoaded = true;
          print('📰 Native Ad loaded');
          if (onAdLoaded != null) onAdLoaded();
        },
        onAdFailedToLoad: (ad, error) {
          isNativeAdLoaded = false;
          print('⚠️ Native Ad failed to load: $error');
          ad.dispose();
          if (onAdFailedToLoad != null) onAdFailedToLoad(error);
        },
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        mainBackgroundColor: Colors.white,
        cornerRadius: 10.0,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          backgroundColor: Colors.blue,
          style: NativeTemplateFontStyle.bold,
          size: 16.0,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.black,
          backgroundColor: Colors.white,
          style: NativeTemplateFontStyle.bold,
          size: 16.0,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.grey,
          backgroundColor: Colors.white,
          style: NativeTemplateFontStyle.normal,
          size: 14.0,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.grey,
          backgroundColor: Colors.white,
          style: NativeTemplateFontStyle.normal,
          size: 12.0,
        ),
      ),
    );
    _nativeAd!.load();
  }

  Widget getNativeAdWidget({double height = 300}) {
    if (_isPremium()) return const SizedBox.shrink();

    if (isNativeAdLoaded && _nativeAd != null) {
      return Container(
        height: 400,
        width: double.infinity,
        alignment: Alignment.center,
        child: AdWidget(ad: _nativeAd!),
      );
    }
    return const SizedBox.shrink();
  }

  void disposeNativeAd() {
    _nativeAd?.dispose();
    _nativeAd = null;
    isNativeAdLoaded = false;
  }

  void disposeAllAds() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _rewardedInterstitialAd?.dispose();
    _appOpenAd?.dispose();
    disposeNativeAd();
  }

  static bool _isPremium() {
    try {
      SplashController splashController =  Get.find<SplashController>();
      if (!(splashController.remoteConfigModel.value?.config?.isAdEnable??false)) {
        return true;
      }
      if (isUserPremium != null) {
        return isUserPremium!();
      }
    } catch (_) {}
    return false;
  }


  static void showAdOnTap(BuildContext context, {required VoidCallback onComplete}) {
    _tapCount++;
    print('👆 Tap count: $_tapCount');

    if (_tapCount % 3 == 0) {
      print('📺 Showing ad on tap #$_tapCount');
      AdService().showInterstitialAdWithLoading(
        context,
        onComplete: onComplete,
        forceShow: false,
      );
    } else {
      print('⏭️ Skipping ad (tap #$_tapCount)');
      onComplete();
    }
  }

}
