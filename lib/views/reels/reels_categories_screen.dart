// reels_categories_screen.dart

import 'package:cinezza/controllers/splash_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';
import '../../models/remote_config_model.dart';
import '../../models/user_model.dart';
import 'reels_webview_screen.dart';

class ReelsCategoriesScreen extends StatefulWidget {
  const ReelsCategoriesScreen({super.key});

  @override
  State<ReelsCategoriesScreen> createState() => _ReelsCategoriesScreenState();
}

class _ReelsCategoriesScreenState extends State<ReelsCategoriesScreen> {
  late SplashController splashController;
  Config? config;
  User? user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    splashController = Get.find<SplashController>();

    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        setState(() {
          config = splashController.remoteConfigModel.value?.config;
          user = splashController.userModel.value?.user;
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final reelsCategories = _getReelsCategories();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildNetPrimeHeader(isDark),
            Expanded(
              child: isLoading
                  ? _buildShimmerLoader(isDark)
                  : reelsCategories.isEmpty
                  ? _buildEmptyView(isDark)
                  : _buildGrid(reelsCategories, isDark),
            ),
          ],
        ),
      ),
    );
  }

  /// HEADER
  Widget _buildNetPrimeHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkPrimary
                      : AppColors.lightPrimary,
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  'Reels Categories',
                  style: TextStyle(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildTimerChip(isDark),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 23),
            child: Text(
              isLoading
                  ? 'Loading categories...'
                  : 'Choose from ${_getReelsCategories().length} trending categories',
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerChip(bool isDark) {
    if (user == null) return const SizedBox.shrink();

    if (user!.planActive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.warning, Color(0xFFF57C00)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star_rounded, size: 14, color: Colors.white),
            SizedBox(width: 4),
            Text(
              'PREMIUM',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.access_time_rounded,
            size: 14,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
          const SizedBox(width: 4),
          Obx(() {
            return Text(
              _formatTime(
                splashController.userModel.value?.user.reelsUsage ?? 0,
              ),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            );
          }),
        ],
      ),
    );
  }

  /// SHIMMER LOADER
  Widget _buildShimmerLoader(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 8,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,
          childAspectRatio: 2.5,
        ),
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: isDark ? AppColors.darkSurface : Colors.grey.shade300,
            highlightColor: isDark
                ? AppColors.darkPrimary.withOpacity(0.1)
                : Colors.grey.shade100,
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? AppColors.darkPrimary.withOpacity(0.3)
                      : AppColors.lightPrimary.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// EMPTY VIEW
  Widget _buildEmptyView(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              color: AppColors.error,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No Categories Available',
            style: TextStyle(
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please check your connection and try again',
            style: TextStyle(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// GRID VIEW
  Widget _buildGrid(List<Map<String, String>> items, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Obx(() {
        splashController.userModel.value!.user;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 15,
            crossAxisSpacing: 15,
            childAspectRatio: 2.5,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final category = items[index];
            return _CategoryCard(
              categoryName: category['name'] ?? "Unknown",
              isDark: isDark,
              onTap: () {
                if (user == null || config == null) return;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReelsWebViewScreen(
                      categoryName: category['name'] ?? "",
                      url: category['url'] ?? "",
                      user: splashController.userModel.value!.user,
                      config: config!,
                    ),
                  ),
                );
              },
            );
          },
        );
      }),
    );
  }

  /// DATA HELPERS
  List<Map<String, String>> _getReelsCategories() {
    if (config?.reels == null) return [];
    return config!.reels!.toCategoriesList();
  }

  String _formatTime(int seconds) {
    if (seconds <= 0) return "0m";
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes}m ${secs}s';
  }
}

class _CategoryCard extends StatelessWidget {
  final String categoryName;
  final bool isDark;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.categoryName,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.darkPrimary.withOpacity(0.3)
              : AppColors.lightPrimary.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? AppColors.darkPrimary.withOpacity(0.15)
                : AppColors.lightPrimary.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          splashColor: isDark
              ? AppColors.darkPrimary.withOpacity(0.1)
              : AppColors.lightPrimary.withOpacity(0.1),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                categoryName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
