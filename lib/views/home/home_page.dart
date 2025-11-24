import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/featured_carousel.dart';
import '../../widgets/movie_card.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final HomeController controller = Get.put(HomeController());
  final ThemeController themeController = Get.find<ThemeController>();
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate card width to show 3.5 movies
    final cardWidth = (screenWidth - 40) / 3.5; // 20px padding left + 20px right
    final cardHeight = cardWidth * 1.5; // 2:3 aspect ratio
    final totalSectionHeight = cardHeight + 50; // card + title space + header

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppColors.darkBackgroundGradient
              : AppColors.lightBackgroundGradient,
        ),
        child: SafeArea(
          child: Obx(() {
            if (controller.isLoading.value) {
              return Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                  strokeWidth: 3,
                ),
              );
            }

            return CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Compact App Bar
                _buildCompactAppBar(context, isDark),

                // Compact Featured Carousel
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: screenHeight * 0.20,
                    child: _buildCompactCarousel(context),
                  ),
                ),

                // Latest Movies
                _buildMovieSection(
                  context,
                  title: 'Latest',
                  icon: Icons.fiber_new_rounded,
                  movies: controller.latestMovies,
                  isDark: isDark,
                  cardWidth: cardWidth,
                  sectionHeight: totalSectionHeight,
                ),

                // Trending
                _buildMovieSection(
                  context,
                  title: 'Trending',
                  icon: Icons.local_fire_department_rounded,
                  movies: controller.trendingMovies,
                  isDark: isDark,
                  showFire: true,
                  cardWidth: cardWidth,
                  sectionHeight: totalSectionHeight,
                ),

                // Coming Soon
                _buildMovieSection(
                  context,
                  title: 'Coming Soon',
                  icon: Icons.upcoming_rounded,
                  movies: controller.upcomingMovies,
                  isDark: isDark,
                  cardWidth: cardWidth,
                  sectionHeight: totalSectionHeight,
                ),

                // For You
                _buildMovieSection(
                  context,
                  title: 'For You',
                  icon: Icons.favorite_rounded,
                  movies: controller.recommendedMovies,
                  isDark: isDark,
                  cardWidth: cardWidth,
                  sectionHeight: totalSectionHeight,
                ),

                // Bottom Spacing
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
              ],
            );
          }),
        ),
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
                ? [AppColors.darkBackground, AppColors.darkBackground.withOpacity(0.95)]
                : [AppColors.lightBackground, AppColors.lightBackground.withOpacity(0.95)],
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
                child: const Icon(Icons.movie_filter_rounded, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ShaderMask(
                  shaderCallback: (bounds) => AppColors.getPrimaryGradient(context).createShader(bounds),
                  child: const Text(
                    'CinemaFlix',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              _buildCompactIconButton(context, Icons.search_rounded, () => Get.toNamed(AppRoutes.search), isDark),
              const SizedBox(width: 8),
              Obx(() => _buildCompactIconButton(
                context,
                themeController.isDarkMode.value ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    () => themeController.toggleTheme(),
                isDark,
                isTheme: true,
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactIconButton(BuildContext context, IconData icon, VoidCallback onTap, bool isDark, {bool isTheme = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          gradient: isTheme ? AppColors.getPrimaryGradient(context) : null,
          color: isTheme ? null : (isDark ? AppColors.darkCardBackground : Colors.white),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: isTheme ? Colors.white : Theme.of(context).colorScheme.primary, size: 18),
      ),
    );
  }

  Widget _buildCompactCarousel(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: PageView.builder(
        onPageChanged: (index) => controller.currentCarouselIndex.value = index,
        itemCount: controller.featuredMovies.length,
        itemBuilder: (context, index) {
          final movie = controller.featuredMovies[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(movie['backdrop'] ?? movie['poster'] ?? '', fit: BoxFit.cover),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 12,
                    right: 12,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            movie['title'] ?? '',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: AppColors.getPrimaryGradient(context),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 16),
                        ),
                      ],
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

  Widget _buildMovieSection(
      BuildContext context, {
        required String title,
        required IconData icon,
        required RxList<Map<String, dynamic>> movies,
        required bool isDark,
        bool showFire = false,
        required double cardWidth,
        required double sectionHeight,
      }) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: sectionHeight,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      gradient: showFire ? AppColors.getTrendingGradient(context) : AppColors.getPrimaryGradient(context),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Icon(icon, size: 13, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.seeAll, arguments: {'title': title, 'movies': movies}),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: AppColors.getPrimaryGradient(context),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'All',
                        style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(left: 16, right: 16),
                itemCount: movies.length > 10 ? 10 : movies.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: SizedBox(
                      width: cardWidth,
                      child: MovieCard(
                        movie: movies[index],
                        onTap: () => controller.onMovieTapped(movies[index]),
                        index: index,
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
  }
}
