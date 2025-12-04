import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/search_controller.dart' as app_search;
import '../../core/theme/app_colors.dart';
import '../../widgets/movie_card.dart';

class SearchPage extends StatelessWidget {
  SearchPage({super.key});

  final app_search.SearchController controller = Get.put(
    app_search.SearchController(),
  );
  final TextEditingController textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: _buildAppBar(context, isDark),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppColors.darkBackgroundGradient
              : AppColors.lightBackgroundGradient,
        ),
        child: Obx(() => _buildBody(context)),
      ),
    );
  }

  /// Build AppBar with search input
  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark) {
    return AppBar(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_rounded,
          color: Theme.of(context).iconTheme.color,
        ),
        onPressed: () => Get.back(),
      ),
      title: Container(
        height: 45,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkCardBackground
              : AppColors.lightBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: TextField(
          controller: textController,
          autofocus: true,
          onChanged: controller.onSearchChanged,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: 'Search movies, shows...',
            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withOpacity(0.5),
            ),
            border: InputBorder.none,
            icon: Icon(
              Icons.search_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 22,
            ),
            suffixIcon: Obx(
              () => controller.searchQuery.value.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear_rounded,
                        size: 20,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      onPressed: () {
                        textController.clear();
                        controller.onSearchChanged('');
                      },
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }

  /// Build main body content based on state
  Widget _buildBody(BuildContext context) {
    // Empty state - show recent searches
    if (controller.searchQuery.value.isEmpty) {
      return _buildRecentSearches(context);
    }

    // Loading state
    if (controller.isSearching.value) {
      return _buildLoadingState(context);
    }

    // Error state
    if (controller.errorMessage.value.isNotEmpty &&
        controller.searchResults.isEmpty) {
      return _buildEmptyState(
        context,
        controller.errorMessage.value,
        Icons.search_off_rounded,
      );
    }

    // Results state
    if (controller.searchResults.isNotEmpty) {
      return _buildSearchResults(context);
    }

    // No results state
    return _buildEmptyState(
      context,
      'No results found',
      Icons.search_off_rounded,
    );
  }

  /// Build recent searches list
  Widget _buildRecentSearches(BuildContext context) {
    if (controller.recentSearches.isEmpty) {
      return _buildEmptyState(
        context,
        'Start searching for movies',
        Icons.search_rounded,
        subtitle: 'Search for your favorite movies and shows',
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Searches',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: controller.clearRecentSearches,
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              label: const Text('Clear All'),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...controller.recentSearches.map((query) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(
                Icons.history_rounded,
                color: Theme.of(context).iconTheme.color?.withOpacity(0.6),
              ),
              title: Text(query, style: Theme.of(context).textTheme.bodyLarge),
              trailing: IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  size: 20,
                  color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
                ),
                onPressed: () => controller.removeRecentSearch(query),
              ),
              onTap: () => controller.searchFromRecent(query, textController),
            ),
          );
        }),
      ],
    );
  }

  /// Build loading state
  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Searching...',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(
                context,
              ).textTheme.bodyLarge?.color?.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  /// Build search results grid
  Widget _buildSearchResults(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 900
        ? 5
        : screenWidth > 600
        ? 4
        : 3;
    final cardWidth =
        (screenWidth - (20 * 2) - (10 * (crossAxisCount - 1))) / crossAxisCount;

    return Column(
      children: [
        // Result count header
        if (controller.totalResults.value > 0)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Text(
              controller.getResultCountText(),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(
                  context,
                ).textTheme.titleSmall?.color?.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        // Results grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            physics: const BouncingScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 2 / 3.3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 14,
            ),
            itemCount: controller.searchResults.length,
            itemBuilder: (context, index) {
              final movie = controller.searchResults[index];
              return MovieCard(movie: movie, index: 0, width: cardWidth);
            },
          ),
        ),
      ],
    );
  }

  /// Build empty state widget
  Widget _buildEmptyState(
    BuildContext context,
    String message,
    IconData icon, {
    String? subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.getPrimaryGradient(context),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(icon, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
