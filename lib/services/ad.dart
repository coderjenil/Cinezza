import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  // Track if interstitial ad is currently showing
  bool _isInterstitialAdShowing = false;

  // ----------------------- TEST AD TOGGLE -----------------------
  // Set to true for test ads, false for production ads
  static const bool testAd = true;

  // ----------------------- Test Ad IDs (Google provided) -----------------------
  static String get _testInterstitialAdId => Platform.isAndroid
      ? "ca-app-pub-3940256099942544/1033173712"
      : "ca-app-pub-3940256099942544/4411468910";

  static String get _testRewardedAdId => Platform.isAndroid
      ? "ca-app-pub-3940256099942544/5224354917"
      : "ca-app-pub-3940256099942544/1712485313";

  static String get _testAppOpenId => Platform.isAndroid
      ? "ca-app-pub-3940256099942544/9257395921"
      : "ca-app-pub-3940256099942544/5575463023";

  static String get _testBannerAdId => Platform.isAndroid
      ? "ca-app-pub-3940256099942544/6300978111"
      : "ca-app-pub-3940256099942544/2934735716";

  static String get _testNativeId => Platform.isAndroid
      ? "ca-app-pub-3940256099942544/2247696110"
      : "ca-app-pub-3940256099942544/3986624511";

  // ----------------------- Dynamic IDs (Production from Remote Config) -----------------------
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

  // ----------------------- Final Ad ID Getters (Test/Production Switch) -----------------------

  static String get interstitialAdId {
    if (testAd) return _testInterstitialAdId;
    return _getRemoteId("interstitial").isNotEmpty
        ? _getRemoteId("interstitial")
        : _testInterstitialAdId;
  }

  static String get rewardedAdId {
    if (testAd) return _testRewardedAdId;
    return _getRemoteId("rewarded").isNotEmpty
        ? _getRemoteId("rewarded")
        : _testRewardedAdId;
  }

  static String get appOpenId {
    if (testAd) return _testAppOpenId;
    return _getRemoteId("app_open").isNotEmpty
        ? _getRemoteId("app_open")
        : _testAppOpenId;
  }

  static String get bannerAdId {
    if (testAd) return _testBannerAdId;
    return _getRemoteId("banner").isNotEmpty
        ? _getRemoteId("banner")
        : _testBannerAdId;
  }

  static String get nativeId {
    if (testAd) return _testNativeId;
    return _getRemoteId("native").isNotEmpty
        ? _getRemoteId("native")
        : _testNativeId;
  }

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

  // ----------------------- Interstitial with Back Button Prevention -----------------------
  Future<void> _showInterstitial(
    BuildContext context,
    VoidCallback onComplete, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    bool dismissed = false;
    bool loaderDismissed = false;

    // Show loader with back button prevention
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      ),
    );

    // Timeout for loading
    Timer(timeout, () {
      if (!loaderDismissed && !_isInterstitialAdShowing) {
        Navigator.pop(context);
        loaderDismissed = true;
        if (!dismissed) {
          dismissed = true;
          onComplete();
        }
      }
    });

    await InterstitialAd.load(
      adUnitId: interstitialAdId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdFailedToLoad: (_) {
          if (!loaderDismissed) {
            Navigator.pop(context);
            loaderDismissed = true;
          }
          if (!dismissed) {
            dismissed = true;
            onComplete();
          }
        },
        onAdLoaded: (ad) {
          if (dismissed) {
            ad.dispose();
            return;
          }

          // Close loader
          if (!loaderDismissed) {
            Navigator.pop(context);
            loaderDismissed = true;
          }

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (_) {
              _isInterstitialAdShowing = true;
              print('📺 Interstitial ad is now showing');
            },
            onAdDismissedFullScreenContent: (_) {
              _isInterstitialAdShowing = false;
              ad.dispose();
              if (!dismissed) {
                dismissed = true;
                onComplete();
              }
              print('✅ Interstitial ad dismissed properly');
            },
            onAdFailedToShowFullScreenContent: (_, error) {
              _isInterstitialAdShowing = false;
              ad.dispose();
              if (!dismissed) {
                dismissed = true;
                onComplete();
              }
              print('❌ Interstitial ad failed to show: $error');
            },
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
            onAdDismissedFullScreenContent: (_) {
              ad.dispose();
              onComplete?.call();
            },
            onAdFailedToShowFullScreenContent: (_, __) {
              ad.dispose();
              onComplete?.call();
            },
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
}

// ------------------------- Shimmer Widget -------------------------
class ShimmerWidget extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;

  const ShimmerWidget({
    super.key,
    required this.child,
    this.baseColor = const Color(0x1AFFFFFF),
    this.highlightColor = const Color(0x33FFFFFF),
  });

  @override
  State<ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: [0.0, 0.5, 1.0],
              transform: _SlidingGradientTransform(
                slidePercent: _animation.value,
              ),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}

// ------------------------- Native Loader Widget with Shimmer -------------------------
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
    final adHeight =
        widget.height ??
        (widget.useCustomLayout
            ? 250.0
            : (widget.type == TemplateType.medium ? 250.0 : 110.0));

    if (!loaded || _ad == null) {
      return ShimmerWidget(
        child: Container(
          height: adHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }

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

  final Duration maxCacheDuration = const Duration(hours: 4);
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

  void loadAd() {
    if (_isPremium()) return;

    // AppOpenAd.load(
    //   adUnitId: AdService.appOpenId,
    //   request: const AdRequest(),
    //   adLoadCallback: AppOpenAdLoadCallback(
    //     onAdLoaded: (ad) {
    //       print('✅ App open ad loaded');
    //       _appOpenLoadTime = DateTime.now();
    //       _appOpenAd = ad;
    //     },
    //     onAdFailedToLoad: (error) {
    //       print('❌ App open ad failed to load: $error');
    //     },
    //   ),
    // );
  }

  void onAppBackgrounded() {
    _lastPauseTime = DateTime.now();
  }

  bool get isAdAvailable {
    if (_appOpenAd == null) return false;
    if (_appOpenLoadTime == null) return false;

    final now = DateTime.now();
    final duration = now.difference(_appOpenLoadTime!);
    return duration < maxCacheDuration;
  }

  void showAdIfAvailable() {
    if (_isPremium()) return;
    if (_isShowingAd) {
      print('⚠️ Ad already showing');
      return;
    }

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
        loadAd();
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
