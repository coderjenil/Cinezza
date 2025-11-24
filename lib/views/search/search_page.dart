import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/search_controller.dart' as app_search;
import '../../core/theme/app_colors.dart';
import '../../widgets/movie_card.dart';

class SearchPage extends StatelessWidget {
  SearchPage({Key? key}) : super(key: key);

  final app_search.SearchController controller = Get.put(app_search.SearchController());
  final TextEditingController textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 900 ? 5 : screenWidth > 600 ? 4 : 3;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppColors.darkBackgroundGradient : AppColors.lightBackgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Search Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_rounded, color: Theme.of(context).iconTheme.color),
                      onPressed: () => Get.back(),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCardBackground : AppColors.lightBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: textController,
                          autofocus: true,
                          onChanged: controller.onSearchChanged,
                          style: Theme.of(context).textTheme.bodyLarge,
                          decoration: InputDecoration(
                            hintText: 'Search movies...',
                            hintStyle: Theme.of(context).textTheme.bodyMedium,
                            border: InputBorder.none,
                            icon: Icon(Icons.search_rounded, color: Theme.of(context).colorScheme.primary),
                            suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                                ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                textController.clear();
                                controller.onSearchChanged('');
                              },
                            )
                                : const SizedBox.shrink()),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Results
              Expanded(
                child: Obx(() {
                  if (controller.searchQuery.value.isEmpty) {
                    return _buildEmptyState(context, 'Start searching for movies', Icons.search_rounded);
                  }

                  if (controller.isSearching.value) {
                    return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary));
                  }

                  if (controller.searchResults.isEmpty) {
                    return _buildEmptyState(context, 'No results found', Icons.search_off_rounded);
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: 0.65,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 14,
                    ),
                    itemCount: controller.searchResults.length,
                    itemBuilder: (context, index) {
                      return MovieCard(movie: controller.searchResults[index], onTap: () {}, index: index);
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.getPrimaryGradient(context),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(message, style: Theme.of(context).textTheme.headlineSmall),
        ],
      ),
    );
  }
}
