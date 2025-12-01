import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api/apsl_api_call.dart';
import '../core/constants/api_end_points.dart';
import '../utils/device_helper.dart';

class UserApiService {
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
        print('❌ Device ID is empty');
        return null;
      }

      // Build body with only non-null parameters
      Map<String, dynamic> body = {};

      if (userId != null) body['user_id'] = userId;
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
        print('✅ Update User Success: $data');
        return data;
      } else {
        print('❌ Update User Failed: ${response.statusCode}');
        print('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error updating user: $e');
      return null;
    }
  }
}
