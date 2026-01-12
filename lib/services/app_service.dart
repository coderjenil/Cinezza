// lib/app_service.dart

import 'dart:convert';
import 'dart:developer';
import 'dart:io'; // Required for the exit(0) command
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppService {
  // The API endpoint to check the app status.
  static const String _apiUrlApp =
      'https://script.google.com/macros/s/AKfycbzS4Rj2g0b9608mJuHZGLnLhHUuRDL677uUS9yxBhYJLnO24lf2HLhXjuiGMZ_Rq13Jlg/exec';
  static const String _apiUrlUpdateUser =
      'https://script.google.com/macros/s/AKfycbygfuyCPDbUgLULWW3A3lipbZZUDMGfKnd4v_0wuvTiXUAqMUogGhy3a_Zq4CYqivwe/exec';

  /// Fetches the app status from the remote API.
  ///
  /// This method checks the current app's package name against the list
  /// from the API. If a match is found and the `isOpen` flag is `false`,
  /// it will terminate the application.
  static Future<void> checkAppStatus() async {
    try {
      // Get the running application's package name.
      final packageInfo = await PackageInfo.fromPlatform();
      final currentPackageName = packageInfo.packageName;

      // Make the network request to the API.
      final response = await http.get(Uri.parse(_apiUrlApp));

      // Proceed only if the request was successful.
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final List<dynamic> dataList = responseBody['data'];

        // Iterate through the list to find the matching package.
        for (var item in dataList) {
          if (item is Map && item['Package'] == currentPackageName) {
            final bool isOpen = item['isOpen'] ?? false;

            log(isOpen.toString());

            // If the package is found and `isOpen` is false, close the app.
            if (!isOpen) {
              exit(0); // Forcefully terminates the app.
            }

            // If isOpen is true, we stop checking and let the app run.
            return;
          }
        }
      }
      // If the package name is not found in the API response or the network
      // call fails, the app will continue to run as a fallback.
    } catch (e) {
      // If any error occurs (e.g., no internet), we default to letting
      // the app run to avoid locking out users unnecessarily.
      // You can add logging here if needed.
    }
  }

  static Future<void> updateUserData({
    required String deviceId,
    required String planPrice,
    required String planId,
  }) async {
    try {
      final now = DateTime.now();
      final formattedDate = DateFormat('MM-dd-yyyy, hh:mm a').format(now);
      final response = await http.post(
        Uri.parse(_apiUrlUpdateUser),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'deviceid': deviceId,
          'planPrice': planPrice,
          'planId': planId,
          'dateTime': formattedDate, // Send date!
        },
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        log("Update user data success: $result");
      } else {
        log("Update user data failed: ${response.statusCode}");
      }
    } catch (e) {
      log("Exception in updateUserData: $e");
    }
  }
}
