import 'package:cinezza/services/user_api_service.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import '../models/movies_model.dart';
import 'cached_image.dart';
import '../core/theme/app_colors.dart';

class MovieCard extends StatefulWidget {
  final Movie movie;
  final int index;
  final bool isFromVideoPlayer;
  final bool isLandScape;
  final void Function() onTap;

  const MovieCard({
    super.key,
    required this.movie,
    this.index = 0,
    this.isFromVideoPlayer = false,
    required this.onTap,
    this.isLandScape = false,
  });

  @override
  State<MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Computed values
  late bool isDark;
  late Color shadowColor;
  late double shadowOpacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(milliseconds: 350 + (widget.index * 40)),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.65, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.2, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: widget.index * 50), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Calculate theme-dependent values only when dependencies change
    isDark = Theme.of(context).brightness == Brightness.dark;
    shadowColor = Colors.black;
    shadowOpacity = isDark ? 0.4 : 0.15;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    widget.onTap();
    UserService().canWatchMovie(
      movie: widget.movie,
      isFromVideoPlayer: widget.isFromVideoPlayer,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: GestureDetector(
            onTap: _handleTap,
            child: SizedBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Container(
                      height: widget.isLandScape ? 100 : 140,
                      width: widget.isLandScape ? 160 : 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: shadowColor.withOpacity(shadowOpacity),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CachedImage(
                              imageUrl: widget.isLandScape
                                  ? widget.movie.thumbUrl2 ?? ''
                                  : widget.movie.thumbUrl ?? '',
                              fit: widget.isLandScape
                                  ? BoxFit.fill
                                  : BoxFit.cover,
                            ),
                            _buildBottomGradient(),
                            _buildPlayButton(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildMovieTitle(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomGradient() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 30,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.25)],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayButton() {
    return Positioned(
      bottom: 4,
      right: 4,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 0.5),
        ),
        child: Image.asset("assets/images/play.png", height: 20),
      ),
    );
  }

  Widget _buildMovieTitle() {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: 24,
        maxWidth: widget.isLandScape ? 100 : 90,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Text(
          widget.movie.movieName ?? 'Unknown',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 10,
            height: 1.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
