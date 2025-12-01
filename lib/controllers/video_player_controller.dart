import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../services/daily_motion_service.dart';
import '../services/user_agent_service.dart';

class AppVideoController extends GetxController {
  VideoPlayerController? videoController;

  final RxBool isInitialized = false.obs;
  final RxBool isPlaying = false.obs;
  final RxBool isBuffering = false.obs;
  final Rx<Duration> position = Duration.zero.obs;
  final Rx<Duration> duration = Duration.zero.obs;
  final RxDouble playbackSpeed = 1.0.obs;

  final Rx<Map<String, dynamic>> currentMovie = Rx<Map<String, dynamic>>({});
  final RxList<Map<String, dynamic>> similarMovies =
      <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadMovieData();
  }

  void _loadMovieData() {
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      currentMovie.value = args['movie'] ?? {};
    }
  }

  Future<void> initializeVideo({String? customUrl}) async {
    String videoUrl;

    if (DailymotionService.isDailymotionUrl(customUrl ?? "")) {
      videoUrl = await DailymotionService.extractStreamUrl(customUrl ?? "");
      final videoUserAgent = await RandomDeviceUserAgent.nextForVideo();

      videoController = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
        httpHeaders: {
          'User-Agent': videoUserAgent,
          'Referer': 'https://www.dailymotion.com/',
          'Accept': '*/*',
          'Connection': 'keep-alive',
        },
      );

      try {
        await videoController!.initialize();
        isInitialized.value = true;

        videoController!.addListener(videoListener);
        videoController!.play();
        isPlaying.value = true;
      } catch (e) {
        print('Error initializing video: $e');
      }
    } else {
      if (customUrl != null) {
        videoUrl = customUrl;
      } else if (currentMovie.value['videoUrl'] != null) {
        videoUrl = currentMovie.value['videoUrl'];
      } else {
        videoUrl = "";
      }


      videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));

      try {
        await videoController!.initialize();
        isInitialized.value = true;

        videoController!.addListener(videoListener);
        videoController!.play();
        isPlaying.value = true;
      } catch (e) {
        print('Error initializing video: $e');
      }
    }
  }

  // Make this public for access from VideoPlayerPage
  void videoListener() {
    if (videoController != null && videoController!.value.isInitialized) {
      position.value = videoController!.value.position;
      duration.value = videoController!.value.duration;
      isPlaying.value = videoController!.value.isPlaying;
      isBuffering.value = videoController!.value.isBuffering;
    }
  }

  void togglePlayPause() {
    if (videoController != null && videoController!.value.isInitialized) {
      if (isPlaying.value) {
        videoController!.pause();
      } else {
        videoController!.play();
      }
    }
  }

  void seekTo(Duration position) {
    if (videoController != null && videoController!.value.isInitialized) {
      videoController!.seekTo(position);
    }
  }

  void seekRelative(int seconds) {
    if (videoController != null && videoController!.value.isInitialized) {
      final newPosition = position.value + Duration(seconds: seconds);
      final clampedPosition = newPosition < Duration.zero
          ? Duration.zero
          : newPosition > duration.value
          ? duration.value
          : newPosition;
      videoController!.seekTo(clampedPosition);
    }
  }

  void setPlaybackSpeed(double speed) {
    if (videoController != null && videoController!.value.isInitialized) {
      videoController!.setPlaybackSpeed(speed);
      playbackSpeed.value = speed;
    }
  }

  void playSimilarMovie(Map<String, dynamic> movie) async {
    if (videoController != null) {
      await videoController!.pause();
      videoController!.removeListener(videoListener);
      await videoController!.dispose();
    }

    currentMovie.value = movie;
    isInitialized.value = false;

    await initializeVideo(customUrl: movie['videoUrl']);
  }

  @override
  void dispose() {
    if (videoController != null) {
      videoController!.removeListener(videoListener);
      videoController!.dispose();
    }
    super.dispose();
  }
}
