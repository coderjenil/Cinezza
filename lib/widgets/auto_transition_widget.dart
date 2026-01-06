import 'package:carousel_slider/carousel_slider.dart';
import 'package:cinezza/core/theme/app_colors.dart';
import 'package:cinezza/services/user_api_service.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../controllers/home_controller.dart';
import '../models/movies_model.dart';
import 'cached_image.dart';

class AutoTransitionBanner extends StatefulWidget {
  const AutoTransitionBanner({
    super.key,
    required this.controller,
    required this.context,
  });

  final HomeController controller;
  final BuildContext context;

  @override
  State<AutoTransitionBanner> createState() => _AutoTransitionBannerState();
}

class _AutoTransitionBannerState extends State<AutoTransitionBanner> {
  final CarouselSliderController _carouselController =
      CarouselSliderController();
  int _currentBannerIndex = 0;

  MoviesModel moviesModel = MoviesModel();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCategory();
  }

  fetchCategory() async {
    try {
      setState(() {
        _isLoading = true;
      });

      moviesModel = await widget.controller.fetchMoviesByCategory(
        categoryId: widget.controller.trendingCategory.categoryId ?? '',
      );

      if (mounted && (moviesModel.data?.isNotEmpty ?? false)) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Show shimmer while loading
    if (_isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Shimmer.fromColors(
          baseColor: isDark ? Colors.grey[850]! : Colors.grey[300]!,
          highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
          period: const Duration(milliseconds: 1500),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      );
    }

    // Show carousel slider with indicators
    return Column(
      children: [
        // Carousel Slider
        CarouselSlider.builder(
          carouselController: _carouselController,
          itemCount: moviesModel.data?.length ?? 0,
          itemBuilder: (context, index, realIndex) {
            final movie = moviesModel.data?[index];
            return GestureDetector(
              onTap: () {
                if (movie != null) {
                  UserService().canWatchMovie(movie: movie);
                }
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.15),
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
                      CachedImage(
                        imageUrl: movie?.thumbUrl2 ?? movie?.thumbUrl ?? '',
                        fit: BoxFit.fill,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.8),
                            ],
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
                                movie?.movieName ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black54,
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 0.5,
                                ),
                              ),
                              child: Image.asset(
                                "assets/images/play.png",
                                height: 30,
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
          },
          options: CarouselOptions(
            height: 190,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayAnimationDuration: const Duration(milliseconds: 1500),
            autoPlayCurve: Curves.easeInOutCubic,
            enlargeCenterPage: false,
            viewportFraction: 1,

            enableInfiniteScroll: true,
            onPageChanged: (index, reason) {
              setState(() {
                _currentBannerIndex = index;
              });
            },
          ),
        ),

        // Dot Indicators
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(moviesModel.data?.length ?? 0, (index) {
            bool isActive = _currentBannerIndex == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 3,
              width: isActive ? 15 : 8,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary
                    : (isDark ? Colors.grey[700] : Colors.grey[400]),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }
}
