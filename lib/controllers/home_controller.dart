import 'package:get/get.dart';
import '../core/constants/movie_images.dart';

class HomeController extends GetxController {
  final RxList<Map<String, dynamic>> featuredMovies = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> latestMovies = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> trendingMovies = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> upcomingMovies = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> recommendedMovies = <Map<String, dynamic>>[].obs;
  final RxInt currentCarouselIndex = 0.obs;
  final RxBool isLoading = true.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadMovies();
  }

  void loadMovies() {
    // Using real TMDB movie images
    featuredMovies.value = MovieImages.featuredMovies;
    latestMovies.value = MovieImages.latestMovies;
    trendingMovies.value = MovieImages.trendingMovies;
    upcomingMovies.value = MovieImages.upcomingMovies;
    recommendedMovies.value = MovieImages.recommendedMovies;

    isLoading.value = false;
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    // Implement search logic here
  }

  void onMovieTapped(Map<String, dynamic> movie) {
    // Navigate to movie detail page
    print('Movie tapped: ${movie['title']}');
  }
}
