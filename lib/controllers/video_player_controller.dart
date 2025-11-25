import 'dart:math';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class AppVideoController extends GetxController {
  VideoPlayerController? videoController;

  final RxBool isInitialized = false.obs;
  final RxBool isPlaying = false.obs;
  final RxBool isBuffering = false.obs;
  final Rx<Duration> position = Duration.zero.obs;
  final Rx<Duration> duration = Duration.zero.obs;
  final RxDouble playbackSpeed = 1.0.obs;

  final Rx<Map<String, dynamic>> currentMovie = Rx<Map<String, dynamic>>({});
  final RxList<Map<String, dynamic>> similarMovies = <Map<String, dynamic>>[].obs;

  // List of sample video URLs
  final List<String> sampleVideos = [
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
  ];

  @override
  void onInit() {
    super.onInit();
    _loadMovieData();
    _loadSimilarMovies();
  }

  void _loadMovieData() {
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      currentMovie.value = args['movie'] ?? {};
    }
  }

  void _loadSimilarMovies() {
    similarMovies.value = [
      {
        'id': 'similar_1',
        'title': 'Inception',
        'poster': 'https://image.tmdb.org/t/p/w500/9gk7adHYeDvHkCSEqAvQNLV5Uge.jpg',
        'videoUrl': sampleVideos[0],
      },
      {
        'id': 'similar_2',
        'title': 'Interstellar',
        'poster': 'https://image.tmdb.org/t/p/w500/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg',
        'videoUrl': sampleVideos[1],
      },
      {
        'id': 'similar_3',
        'title': 'The Matrix',
        'poster': 'https://image.tmdb.org/t/p/w500/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg',
        'videoUrl': sampleVideos[2],
      },
      {
        'id': 'similar_4',
        'title': 'The Dark Knight',
        'poster': 'https://image.tmdb.org/t/p/w500/qJ2tW6WMUDux911r6m7haRef0WH.jpg',
        'videoUrl': sampleVideos[3],
      },
      {
        'id': 'similar_5',
        'title': 'Fight Club',
        'poster': 'https://image.tmdb.org/t/p/w500/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg',
        'videoUrl': sampleVideos[4],
      },
      {
        'id': 'similar_6',
        'title': 'Pulp Fiction',
        'poster': 'https://image.tmdb.org/t/p/w500/d5iIlFn5s0ImszYzBPb8JPIfbXD.jpg',
        'videoUrl': sampleVideos[5],
      },
      {
        'id': 'similar_7',
        'title': 'The Shawshank Redemption',
        'poster': 'https://image.tmdb.org/t/p/w500/q6y0Go1tsGEsmtFryDOJo3dEmqu.jpg',
        'videoUrl': sampleVideos[6],
      },
      {
        'id': 'similar_8',
        'title': 'The Godfather',
        'poster': 'https://image.tmdb.org/t/p/w500/3bhkrj58Vtu7enYsRolD1fZdja1.jpg',
        'videoUrl': sampleVideos[7],
      },
      {
        'id': 'similar_9',
        'title': 'Forrest Gump',
        'poster': 'https://image.tmdb.org/t/p/w500/arw2vcBveWOVZr6pxd9XTd1TdQa.jpg',
        'videoUrl': sampleVideos[8],
      },
      {
        'id': 'similar_10',
        'title': 'The Lord of the Rings',
        'poster': 'https://image.tmdb.org/t/p/w500/6oom5QYQ2yQTMJIbnvbkBL9cHo6.jpg',
        'videoUrl': sampleVideos[9],
      },
    ];
  }

  Future<void> initializeVideo({String? customUrl}) async {
    // Get random video URL if not provided
    String videoUrl;

    if (customUrl != null) {
      videoUrl = customUrl;
    } else if (currentMovie.value['videoUrl'] != null) {
      videoUrl = currentMovie.value['videoUrl'];
    } else {
      // Pick random video from list
      final random = Random();
      videoUrl = sampleVideos[random.nextInt(sampleVideos.length)];
    }

    videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));

    try {
      await videoController!.initialize();
      isInitialized.value = true;

      videoController!.addListener(_videoListener);
      videoController!.play();
      isPlaying.value = true;
    } catch (e) {
      print('Error initializing video: $e');
    }
  }

  void _videoListener() {
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
    await videoController?.dispose();

    currentMovie.value = movie;
    isInitialized.value = false;

    // Use video URL from movie data
    await initializeVideo(customUrl: movie['videoUrl']);
  }

  @override
  void dispose() {
    videoController?.removeListener(_videoListener);
    videoController?.dispose();
    super.dispose();
  }
}
