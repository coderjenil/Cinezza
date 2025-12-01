import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class WatchHistoryService {
  static const String _watchHistoryKey = 'watch_history';

  // Save watch progress for a series
  static Future<void> saveWatchProgress({
    required String movieId,
    required String movieName,
    required int seasonIndex,
    required int episodeIndex,
    required int episodeNo,
    required String episodeName,
    required String videoUrl,
    required int positionSeconds,
    required int durationSeconds,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final watchData = {
        'movieId': movieId,
        'movieName': movieName,
        'seasonIndex': seasonIndex,
        'episodeIndex': episodeIndex,
        'episodeNo': episodeNo,
        'episodeName': episodeName,
        'videoUrl': videoUrl,
        'positionSeconds': positionSeconds,
        'durationSeconds': durationSeconds,
        'lastWatched': DateTime.now().toIso8601String(),
      };

      // Store with key as movieId
      await prefs.setString('watch_$movieId', json.encode(watchData));

      // Also maintain a list of all watched movie IDs for quick access
      List<String> watchedMovies = prefs.getStringList(_watchHistoryKey) ?? [];
      if (!watchedMovies.contains(movieId)) {
        watchedMovies.insert(0, movieId); // Add to beginning
        await prefs.setStringList(_watchHistoryKey, watchedMovies);
      }
    } catch (e) {
      print('Error saving watch progress: $e');
    }
  }

  // Get watch progress for a specific movie/series
  static Future<Map<String, dynamic>?> getWatchProgress(String movieId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? watchDataStr = prefs.getString('watch_$movieId');

      if (watchDataStr != null) {
        return json.decode(watchDataStr) as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error getting watch progress: $e');
    }
    return null;
  }

  // Check if user should continue from last episode
  static Future<bool> hasWatchHistory(String movieId) async {
    final progress = await getWatchProgress(movieId);
    return progress != null;
  }

  // Clear watch history for a specific movie
  static Future<void> clearMovieHistory(String movieId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('watch_$movieId');

      List<String> watchedMovies = prefs.getStringList(_watchHistoryKey) ?? [];
      watchedMovies.remove(movieId);
      await prefs.setStringList(_watchHistoryKey, watchedMovies);
    } catch (e) {
      print('Error clearing movie history: $e');
    }
  }

  // Get all watch history (for continue watching section)
  static Future<List<Map<String, dynamic>>> getAllWatchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> watchedMovies = prefs.getStringList(_watchHistoryKey) ?? [];

      List<Map<String, dynamic>> historyList = [];
      for (String movieId in watchedMovies) {
        final watchData = await getWatchProgress(movieId);
        if (watchData != null) {
          historyList.add(watchData);
        }
      }
      return historyList;
    } catch (e) {
      print('Error getting all watch history: $e');
      return [];
    }
  }

  // Calculate watch percentage
  static double getWatchPercentage(int positionSeconds, int durationSeconds) {
    if (durationSeconds == 0) return 0;
    return (positionSeconds / durationSeconds * 100).clamp(0, 100);
  }

  // Check if episode is completed (watched > 90%)
  static bool isEpisodeCompleted(int positionSeconds, int durationSeconds) {
    return getWatchPercentage(positionSeconds, durationSeconds) > 90;
  }
}
