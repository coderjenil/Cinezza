// reels_webview_screen.dart

import 'dart:async';
import 'package:app/controllers/splash_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  int _remainingSeconds = 0;
  int _initialSeconds = 0;
  bool _isPremium = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _isPremium = widget.user.planActive;
    _initialSeconds = widget.user.reelsUsage;
    _remainingSeconds = _initialSeconds;

    _initializeWebView();

    if (!_isPremium) {
      _startTimer();
      _startPeriodicSync();
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

  // ------------------------ PAUSE WEBVIEW SOUND ------------------------

  Future<void> _pauseWebMedia() async {
    try {
      await _controller.runJavaScript("""
        document.querySelectorAll('video').forEach(v => { try { v.pause(); v.muted = true; } catch(e){} });
        document.querySelectorAll('audio').forEach(a => { try { a.pause(); a.muted = true; } catch(e){} });
      """);
      debugPrint("⏸️ WebView media paused");
    } catch (e) {
      debugPrint("❌ Error pausing web media: $e");
    }
  }

  // ------------------------ WEBVIEW SETUP ------------------------

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.darkBackground)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _loadingPercentage = 0),
          onProgress: (progress) =>
              setState(() => _loadingPercentage = progress),
          onPageFinished: (_) => setState(() => _loadingPercentage = 100),
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  // ------------------------ TIMER SYSTEM ------------------------

  void _startTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _stopTimer();
        _showTimeExpiredScreen();
      }
    });
  }

  void _stopTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
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

  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!_isPremium) _syncUsageToBackend();
    });
  }

  Future<void> _saveAndSyncUsage() async {
    await ReelsTimerHelper.saveRemainingTime(_remainingSeconds);
    await _syncUsageToBackend();
  }

  Future<void> _syncUsageToBackend() async {
    try {
      await UserService.updateUserByDeviceId(reelsUsage: _remainingSeconds);
    } catch (_) {}
  }

  Future<void> _saveTimerBeforeExit() async {
    await _saveAndSyncUsage();
  }

  // ------------------------ TIME EXPIRED HANDLER ------------------------

  void _showTimeExpiredScreen() async {
    _stopTimer();
    _syncTimer?.cancel();
    await _syncUsageToBackend();

    // 🔇 Pause sound BEFORE navigating
    await _pauseWebMedia();

    if (!mounted) return;

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => TimeExpiredScreen(
          user: widget.user,
          onAdWatched: () async => Navigator.pop(context, true),
          onGoBack: () => Navigator.pop(context, false),
        ),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      // User watched rewarded ad → grant time
      setState(() {
        _remainingSeconds +=
            Get.find<SplashController>()
                .remoteConfigModel
                .value
                ?.config
                .reelIncreaseTime ??
            60;

        _initialSeconds = _remainingSeconds;
      });

      await ReelsTimerHelper.saveRemainingTime(_remainingSeconds);
      await _syncUsageToBackend();

      _startTimer();
      _startPeriodicSync();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("🎉 +5 min added! Enjoy watching."),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }

  // ------------------------ LIFECYCLE ------------------------

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isPremium) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _pauseWebMedia();
      _pauseTimer();
    } else if (state == AppLifecycleState.resumed) {
      _resumeTimer();
    }
  }

  // ------------------------ UI ------------------------

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m}m ${s}s';
  }

  Color _timerColor() {
    if (_remainingSeconds < 60) return AppColors.error;
    if (_remainingSeconds < 300) return AppColors.warning;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          children: [
            Text(widget.categoryName),
            Spacer(),
            if (!_isPremium)
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _timerColor(),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _formatTime(_remainingSeconds),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loadingPercentage < 100)
            LinearProgressIndicator(
              value: _loadingPercentage / 100,
              backgroundColor: Colors.black,
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
        ],
      ),
    );
  }
}
