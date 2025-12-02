import 'dart:convert';

import 'package:app/controllers/splash_controller.dart';
import 'package:app/models/movies_model.dart';
import 'package:app/views/premium/premium_plan_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../api/apsl_api_call.dart';
import '../core/constants/api_end_points.dart';
import '../models/user_model.dart';
import '../utils/device_helper.dart';
import '../views/video_player/video_player_page.dart';

class UserService {
  static Future<Map<String, dynamic>?> updateUserByDeviceId({
    String? userId,
    bool? planActive,
    String? activePlan,
    String? planExpiryDate,
    int? trialCount,
    int? reelsUsage,
    String? lastActive,
  }) async {
    try {
      // Get device ID
      final deviceId = await DeviceHelper.getDeviceId();

      if (deviceId.isEmpty) {
        debugPrint('❌ Device ID is empty');
        return null;
      }

      // Build body with only non-null parameters
      Map<String, dynamic> body = {};

      if (planActive != null) body['plan_active'] = planActive;
      if (activePlan != null) body['active_plan'] = activePlan;
      if (planExpiryDate != null) body['plan_expiry_date'] = planExpiryDate;
      if (trialCount != null) body['trial_count'] = trialCount;
      if (reelsUsage != null) body['reelsUsage'] = reelsUsage;
      if (lastActive != null) body['last_active'] = lastActive;

      http.Response response = await ApiCall.callService(
        requestInfo: APIRequestInfoObj(
          requestType: HTTPRequestType.put,
          url: ApiEndPoints.updateUserByDevice + deviceId,
          headers: ApiHeaders.getHeaders(),
          parameter: body.isEmpty ? null : body, // Send null if no parameters
          serviceName: 'Update User',
          timeSecond: 30,
        ),
      );

      // Parse response
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        SplashController splashController = Get.find<SplashController>();
        splashController.userModel.value = UserModel.fromJson(data);
        debugPrint('✅ Update User Success: $data');
      } else {
        debugPrint('❌ Update User Failed: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error updating user: $e');
      return null;
    }
    return null;
  }

  void canWatchMovie({required Movie movie}) {
    final splash = Get.find<SplashController>();
    final user = splash.userModel.value?.user;

    // If user data not loaded yet, prevent crash
    if (user == null) {
      debugPrint("⚠ User data unavailable, redirecting to premium.");
      // Get.to(() => PremiumPlansPage());
      return;
    }

    final bool isPremium = user.planActive == true;
    final bool hasTrial = (user.trialCount) > 0;

    if (isPremium || hasTrial) {
      Get.to(() => VideoPlayerPage(movie: movie));
    } else {
      Get.to(() => PremiumPlansPage());
    }
  }
}
