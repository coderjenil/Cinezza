import 'package:flutter/services.dart';

class VolumeService {
  static const platform = MethodChannel('com.app/volume');

  static Future<void> hideSystemVolumeUI() async {
    try {
      await platform.invokeMethod('hideSystemUI');
    } catch (e) {
      print('Error hiding system volume UI: $e');
    }
  }
}
