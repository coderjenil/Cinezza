import 'package:app/core/constants/api_end_points.dart';
import 'package:app/models/remote_config_model.dart';
import 'package:app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../api/apsl_api_call.dart';
import '../core/routes/app_routes.dart';
import '../utils/device_helper.dart';

class SplashController extends GetxController {
  final RxBool isLoading = true.obs;
  final RxString loadingMessage = 'Initializing...'.obs;
  final RxDouble progress = 0.0.obs;
  Rx<UserModel?> userModel = Rx<UserModel?>(null);
  Rx<RemoteConfigModel?> remoteConfigModel = Rx<RemoteConfigModel?>(null);
  String? deviceId;
  bool get isPremium => userModel.value?.user.planActive == true;

  int get trialLeft => userModel.value?.user.trialCount ?? 0;

  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Step 1: Get Device ID
      loadingMessage.value = 'Getting device info...';
      progress.value = 0.2;
      await fetchConfig();
      await _getDeviceId();
      await Future.delayed(Duration(milliseconds: 500));

      // Step 2: Register User with Device ID
      loadingMessage.value = 'Registering device...';
      progress.value = 0.5;
      await _registerUser();
      await Future.delayed(Duration(milliseconds: 500));

      // Step 3: Initialize Services
      loadingMessage.value = 'Preparing app...';
      progress.value = 0.8;
      await _initializeServices();
      await Future.delayed(Duration(milliseconds: 500));

      // Step 4: Complete
      loadingMessage.value = 'Ready!';
      progress.value = 1.0;
      await Future.delayed(Duration(milliseconds: 500));

      // Navigate to main screen
      isLoading.value = false;
      Get.offAllNamed(AppRoutes.mainNavigation);
    } catch (e) {
      debugPrint('Error during initialization: $e');
      // Navigate anyway after delay
      await Future.delayed(Duration(seconds: 2));
      Get.offAllNamed(AppRoutes.mainNavigation);
    }
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
    if (deviceId == null || deviceId!.isEmpty) {
      debugPrint('Device ID is null or empty');
      return;
    }

    try {
      // Method 1: Using your existing ApiCall service
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

      // Parse response
      if (response.statusCode == 200) {
        userModel.value = userModelFromJson(response.body);

        if (userModel.value?.user.planExpiryDate != null) {
          final expiryDate = DateTime.tryParse(
            userModel.value?.user.planExpiryDate ?? "",
          );

          if (expiryDate != null && expiryDate.isBefore(DateTime.now())) {
            /// 🛠 Update backend subscription status to inactive
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
                timeSecond: 30,
              ),
            );

            Get.find<SplashController>().userModel.value = userModelFromJson(
              res.body,
            );
          }
        }
      } else {
        debugPrint('Register User Failed: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error registering user: $e');
      // Don't rethrow - continue app initialization even if registration fails
    }
  }

  Future<void> _initializeServices() async {
    // Initialize other services here
    await Future.delayed(Duration(milliseconds: 500));
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
        'Remote Config: ${remoteConfigModel.value?.config?.appVersion}',
      );
    } catch (e) {
      rethrow;
    } finally {}
  }
}
