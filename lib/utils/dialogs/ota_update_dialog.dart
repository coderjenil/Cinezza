import 'package:flutter/material.dart';
import 'package:ota_update/ota_update.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/theme/app_colors.dart';

class OTAUpdateDialog extends StatefulWidget {
  final String title;
  final String message;
  final String buttonText;
  final String downloadUrl;
  final bool isForceUpdate;

  const OTAUpdateDialog({
    super.key,
    this.title = "Update Required",
    this.message = "A new version is available. Download the update.",
    this.buttonText = "Update Now",
    required this.downloadUrl,
    this.isForceUpdate = false,
  });

  @override
  State<OTAUpdateDialog> createState() => _OTAUpdateDialogState();
}

class _OTAUpdateDialogState extends State<OTAUpdateDialog> {
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String _statusMessage = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? AppColors.darkPrimary.withOpacity(0.3)
                  : AppColors.lightPrimary.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkPrimary.withOpacity(0.1)
                      : AppColors.lightPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkPrimary.withOpacity(0.3)
                        : AppColors.lightPrimary.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.download_rounded,
                  size: 40,
                  color: isDark
                      ? AppColors.darkPrimary
                      : AppColors.lightPrimary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              !_isDownloading
                  ? Text(
                      widget.message,
                      style: TextStyle(
                        fontSize: 15,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    )
                  : Column(
                      children: [
                        Text(
                          '${(_downloadProgress * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.darkPrimary
                                : AppColors.lightPrimary,
                          ),
                        ),
                        if (_statusMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _statusMessage,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
              if (_isDownloading)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: LinearProgressIndicator(
                    value: _downloadProgress,
                    backgroundColor: isDark
                        ? AppColors.darkCardBackground
                        : Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? AppColors.darkPrimary
                        : AppColors.lightPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: const Icon(Icons.download_rounded, color: Colors.white),
                  label: Text(
                    widget.buttonText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: _isDownloading ? null : _handleOTAUpdate,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleOTAUpdate() async {
    final hasPermission = await _requestInstallPermission();
    if (!hasPermission) {
      _showError('Install permission is required to update the app');
      return;
    }

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
      _statusMessage = 'Preparing download...';
    });

    try {
      OtaUpdate()
          .execute(
            widget.downloadUrl,
            destinationFilename:
                'app_update_${DateTime.now().millisecondsSinceEpoch}.apk',
          )
          .listen(
            (OtaEvent event) {
              if (!mounted) return;
              setState(() {
                switch (event.status) {
                  case OtaStatus.DOWNLOADING:
                    _downloadProgress =
                        double.tryParse(event.value ?? '0')! / 100.0;
                    _statusMessage = "Downloading update...";
                    break;
                  case OtaStatus.INSTALLING:
                    _downloadProgress = 1.0;
                    _statusMessage = "Opening installer...";
                    break;
                  case OtaStatus.PERMISSION_NOT_GRANTED_ERROR:
                    _statusMessage = 'Permission denied';
                    _showError('Please grant installation permission');
                    _isDownloading = false;
                    break;
                  case OtaStatus.DOWNLOAD_ERROR:
                    _statusMessage = 'Download failed';
                    _showError('Failed to download update');
                    _isDownloading = false;
                    break;
                  default:
                    break;
                }
              });
            },
            onError: (error) {
              _showError('Update failed: $error');
              setState(() {
                _isDownloading = false;
              });
            },
          );
    } catch (e) {
      _showError('Update failed: $e');
      setState(() {
        _isDownloading = false;
      });
    }
  }

  Future<bool> _requestInstallPermission() async {
    if (await Permission.requestInstallPackages.isGranted) {
      return true;
    }
    final status = await Permission.requestInstallPackages.request();
    return status.isGranted;
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
