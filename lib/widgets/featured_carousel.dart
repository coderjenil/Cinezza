import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import 'cached_image.dart';
import '../core/theme/app_colors.dart';

class FeaturedCarousel extends StatelessWidget {
  final List<Map<String, dynamic>> movies;
  final Function(Map<String, dynamic>) onMovieTap;
  final RxInt currentIndex;

  const FeaturedCarousel({
    Key? key,
    required this.movies,
    required this.onMovieTap,
    required this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final double bannerHeight = screenWidth > 600
        ? 180
        : screenHeight * 0.22;

    final pageController = PageController(viewportFraction: 0.92);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: bannerHeight + 30,
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: pageController,
              onPageChanged: (index) => currentIndex.value = index,
              itemCount: movies.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return Obx(() {
                  final isActive = currentIndex.value == index;
                  return AnimatedScale(
                    scale: isActive ? 1.0 : 0.94,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    child: _buildBannerCard(context, movies[index], isActive, isDark),
                  );
                });
              },
            ),
          ),
          const SizedBox(height: 8),
          _buildIndicator(context, isDark),
        ],
      ),
    );
  }

  Widget _buildBannerCard(BuildContext context, Map<String, dynamic> movie, bool isActive, bool isDark) {
    return GestureDetector(
      onTap: () => onMovieTap(movie),
      child: Container(
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
              // Full Background Image
              CachedImage(
                imageUrl: movie['backdrop'] ?? movie['poster'] ?? '',
                fit: BoxFit.cover,
              ),

              // Gradient Overlay for Title
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),

              // Title and Play Button at Bottom
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        movie['title'] ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: AppColors.getPrimaryGradient(context),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 20,
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

  Widget _buildIndicator(BuildContext context, bool isDark) {
    return Obx(() => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        movies.length,
            (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: currentIndex.value == index ? 18 : 5,
          height: 5,
          decoration: BoxDecoration(
            gradient: currentIndex.value == index
                ? AppColors.getPrimaryGradient(context)
                : null,
            color: currentIndex.value == index
                ? null
                : Colors.grey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    ));
  }
}
