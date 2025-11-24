import 'package:get/get.dart';

class ReelsController extends GetxController {
  final RxList<Map<String, dynamic>> reels = <Map<String, dynamic>>[].obs;
  final RxInt currentReelIndex = 0.obs;
  final RxBool isLoading = true.obs;
  final RxSet<String> likedReels = <String>{}.obs;
  final RxSet<String> savedReels = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadReels();
  }

  void loadReels() {
    // Simulated reels data - Replace with API calls
    reels.value = List.generate(
      15,
          (index) => {
        'id': 'reel_$index',
        'title': 'Epic Movie Moment #${index + 1}',
        'thumbnail': 'https://via.placeholder.com/400x700/0A0E27/00F0FF?text=Reel+${index + 1}',
        'videoUrl': 'https://example.com/reel_$index.mp4',
        'likes': 1000 + (index * 100),
        'views': 10000 + (index * 500),
        'username': 'user_${index % 5}',
        'userAvatar': 'https://via.placeholder.com/100x100/FF0080/FFFFFF?text=U${index % 5}',
      },
    );

    isLoading.value = false;
  }

  void toggleLike(String reelId) {
    if (likedReels.contains(reelId)) {
      likedReels.remove(reelId);
    } else {
      likedReels.add(reelId);
    }
  }

  void toggleSave(String reelId) {
    if (savedReels.contains(reelId)) {
      savedReels.remove(reelId);
    } else {
      savedReels.add(reelId);
    }
  }

  void shareReel(String reelId) {
    // Implement share functionality
    print('Sharing reel: $reelId');
  }

  void onReelChanged(int index) {
    currentReelIndex.value = index;
  }
}
