import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/reels_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/reel_card.dart';

class ReelsPage extends StatelessWidget {
  ReelsPage({Key? key}) : super(key: key);

  final ReelsController controller = Get.put(ReelsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          );
        }

        return PageView.builder(
          scrollDirection: Axis.vertical,
          onPageChanged: controller.onReelChanged,
          itemCount: controller.reels.length,
          itemBuilder: (context, index) {
            final reel = controller.reels[index];
            final reelId = reel['id'] as String;

            return ReelCard(
              reel: reel,
              isLiked: controller.likedReels.contains(reelId),
              isSaved: controller.savedReels.contains(reelId),
              onLike: () => controller.toggleLike(reelId),
              onSave: () => controller.toggleSave(reelId),
              onShare: () => controller.shareReel(reelId),
            );
          },
        );
      }),
    );
  }
}
