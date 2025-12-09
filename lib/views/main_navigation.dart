import 'package:cinezza/controllers/splash_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/theme/app_colors.dart';
import 'home/home_page.dart';
import 'adult_content/adult_content_page.dart';
import 'reels/reels_categories_screen.dart';
import 'profile/profile_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  final RxInt currentIndex = 0.obs;
  late final SplashController splashController;

  @override
  void initState() {
    super.initState();
    splashController = Get.find<SplashController>();
  }

  bool get showMature =>
      splashController.remoteConfigModel.value?.config.showMature ?? false;

  List<Widget> get pages => [
    HomePage(),
    if (showMature) AdultContentPage(),
    if (showMature) ReelsCategoriesScreen(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      // Safety: clamp index in case showMature changed from true->false
      if (currentIndex.value >= pages.length) {
        currentIndex.value = pages.length - 1;
      }

      return Scaffold(
        body: IndexedStack(index: currentIndex.value, children: pages),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            gradient: isDark
                ? LinearGradient(
                    colors: [AppColors.darkSurface, AppColors.darkBackground],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                : LinearGradient(
                    colors: [AppColors.lightSurface, AppColors.lightBackground],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
            boxShadow: [
              BoxShadow(
                color: AppColors.darkPrimary.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
            border: Border(
              top: BorderSide(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.05),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(context, 0, Icons.home_rounded, 'Home', isDark),

                  if (showMature)
                    _buildNavItem(
                      context,
                      1,
                      Icons.eighteen_up_rating_rounded,
                      '18+',
                      isDark,
                    ),

                  if (showMature)
                    _buildNavItem(
                      context,
                      2,
                      Icons.video_library_rounded,
                      'Reels',
                      isDark,
                    ),

                  _buildNavItem(
                    context,
                    showMature ? 3 : 1,
                    Icons.person_rounded,
                    'Profile',
                    isDark,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    IconData icon,
    String label,
    bool isDark,
  ) {
    final isSelected = currentIndex.value == index;

    return GestureDetector(
      onTap: () => currentIndex.value = index,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.getPrimaryGradient(context) : null,
          color: isSelected
              ? null
              : (isDark ? Colors.transparent : Colors.transparent),
          borderRadius: BorderRadius.circular(14),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Colors.white
                  : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary),
              size: 22,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
