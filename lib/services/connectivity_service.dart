import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../views/no_internet_screen.dart';

class ConnectivityService extends GetxService {
  final Connectivity _connectivity = Connectivity();
  late final StreamSubscription<List<ConnectivityResult>> _subscription;
  final RxBool isConnected = true.obs;

  Future<ConnectivityService> init() async {
    // Initial check
    final hasInternet = await InternetConnectionChecker().hasConnection;
    isConnected.value = hasInternet;
    _handleConnectionChange(hasInternet);

    // Listen to connectivity changes
    _subscription = _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> result,
    ) async {
      // connectivity_plus only tells network type, not real internet
      final hasInternet = await InternetConnectionChecker().hasConnection;
      if (isConnected.value != hasInternet) {
        isConnected.value = hasInternet;
        _handleConnectionChange(hasInternet);
      }
    });

    return this;
  }

  void _handleConnectionChange(bool hasInternet) {
    if (!hasInternet) {
      // Show full-screen no-internet overlay if not already open
      if (!(Get.isDialogOpen ?? false)) {
        Get.dialog(
          const NoInternetScreen(),
          barrierDismissible: false,
          useSafeArea: true,
        );
      }
    } else {
      // Close no-internet overlay if open
      if (Get.isDialogOpen ?? false) {
        Get.back(); // pop dialog
      }
    }
  }

  @override
  void onClose() {
    _subscription.cancel();
    super.onClose();
  }
}
