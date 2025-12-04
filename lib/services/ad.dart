import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../controllers/splash_controller.dart';
import '../widgets/banner_ad_widget.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  static bool Function()? isUserPremium;

  int _adCounter = 0;
  int _delayCount = 1;

  // ----------------------- Dynamic IDs -----------------------
  static String _getRemoteId(String type) {
    try {
      final controller = Get.find<SplashController>();
      final ids = controller.remoteConfigModel.value?.config.adIds;

      switch (type) {
        case "interstitial":
          return ids?.interstitial ?? "";
        case "rewarded":
          return ids?.rewarded ?? "";
        case "rewarded_interstitial":
          return ids?.rewardedInterstitial ?? "";
        case "app_open":
          return ids?.appOpen ?? "";
        case "banner":
          return ids?.banner ?? "";
        case "native":
          return ids?.native ?? "";
        default:
          return "";
      }
    } catch (_) {
      return "";
    }
  }

  // ----------------------- Test fallback + final getters -----------------------

  static String get interstitialAdId => _getRemoteId("interstitial").isNotEmpty
      ? _getRemoteId("interstitial")
      : (Platform.isAndroid
            ? "ca-app-pub-3940256099942544/1033173712"
            : "ca-app-pub-3940256099942544/4411468910");

  static String get rewardedAdId => _getRemoteId("rewarded").isNotEmpty
      ? _getRemoteId("rewarded")
      : (Platform.isAndroid
            ? "ca-app-pub-3940256099942544/5224354917"
            : "ca-app-pub-3940256099942544/1712485313");

  static String get rewardedInterstitialId =>
      _getRemoteId("rewarded_interstitial").isNotEmpty
      ? _getRemoteId("rewarded_interstitial")
      : (Platform.isAndroid
            ? "ca-app-pub-3940256099942544/5354046379"
            : "ca-app-pub-3940256099942544/6978759866");

  static String get appOpenId => _getRemoteId("app_open").isNotEmpty
      ? _getRemoteId("app_open")
      : (Platform.isAndroid
            ? "ca-app-pub-3940256099942544/9257395921"
            : "ca-app-pub-3940256099942544/5575463023");

  static String get bannerAdId => _getRemoteId("banner").isNotEmpty
      ? _getRemoteId("banner")
      : (Platform.isAndroid
            ? "ca-app-pub-3940256099942544/6300978111"
            : "ca-app-pub-3940256099942544/2934735716");

  static String get nativeId => _getRemoteId("native").isNotEmpty
      ? _getRemoteId("native")
      : (Platform.isAndroid
            ? "ca-app-pub-3940256099942544/2247696110"
            : "ca-app-pub-3940256099942544/3986624511");

  // ----------------------- Banner -----------------------
  Widget banner({bool forceShow = false}) {
    if (forceShow == true) return const BannerAdWidget(forceShow: true);
    if (_isPremium()) return const SizedBox.shrink();
    return const BannerAdWidget();
  }

  // ----------------------- Delay Logic -----------------------
  void setDelay(int count) => _delayCount = count;

  bool _shouldShow() {
    if (_delayCount == 0) return true;
    return ((_adCounter - 1) % (_delayCount + 1)) == 0;
  }

  // ----------------------- MAIN METHOD -----------------------
  Future<void> showAdWithCounter(
    BuildContext context, {
    required VoidCallback onComplete,
  }) async {
    if (_isPremium()) {
      onComplete();
      return;
    }

    _adCounter++;

    if (_shouldShow()) {
      await _showInterstitial(context, onComplete);
    } else {
      onComplete();
    }
  }

  // ----------------------- Interstitial -----------------------
  Future<void> _showInterstitial(
    BuildContext context,
    VoidCallback onComplete, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    _showLoader(context);

    bool dismissed = false;

    Timer(timeout, () {
      if (!dismissed) {
        Navigator.pop(context);
        dismissed = true;
        onComplete();
      }
    });

    await InterstitialAd.load(
      adUnitId: interstitialAdId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdFailedToLoad: (_) {
          if (!dismissed) {
            Navigator.pop(context);
            dismissed = true;
            onComplete();
          }
        },
        onAdLoaded: (ad) {
          if (dismissed) {
            ad.dispose();
            return;
          }

          Navigator.pop(context);
          dismissed = true;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (_) => onComplete(),
            onAdFailedToShowFullScreenContent: (_, __) => onComplete(),
          );

          ad.show();
        },
      ),
    );
  }

  // ----------------------- Rewarded -----------------------
  Future<void> showRewarded(
    BuildContext context, {
    required Function(AdWithoutView, RewardItem) onReward,
    VoidCallback? onComplete,
  }) async {
    if (_isPremium()) {
      onComplete?.call();
      return;
    }

    _showLoader(context);

    RewardedAd.load(
      adUnitId: rewardedAdId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdFailedToLoad: (_) {
          Navigator.pop(context);
          onComplete?.call();
        },
        onAdLoaded: (ad) {
          Navigator.pop(context);

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (_) => onComplete?.call(),
            onAdFailedToShowFullScreenContent: (_, __) => onComplete?.call(),
          );

          ad.show(
            onUserEarnedReward: (adView, reward) => onReward(adView, reward),
          );
        },
      ),
    );
  }

  // ----------------------- Rewarded Interstitial -----------------------
  Future<void> showRewardedInterstitial(
    BuildContext context, {
    required Function(AdWithoutView, RewardItem) onReward,
    VoidCallback? onComplete,
  }) async {
    if (_isPremium()) {
      onComplete?.call();
      return;
    }

    _showLoader(context);

    RewardedInterstitialAd.load(
      adUnitId: rewardedInterstitialId,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdFailedToLoad: (_) {
          Navigator.pop(context);
          onComplete?.call();
        },
        onAdLoaded: (ad) {
          Navigator.pop(context);

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (_) => onComplete?.call(),
            onAdFailedToShowFullScreenContent: (_, __) => onComplete?.call(),
          );

          ad.show(
            onUserEarnedReward: (adView, reward) => onReward(adView, reward),
          );
        },
      ),
    );
  }

  // ----------------------- App Open -----------------------
  Future<void> showAppOpen() async {
    if (_isPremium()) return;

    await AppOpenAd.load(
      adUnitId: appOpenId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) => ad.show(),
        onAdFailedToLoad: (_) {},
      ),
    );
  }

  // ----------------------- Native -----------------------
  Widget native() {
    if (_isPremium()) return const SizedBox.shrink();
    return _NativeAdLoader();
  }

  // ----------------------- UI Loader -----------------------
  void _showLoader(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          const Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }

  // ----------------------- Premium Check -----------------------
  bool _isPremium() {
    final controller = Get.find<SplashController>();
    bool remote =
        controller.remoteConfigModel.value?.config.isAdsEnable ?? true;

    if (!remote) return true;
    if (isUserPremium != null) return isUserPremium!.call();

    return false;
  }
}

// ------------------------- Native Loader Widget -------------------------
class _NativeAdLoader extends StatefulWidget {
  @override
  State<_NativeAdLoader> createState() => _NativeAdLoaderState();
}

class _NativeAdLoaderState extends State<_NativeAdLoader> {
  NativeAd? _ad;
  bool loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _ad = NativeAd(
      adUnitId: AdService.nativeId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (_) => setState(() => loaded = true),
        onAdFailedToLoad: (_, __) => setState(() => loaded = false),
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
      ),
    );

    _ad!.load();
  }

  @override
  Widget build(BuildContext context) {
    if (!loaded) return const SizedBox.shrink();
    return SizedBox(height: 300, child: AdWidget(ad: _ad!));
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }
}
