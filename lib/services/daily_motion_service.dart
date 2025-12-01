import 'dart:convert';
import '../models/stream_model.dart';
import '../models/video_info_model.dart';
import 'http_client_service.dart';
import 'user_agent_service.dart';

class DailymotionService {
  static Future<Map<String, dynamic>> fetchComplete(String videoUrl) async {
    final id = _mediaId(videoUrl);
    final uri = Uri.parse(
      'https://www.dailymotion.com/player/metadata/video/$id',
    );

    final headers = {
      'User-Agent': await RandomDeviceUserAgent.next(),
      'Accept': 'application/json, text/plain, */*',
      'Accept-Language': 'en-US,en;q=0.9',
      'Accept-Encoding': 'gzip, deflate, br',
      'Referer': 'https://www.dailymotion.com/',
      'Origin': 'https://www.dailymotion.com',
      'Sec-Fetch-Dest': 'empty',
      'Sec-Fetch-Mode': 'cors',
      'Sec-Fetch-Site': 'same-origin',
    };

    final res = await RobustHttpClientManager.safeGet(uri, headers);

    if (res.statusCode != 200) {
      throw Exception('Failed to fetch video metadata: ${res.statusCode}');
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;

    // Extract video info
    final videoInfo = VideoInfo(
      title: json['title'] ?? 'Unknown Title',
      description: json['description'] ?? '',
      thumbnail: json['posters']?['720'] ?? '',
      duration: Duration(seconds: json['duration'] ?? 0),
      uploader: json['owner']?['screenname'] ?? 'Unknown',
      viewCount: json['views_total'] ?? 0,
    );

    // Extract streams
    final quals = json['qualities'] as Map<String, dynamic>?;
    final streams = <StreamList>[];

    if (quals != null) {
      for (final key in ['auto', 'hls', ...quals.keys]) {
        final arr = quals[key];
        if (arr is List) {
          for (final e in arr) {
            if (e is Map && e['url'] != null) {
              streams.add(
                StreamList(
                  label: key == 'auto' ? 'Auto' : key.toUpperCase(),
                  format: 'm3u8',
                  url: e['url'],
                  originalUrl: videoUrl,
                  quality: e['quality'] ?? key,
                  width: e['width'],
                  height: e['height'],
                ),
              );
            }
          }
          if (streams.isNotEmpty) break;
        }
      }
    }

    if (streams.isEmpty) throw Exception('No playable streams found');

    return {
      'streams': streams,
      'videoInfo': videoInfo,
      'userAgent': headers['User-Agent'],
    };
  }

  static Future<String> extractStreamUrl(String videoUrl) async {
    final result = await fetchComplete(videoUrl);
    final streams = result['streams'] as List<StreamList>;
    return streams.first.url;
  }

  static String _mediaId(String url) {
    final r = RegExp(r'(?:video/|embed/video/)?([a-zA-Z0-9]+)(?:\?.*)?$');
    final match = r.firstMatch(url);
    if (match != null) return match.group(1)!;
    return url.substring(url.lastIndexOf('/') + 1).split('?')[0];
  }

  static bool isDailymotionUrl(String url) {
    return url.contains('dailymotion.com') && url.contains('/video/');
  }
}
