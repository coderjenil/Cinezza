import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../core/theme/app_colors.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({Key? key}) : super(key: key);

  final ProfileController controller = Get.put(ProfileController());
  final ThemeController themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppColors.darkBackgroundGradient
              : AppColors.lightBackgroundGradient,
        ),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header
              _buildHeader(context, isDark),

              // Support & Community Section
              _buildSectionHeader(context, 'Support & Community', Icons.support_rounded),

              _buildMenuItem(
                context,
                icon: Icons.movie_creation_rounded,
                iconColor: const Color(0xFF3B82F6),
                title: 'Request a Movie',
                subtitle: "Can't find what you're looking for?",
                onTap: () => _handleRequestMovie(context),
                isDark: isDark,
              ),

              _buildMenuItem(
                context,
                icon: Icons.contact_support_rounded,
                iconColor: const Color(0xFF10B981),
                title: 'Contact Us',
                subtitle: 'Get help and support',
                onTap: () => _handleContactUs(),
                isDark: isDark,
              ),

              _buildMenuItem(
                context,
                icon: Icons.telegram_rounded,
                iconColor: const Color(0xFF0088cc),
                title: 'Join Our Community',
                subtitle: 'Connect with us on Telegram',
                onTap: () => _launchURL('https://t.me/cinemaflix'),
                isDark: isDark,
                showExternalIcon: true,
              ),

              _buildMenuItem(
                context,
                icon: Icons.camera_alt_rounded,
                iconColor: const Color(0xFFE1306C),
                title: 'Follow us on Instagram',
                subtitle: '@CinemaFlix_App',
                onTap: () => _launchURL('https://instagram.com/cinemaflix_app'),
                isDark: isDark,
                showExternalIcon: true,
              ),

              _buildMenuItem(
                context,
                icon: Icons.facebook_rounded,
                iconColor: const Color(0xFF1877F2),
                title: 'Follow us on Facebook',
                subtitle: '@CinemaFlix_App',
                onTap: () => _launchURL('https://facebook.com/cinemaflix'),
                isDark: isDark,
                showExternalIcon: true,
              ),

              _buildMenuItem(
                context,
                icon: Icons.privacy_tip_rounded,
                iconColor: const Color(0xFF8B5CF6),
                title: 'Privacy Policy',
                subtitle: 'Data & security',
                onTap: () => _handlePrivacyPolicy(context),
                isDark: isDark,
              ),

              // App Info Section
              _buildSectionHeader(context, 'App Info', Icons.info_rounded),

              _buildMenuItem(
                context,
                icon: Icons.share_rounded,
                iconColor: const Color(0xFF06B6D4),
                title: 'Share App',
                subtitle: 'Tell your friends about CinemaFlix',
                onTap: () => _handleShareApp(),
                isDark: isDark,
              ),

              _buildMenuItem(
                context,
                icon: Icons.copyright_rounded,
                iconColor: const Color(0xFF64748B),
                title: 'Copyright',
                subtitle: '©2025 CinemaFlix',
                onTap: () => _showCopyrightDialog(context),
                isDark: isDark,
              ),

              _buildMenuItem(
                context,
                icon: Icons.info_outline_rounded,
                iconColor: const Color(0xFF3B82F6),
                title: 'App Version',
                subtitle: 'V1.0.2',
                onTap: () => _showVersionDialog(context),
                isDark: isDark,
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: AppColors.getPrimaryGradient(context),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Latest',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              // Theme Toggle
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCardBackground : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.black.withOpacity(0.05),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: AppColors.getPrimaryGradient(context),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            themeController.isDarkMode.value
                                ? Icons.dark_mode_rounded
                                : Icons.light_mode_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dark Mode',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                themeController.isDarkMode.value ? 'Enabled' : 'Disabled',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Obx(() => Switch(
                          value: themeController.isDarkMode.value,
                          onChanged: (value) => themeController.toggleTheme(),
                          activeColor: Theme.of(context).colorScheme.primary,
                        )),
                      ],
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return SliverAppBar(
      floating: true,
      snap: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      toolbarHeight: 60,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [AppColors.darkBackground, AppColors.darkBackground.withOpacity(0.95)]
                : [AppColors.lightBackground, AppColors.lightBackground.withOpacity(0.95)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColors.getPrimaryGradient(context),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.person_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profile & Settings',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'Manage your preferences',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
      BuildContext context, {
        required IconData icon,
        required Color iconColor,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
        required bool isDark,
        bool showExternalIcon = false,
        Widget? trailing,
      }) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCardBackground : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.05),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  trailing ??
                      Icon(
                        showExternalIcon ? Icons.open_in_new_rounded : Icons.chevron_right_rounded,
                        color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
                        size: showExternalIcon ? 18 : 24,
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleRequestMovie(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildRequestMovieSheet(context),
    );
  }

  Widget _buildRequestMovieSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final TextEditingController movieController = TextEditingController();

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: AppColors.getPrimaryGradient(context),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.movie_creation_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Request a Movie',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: movieController,
              decoration: InputDecoration(
                hintText: 'Enter movie name...',
                filled: true,
                fillColor: isDark ? AppColors.darkCardBackground : AppColors.lightBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (movieController.text.isNotEmpty) {
                    Get.back();
                    Get.snackbar(
                      'Request Sent',
                      'We will notify you when ${movieController.text} is available',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: AppColors.success,
                      colorText: Colors.white,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                child: const Text(
                  'Submit Request',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleContactUs() {
    _launchURL('https://wa.me/1234567890');
  }

  void _handlePrivacyPolicy(BuildContext context) {
    Get.snackbar(
      'Privacy Policy',
      'Opening privacy policy...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _handleShareApp() {
    Share.share('Check out CinemaFlix - The best movie streaming app!\n\nDownload now: https://cinemaflix.com');
  }

  void _showCopyrightDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Copyright Information'),
        content: const Text('©2025 CinemaFlix. All rights reserved.\n\nThis app and its content are protected by copyright law.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showVersionDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('App Version'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Version: 1.0.2'),
            const SizedBox(height: 8),
            const Text('Build: 102'),
            const SizedBox(height: 8),
            const Text('Release Date: November 2025'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'Error',
        'Could not open link',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }
}
