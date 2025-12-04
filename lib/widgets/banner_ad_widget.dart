import 'dart:io';
import 'package:app/controllers/splash_controller.dart';
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

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  void _loadBanner() {
    if (_disposed) return;

    final splash = Get.find<SplashController>();
    final remoteId = splash.remoteConfigModel.value?.config.adIds.banner ?? "";

    final adUnit = remoteId.isNotEmpty
        ? remoteId
        : Platform.isAndroid
        ? "ca-app-pub-3940256099942544/6300978111"
        : "ca-app-pub-3940256099942544/2934735716";

    _bannerAd = BannerAd(
      adUnitId: adUnit,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (_disposed || !mounted) return;
          setState(() => _isBannerLoaded = true);
          debugPrint("🎉 Banner Ad Loaded: ${ad.hashCode}");
        },
        onAdFailedToLoad: (_, error) {
          debugPrint("❌ Banner Ad Failed: $error");
          if (!_disposed) setState(() => _isBannerLoaded = false);
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _disposed = true;
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // 👉 Force show is useful for testing banners in layouts
    if (widget.forceShow) {
      return _isBannerLoaded ? _bannerBox() : _loadingShimmer();
    }

    final splash = Get.find<SplashController>();

    final adsEnabled =
        splash.remoteConfigModel.value?.config.isAdsEnable ?? true;
    final isPremium = splash.userModel.value?.user.planActive ?? false;

    if (!adsEnabled || isPremium) {
      return const SizedBox.shrink();
    }

    return _isBannerLoaded ? _bannerBox() : _loadingShimmer();
  }

  Widget _bannerBox() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 60, // 👈 ensures visibility inside list layouts
      alignment: Alignment.center,
      child: AdWidget(ad: _bannerAd!),
    );
  }

  Widget _loadingShimmer() {
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
