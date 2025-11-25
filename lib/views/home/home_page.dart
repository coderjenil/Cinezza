import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/cached_image.dart';
import '../../widgets/movie_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final HomeController controller = Get.put(HomeController());
  final ThemeController themeController = Get.find<ThemeController>();
  final ScrollController _scrollController = ScrollController();
  Timer? _autoScrollTimer;
  late AnimationController _transitionController;
  late List<AnimationController> _rowAnimationControllers;
  int _currentBannerIndex = 0;
  int _nextBannerIndex = 1;

  @override
  void initState() {
    super.initState();

    _transitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Initialize 4 row animation controllers with optimized duration
    _rowAnimationControllers = List.generate(
      4,
          (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
    );

    _startAutoTransition();
    _startRowAnimations();
  }

  void _startRowAnimations() async {
    // Wait a bit for initial render
    await Future.delayed(const Duration(milliseconds: 100));

    // Stagger animations with shorter delays for smoother effect
    for (int i = 0; i < _rowAnimationControllers.length; i++) {
      if (mounted) {
        await Future.delayed(Duration(milliseconds: i * 100));
        _rowAnimationControllers[i].forward();
      }
    }
  }

  void _startAutoTransition() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          _nextBannerIndex = (_currentBannerIndex + 1) % controller.featuredMovies.length;
        });

        _transitionController.forward(from: 0).then((_) {
          if (mounted) {
            setState(() {
              _currentBannerIndex = _nextBannerIndex;
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _transitionController.dispose();
    for (var controller in _rowAnimationControllers) {
      controller.dispose();
    }
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
                _buildCompactAppBar(context, isDark),

                // Auto-Transition Banner (UNCHANGED)
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: screenHeight * 0.22,
                    child: _buildAutoTransitionBanner(context),
                  ),
                ),

                // Animated Movie Sections
                _buildAnimatedMovieSection(
                  context,
                  title: 'Latest',
                  icon: Icons.fiber_new_rounded,
                  movies: controller.latestMovies,
                  isDark: isDark,
                  cardWidth: cardWidth,
                  sectionHeight: totalSectionHeight,
                  animationIndex: 0,
                ),

                _buildAnimatedMovieSection(
                  context,
                  title: 'Trending',
                  icon: Icons.local_fire_department_rounded,
                  movies: controller.trendingMovies,
                  isDark: isDark,
                  showFire: true,
                  cardWidth: cardWidth,
                  sectionHeight: totalSectionHeight,
                  animationIndex: 1,
                ),

                _buildAnimatedMovieSection(
                  context,
                  title: 'Coming Soon',
                  icon: Icons.upcoming_rounded,
                  movies: controller.upcomingMovies,
                  isDark: isDark,
                  cardWidth: cardWidth,
                  sectionHeight: totalSectionHeight,
                  animationIndex: 2,
                ),

                _buildAnimatedMovieSection(
                  context,
                  title: 'For You',
                  icon: Icons.favorite_rounded,
                  movies: controller.recommendedMovies,
                  isDark: isDark,
                  cardWidth: cardWidth,
                  sectionHeight: totalSectionHeight,
                  animationIndex: 3,
                ),

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

  // BANNER CODE - COMPLETELY UNCHANGED
  Widget _buildAutoTransitionBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: AnimatedBuilder(
        animation: _transitionController,
        builder: (context, child) {
          final progress = _transitionController.value;
          final currentMovie = controller.featuredMovies[_currentBannerIndex];
          final nextMovie = controller.featuredMovies[_nextBannerIndex];
          final easeProgress = Curves.easeInOutCubic.transform(progress);

          return Stack(
            children: [
              // Background - Next image
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Transform.scale(
                        scale: 0.8 + (easeProgress * 0.2),
                        child: CachedImage(
                          imageUrl: nextMovie['backdrop'] ?? nextMovie['poster'] ?? '',
                          fit: BoxFit.cover,
                        ),
                      ),
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
                        bottom: 12,
                        left: 14,
                        right: 14,
                        child: Opacity(
                          opacity: easeProgress,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  nextMovie['title'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  gradient: AppColors.getPrimaryGradient(context),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                                      blurRadius: 12,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 18),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Foreground - Current image
              Opacity(
                opacity: 1.0 - easeProgress,
                child: Transform.scale(
                  scale: 1.0 + (easeProgress * 0.3),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.3 * (1 - easeProgress)),
                          blurRadius: 20,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CachedImage(
                            imageUrl: currentMovie['backdrop'] ?? currentMovie['poster'] ?? '',
                            fit: BoxFit.cover,
                          ),
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
                            bottom: 12,
                            left: 14,
                            right: 14,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    currentMovie['title'] ?? '',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    gradient: AppColors.getPrimaryGradient(context),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                                        blurRadius: 12,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 18),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // OPTIMIZED ROW ANIMATIONS
  Widget _buildAnimatedMovieSection(
      BuildContext context, {
        required String title,
        required IconData icon,
        required RxList<Map<String, dynamic>> movies,
        required bool isDark,
        bool showFire = false,
        required double cardWidth,
        required double sectionHeight,
        required int animationIndex,
      }) {
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: _rowAnimationControllers[animationIndex],
        builder: (context, child) {
          // Optimized animations with shorter distance
          final slideValue = Tween<double>(begin: 30.0, end: 0.0)
              .animate(CurvedAnimation(
            parent: _rowAnimationControllers[animationIndex],
            curve: Curves.easeOut,
          ))
              .value;

          final fadeValue = Tween<double>(begin: 0.0, end: 1.0)
              .animate(CurvedAnimation(
            parent: _rowAnimationControllers[animationIndex],
            curve: Curves.easeIn,
          ))
              .value;

          return Transform.translate(
            offset: Offset(0, slideValue),
            child: Opacity(
              opacity: fadeValue,
              child: SizedBox(
                height: sectionHeight,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                      child: Row(
                        children: [
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
                            child: Row(
                              spacing: 5,
                              children: [
                                Text(
                                  'See All',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                Icon(Icons.arrow_forward_ios,size: 10,)
                              ],
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
                                onTap: () => controller.onMovieTapped(movies[index]),
                                index: index,
                                width: cardWidth,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
