import 'dart:convert';

import 'package:cinezza/controllers/premium_controller.dart';
import 'package:cinezza/controllers/splash_controller.dart';
import 'package:cinezza/models/movies_model.dart';
import 'package:cinezza/models/premium_plan_model.dart';
import 'package:cinezza/services/ad.dart';
import 'package:cinezza/services/app_service.dart';
import 'package:cinezza/views/main_navigation.dart';
import 'package:cinezza/views/premium/premium_plan_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../api/apsl_api_call.dart';
import '../core/constants/api_end_points.dart';
import '../core/routes/app_routes.dart';
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
    bool isFromPlan = false,
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

  static Future<void> updatePlan({required String planId}) async {
    try {
      // Get device ID
      final deviceId = await DeviceHelper.getDeviceId();

      http.Response response = await ApiCall.callService(
        requestInfo: APIRequestInfoObj(
          requestType: HTTPRequestType.post,
          url: ApiEndPoints.upgradePlan,
          headers: ApiHeaders.getHeaders(),
          parameter: {"device_id": deviceId, "planId": planId},
          serviceName: 'Update User plan',
          timeSecond: 30,
        ),
      );

      http.Response user = await ApiCall.callService(
        requestInfo: APIRequestInfoObj(
          requestType: HTTPRequestType.post,
          url: ApiEndPoints.registerUserUrl,
          headers: ApiHeaders.getHeaders(),
          parameter: {'device_id': deviceId},
          serviceName: 'Register User',
          timeSecond: 30,
        ),
      );

      SplashController splashController = Get.find<SplashController>();
      splashController.userModel.value = userModelFromJson(user.body);

      debugPrint("$response");

      PremiumController premiumController = Get.find<PremiumController>();

      PlanModel plan = premiumController.premiumPlans.firstWhere(
        (element) => element.planId == planId,
      );
      AppService.updateUserData(
        deviceId: deviceId,
        planPrice: plan.finalPrice.toString(),
        planId: plan.title,
      );
    } catch (e) {
      rethrow;
    } finally {}
  }

  void canWatchMovie({required Movie movie, bool isFromVideoPlayer = false}) {
    final splash = Get.find<SplashController>();
    final user = splash.userModel.value?.user;

    if (user == null) return;

    final bool isPremium = user.planActive == true;
    final bool hasTrial = user.trialCount > 0;

    if (isFromVideoPlayer) {
      // Replace only the current video player page, keep Home page intact

      Get.offUntil(
        GetPageRoute(
          page: () => MainNavigation(),
          routeName: AppRoutes.mainNavigation,
        ),
        (route) => route.settings.name != AppRoutes.mainNavigation,
      );
    }

    if (isPremium || hasTrial) {
      if (isPremium) {
        Get.to(() => VideoPlayerPage(movie: movie));
      } else {
        AdService().showAdWithCounter(
          Get.context!,
          onComplete: () {
            Get.to(() => VideoPlayerPage(movie: movie));
          },
        );
      }
    } else {
      AdService().showAdWithCounter(
        Get.context!,
        onComplete: () {
          Get.to(() => PremiumPlansPage());
        },
      );
    }
  }

  Future<void> requestMovie({required String movieName}) async {
    try {
      // Get device ID
      final deviceId = await DeviceHelper.getDeviceId();
      http.Response response = await ApiCall.callService(
        requestInfo: APIRequestInfoObj(
          requestType: HTTPRequestType.post,
          url: ApiEndPoints.requestMovie,
          headers: ApiHeaders.getHeaders(),
          parameter: {"movie_name": movieName, "device_id": deviceId},
          serviceName: 'Request Movie',
          timeSecond: 30,
        ),
      );
    } catch (e) {
      rethrow;
    } finally {}
  }

  static Future<void> increaseMovieView({required String movieId}) async {
    try {
      http.Response response = await ApiCall.callService(
        requestInfo: APIRequestInfoObj(
          requestType: HTTPRequestType.post,
          url: "${ApiEndPoints.increaseMovieViewCount}$movieId/view",
          headers: ApiHeaders.getHeaders(),
          serviceName: 'Increase Movie view count',
          timeSecond: 30,
        ),
      );
    } catch (e) {
      rethrow;
    } finally {}
  }

  // Add this method to UserService class
  static Future<void> refreshUserStatus() async {
    try {
      final deviceId = await DeviceHelper.getDeviceId();

      http.Response response = await ApiCall.callService(
        requestInfo: APIRequestInfoObj(
          requestType: HTTPRequestType.get,
          url: ApiEndPoints.updateUserByDevice + deviceId,
          headers: ApiHeaders.getHeaders(),
          serviceName: 'Refresh User Status',
          timeSecond: 30,
        ),
      );

      if (response.statusCode == 200) {
        SplashController splashController = Get.find<SplashController>();
        splashController.userModel.value = userModelFromJson(response.body);
        debugPrint(
          '✅ User status refreshed - Premium: ${splashController.userModel.value?.user?.planActive}',
        );
      }
    } catch (e) {
      debugPrint('❌ Error refreshing user status: $e');
    }
  }

}
