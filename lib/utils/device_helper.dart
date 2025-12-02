import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';

class DeviceHelper {
  /// Get unique device ID directly from hardware (NO STORAGE)
  static Future<String> getDeviceId() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String identifier = '';

    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        // Android ID - Unique per device
        identifier = androidInfo.id;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        // iOS Identifier for Vendor
        identifier = iosInfo.identifierForVendor ?? '';
      }
    } catch (e) {
      debugPrint('Error getting device ID: $e');
    }

    return identifier;
  }

  /// Get detailed device info
  static Future<Map<String, dynamic>> getDeviceInfo() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        return {
          'platform': 'Android',
          'version': androidInfo.version.release,
          'sdk_int': androidInfo.version.sdkInt,
          'model': androidInfo.model,
          'brand': androidInfo.brand,
          'manufacturer': androidInfo.manufacturer,
          'device_id': androidInfo.id,
          'device_name': '${androidInfo.brand} ${androidInfo.model}',
        };
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        return {
          'platform': 'iOS',
          'version': iosInfo.systemVersion,
          'model': iosInfo.model,
          'name': iosInfo.name,
          'device_id': iosInfo.identifierForVendor,
          'device_name': '${iosInfo.name} ${iosInfo.model}',
        };
      }
    } catch (e) {
      debugPrint('Error getting device info: $e');
    }

    return {'platform': 'Unknown'};
  }
}
