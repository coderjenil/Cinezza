import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/adult_content_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../widgets/movie_card.dart';

class AdultContentPage extends StatelessWidget {
  AdultContentPage({Key? key}) : super(key: key);

  final AdultContentController controller = Get.put(AdultContentController());

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate card width to show 3.5 movies
    final cardWidth = (screenWidth - 40) / 3.5;
    final cardHeight = cardWidth * 1.5;
    final totalSectionHeight = cardHeight + 50;

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
            if (!controller.ageVerified.value) {
              return _buildAgeVerification(context, isDark);
            }

            if (controller.isLoading.value) {
              return Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                  strokeWidth: 3,
                ),
              );
            }

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Header
                _buildHeader(context, isDark),

                // Adult Series
                _buildMovieSection(
                  context,
                  title: 'Adult Series',
                  icon: Icons.tv_rounded,
                  movies: controller.adultSeries,
                  isDark: isDark,
                  cardWidth: cardWidth,
                  sectionHeight: totalSectionHeight,
                ),

                // Adult Movies
                _buildMovieSection(
                  context,
                  title: 'Adult Movies',
                  icon: Icons.movie_rounded,
                  movies: controller.adultMovies,
                  isDark: isDark,
                  cardWidth: cardWidth,
                  sectionHeight: totalSectionHeight,
                ),

                // Popular
                _buildMovieSection(
                  context,
                  title: 'Popular',
                  icon: Icons.local_fire_department_rounded,
                  movies: controller.popularAdult,
                  isDark: isDark,
                  showFire: true,
                  cardWidth: cardWidth,
                  sectionHeight: totalSectionHeight,
                ),

                // New Releases
                _buildMovieSection(
                  context,
                  title: 'New Releases',
                  icon: Icons.fiber_new_rounded,
                  movies: controller.newReleases,
                  isDark: isDark,
                  cardWidth: cardWidth,
                  sectionHeight: totalSectionHeight,
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
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
                child: const Icon(Icons.eighteen_up_rating_rounded, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '18+ Content',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Mature content',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 9,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning_rounded, color: AppColors.error, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      '18+',
                      style: TextStyle(
                        color: AppColors.error,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
                      gradient: showFire
                          ? AppColors.getTrendingGradient(context)
                          : AppColors.getPrimaryGradient(context),
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
                    onTap: () => Get.toNamed(
                      AppRoutes.seeAll,
                      arguments: {'title': title, 'movies': movies},
                    ),
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
                    padding: const EdgeInsets.only(right: 8),
                    child: SizedBox(
                      width: cardWidth,
                      child: MovieCard(
                        movie: movies[index],
                        onTap: () => controller.onContentTapped(movies[index]),
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

  Widget _buildAgeVerification(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: AppColors.getPrimaryGradient(context),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.eighteen_up_rating_rounded,
                size: 80,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Age Verification',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'This section contains mature content suitable only for viewers 18 years and older.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () => controller.verifyAge(true),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                decoration: BoxDecoration(
                  gradient: AppColors.getPrimaryGradient(context),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Text(
                  'I am 18 or older',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'Go Back',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
