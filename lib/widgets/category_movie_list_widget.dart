import 'package:cinezza/controllers/home_controller.dart';
import 'package:cinezza/models/categories_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../core/routes/app_routes.dart';
import '../models/movies_model.dart';
import '../widgets/movie_card.dart';

class CategoryMoviesList extends StatefulWidget {
  final IconData icon;
  final bool showFire;

  final CategoryModel category;

  const CategoryMoviesList({
    super.key,
    required this.icon,
    this.showFire = false,
    required this.category,
  });

  @override
  State<CategoryMoviesList> createState() => _CategoryMoviesListState();
}

class _CategoryMoviesListState extends State<CategoryMoviesList>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Future<MoviesModel> _moviesFuture;
  final HomeController controller = Get.find<HomeController>();

  // Computed values
  late bool isDark;

  @override
  void initState() {
    super.initState();
    _moviesFuture = controller.fetchMoviesByCategory(
      categoryId: widget.category.categoryId ?? "",
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    isDark = Theme.of(context).brightness == Brightness.dark;
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.category.isLandScape ?? false ? 150 : 190,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.category.name ?? '',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () =>
                      Get.toNamed(AppRoutes.seeAll, arguments: widget.category),
                  child: Row(
                    spacing: 5,
                    children: [
                      Text(
                        'See All',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 10),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<MoviesModel>(
              future: _moviesFuture,
              builder: (context, snapshot) {
                // Show shimmer while loading
                if (snapshot.connectionState == ConnectionState.waiting ||
                    snapshot.connectionState == ConnectionState.none) {
                  return _buildShimmerLoader();
                }

                // Handle errors
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Failed to load movies',
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  );
                }

                // Check if we have data
                if (!snapshot.hasData ||
                    snapshot.data == null ||
                    snapshot.data!.data == null ||
                    snapshot.data!.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'No movies found',
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  );
                }

                // We have data - show it with animation!
                final movies = snapshot.data!.data!;
                movies.sort((a, b) {
                  final aDate = a.createdAt != null
                      ? DateTime.tryParse(a.createdAt!) ?? DateTime(1970)
                      : DateTime(1970);
                  final bDate = b.createdAt != null
                      ? DateTime.tryParse(b.createdAt!) ?? DateTime(1970)
                      : DateTime(1970);
                  return bDate.compareTo(aDate);
                });

                // Trigger fade-in animation
                if (_fadeController.status == AnimationStatus.dismissed) {
                  _fadeController.forward();
                }

                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(left: 16, right: 16),
                      itemCount: movies.length > 10 ? 10 : movies.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: MovieCard(
                            isLandScape: widget.category.isLandScape ?? false,
                            onTap: () {},
                            movie: movies[index],
                            index: index,
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoader() {
    // Calculate exact dimensions based on isLandScape property
    final double cardWidth = widget.category.isLandScape ?? false ? 150 : 100;
    final double cardHeight = widget.category.isLandScape ?? false ? 90 : 137;
    final double titleMaxWidth = widget.category.isLandScape ?? false
        ? 100
        : 90;

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[850]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      period: const Duration(milliseconds: 1500),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(left: 16, right: 16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: SizedBox(
              width: cardWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Poster shimmer with exact dimensions
                  Container(
                    height: cardHeight,
                    width: cardWidth,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Title shimmer
                  Container(
                    width: titleMaxWidth,
                    height: 10, // Match MovieCard title fontSize: 10
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
    );
  }
}
