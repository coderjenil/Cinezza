import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../api/apsl_api_call.dart';
import '../core/constants/api_end_points.dart';
import '../models/categories_model.dart';
import '../models/movies_model.dart';

class HomeController extends GetxController {
  // Category lists with proper typing
  final RxList<CategoryModel> adultCategories = <CategoryModel>[].obs;
  final RxList<CategoryModel> allCategories = <CategoryModel>[].obs;
  final RxList<CategoryModel> nonAdultCategories = <CategoryModel>[].obs;
  CategoryModel trendingCategory = CategoryModel();
  MoviesModel moviesModel = MoviesModel();

  final RxInt currentCarouselIndex = 0.obs;
  final RxBool isLoading = true.obs;
  final RxString searchQuery = ''.obs;

  RxBool isCategoryFetching = false.obs;

  Future<void> fetchAllCategories() async {
    try {
      var res = await ApiCall.callService(
        requestInfo: APIRequestInfoObj(
          requestType: HTTPRequestType.get,
          headers: ApiHeaders.getHeaders(),
          url: ApiEndPoints.getAllCategories,
        ),
      );

      debugPrint(res.toString());

      // Parse response using model
      final categoriesModel = categoriesModelFromJson(res.body);

      if (categoriesModel.success == true && categoriesModel.data != null) {
        allCategories.value = categoriesModel.data ?? [];

        trendingCategory =
            allCategories.firstWhereOrNull(
              (cat) => cat.name?.toLowerCase() == 'trending',
            ) ??
            CategoryModel();

        debugPrint('Trending Category: ${trendingCategory.name}');
        // Filter adult categories
        final adult = categoriesModel.data!
            .where((cat) => cat.isAdult == true)
            .toList();

        // Filter non-adult categories
        final nonAdult = categoriesModel.data!
            .where((cat) => cat.isAdult == false)
            .toList();

        // Sort by index
        adult.sort((a, b) => (a.index ?? 0).compareTo(b.index ?? 0));
        nonAdult.sort((a, b) => (a.index ?? 0).compareTo(b.index ?? 0));

        // Assign to observable lists
        adultCategories.value = adult;
        nonAdultCategories.value = nonAdult;

        debugPrint('Adult Categories: ${adultCategories.length}');
        debugPrint('Non-Adult Categories: ${nonAdultCategories.length}');

        // Print category names for verification
        debugPrint('Adult: ${adult.map((c) => c.name).toList()}');
        debugPrint('Non-Adult: ${nonAdult.map((c) => c.name).toList()}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<MoviesModel> fetchMoviesByCategory({
    required String categoryId,
    int limit = 10,
  }) async {
    final res = await ApiCall.callService(
      requestInfo: APIRequestInfoObj(
        requestType: HTTPRequestType.get,
        headers: ApiHeaders.getHeaders(),
        url:
            "${ApiEndPoints.getMoviesByCategory}$categoryId?page=1&limit=$limit",
      ),
    );
    return moviesModelFromJson(res.body);
  }

  Future<MoviesModel> fetchMoviesByCategoryWithPage(
    String categoryId,
    int page,
  ) async {
    final res = await ApiCall.callService(
      requestInfo: APIRequestInfoObj(
        requestType: HTTPRequestType.get,
        headers: ApiHeaders.getHeaders(),
        url:
            "${ApiEndPoints.getMoviesByCategory}$categoryId?page=$page&limit=20",
      ),
    );
    return moviesModelFromJson(res.body);
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    // Implement search logic here
  }

  void onMovieTapped(Map<String, dynamic> movie) {}
}
