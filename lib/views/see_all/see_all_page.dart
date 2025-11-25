import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/animated_grid_card.dart';

class SeeAllPage extends StatelessWidget {
  const SeeAllPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>;
    final String title = args['title'] ?? 'Movies';
    final List<Map<String, dynamic>> movies = args['movies'] ?? [];
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 900 ? 5 : screenWidth > 600 ? 4 : 3;
    final cardWidth = (screenWidth - (20 * 2) - (10 * (crossAxisCount - 1))) / crossAxisCount;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: Theme.of(context).iconTheme.color),
          onPressed: () => Get.back(),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: AppColors.getPrimaryGradient(context),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${movies.length} Movies',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppColors.darkBackgroundGradient
              : AppColors.lightBackgroundGradient,
        ),
        child: GridView.builder(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 2 / 3.3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 14,
          ),
          itemCount: movies.length,
          itemBuilder: (context, index) {
            return AnimatedGridCard(
              movie: movies[index],
              index: index,
              cardWidth: cardWidth,
              onTap: () {},
            );
          },
        ),
      ),
    );
  }
}
