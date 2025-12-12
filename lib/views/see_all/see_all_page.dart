import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../models/categories_model.dart';
import '../../models/movies_model.dart';
import '../../widgets/movie_card.dart';

class SeeAllPage extends StatefulWidget {
  const SeeAllPage({super.key});

  @override
  State<SeeAllPage> createState() => _SeeAllPageState();
}

class _SeeAllPageState extends State<SeeAllPage> {
  final HomeController controller = Get.find<HomeController>();
  final ScrollController _scrollController = ScrollController();

  final List<Movie> _movies = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMoreData = true;
  CategoryModel? _category;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeData() {
    _category = Get.arguments as CategoryModel?;

    if (_category != null && _category!.categoryId != null) {
      _loadMoreMovies();
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 400 &&
        !_isLoading &&
        _hasMoreData) {
      _loadMoreMovies();
    }
  }

  Future<void> _loadMoreMovies() async {
    if (_isLoading || !_hasMoreData || _category?.categoryId == null) return;

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final moviesModel = await controller.fetchMoviesByCategoryWithPage(
        _category!.categoryId!,
        _currentPage,
      );

      if (moviesModel.success == true && moviesModel.data != null) {
        // Create mutable copy and sort by latest first
        final newMovies = List<Movie>.from(moviesModel.data!);

        newMovies.sort((a, b) {
          final aDate = a.createdAt != null
              ? DateTime.tryParse(a.createdAt!) ?? DateTime(1970)
              : DateTime(1970);
          final bDate = b.createdAt != null
              ? DateTime.tryParse(b.createdAt!) ?? DateTime(1970)
              : DateTime(1970);
          return bDate.compareTo(aDate);
        });

        if (mounted) {
          setState(() {
            _movies.addAll(newMovies);
            _currentPage++;
            _hasMoreData = moviesModel.pagination?.hasNextPage ?? false;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _hasMoreData = false;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load movies: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 900
        ? 5
        : screenWidth > 600
        ? 4
        : 3;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          child: Column(
            children: [
              Container(
                height: 50, // Smaller height
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurface
                      : AppColors.lightSurface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      onPressed: () => Get.back(),
                    ),
                    Text(
                      _category?.name ?? 'Movies',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              // Grid with Pagination
              Expanded(
                child: _movies.isEmpty && _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _movies.isEmpty
                    ? const Center(child: Text('No movies found'))
                    : GridView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 14,
                        ),
                        itemCount: _movies.length + (_hasMoreData ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _movies.length) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          final movie = _movies[index];
                          return MovieCard(
                            onTap: () {},
                            movie: movie,

                            index: 0, // Pass 0 to disable staggered animation
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
