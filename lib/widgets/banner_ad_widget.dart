import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../controllers/splash_controller.dart';
import 'CommonShimmer.dart';

class BannerAdWidget extends StatefulWidget {
  final bool forceShow;

  const BannerAdWidget({
    Key? key, // ✅ Add Key parameter
    this.forceShow = false,
  }) : super(key: key);

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget>
    with AutomaticKeepAliveClientMixin {
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;
  bool _isDisposed = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    if (_isDisposed) return;

    SplashController splashController = Get.find<SplashController>();

    _bannerAd = BannerAd(
      // adUnitId: splashController.remoteConfigModel.value?.config?.adIds?.banner??"",
      adUnitId: "ca-app-pub-3940256099942544/6300978111",
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!_isDisposed && mounted) {
            setState(() {
              _isBannerAdLoaded = true;
            });
            print('✅ Banner Ad loaded: ${ad.hashCode}');
          }
        },
        onAdFailedToLoad: (ad, error) {
          print('❌ Banner Ad failed: $error');
          ad.dispose();
          if (!_isDisposed && mounted) {
            setState(() {
              _isBannerAdLoaded = false;
            });
          }
        },
      ),
    );

    _bannerAd!.load();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Builder(
      builder: (context) {
        if (widget.forceShow) {
          if (_isBannerAdLoaded && _bannerAd != null) {
            return Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SizedBox(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
            );
          }
          return _buildShimmer();
        }

        SplashController splashController = Get.find<SplashController>();
        final isUserPremium = splashController.remoteConfigModel.value?.config?.enableTrial ?? false;
        final shouldShowAds = splashController.remoteConfigModel.value?.config?.isAdEnable ?? false;

        if (!shouldShowAds || isUserPremium) {
          return const SizedBox.shrink();
        }

        if (_isBannerAdLoaded && _bannerAd != null) {
          return Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
          );
        }

        return _buildShimmer();
      },
    );
  }

  CommonShimmer _buildShimmer() {
    return CommonShimmer(
      colorOpacity: 0.4,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        height: 50,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFffffff), Color(0xFFffffff)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
