import 'dart:io';
import 'package:cinezza/controllers/splash_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'CommonShimmer.dart';

class BannerAdWidget extends StatefulWidget {
  final bool forceShow;
  const BannerAdWidget({super.key, this.forceShow = false});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget>
    with AutomaticKeepAliveClientMixin {
  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;
  bool _disposed = false;

  final SplashController splash = Get.find<SplashController>();

  // Computed values - calculated once
  late bool adsEnabled;
  late bool isPremium;
  late String adUnitId;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeAdSettings();
  }

  void _initializeAdSettings() {
    // Calculate ad settings once in initState
    adsEnabled = splash.remoteConfigModel.value?.config.isAdsEnable ?? true;
    isPremium = splash.userModel.value?.user.planActive ?? false;

    // Determine ad unit ID once
    final remoteId = splash.remoteConfigModel.value?.config.adIds.banner ?? "";
    adUnitId = remoteId.isNotEmpty
        ? remoteId
        : Platform.isAndroid
        ? "ca-app-pub-3940256099942544/6300978111"
        : "ca-app-pub-3940256099942544/2934735716";

    // Load banner only if conditions are met
    if ((adsEnabled && !isPremium) || widget.forceShow) {
      _loadBanner();
    } else {
      debugPrint("🚫 Ads disabled or user is premium — banner will NOT load.");
    }
  }

  void _loadBanner() {
    if (_disposed) return;

    debugPrint("📡 Loading Banner Ad: $adUnitId");

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (_disposed || !mounted) return;
          if (mounted) {
            setState(() => _isBannerLoaded = true);
          }
          debugPrint("🎉 Banner Ad Loaded: ${ad.hashCode}");
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint("❌ Banner Ad Failed: $error");
          ad.dispose();
          if (!_disposed && mounted) {
            setState(() => _isBannerLoaded = false);
          }
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _disposed = true;
    _bannerAd?.dispose();
    _bannerAd = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // 👉 Force show for UI testing
    if (widget.forceShow) {
      return _isBannerLoaded ? _buildBannerBox() : _buildLoadingShimmer();
    }

    // 🚫 Return empty widget if ads disabled or user is premium
    if (!adsEnabled || isPremium) {
      return const SizedBox.shrink();
    }

    return _isBannerLoaded ? _buildBannerBox() : _buildLoadingShimmer();
  }

  Widget _buildBannerBox() {
    if (_bannerAd == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      height: 60,
      alignment: Alignment.center,
      child: AdWidget(ad: _bannerAd!),
    );
  }

  Widget _buildLoadingShimmer() {
    return CommonShimmer(
      colorOpacity: 0.3,
      child: Container(
        height: 60,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
