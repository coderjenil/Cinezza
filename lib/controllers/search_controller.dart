import 'package:get/get.dart';

class SearchController extends GetxController {
  final RxString searchQuery = ''.obs;
  final RxList<Map<String, dynamic>> searchResults = <Map<String, dynamic>>[].obs;
  final RxBool isSearching = false.obs;
  final RxList<String> recentSearches = <String>[].obs;

  void onSearchChanged(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      searchResults.clear();
      isSearching.value = false;
    } else {
      performSearch(query);
    }
  }

  void performSearch(String query) {
    isSearching.value = true;

    // Simulated search - Replace with actual API call
    Future.delayed(const Duration(milliseconds: 500), () {
      searchResults.value = List.generate(
        15,
            (index) => {
          'id': 'search_$index',
          'title': '$query Result ${index + 1}',
          'poster': 'https://via.placeholder.com/300x450/1A1F3A/00F0FF?text=Result+${index + 1}',
          'rating': 7.0 + (index % 3) * 0.5,
          'year': 2024,
        },
      );
      isSearching.value = false;
    });
  }

  void addToRecentSearches(String query) {
    if (!recentSearches.contains(query)) {
      recentSearches.insert(0, query);
      if (recentSearches.length > 10) {
        recentSearches.removeLast();
      }
    }
  }

  void clearRecentSearches() {
    recentSearches.clear();
  }
}
