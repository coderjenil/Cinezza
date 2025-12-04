import 'dart:async';

import 'package:app/controllers/splash_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../controllers/home_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../utils/dialogs/first_time_credit_dialog.dart';
import '../../utils/dialogs/show_aleart.dart';
import '../../widgets/auto_transition_widget.dart';
import '../../widgets/banner_ad_widget.dart'; // ADD THIS IMPORT
import '../../widgets/category_movie_list_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final HomeController controller = Get.put(HomeController());
  final ThemeController themeController = Get.find();
  final ScrollController _scrollController = ScrollController();
  final SplashController splashController = Get.find<SplashController>();
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  fetchCategories() async {
    try {
      controller.isLoading.value = true;

      await controller.fetchAllCategories();
      // Show dialog only if new user AND has credits
      // if (splashController.isNewUser.value) {
      showDialog(
        context: Get.context!,
        barrierDismissible: false,
        builder: (_) => ModernCreditDialog(
          credits: splashController.userModel.value!.user.trialCount,
          onContinue: () {
            Get.back();
          },
        ),
      );
      // }
    } catch (e) {
      showAlert(context: context, message: e);
    } finally {
      controller.isLoading.value = false;
    }
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 40) / 3.5;
    final cardHeight = cardWidth * 1.5;
    final titleHeight = 28.0;
    final totalSectionHeight = cardHeight + titleHeight + 30;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppColors.darkBackgroundGradient
              : AppColors.lightBackgroundGradient,
        ),
        child: SafeArea(
          child: Obx(() {
            if (controller.isLoading.value) {
              return CustomScrollView(
                physics: const NeverScrollableScrollPhysics(),
                slivers: [
                  _buildCompactAppBar(context, isDark),
                  SliverToBoxAdapter(
                    child: Shimmer.fromColors(
                      baseColor: isDark ? Colors.grey[850]! : Colors.grey[300]!,
                      highlightColor: isDark
                          ? Colors.grey[700]!
                          : Colors.grey[100]!,
                      period: const Duration(milliseconds: 1500),
                      child: SizedBox(height: screenHeight * 0.22),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _buildShimmerLoading(
                      context,
                      isDark,
                      cardWidth,
                      totalSectionHeight,
                    ),
                  ),
                ],
              );
            }

            return CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildCompactAppBar(context, isDark),

                // Auto-Transition Banner
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: screenHeight * 0.22,
                    child: AutoTransitionBanner(
                      context: context,
                      controller: controller,
                    ),
                  ),
                ),

                // Categories with Banner Ads
                SliverToBoxAdapter(
                  child: _buildCategoriesWithAds(cardWidth, totalSectionHeight),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),
              ],
            );
          }),
        ),
      ),
    );
  }

  /// BUILD CATEGORIES WITH BANNER ADS EVERY 2 CATEGORIES
  Widget _buildCategoriesWithAds(double cardWidth, double totalSectionHeight) {
    final categories = controller.nonAdultCategories
        .where((cat) => cat.name != "Trending")
        .toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];

        return Column(
          children: [
            // Movie Category
            CategoryMoviesList(
              category: category,
              icon: Icons.movie_filter_rounded,
              cardWidth: cardWidth,
              sectionHeight: totalSectionHeight,
            ),

            // Add Banner Ad after every 2nd category
            if ((index + 1) % 2 == 0 && index < categories.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: BannerAdWidget(),
              ),
          ],
        );
      },
    );
  }

  Widget _buildShimmerLoading(
    BuildContext context,
    bool isDark,
    double cardWidth,
    double sectionHeight,
  ) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[850]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      period: const Duration(milliseconds: 1500),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: SizedBox(
              height: sectionHeight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title shimmer
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                    child: Row(
                      children: [
                        Container(
                          width: 120,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 60,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Movie cards shimmer
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(left: 16, right: 16),
                      itemCount: 5,
                      itemBuilder: (context, idx) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: SizedBox(
                            width: cardWidth,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Poster shimmer
                                Flexible(
                                  child: AspectRatio(
                                    aspectRatio: 2 / 3,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Title shimmer
                                Container(
                                  width: cardWidth * 0.8,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCompactAppBar(BuildContext context, bool isDark) {
    return SliverAppBar(
      floating: true,
      snap: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      toolbarHeight: 50,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [
                    AppColors.darkBackground,
                    AppColors.darkBackground.withOpacity(0.95),
                  ]
                : [
                    AppColors.lightBackground,
                    AppColors.lightBackground.withOpacity(0.95),
                  ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: AppColors.getPrimaryGradient(context),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.movie_filter_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ShaderMask(
                  shaderCallback: (bounds) => AppColors.getPrimaryGradient(
                    context,
                  ).createShader(bounds),
                  child: const Text(
                    'CinemaFlix',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              _buildCompactIconButton(
                context,
                Icons.search_rounded,
                () => Get.toNamed(AppRoutes.search),
                isDark,
              ),
              const SizedBox(width: 8),
              Obx(
                () => _buildCompactIconButton(
                  context,
                  themeController.isDarkMode.value
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                  () => themeController.toggleTheme(),
                  isDark,
                  isTheme: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactIconButton(
    BuildContext context,
    IconData icon,
    VoidCallback onTap,
    bool isDark, {
    bool isTheme = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          gradient: isTheme ? AppColors.getPrimaryGradient(context) : null,
          color: isTheme
              ? null
              : (isDark ? AppColors.darkCardBackground : Colors.white),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: isTheme ? Colors.white : Theme.of(context).colorScheme.primary,
          size: 18,
        ),
      ),
    );
  }
}
