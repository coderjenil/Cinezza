import 'dart:convert';

import 'package:cinezza/core/constants/api_end_points.dart';
import 'package:cinezza/models/remote_config_model.dart';
import 'package:cinezza/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import '../api/apsl_api_call.dart';
import '../core/routes/app_routes.dart';
import '../services/ad.dart';
import '../utils/device_helper.dart';
import '../utils/dialogs/maintenance_mode_dialog.dart';
import '../utils/dialogs/ota_update_dialog.dart';

class SplashController extends GetxController {
  final RxBool isLoading = true.obs;
  final RxBool isPaymentInProgress = false.obs;
  final RxString loadingMessage = 'Initializing...'.obs;
  final RxDouble progress = 0.0.obs;
  Rx<UserModel?> userModel = Rx<UserModel?>(null);
  Rx<RemoteConfigModel?> remoteConfigModel = Rx<RemoteConfigModel?>(null);
  String? deviceId;
  bool get isPremium => userModel.value?.user.planActive == true;

  int get trialLeft => userModel.value?.user.trialCount ?? 0;
  RxBool isNewUser = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  PackageInfo? packageInfo;

  Future<void> _initializeApp() async {
    try {
      // Step 1: Get Package Info
      loadingMessage.value = 'Loading app info...';
      progress.value = 0.1;
      packageInfo = await PackageInfo.fromPlatform();
      update();

      // Step 2: Fetch Remote Config
      loadingMessage.value = 'Checking server status...';
      progress.value = 0.2;

      await fetchConfig();
      AdService().setDelay(remoteConfigModel.value?.config.adDelayCount ?? 3);
      update();

      // Step 3: Check Maintenance Mode
      if (remoteConfigModel.value?.config.maintenanceMode == true) {
        loadingMessage.value = 'Server under maintenance';
        progress.value = 0.0;
        update();
        _showMaintenanceDialog();
        return;
      }

      // Step 4: Check Version Update
      final updateRequired = await _checkForUpdate();
      if (updateRequired != null &&
          (remoteConfigModel.value?.config.forceUpdate ?? true)) {
        loadingMessage.value = 'Update available';
        progress.value = 0.0;
        update();
        _showUpdateDialog(updateRequired);
        return;
      }

      // Step 5: Get Device ID
      loadingMessage.value = 'Getting device info...';
      progress.value = 0.4;
      await _getDeviceId();
      update();

      // Step 6: Register User
      loadingMessage.value = 'Registering device...';
      progress.value = 0.6;
      await _registerUser();
      update();

      // Step 7: Initialize Services
      loadingMessage.value = 'Preparing app...';
      progress.value = 0.9;
      await _initializeServices();
      update();

      // Step 8: Complete
      loadingMessage.value = 'Ready!';
      progress.value = 1.0;
      update();

      isLoading.value = false;
      Get.offAllNamed(AppRoutes.mainNavigation);
    } catch (e) {
      debugPrint('Error during initialization: $e');

      if (remoteConfigModel.value?.config.maintenanceMode == true) {
        _showMaintenanceDialog();
      } else {
        Get.offAllNamed(AppRoutes.mainNavigation);
      }
    }
  }

  Future<Map<String, dynamic>?> _checkForUpdate() async {
    try {
      if (packageInfo == null || remoteConfigModel.value == null) {
        return null;
      }

      final currentVersion = packageInfo!.version;
      final minVersion = remoteConfigModel.value!.config.minAppVersion;
      final latestVersion = remoteConfigModel.value!.config.appVersion;
      final downloadUrl = remoteConfigModel.value!.config.apkDownloadUrl;

      debugPrint('Current Version: $currentVersion');
      debugPrint('Min Required Version: $minVersion');
      debugPrint('Latest Version: $latestVersion');

      // Compare versions
      final isForceUpdate = _isVersionLower(currentVersion, minVersion);
      final isUpdateAvailable = _isVersionLower(currentVersion, latestVersion);

      if (isForceUpdate) {
        return {
          'isForceUpdate': true,
          'currentVersion': currentVersion,
          'latestVersion': latestVersion,
          'downloadUrl': downloadUrl,
        };
      } else if (isUpdateAvailable) {
        return {
          'isForceUpdate': false,
          'currentVersion': currentVersion,
          'latestVersion': latestVersion,
          'downloadUrl': downloadUrl,
        };
      }

      return null;
    } catch (e) {
      debugPrint('Error checking for update: $e');
      return null;
    }
  }

  bool _isVersionLower(String current, String target) {
    final currentParts = current.split('.').map(int.parse).toList();
    final targetParts = target.split('.').map(int.parse).toList();

    for (int i = 0; i < 3; i++) {
      final currentPart = i < currentParts.length ? currentParts[i] : 0;
      final targetPart = i < targetParts.length ? targetParts[i] : 0;

      if (currentPart < targetPart) return true;
      if (currentPart > targetPart) return false;
    }

    return false;
  }

  void _showUpdateDialog(Map<String, dynamic> updateInfo) {
    Get.dialog(
      OTAUpdateDialog(
        downloadUrl: updateInfo['downloadUrl'],
        isForceUpdate: updateInfo['isForceUpdate'],
      ),
      barrierDismissible: !updateInfo['isForceUpdate'],
      barrierColor: Colors.black87,
    );
  }

  void _showMaintenanceDialog() {
    Get.dialog(
      MaintenanceModeDialog(
        contactEmail: remoteConfigModel.value?.config.contactUs,
        websiteUrl: remoteConfigModel.value?.config.webUrl,
      ),
      barrierDismissible: false,
      barrierColor: Colors.black87,
    );
  }

  Future<void> _getDeviceId() async {
    try {
      deviceId = await DeviceHelper.getDeviceId();
      debugPrint('Device ID: $deviceId');

      // Get full device info for debugging
      Map<String, dynamic> deviceInfo = await DeviceHelper.getDeviceInfo();
      debugPrint('Device Info: $deviceInfo');
    } catch (e) {
      debugPrint('Error getting device ID: $e');
      rethrow;
    }
  }

  Future<void> _registerUser() async {
    if (deviceId == null || deviceId!.isEmpty) return;

    try {
      http.Response response = await ApiCall.callService(
        requestInfo: APIRequestInfoObj(
          requestType: HTTPRequestType.post,
          url: ApiEndPoints.registerUserUrl,
          headers: ApiHeaders.getHeaders(),
          parameter: {'device_id': deviceId!},
          serviceName: 'Register User',
          timeSecond: 30,
        ),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        userModel.value = UserModel.fromJson(decoded);

        final message = decoded["message"].toString().toLowerCase();

        // Check new user logic
        isNewUser.value = message.contains("registered");

        // Subscription expiry logic
        if (userModel.value?.user.planExpiryDate != null) {
          final expiryDate = DateTime.tryParse(
            userModel.value!.user.planExpiryDate!,
          );

          if (expiryDate != null && expiryDate.isBefore(DateTime.now())) {
            var res = await ApiCall.callService(
              requestInfo: APIRequestInfoObj(
                requestType: HTTPRequestType.put,
                url: ApiEndPoints.updateUserByDevice + deviceId!,
                headers: ApiHeaders.getHeaders(),
                parameter: {
                  "plan_active": false,
                  "active_plan": null,
                  "plan_expiry_date": null,
                },
                serviceName: 'Expire Subscription',
              ),
            );

            userModel.value = userModelFromJson(res.body);
          }
        }
      }
    } catch (e) {
      debugPrint('Error registering user: $e');
    }
  }

  Future<void> _initializeServices() async {
    // Initialize other services here if needed
    // Removed artificial delay
  }

  // Retry initialization if failed
  void retryInitialization() {
    isLoading.value = true;
    progress.value = 0.0;
    _initializeApp();
  }

  fetchConfig() async {
    try {
      var res = await ApiCall.callService(
        requestInfo: APIRequestInfoObj(
          requestType: HTTPRequestType.get,
          url: ApiEndPoints.fetchRemoteConfig,
          headers: ApiHeaders.getHeaders(),
          serviceName: 'Fetch Remote Config',
          timeSecond: 30,
        ),
      );

      remoteConfigModel.value = remoteConfigModelFromJson(res.body);

      debugPrint(
        'Remote Config: ${remoteConfigModel.value?.config.appVersion}',
      );
    } catch (e) {
      rethrow;
    }
  }
}
