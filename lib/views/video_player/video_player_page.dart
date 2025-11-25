import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../controllers/video_player_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/movie_card.dart';

class VideoPlayerPage extends StatefulWidget {
  const VideoPlayerPage({Key? key}) : super(key: key);

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  final AppVideoController controller = Get.put(AppVideoController());
  Timer? _hideControlsTimer;
  bool _showControls = true;
  bool _isLocked = false;
  bool _isFullscreen = false;
  double _brightness = 0.5;
  double _volume = 0.5;
  bool _isDraggingBrightness = false;
  bool _isDraggingVolume = false;
  double _swipeStartPosition = 0;
  bool _isSwiping = false;
  Duration? _swipeSeekPosition;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    _setupVolumeListener();
    WakelockPlus.enable();
    // Allow both portrait orientations for normal view
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void _initializePlayer() async {
    await controller.initializeVideo();
    _getBrightness();
    _getVolume();
  }

  void _setupVolumeListener() {
    FlutterVolumeController.addListener((volume) {
      if (!_isDraggingVolume && mounted) {
        setState(() => _volume = volume);
      }
    });
  }

  void _getBrightness() async {
    try {
      final brightness = await ScreenBrightness().current;
      if (mounted) setState(() => _brightness = brightness);
    } catch (e) {
      print('Error getting brightness: $e');
    }
  }

  void _getVolume() async {
    final volume = await FlutterVolumeController.getVolume();
    if (mounted) setState(() => _volume = volume ?? 0.5);
  }

  void _setBrightness(double brightness) async {
    try {
      await ScreenBrightness().setScreenBrightness(brightness);
      setState(() => _brightness = brightness);
    } catch (e) {
      print('Error setting brightness: $e');
    }
  }

  void _setVolume(double volume) {
    FlutterVolumeController.setVolume(volume);
    setState(() => _volume = volume);
  }

  void _toggleFullscreen() {
    setState(() => _isFullscreen = !_isFullscreen);

    if (_isFullscreen) {
      // Enter fullscreen - landscape mode (left and right)
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      // Exit fullscreen - portrait mode (up and down)
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }

    _startHideControlsTimer();
  }

  void _toggleControls() {
    if (_isLocked) return;
    setState(() => _showControls = !_showControls);
    if (_showControls) _startHideControlsTimer();
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && controller.isPlaying.value && !_isLocked) {
        setState(() => _showControls = false);
      }
    });
  }

  Future<bool> _onWillPop() async {
    if (_isFullscreen) {
      _toggleFullscreen();
      return false; // Don't exit the page
    }
    return true; // Exit the page
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    FlutterVolumeController.removeListener();
    WakelockPlus.disable();
    // Reset to all orientations on dispose
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: _isFullscreen ? _buildFullscreenPlayer() : _buildNormalPlayer(),
    );
  }

  Widget _buildNormalPlayer() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 40) / 3.5;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Video Player Section
            Obx(() {
              if (!controller.isInitialized.value) {
                return AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                );
              }

              return _buildVideoPlayer();
            }),

            // Similar Movies Section
            Expanded(
              child: Container(
                color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Similar Movies',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Obx(() => ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: controller.similarMovies.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: SizedBox(
                              width: cardWidth,
                              child: MovieCard(
                                movie: controller.similarMovies[index],
                                onTap: () => controller.playSimilarMovie(controller.similarMovies[index]),
                                index: index,
                                width: cardWidth,
                              ),
                            ),
                          );
                        },
                      )),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullscreenPlayer() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        if (!controller.isInitialized.value) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        return Center(
          child: _buildVideoPlayer(),
        );
      }),
    );
  }

  Widget _buildVideoPlayer() {
    return Container(
      color: Colors.black,
      child: Center(
        child: AspectRatio(
          aspectRatio: controller.videoController!.value.aspectRatio,
          child: GestureDetector(
            onTap: _isLocked ? null : _toggleControls,
            onDoubleTapDown: _isLocked ? null : (details) => _handleDoubleTap(details),
            onVerticalDragUpdate: _isLocked ? null : (details) => _handleVerticalDrag(details),
            onVerticalDragEnd: _isLocked ? null : (_) {
              setState(() {
                _isDraggingBrightness = false;
                _isDraggingVolume = false;
              });
            },
            onHorizontalDragStart: _isLocked ? null : (details) => _handleHorizontalDragStart(details),
            onHorizontalDragUpdate: _isLocked ? null : (details) => _handleHorizontalDragUpdate(details),
            onHorizontalDragEnd: _isLocked ? null : (_) => _handleHorizontalDragEnd(),
            child: Stack(
              fit: StackFit.expand,
              children: [
                VideoPlayer(controller.videoController!),

                if (_isDraggingBrightness) _buildBrightnessIndicator(),
                if (_isDraggingVolume) _buildVolumeIndicator(),
                if (_isSwiping) _buildSeekIndicator(),

                if (_showControls && !_isLocked) _buildControlsOverlay(),

                if (_showControls || _isLocked) _buildLockButton(),

                if (controller.isBuffering.value)
                  Center(child: CircularProgressIndicator(color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlsOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withOpacity(0.7),
          ],
        ),
      ),
      child: Column(
        children: [
          _buildTopControls(),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildControlButton(Icons.replay_10_rounded, () => controller.seekRelative(-10)),
                Obx(() => _buildControlButton(
                  controller.isPlaying.value ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  controller.togglePlayPause,
                  size: 60,
                )),
                _buildControlButton(Icons.forward_10_rounded, () => controller.seekRelative(10)),
              ],
            ),
          ),
          _buildBottomControls(),
        ],
      ),
    );
  }

  Widget _buildTopControls() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () {
              if (_isFullscreen) {
                _toggleFullscreen();
              } else {
                Get.back();
              }
            },
          ),
          Expanded(
            child: Obx(() => Text(
              controller.currentMovie.value['title'] ?? 'Video Player',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )),
          ),
          PopupMenuButton<double>(
            icon: const Icon(Icons.speed_rounded, color: Colors.white),
            onSelected: (speed) => controller.setPlaybackSpeed(speed),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 0.25, child: Text('0.25x')),
              const PopupMenuItem(value: 0.5, child: Text('0.5x')),
              const PopupMenuItem(value: 0.75, child: Text('0.75x')),
              const PopupMenuItem(value: 1.0, child: Text('Normal')),
              const PopupMenuItem(value: 1.25, child: Text('1.25x')),
              const PopupMenuItem(value: 1.5, child: Text('1.5x')),
              const PopupMenuItem(value: 2.0, child: Text('2.0x')),
            ],
          ),
          IconButton(
            icon: Icon(
              _isFullscreen ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded,
              color: Colors.white,
            ),
            onPressed: _toggleFullscreen,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(() {
            final position = controller.position.value;
            final duration = controller.duration.value;

            return Column(
              children: [
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                  ),
                  child: Slider(
                    value: position.inMilliseconds.toDouble(),
                    min: 0,
                    max: duration.inMilliseconds.toDouble(),
                    onChanged: (value) {
                      controller.seekTo(Duration(milliseconds: value.toInt()));
                    },
                    activeColor: AppColors.primary,
                    inactiveColor: Colors.white30,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(position),
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      Text(
                        _formatDuration(duration),
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildControlButton(IconData icon, VoidCallback onPressed, {double size = 40}) {
    return IconButton(
      icon: Icon(icon, color: Colors.white, size: size),
      onPressed: onPressed,
    );
  }

  Widget _buildLockButton() {
    return Positioned(
      right: 16,
      top: MediaQuery.of(context).size.height * 0.4,
      child: IconButton(
        icon: Icon(
          _isLocked ? Icons.lock_rounded : Icons.lock_open_rounded,
          color: Colors.white,
          size: 30,
        ),
        onPressed: () {
          setState(() => _isLocked = !_isLocked);
          if (_isLocked) {
            setState(() => _showControls = false);
          } else {
            setState(() => _showControls = true);
            _startHideControlsTimer();
          }
        },
      ),
    );
  }

  Widget _buildBrightnessIndicator() {
    return Container(
      alignment: Alignment.center,
      color: Colors.black45,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.brightness_6_rounded, color: Colors.white, size: 40),
          const SizedBox(height: 8),
          Text(
            '${(_brightness * 100).toInt()}%',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeIndicator() {
    return Container(
      alignment: Alignment.center,
      color: Colors.black45,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _volume > 0.5 ? Icons.volume_up_rounded : _volume > 0 ? Icons.volume_down_rounded : Icons.volume_off_rounded,
            color: Colors.white,
            size: 40,
          ),
          const SizedBox(height: 8),
          Text(
            '${(_volume * 100).toInt()}%',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildSeekIndicator() {
    final seekPosition = _swipeSeekPosition ?? controller.position.value;
    final difference = seekPosition.inSeconds - controller.position.value.inSeconds;

    return Container(
      alignment: Alignment.center,
      color: Colors.black45,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            difference > 0 ? Icons.fast_forward_rounded : Icons.fast_rewind_rounded,
            color: Colors.white,
            size: 50,
          ),
          const SizedBox(height: 8),
          Text(
            '${difference > 0 ? '+' : ''}${difference}s',
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            _formatDuration(seekPosition),
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _handleDoubleTap(TapDownDetails details) {
    final width = MediaQuery.of(context).size.width;
    final dx = details.localPosition.dx;

    if (dx < width / 2) {
      controller.seekRelative(-10);
    } else {
      controller.seekRelative(10);
    }
  }

  void _handleVerticalDrag(DragUpdateDetails details) {
    final width = MediaQuery.of(context).size.width;
    final dx = details.localPosition.dx;
    final dy = details.primaryDelta ?? 0;

    if (dx < width / 2) {
      setState(() {
        _isDraggingBrightness = true;
        _brightness = (_brightness - (dy / 500)).clamp(0.0, 1.0);
      });
      _setBrightness(_brightness);
    } else {
      setState(() {
        _isDraggingVolume = true;
        _volume = (_volume - (dy / 500)).clamp(0.0, 1.0);
      });
      _setVolume(_volume);
    }
  }

  void _handleHorizontalDragStart(DragStartDetails details) {
    setState(() {
      _isSwiping = true;
      _swipeStartPosition = details.localPosition.dx;
      _swipeSeekPosition = controller.position.value;
    });
  }

  void _handleHorizontalDragUpdate(DragUpdateDetails details) {
    final dx = details.primaryDelta ?? 0;
    final seekSeconds = (dx / 10).round();

    setState(() {
      final newPosition = (_swipeSeekPosition ?? controller.position.value) + Duration(seconds: seekSeconds);
      final maxDuration = controller.duration.value;

      _swipeSeekPosition = Duration(
        milliseconds: newPosition.inMilliseconds.clamp(0, maxDuration.inMilliseconds),
      );
    });
  }

  void _handleHorizontalDragEnd() {
    if (_swipeSeekPosition != null) {
      controller.seekTo(_swipeSeekPosition!);
    }
    setState(() {
      _isSwiping = false;
      _swipeSeekPosition = null;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }
}
