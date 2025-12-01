import 'dart:convert';
import 'package:app/core/constants/api_end_points.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../api/apsl_api_call.dart';
import '../core/routes/app_routes.dart';
import '../services/user_api_service.dart';
import '../utils/device_helper.dart';

class SplashController extends GetxController {
  final RxBool isLoading = true.obs;
  final RxString loadingMessage = 'Initializing...'.obs;
  final RxDouble progress = 0.0.obs;
  String? deviceId;

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
      print('Error during initialization: $e');
      // Navigate anyway after delay
      await Future.delayed(Duration(seconds: 2));
      Get.offAllNamed(AppRoutes.mainNavigation);
    }
  }

  Future<void> _getDeviceId() async {
    try {
      deviceId = await DeviceHelper.getDeviceId();
      print('Device ID: $deviceId');

      // Get full device info for debugging
      Map<String, dynamic> deviceInfo = await DeviceHelper.getDeviceInfo();
      print('Device Info: $deviceInfo');
    } catch (e) {
      print('Error getting device ID: $e');
      rethrow;
    }
  }

  Future<void> _registerUser() async {
    if (deviceId == null || deviceId!.isEmpty) {
      print('Device ID is null or empty');
      return;
    }

    try {
      // Method 1: Using your existing ApiCall service
      http.Response response = await ApiCall.callService(
        requestInfo: APIRequestInfoObj(
          requestType: HTTPRequestType.post,
          url: ApiEndPoints.registerUserUrl,
          headers: ApiHeaders.getHeaders(),
          parameter: {
            'device_id': deviceId!,
          },
          serviceName: 'Register User',
          timeSecond: 30,
        ),
      );

      // Parse response
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Register User Success: $data');
      } else {
        print('Register User Failed: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('Error registering user: $e');
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
}
