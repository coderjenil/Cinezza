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
  static Future<void> showAppOpen() async {
    if (_isPremium()) return;

    await AppOpenAd.load(
      adUnitId: appOpenId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) => ad.show(),
        onAdFailedToLoad: (e) {
          debugPrint(e.toString());
        },
      ),
    );
  }

  // ----------------------- Native -----------------------
  Widget native({
    TemplateType type = TemplateType.small,
    bool useCustomLayout = false,
    double? height,
  }) {
    if (_isPremium()) return const SizedBox.shrink();
    return NativeAdLoader(
      type: type,
      useCustomLayout: useCustomLayout,
      height: height,
    );
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
  static bool _isPremium() {
    final controller = Get.find<SplashController>();
    bool remote =
        controller.remoteConfigModel.value?.config.isAdsEnable ?? true;

    if (!remote) return true;
    if (controller.isPremium) return true;

    return false;
  }
}

// ------------------------- Native Loader Widget -------------------------
class NativeAdLoader extends StatefulWidget {
  final TemplateType type;
  final bool useCustomLayout;
  final double? height;

  const NativeAdLoader({
    super.key,
    this.type = TemplateType.small,
    this.useCustomLayout = false,
    this.height,
  });

  @override
  State<NativeAdLoader> createState() => _NativeAdLoaderState();
}

class _NativeAdLoaderState extends State<NativeAdLoader> {
  NativeAd? _ad;
  bool loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    if (widget.useCustomLayout) {
      // Custom layout - prevents content cutting
      _ad = NativeAd(
        adUnitId: AdService.nativeId,
        factoryId: 'customAdFactory',
        request: const AdRequest(),
        listener: NativeAdListener(
          onAdLoaded: (_) {
            print('✅ Custom native ad loaded successfully');
            if (mounted) setState(() => loaded = true);
          },
          onAdFailedToLoad: (ad, error) {
            print('❌ Custom native ad failed to load: $error');
            ad.dispose();
            if (mounted) setState(() => loaded = false);
          },
        ),
      );
    } else {
      // Template layout
      _ad = NativeAd(
        adUnitId: AdService.nativeId,
        request: const AdRequest(),
        listener: NativeAdListener(
          onAdLoaded: (_) {
            print('✅ Template native ad loaded successfully');
            if (mounted) setState(() => loaded = true);
          },
          onAdFailedToLoad: (ad, error) {
            print('❌ Template native ad failed to load: $error');
            ad.dispose();
            if (mounted) setState(() => loaded = false);
          },
        ),
        nativeTemplateStyle: NativeTemplateStyle(templateType: widget.type),
      );
    }

    _ad!.load();
  }

  @override
  Widget build(BuildContext context) {
    if (!loaded || _ad == null) return const SizedBox.shrink();

    // Use provided height or default based on layout type
    final adHeight =
        widget.height ??
        (widget.useCustomLayout
            ? 250.0
            : (widget.type == TemplateType.medium ? 250.0 : 110.0));

    return SizedBox(
      height: adHeight,
      width: double.infinity,
      child: AdWidget(ad: _ad!),
    );
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }
}

class AppLifecycleHandler extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // AdService.showAppOpen();
    }
  }
}

class AppOpenAdManager {
  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;
  DateTime? _appOpenLoadTime;

  /// Maximum duration allowed between loading and showing the ad
  final Duration maxCacheDuration = const Duration(hours: 4);

  /// Minimum time app must be in background before showing ad again
  final Duration minBackgroundDuration = const Duration(seconds: 30);
  DateTime? _lastPauseTime;

  static bool _isPremium() {
    try {
      final controller = Get.find<SplashController>();
      bool remote =
          controller.remoteConfigModel.value?.config.isAdsEnable ?? true;
      if (!remote) return true;
      if (controller.isPremium) return true;
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Load an app open ad
  void loadAd() {
    if (_isPremium()) return;

    AppOpenAd.load(
      adUnitId: AdService.appOpenId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          print('✅ App open ad loaded');
          _appOpenLoadTime = DateTime.now();
          _appOpenAd = ad;
        },
        onAdFailedToLoad: (error) {
          print('❌ App open ad failed to load: $error');
        },
      ),
    );
  }

  /// Track when app goes to background
  void onAppBackgrounded() {
    _lastPauseTime = DateTime.now();
  }

  /// Whether an ad is available and not expired
  bool get isAdAvailable {
    if (_appOpenAd == null) return false;
    if (_appOpenLoadTime == null) return false;

    final now = DateTime.now();
    final duration = now.difference(_appOpenLoadTime!);
    return duration < maxCacheDuration;
  }

  /// Show the ad if available
  void showAdIfAvailable() {
    if (_isPremium()) return;
    if (_isShowingAd) {
      print('⚠️ Ad already showing');
      return;
    }

    // Check if app was in background long enough
    if (_lastPauseTime != null) {
      final backgroundDuration = DateTime.now().difference(_lastPauseTime!);
      if (backgroundDuration < minBackgroundDuration) {
        print('⚠️ App was not in background long enough');
        return;
      }
    }

    if (!isAdAvailable) {
      print('⚠️ Ad not available or expired. Loading new ad...');
      loadAd();
      return;
    }

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
        print('📺 App open ad showed');
      },
      onAdDismissedFullScreenContent: (ad) {
        print('✅ App open ad dismissed');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        loadAd(); // Preload next ad
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('❌ Failed to show app open ad: $error');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        loadAd();
      },
    );

    _appOpenAd!.show();
  }

  void dispose() {
    _appOpenAd?.dispose();
    _appOpenAd = null;
  }
}
