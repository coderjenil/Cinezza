// reels_webview_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../models/remote_config_model.dart';
import '../../models/user_model.dart';
import '../../services/reels_timer_helper.dart';
import '../../services/user_api_service.dart';
import 'time_expired_screen.dart';

class ReelsWebViewScreen extends StatefulWidget {
  final String categoryName;
  final String url;
  final User user;
  final Config config;

  const ReelsWebViewScreen({
    super.key,
    required this.categoryName,
    required this.url,
    required this.user,
    required this.config,
  });

  @override
  State<ReelsWebViewScreen> createState() => _ReelsWebViewScreenState();
}

class _ReelsWebViewScreenState extends State<ReelsWebViewScreen>
    with WidgetsBindingObserver {
  late WebViewController _controller;
  int _loadingPercentage = 0;
  Timer? _countdownTimer;
  Timer? _syncTimer;

  // 🔥 ACCURATE TIME TRACKING
  int _remainingSeconds = 0;
  int _initialSeconds = 0;
  DateTime? _sessionStartTime;
  bool _isPremium = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _isPremium = widget.user.planActive ?? false;
    _initialSeconds = widget.user.reelsUsage ?? 0;
    _remainingSeconds = _initialSeconds;
    _sessionStartTime = DateTime.now();

    debugPrint('🎬 Session started with $_remainingSeconds seconds');

    _initializeWebView();

    if (!_isPremium) {
      _startTimer();
      _startPeriodicSync(); // Sync every 30 seconds
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopTimer();
    _syncTimer?.cancel();

    if (!_isPremium) {
      _saveTimerBeforeExit();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isPremium) {
      if (state == AppLifecycleState.paused ||
          state == AppLifecycleState.inactive) {
        debugPrint('⏸️ App paused - saving state');
        _pauseTimer();
      } else if (state == AppLifecycleState.resumed) {
        debugPrint('▶️ App resumed - resuming timer');
        _resumeTimer();
      }
    }
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.darkBackground)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            if (mounted) {
              setState(() => _loadingPercentage = 0);
            }
          },
          onProgress: (progress) {
            if (mounted) {
              setState(() => _loadingPercentage = progress);
            }
          },
          onPageFinished: (url) {
            if (mounted) {
              setState(() => _loadingPercentage = 100);
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  // 🔥 ACCURATE TIMER
  void _startTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        if (mounted) {
          setState(() {
            _remainingSeconds--;
          });
        }

        // Log every 10 seconds
        if (_remainingSeconds % 10 == 0) {
          final elapsed = _initialSeconds - _remainingSeconds;
          debugPrint(
            '⏱️ Watched: $elapsed sec | Remaining: $_remainingSeconds sec',
          );
        }
      } else {
        debugPrint('⏰ Time expired!');
        _stopTimer();
        _showTimeExpiredScreen();
      }
    });
  }

  void _stopTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  // 🔥 PERIODIC SYNC (Every 30 seconds)
  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!_isPremium && mounted) {
        _syncUsageToBackend();
      }
    });
  }

  void _pauseTimer() async {
    _stopTimer();
    await _saveAndSyncUsage();
  }

  void _resumeTimer() {
    if (_remainingSeconds > 0) {
      _startTimer();
    } else {
      _showTimeExpiredScreen();
    }
  }

  // 🔥 SAVE AND SYNC
  Future<void> _saveAndSyncUsage() async {
    await ReelsTimerHelper.saveRemainingTime(_remainingSeconds);
    await _syncUsageToBackend();
  }

  Future<void> _saveTimerBeforeExit() async {
    debugPrint('💾 Saving before exit: $_remainingSeconds seconds');
    await _saveAndSyncUsage();
  }

  // 🔥 SYNC TO BACKEND
  Future<void> _syncUsageToBackend() async {
    try {
      debugPrint('📤 Syncing to backend: $_remainingSeconds seconds');

      await UserService.updateUserByDeviceId(reelsUsage: _remainingSeconds);
    } catch (e) {
      debugPrint('❌ Error syncing to backend: $e');
    }
  }

  // Replace the _showTimeExpiredScreen function in reels_webview_screen.dart

  void _showTimeExpiredScreen() async {
    // Stop timers before navigation
    _stopTimer();
    _syncTimer?.cancel();

    await _syncUsageToBackend();

    if (!mounted) return;

    // 🔥 USE PUSH INSTEAD OF PUSH_REPLACEMENT
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => TimeExpiredScreen(
          user: widget.user,
          onAdWatched: () async {
            // This returns true to indicate ad was watched
            Navigator.pop(context, true);
          },
          onGoBack: () {
            // This returns false or null
            Navigator.pop(context, false);
          },
        ),
      ),
    );

    // Handle the result after returning from TimeExpiredScreen
    if (!mounted) return;

    if (result == true) {
      // Ad was watched - grant bonus time
      setState(() {
        _remainingSeconds += 300;
        _initialSeconds = _remainingSeconds;
      });

      debugPrint(
        '🎁 Bonus time granted: +300 seconds. New total: $_remainingSeconds',
      );

      await ReelsTimerHelper.saveRemainingTime(_remainingSeconds);
      await _syncUsageToBackend();

      // Restart timer
      _startTimer();
      _startPeriodicSync();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '🎉 +5 minutes added! Continue watching.',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } else {
      // User chose to go back - exit the screen
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) return '${hours}h ${minutes}m ${secs}s';
    return '${minutes}m ${secs}s';
  }

  Color _getTimerColor() {
    if (_remainingSeconds < 60) return AppColors.error;
    if (_remainingSeconds < 300) return AppColors.warning;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop && !_isPremium) {
          await _saveTimerBeforeExit();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.darkBackground,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              // gradient: isDark
              //     ? AppColors.darkPrimaryGradient
              //     : AppColors.lightPrimaryGradient,
            ),
          ),
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 20,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.categoryName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (!_isPremium)
                Text(
                  'Time remaining',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
            ],
          ),
          actions: [
            if (!_isPremium)
              Padding(
                padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getTimerColor(),
                        _getTimerColor().withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: _getTimerColor().withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _remainingSeconds < 60
                            ? Icons.timer_off_rounded
                            : Icons.access_time_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatTime(_remainingSeconds),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_loadingPercentage < 100)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: isDark
                        ? AppColors.darkPrimaryGradient
                        : AppColors.lightPrimaryGradient,
                  ),
                  child: LinearProgressIndicator(
                    value: _loadingPercentage / 100.0,
                    backgroundColor: Colors.transparent,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
