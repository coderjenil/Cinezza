import 'dart:async';
import 'package:app/models/movies_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../controllers/splash_controller.dart';
import '../../controllers/video_player_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../services/user_api_service.dart';
import '../../services/volume_service.dart';
import '../../services/watch_history_service.dart';

enum VideoFit { fill, fit }

class VideoPlayerPage extends StatefulWidget {
  final Movie movie;

  const VideoPlayerPage({super.key, required this.movie});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  final AppVideoController controller = Get.put(AppVideoController());
  Timer? _hideControlsTimer;
  Timer? _progressSaveTimer;
  bool _showControls = true;
  bool _isLocked = false;
  bool _isFullscreen = false;
  VideoFit _videoFit = VideoFit.fit;
  double _brightness = 0.5;
  double _volume = 0.5;
  bool _isDraggingBrightness = false;
  bool _isDraggingVolume = false;
  bool _isSwiping = false;
  Duration? _swipeSeekPosition;

  int _selectedSeasonIndex = 0;
  int _currentSeasonIndex = 0;
  int _currentEpisodeIndex = 0;
  String? _currentVideoUrl;
  Map<String, dynamic>? _watchHistory;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeContent();
    _hideSystemVolumeUI();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    WakelockPlus.enable();
  }

  Future<void> _initializeContent() async {
    if (widget.movie.seasons != null && widget.movie.seasons!.isNotEmpty) {
      await _loadWatchHistoryAndPlay();
      _decreaseTrialCount();
    } else {
      _currentVideoUrl = widget.movie.videoUrl;
      await _initializePlayer();
      _decreaseTrialCount();
    }
  }

  Future<void> _loadWatchHistoryAndPlay() async {
    _watchHistory = await WatchHistoryService.getWatchProgress(
      widget.movie.id ?? '',
    );

    if (_watchHistory != null) {
      _currentSeasonIndex = _watchHistory!['seasonIndex'] ?? 0;
      _currentEpisodeIndex = _watchHistory!['episodeIndex'] ?? 0;
      _selectedSeasonIndex = _currentSeasonIndex;
      _currentVideoUrl = _watchHistory!['videoUrl'];
    } else {
      _currentSeasonIndex = widget.movie.seasons!.length - 1;
      _currentEpisodeIndex = 0;
      _selectedSeasonIndex = _currentSeasonIndex;

      final latestSeason = widget.movie.seasons![_currentSeasonIndex];
      _currentVideoUrl = latestSeason.episodes![0].videoUrl;
    }

    await _initializePlayer();

    if (_watchHistory != null) {
      final lastPosition = Duration(
        seconds: _watchHistory!['positionSeconds'] ?? 0,
      );
      if (lastPosition.inSeconds > 5) {
        await Future.delayed(const Duration(milliseconds: 800));
        if (controller.isInitialized.value) {
          controller.seekTo(lastPosition);
        }
      }
    }

    _startProgressTracking();
  }

  void _hideSystemVolumeUI() async {
    FlutterVolumeController.showSystemUI = false;
    await VolumeService.hideSystemVolumeUI();
  }

  Future<void> _initializePlayer() async {
    setState(() => _isInitializing = true);
    await controller.initializeVideo(customUrl: _currentVideoUrl);
    _getBrightness();
    _getInitialVolume();
    setState(() => _isInitializing = false);
  }

  Future<void> _decreaseTrialCount() async {
    try {
      final splash = Get.find<SplashController>();
      final user = splash.userModel.value?.user;

      if (user == null) return;

      final remaining = (user.trialCount);

      if (remaining > 0 && (user.planActive == false)) {
        debugPrint("🎟 Trial used. Remaining: ${remaining - 1}");
        await UserService.updateUserByDeviceId(
          userId: user.id,
          trialCount: remaining - 1,
        );
      }
    } catch (e) {
      debugPrint("❌ Error reducing trial count: $e");
    }
  }

  void _startProgressTracking() {
    if (widget.movie.seasons == null || widget.movie.seasons!.isEmpty) {
      return;
    }

    _progressSaveTimer = Timer.periodic(
      const Duration(seconds: 5),
      (timer) => _saveWatchProgress(),
    );
  }

  Future<void> _saveWatchProgress() async {
    if (widget.movie.id == null ||
        widget.movie.seasons == null ||
        widget.movie.seasons!.isEmpty) {
      return;
    }

    if (!controller.isInitialized.value) return;

    final season = widget.movie.seasons![_currentSeasonIndex];
    final episode = season.episodes![_currentEpisodeIndex];

    await WatchHistoryService.saveWatchProgress(
      movieId: widget.movie.id!,
      movieName: widget.movie.movieName ?? '',
      seasonIndex: _currentSeasonIndex,
      episodeIndex: _currentEpisodeIndex,
      episodeNo: episode.episodeNo ?? (_currentEpisodeIndex + 1),
      episodeName: episode.episodeName ?? 'Episode ${episode.episodeNo}',
      videoUrl: _currentVideoUrl ?? '',
      positionSeconds: controller.position.value.inSeconds,
      durationSeconds: controller.duration.value.inSeconds,
    );
  }

  void _playEpisode(int seasonIndex, int episodeIndex) {
    final season = widget.movie.seasons![seasonIndex];
    final episode = season.episodes![episodeIndex];

    setState(() {
      _currentSeasonIndex = seasonIndex;
      _currentEpisodeIndex = episodeIndex;
      _selectedSeasonIndex = seasonIndex;
      _currentVideoUrl = episode.videoUrl;
    });

    _reinitializeVideo(episode.videoUrl ?? '');
  }

  void _playEpisodeFromBottomSheet(
    BuildContext bottomSheetContext,
    int seasonIndex,
    int episodeIndex,
  ) {
    final season = widget.movie.seasons![seasonIndex];
    final episode = season.episodes![episodeIndex];

    Navigator.of(bottomSheetContext).pop();

    setState(() {
      _currentSeasonIndex = seasonIndex;
      _currentEpisodeIndex = episodeIndex;
      _selectedSeasonIndex = seasonIndex;
      _currentVideoUrl = episode.videoUrl;
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      _reinitializeVideo(episode.videoUrl ?? '');
    });
  }

  Future<void> _reinitializeVideo(String videoUrl) async {
    setState(() => _isInitializing = true);

    if (controller.videoController != null) {
      await controller.videoController!.pause();
      controller.videoController!.removeListener(controller.videoListener);
      await controller.videoController!.dispose();
    }

    controller.isInitialized.value = false;
    controller.isPlaying.value = false;

    await controller.initializeVideo(customUrl: videoUrl);

    setState(() => _isInitializing = false);
  }

  void _showEpisodeSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      isDismissible: true,
      enableDrag: true,
      builder: (bottomSheetContext) =>
          _buildEpisodeBottomSheet(bottomSheetContext),
    );
  }

  void _toggleFullscreen() {
    setState(() => _isFullscreen = !_isFullscreen);

    if (_isFullscreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  void _cycleVideoFit() {
    setState(() {
      switch (_videoFit) {
        case VideoFit.fit:
          _videoFit = VideoFit.fill;
          break;
        case VideoFit.fill:
          _videoFit = VideoFit.fit;
          break;
      }
    });
  }

  void _getBrightness() async {
    try {
      final brightness = await ScreenBrightness().current;
      if (mounted) setState(() => _brightness = brightness);
    } catch (e) {
      debugPrint('Error getting brightness: $e');
    }
  }

  void _getInitialVolume() async {
    if (mounted) {
      setState(() => _volume = 0.5);
      _applyVolume();
    }
  }

  void _setBrightness(double brightness) async {
    try {
      await ScreenBrightness().setScreenBrightness(brightness);
      setState(() => _brightness = brightness);
    } catch (e) {
      debugPrint('Error setting brightness: $e');
    }
  }

  void _applyVolume() {
    double systemVolume;
    double audioBoost;

    if (_volume <= 0.5) {
      systemVolume = _volume * 2;
      audioBoost = 1.0;
    } else {
      systemVolume = 1.0;
      audioBoost = (_volume - 0.5) * 2 + 1.0;
    }

    FlutterVolumeController.setVolume(systemVolume);

    if (controller.videoController != null &&
        controller.videoController!.value.isInitialized) {
      controller.videoController!.setVolume(audioBoost);
    }
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
      return false;
    }
    return true;
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _progressSaveTimer?.cancel();
    _saveWatchProgress();
    FlutterVolumeController.showSystemUI = true;
    WakelockPlus.disable();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    if (controller.videoController != null) {
      controller.videoController!.removeListener(controller.videoListener);
      controller.videoController!.dispose();
    }

    Get.delete<AppVideoController>();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isFullscreen) {
      return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: _buildVideoPlayerSection(), // fullscreen = only player UI
        ),
      );
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: isDark
            ? AppColors.darkBackground
            : AppColors.lightBackground,
        body: SafeArea(
          child: Column(
            children: [
              _buildVideoPlayerSection(),
              Expanded(
                child: SingleChildScrollView(
                  child: _buildDetailsSection(isDark),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- VIDEO AREA ----------------

  Widget _buildVideoPlayerSection() {
    final height = _isFullscreen
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width * 9 / 16;

    return Container(
      height: height,
      width: double.infinity,
      color: Colors.black,
      child: _isInitializing
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Obx(() {
              if (!controller.isInitialized.value) {
                return Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }
              return ClipRect(child: _buildVideoPlayer());
            }),
    );
  }

  Widget _buildVideoPlayer() {
    return GestureDetector(
      onTap: _isLocked ? null : _toggleControls,
      onDoubleTapDown: _isLocked
          ? null
          : (details) => _handleDoubleTap(details),
      onVerticalDragUpdate: _isLocked
          ? null
          : (details) => _handleVerticalDrag(details),
      onVerticalDragEnd: _isLocked
          ? null
          : (_) {
              setState(() {
                _isDraggingBrightness = false;
                _isDraggingVolume = false;
              });
            },
      onHorizontalDragStart: _isLocked
          ? null
          : (details) => _handleHorizontalDragStart(details),
      onHorizontalDragUpdate: _isLocked
          ? null
          : (details) => _handleHorizontalDragUpdate(details),
      onHorizontalDragEnd: _isLocked ? null : (_) => _handleHorizontalDragEnd(),
      child: Container(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildVideoWithFit(),
            if (_isDraggingBrightness) _buildBrightnessIndicator(),
            if (_isDraggingVolume) _buildVolumeIndicator(),
            if (_isSwiping) _buildSeekIndicator(),
            // Controls + lock button
            if (_showControls && !_isLocked) _buildControlsOverlay(),
            if (_showControls || _isLocked) _buildLockButton(),
            if (controller.isBuffering.value)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const SizedBox(
                    height: 26,
                    width: 26,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoWithFit() {
    if (!controller.videoController!.value.isInitialized) {
      return const SizedBox.shrink();
    }

    final videoController = controller.videoController!;
    final videoSize = videoController.value.size;
    final videoAspectRatio = videoSize.width / videoSize.height;

    final videoWidget = VideoPlayer(videoController);

    switch (_videoFit) {
      case VideoFit.fill:
        return SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.fill,
            child: SizedBox(
              width: videoSize.width,
              height: videoSize.height,
              child: videoWidget,
            ),
          ),
        );
      case VideoFit.fit:
        return Center(
          child: AspectRatio(aspectRatio: videoAspectRatio, child: videoWidget),
        );
    }
  }

  // ---------------- DETAILS AREA ----------------

  Widget _buildDetailsSection(bool isDark) {
    final textTheme = Theme.of(context).textTheme;
    final accent = AppColors.primary;

    final movieName = widget.movie.movieName ?? 'Untitled';
    final rating = widget.movie.rating?.toStringAsFixed(1);
    final year = widget.movie.createdAt != null
        ? DateTime.parse(widget.movie.createdAt!).year.toString()
        : '2024';
    final category = widget.movie.category ?? 'Action';
    final hasSeasons =
        widget.movie.seasons != null && widget.movie.seasons!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + meta section card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF16161A) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                if (!isDark)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, 8),
                    blurRadius: 18,
                  ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movieName,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (rating != null)
                      _metaChip(
                        icon: Icons.star_rounded,
                        label: rating,
                        color: Colors.amber,
                      ),
                    _metaChip(icon: Icons.calendar_today_rounded, label: year),
                    _metaChip(icon: Icons.category_rounded, label: category),
                    if (hasSeasons)
                      _metaChip(
                        icon: Icons.movie_creation_outlined,
                        label: '${widget.movie.seasons!.length} Seasons',
                      ),
                  ],
                ),
                if ((widget.movie.description ?? '').isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    widget.movie.description!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.grey[400] : Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          if (hasSeasons) ...[
            const SizedBox(height: 20),
            // Episodes card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF16161A) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      offset: const Offset(0, 6),
                      blurRadius: 14,
                    ),
                ],
              ),
              child: _buildEpisodeSelector(isDark),
            ),
          ],

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _metaChip({
    required IconData icon,
    required String label,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color?.withOpacity(0.6) ?? Colors.white.withOpacity(0.15),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color ?? Colors.grey[300]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color ?? Colors.grey[200],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    bool isDark,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: isDark ? const Color(0xFF16161A) : Colors.white,
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.06),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isDark ? Colors.white : Colors.black87,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEpisodeSelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Row(
          children: [
            const Icon(
              Icons.play_circle_fill_rounded,
              size: 20,
              color: Colors.white70,
            ),
            const SizedBox(width: 8),
            Text(
              'Episodes',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _showEpisodeSelector,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              icon: const Icon(Icons.grid_view_rounded, size: 18),
              label: const Text('All'),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Season dropdown
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF25252A) : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedSeasonIndex,
              isExpanded: true,
              dropdownColor: isDark ? const Color(0xFF25252A) : Colors.white,
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              items: List.generate(widget.movie.seasons!.length, (index) {
                final season = widget.movie.seasons![index];
                return DropdownMenuItem(
                  value: index,
                  child: Text(
                    'Season ${season.seasonNo?.toString().padLeft(2, '0') ?? (index + 1).toString().padLeft(2, '0')}',
                  ),
                );
              }),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedSeasonIndex = value);
                }
              },
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Horizontal episodes strip
        SizedBox(
          height: 54,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount:
                widget.movie.seasons![_selectedSeasonIndex].episodes?.length ??
                0,
            itemBuilder: (context, index) {
              final episode =
                  widget.movie.seasons![_selectedSeasonIndex].episodes![index];
              final episodeNo = episode.episodeNo ?? (index + 1);
              final isCurrentEpisode =
                  _selectedSeasonIndex == _currentSeasonIndex &&
                  index == _currentEpisodeIndex;

              return Padding(
                padding: EdgeInsets.only(
                  right:
                      index ==
                          (widget
                                  .movie
                                  .seasons![_selectedSeasonIndex]
                                  .episodes!
                                  .length -
                              1)
                      ? 0
                      : 8,
                ),
                child: GestureDetector(
                  onTap: () => _playEpisode(_selectedSeasonIndex, index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 54,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: isCurrentEpisode
                          ? AppColors.primary
                          : (isDark
                                ? const Color(0xFF25252A)
                                : Colors.grey[200]),
                      boxShadow: isCurrentEpisode
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        episodeNo.toString().padLeft(2, '0'),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: isCurrentEpisode
                              ? FontWeight.bold
                              : FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEpisodeBottomSheet(BuildContext bottomSheetContext) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedSeason = widget.movie.seasons![_selectedSeasonIndex];
    final episodes = selectedSeason.episodes ?? [];

    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF101014) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF25252A)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButton<int>(
                        value: _selectedSeasonIndex,
                        dropdownColor: isDark
                            ? const Color(0xFF25252A)
                            : Colors.white,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        items: List.generate(widget.movie.seasons!.length, (
                          index,
                        ) {
                          final season = widget.movie.seasons![index];
                          return DropdownMenuItem(
                            value: index,
                            child: Text(
                              'Season ${season.seasonNo?.toString().padLeft(2, '0') ?? (index + 1).toString().padLeft(2, '0')}',
                            ),
                          );
                        }),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedSeasonIndex = value);
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () => Navigator.of(bottomSheetContext).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.1,
              ),
              itemCount: episodes.length,
              itemBuilder: (context, index) {
                final episode = episodes[index];
                final episodeNo = episode.episodeNo ?? (index + 1);
                final isCurrentEpisode =
                    _selectedSeasonIndex == _currentSeasonIndex &&
                    index == _currentEpisodeIndex;

                return GestureDetector(
                  onTap: () => _playEpisodeFromBottomSheet(
                    bottomSheetContext,
                    _selectedSeasonIndex,
                    index,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: isCurrentEpisode
                          ? AppColors.primary
                          : (isDark
                                ? const Color(0xFF25252A)
                                : Colors.grey[200]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        episodeNo.toString().padLeft(2, '0'),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: isCurrentEpisode
                              ? FontWeight.bold
                              : FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- CONTROLS OVER VIDEO ----------------

  Widget _buildControlsOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.75),
            Colors.black.withOpacity(0.2),
            Colors.black.withOpacity(0.2),
            Colors.black.withOpacity(0.85),
          ],
        ),
      ),
      child: Column(
        children: [
          _buildTopControls(),
          Expanded(
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildControlButton(
                    Icons.replay_10_rounded,
                    () => controller.seekRelative(-10),
                    size: _isFullscreen ? 34 : 26,
                  ),
                  const SizedBox(width: 26),
                  Obx(
                    () => _buildControlButton(
                      controller.isPlaying.value
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      controller.togglePlayPause,
                      size: _isFullscreen ? 52 : 38,
                      isPrimary: true,
                    ),
                  ),
                  const SizedBox(width: 26),
                  _buildControlButton(
                    Icons.forward_10_rounded,
                    () => controller.seekRelative(10),
                    size: _isFullscreen ? 34 : 26,
                  ),
                ],
              ),
            ),
          ),
          _buildBottomControls(),
        ],
      ),
    );
  }

  Widget _buildTopControls() {
    IconData fitIcon;
    switch (_videoFit) {
      case VideoFit.fill:
        fitIcon = Icons.fit_screen_rounded;
        break;
      case VideoFit.fit:
        fitIcon = Icons.aspect_ratio_rounded;
        break;
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(
        _isFullscreen ? 12 : 8,
        _isFullscreen ? 12 : 8,
        _isFullscreen ? 12 : 8,
        0,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 24,
            ),
            onPressed: () {
              if (_isFullscreen) {
                _toggleFullscreen();
              } else {
                Get.back();
              }
            },
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              widget.movie.movieName ?? 'Video Player',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (_isFullscreen)
            IconButton(
              icon: Icon(fitIcon, color: Colors.white, size: 22),
              onPressed: _cycleVideoFit,
              tooltip: 'Change fit mode',
            ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        _isFullscreen ? 16 : 12,
        0,
        _isFullscreen ? 16 : 12,
        _isFullscreen ? 16 : 12,
      ),
      child: Obx(() {
        final position = controller.position.value;
        final duration = controller.duration.value;

        return Row(
          children: [
            Text(
              _formatDuration(position),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SliderTheme(
                data: SliderThemeData(
                  trackHeight: 3,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 7,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 14,
                  ),
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: Colors.white.withOpacity(0.3),
                  thumbColor: AppColors.primary,
                  overlayColor: AppColors.primary.withOpacity(0.3),
                ),
                child: Slider(
                  value: position.inMilliseconds
                      .clamp(0, duration.inMilliseconds)
                      .toDouble(),
                  min: 0,
                  max: duration.inMilliseconds.toDouble().clamp(
                    1,
                    double.infinity,
                  ),
                  onChanged: (value) {
                    controller.seekTo(Duration(milliseconds: value.toInt()));
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _formatDuration(duration),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            IconButton(
              icon: Icon(
                _isFullscreen
                    ? Icons.fullscreen_exit_rounded
                    : Icons.fullscreen_rounded,
                color: Colors.white,
                size: 22,
              ),
              onPressed: _toggleFullscreen,
              tooltip: _isFullscreen ? 'Exit fullscreen' : 'Fullscreen',
            ),
          ],
        );
      }),
    );
  }

  Widget _buildControlButton(
    IconData icon,
    VoidCallback onPressed, {
    double size = 40,
    bool isPrimary = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isPrimary
            ? AppColors.primary.withOpacity(0.95)
            : Colors.black.withOpacity(0.3),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.5),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: size),
        onPressed: onPressed,
        padding: EdgeInsets.all(size / 6),
      ),
    );
  }

  Widget _buildLockButton() {
    return Positioned(
      left: 16,
      top: MediaQuery.of(context).size.height * (_isFullscreen ? 0.40 : 0.32),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.55),
        ),
        child: IconButton(
          icon: Icon(
            _isLocked ? Icons.lock_rounded : Icons.lock_open_rounded,
            color: Colors.white,
            size: 22,
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
      ),
    );
  }

  // ---------------- INDICATORS ----------------

  Widget _buildBrightnessIndicator() {
    return Container(
      alignment: Alignment.center,
      color: Colors.black54,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.85),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.brightness_6_rounded,
              color: Colors.white,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              '${(_brightness * 100).toInt()}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVolumeIndicator() {
    final percentage = (_volume * 200).toInt();
    final isBoost = _volume > 0.5;

    return Container(
      alignment: Alignment.center,
      color: Colors.black54,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.85),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _volume > 0.5
                  ? Icons.volume_up_rounded
                  : _volume > 0
                  ? Icons.volume_down_rounded
                  : Icons.volume_off_rounded,
              color: isBoost ? Colors.orange : Colors.white,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              '$percentage%',
              style: TextStyle(
                color: isBoost ? Colors.orange : Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isBoost)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Audio Boost',
                  style: TextStyle(color: Colors.orange.shade300, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeekIndicator() {
    final seekPosition = _swipeSeekPosition ?? controller.position.value;
    final difference =
        seekPosition.inSeconds - controller.position.value.inSeconds;

    return Container(
      alignment: Alignment.center,
      color: Colors.black54,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.85),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              difference > 0
                  ? Icons.fast_forward_rounded
                  : Icons.fast_rewind_rounded,
              color: Colors.white,
              size: 50,
            ),
            const SizedBox(height: 12),
            Text(
              '${difference > 0 ? '+' : ''}${difference}s',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatDuration(seekPosition),
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- GESTURE HANDLERS ----------------

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
      _applyVolume();
    }
  }

  void _handleHorizontalDragStart(DragStartDetails details) {
    setState(() {
      _isSwiping = true;
      _swipeSeekPosition = controller.position.value;
    });
  }

  void _handleHorizontalDragUpdate(DragUpdateDetails details) {
    final dx = details.primaryDelta ?? 0;
    final seekSeconds = (dx / 10).round();

    setState(() {
      final newPosition =
          (_swipeSeekPosition ?? controller.position.value) +
          Duration(seconds: seekSeconds);
      final maxDuration = controller.duration.value;

      _swipeSeekPosition = Duration(
        milliseconds: newPosition.inMilliseconds.clamp(
          0,
          maxDuration.inMilliseconds,
        ),
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

  // ---------------- UTILS ----------------

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
