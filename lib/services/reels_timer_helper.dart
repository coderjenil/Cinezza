// services/reels_timer_helper.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReelsTimerHelper {
  static const String _keyRemainingTime = 'reels_remaining_time';
  static const String _keyLastSaveTime = 'reels_last_save_time';

  /// Get remaining time from storage
  static Future<int> getRemainingTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyRemainingTime) ?? 0;
  }

  /// Save remaining time to storage with timestamp
  static Future<void> saveRemainingTime(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyRemainingTime, seconds);
    await prefs.setInt(_keyLastSaveTime, DateTime.now().millisecondsSinceEpoch);
    debugPrint('💾 Saved to local: $seconds seconds');
  }

  /// Calculate accurate elapsed time since last save
  static Future<int> getElapsedTimeSinceLastSave() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSaveTime = prefs.getInt(_keyLastSaveTime);

    if (lastSaveTime == null) return 0;

    final now = DateTime.now().millisecondsSinceEpoch;
    final elapsedMillis = now - lastSaveTime;
    return (elapsedMillis / 1000).floor();
  }

  /// Clear all timer data
  static Future<void> clearTimerData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyRemainingTime);
    await prefs.remove(_keyLastSaveTime);
  }
}
