import 'package:get/get.dart';

class ProfileController extends GetxController {
  final Rx<Map<String, dynamic>> userProfile = Rx<Map<String, dynamic>>({});
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
  }

  void loadUserProfile() {
    // Simulated user data - Replace with API calls
    userProfile.value = {
      'username': 'MovieLover2024',
      'email': 'movielover@example.com',
      'avatar': 'https://via.placeholder.com/200x200/FF0080/FFFFFF?text=ML',
      'memberSince': '2023',
      'watchedMovies': 234,
      'favoriteGenre': 'Sci-Fi',
    };

    isLoading.value = false;
  }

  void updateNotificationSettings(bool enabled) {
    // Implement notification settings
    print('Notifications: $enabled');
  }

  void updateDownloadQuality(String quality) {
    // Implement download quality settings
    print('Download quality: $quality');
  }

  void logout() {
    // Implement logout logic
    print('Logging out...');
    Get.offAllNamed('/login');
  }

  void openHelpCenter() {
    // Navigate to help center
    print('Opening help center...');
  }

  void openPrivacySettings() {
    // Navigate to privacy settings
    print('Opening privacy settings...');
  }
}
