import 'package:cinezza/controllers/premium_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'controllers/home_controller.dart';
import 'controllers/splash_controller.dart';
import 'controllers/theme_controller.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_themes.dart';
import 'services/ad.dart';
import 'services/app_service.dart';

// NEW
import 'services/connectivity_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();
  AppService.checkAppStatus();
  MobileAds.instance.initialize();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  Get.put(HomeController());
  Get.put(SplashController());
  Get.put(PremiumController());

  // NEW: init connectivity service *before* runApp
  await Get.putAsync<ConnectivityService>(() async {
    final service = ConnectivityService();
    return service.init();
  });

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final AppOpenAdManager _appOpenAdManager = AppOpenAdManager();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _appOpenAdManager.loadAd(); // Initial load
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _appOpenAdManager.onAppBackgrounded();
        break;
      case AppLifecycleState.resumed:
        _appOpenAdManager.showAdIfAvailable();
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _appOpenAdManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.put(ThemeController());
    return Obx(
      () => GetMaterialApp(
        title: 'Cinezza',
        debugShowCheckedModeBanner: false,
        theme: AppThemes.lightTheme,
        darkTheme: AppThemes.darkTheme,
        themeMode: themeController.theme,
        initialRoute: AppRoutes.splash,
        getPages: AppRoutes.routes,
      ),
    );
  }
}
