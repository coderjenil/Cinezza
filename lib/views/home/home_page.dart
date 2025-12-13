import 'dart:async';

import 'package:cinezza/controllers/splash_controller.dart';
import 'package:cinezza/views/premium/premium_plan_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';

import '../../controllers/home_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../utils/dialogs/first_time_credit_dialog.dart';
import '../../utils/dialogs/show_aleart.dart';
import '../../widgets/auto_transition_widget.dart';
import '../../widgets/banner_ad_widget.dart';
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

  // Computed values - calculated once per layout change
  late double screenHeight;

  late bool isDark;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Calculate values only when dependencies change
    _calculateDimensions();
  }

  void _calculateDimensions() {
    screenHeight = MediaQuery.of(context).size.height;
    isDark = Theme.of(context).brightness == Brightness.dark;
  }

  Future<void> fetchCategories() async {
    try {
      controller.isLoading.value = true;

      await controller.fetchAllCategories();
      // Show dialog only if new user AND has credits
      if (splashController.isNewUser.value) {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => ModernCreditDialog(
              credits: splashController.userModel.value!.user.trialCount,
              onContinue: () {
                Get.back();
              },
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        showAlert(context: context, message: e);
      }
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
                  _buildCompactAppBar(),
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
                  SliverToBoxAdapter(child: _buildShimmerLoading()),
                ],
              );
            }

            return CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildCompactAppBar(),

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
                SliverToBoxAdapter(child: _buildCategoriesWithAds()),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),
              ],
            );
          }),
        ),
      ),
    );
  }

  /// BUILD CATEGORIES WITH BANNER ADS EVERY 2 CATEGORIES
  Widget _buildCategoriesWithAds() {
    final categories = controller.nonAdultCategories
        .where(
          (cat) =>
              cat.name != "Trending" &&
              cat.name != "Web Movies" &&
              cat.name != "Web Adult",
        )
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
            ),

            // Add Banner Ad after every 2nd category
            if ((index + 1) % 2 == 0 && index < categories.length - 1)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: BannerAdWidget(),
              ),
          ],
        );
      },
    );
  }

  Widget _buildShimmerLoading() {
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
            padding: const EdgeInsets.only(bottom: 0),
            child: SizedBox(
              height: 190, // Match CategoryMoviesList height for portrait
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title shimmer - matches CategoryMoviesList padding
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                    child: Row(
                      children: [
                        Container(
                          width: 120,
                          height: 15, // Match actual title fontSize: 15
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 60,
                          height: 12, // Match "See All" fontSize: 12
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
                            width: 100, // Match MovieCard portrait width
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Poster shimmer - matches MovieCard dimensions
                                Container(
                                  height:
                                      140, // Match MovieCard portrait height
                                  width: 100, // Match MovieCard portrait width
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                const SizedBox(
                                  height: 4,
                                ), // Match MovieCard spacing
                                // Title shimmer
                                Container(
                                  width: 90, // Match _buildMovieTitle maxWidth
                                  height: 10, // Match title fontSize: 10
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

  Widget _buildCompactAppBar() {
    return SliverAppBar(
      floating: true,
      snap: true,
      elevation: 0,
      backgroundColor: Colors.red,
      toolbarHeight: 40,
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: ShaderMask(
                  shaderCallback: (bounds) => AppColors.getPrimaryGradient(
                    context,
                  ).createShader(bounds),
                  child: const Text(
                    'Cinezza',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              _buildCompactIconButton(
                Icons.search_rounded,
                () => Get.toNamed(AppRoutes.search),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  Get.to(() => PremiumPlansPage());
                },
                child: Lottie.asset(
                  "assets/jsons/icon_1.json",
                  height: 60,
                  width: 50,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactIconButton(
    IconData icon,
    VoidCallback onTap, {
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
