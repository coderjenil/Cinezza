import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../api/apsl_api_call.dart';
import '../core/constants/api_end_points.dart';
import '../models/movies_model.dart';

class SearchController extends GetxController {
  // Observables
  final RxString searchQuery = ''.obs;
  final RxBool isSearching = false.obs;
  final RxList<Movie> searchResults = <Movie>[].obs;
  final RxList<String> recentSearches = <String>[].obs;
  final RxString errorMessage = ''.obs;
  final RxInt totalResults = 0.obs;

  // Worker for debounce
  Worker? _debounceWorker;

  @override
  void onInit() {
    super.onInit();
    _initializeDebounce();
    _loadRecentSearches();
  }

  /// Initialize debounce worker for search query
  /// Only triggers search after user stops typing for 500ms
  void _initializeDebounce() {
    _debounceWorker = debounce(searchQuery, (value) {
      if (value.isNotEmpty) {
        _performSearch(value);
      } else {
        _clearSearchResults();
      }
    }, time: const Duration(milliseconds: 500));
  }

  /// Handle search query changes
  void onSearchChanged(String query) {
    searchQuery.value = query.trim();
    errorMessage.value = '';

    // Clear results immediately if query is empty
    if (query.isEmpty) {
      _clearSearchResults();
    }
  }

  /// Perform the actual search API call
  Future<void> _performSearch(String query) async {
    try {
      isSearching.value = true;
      errorMessage.value = '';

      final response = await ApiCall.callService(
        requestInfo: APIRequestInfoObj(
          requestType: HTTPRequestType.get,
          headers: ApiHeaders.getHeaders(),
          url: '${ApiEndPoints.movieSearch}$query',
        ),
      );

      debugPrint('Search API Response: ${response.toString()}');
      debugPrint('Response Status Code: ${response.statusCode}');

      // Check if response is http.Response
      if (response.statusCode == 200) {
        // Decode JSON from response body
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        _parseAndUpdateResults(jsonData, query);
      } else {
        errorMessage.value = 'Error: ${response.statusCode}';
        searchResults.clear();
        totalResults.value = 0;
      }
    } catch (e) {
      debugPrint('Search error: $e');
      errorMessage.value = 'An error occurred while searching';
      searchResults.clear();
      totalResults.value = 0;
    } finally {
      isSearching.value = false;
    }
  }

  /// Parse API response and update search results
  void _parseAndUpdateResults(dynamic data, String query) {
    try {
      // Parse the complete response using MoviesModel
      final moviesModel = MoviesModel.fromJson(data);

      if (moviesModel.success == true && moviesModel.data != null) {
        searchResults.value = moviesModel.data!;
        totalResults.value = moviesModel.data!.length;

        if (searchResults.isEmpty) {
          errorMessage.value = 'No results found for "$query"';
        } else {
          // Add to recent searches only if results found
          _addToRecentSearches(query);
          errorMessage.value = '';
        }
      } else {
        searchResults.clear();
        totalResults.value = 0;
        errorMessage.value = moviesModel.message ?? 'No results found';
      }
    } catch (e) {
      debugPrint('Parse error: $e');
      searchResults.clear();
      totalResults.value = 0;
      errorMessage.value = 'Failed to parse search results';
    }
  }

  /// Clear search results
  void _clearSearchResults() {
    searchResults.clear();
    isSearching.value = false;
    errorMessage.value = '';
    totalResults.value = 0;
  }

  /// Add query to recent searches (max 10)
  void _addToRecentSearches(String query) {
    if (query.isEmpty) return;

    // Remove if already exists
    recentSearches.remove(query);

    // Add to beginning
    recentSearches.insert(0, query);

    // Keep only last 10
    if (recentSearches.length > 10) {
      recentSearches.removeRange(10, recentSearches.length);
    }

    _saveRecentSearches();
  }

  /// Load recent searches from storage
  Future<void> _loadRecentSearches() async {
    try {
      final storage = GetStorage();
      final saved = storage.read<List>('recent_searches');
      if (saved != null) {
        recentSearches.value = List<String>.from(saved);
      }
    } catch (e) {
      debugPrint('Load recent searches error: $e');
    }
  }

  /// Save recent searches to storage
  Future<void> _saveRecentSearches() async {
    try {
      final storage = GetStorage();
      await storage.write('recent_searches', recentSearches.toList());
    } catch (e) {
      debugPrint('Save recent searches error: $e');
    }
  }

  /// Clear all recent searches
  void clearRecentSearches() {
    recentSearches.clear();
    _saveRecentSearches();
  }

  /// Remove a specific recent search
  void removeRecentSearch(String query) {
    recentSearches.remove(query);
    _saveRecentSearches();
  }

  /// Quick search from recent searches
  void searchFromRecent(String query, TextEditingController textController) {
    textController.text = query;
    searchQuery.value = query;
  }

  /// Get result count text
  String getResultCountText() {
    if (totalResults.value == 0) return '';
    return 'Found ${totalResults.value} result${totalResults.value > 1 ? 's' : ''}';
  }

  @override
  void onClose() {
    _debounceWorker?.dispose();
    super.onClose();
  }
}
