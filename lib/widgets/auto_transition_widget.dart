import 'dart:async';

import 'package:cinezza/services/user_api_service.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../controllers/home_controller.dart';
import '../core/theme/app_colors.dart';
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

class _AutoTransitionBannerState extends State<AutoTransitionBanner>
    with TickerProviderStateMixin {
  late AnimationController _transitionController;

  int _currentBannerIndex = 0;
  int _nextBannerIndex = 1;
  Timer? _autoScrollTimer;

  MoviesModel moviesModel = MoviesModel();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _transitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

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
        _startAutoTransition();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _startAutoTransition() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted && (moviesModel.data?.isNotEmpty ?? false)) {
        setState(() {
          _nextBannerIndex =
              (_currentBannerIndex + 1) % (moviesModel.data?.length ?? 1);
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Show shimmer while loading
    if (_isLoading || moviesModel.data == null || moviesModel.data!.isEmpty) {
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

    // Show actual banner with animation
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (moviesModel.data != null) {
          UserService().canWatchMovie(
            movie: moviesModel.data![_currentBannerIndex],
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: AnimatedBuilder(
          animation: _transitionController,
          builder: (context, child) {
            final progress = _transitionController.value;
            final currentMovie = moviesModel.data?[_currentBannerIndex];
            final nextMovie = moviesModel.data?[_nextBannerIndex];
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
                        Transform.scale(
                          scale: 0.8 + (easeProgress * 0.2),
                          child: CachedImage(
                            imageUrl:
                                nextMovie?.thumbUrl2 ??
                                nextMovie?.thumbUrl ??
                                '',
                            fit: BoxFit.cover,
                          ),
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
                          child: Opacity(
                            opacity: easeProgress,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    nextMovie?.movieName ?? '',
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
                            color: Theme.of(context).colorScheme.primary
                                .withOpacity(0.3 * (1 - easeProgress)),
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
                              imageUrl:
                                  currentMovie?.thumbUrl2 ??
                                  currentMovie?.thumbUrl ??
                                  '',
                              fit: BoxFit.cover,
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
                                      currentMovie?.movieName ?? '',
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
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
