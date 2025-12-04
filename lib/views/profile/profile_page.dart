import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/splash_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../utils/dialogs/copy_right_dialog.dart';
import '../../utils/dialogs/request_movie_dialog.dart';
import '../premium/premium_plan_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ThemeController themeController = Get.find<ThemeController>();

  final SplashController splashController = Get.find<SplashController>();
  String version = 'Loading...';

  @override
  initState() {
    super.initState();
    _loadAppVersion();
  }

  _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
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
              _buildHeader(context, isDark),

              // ⭐ NEW Premium Status Card (AFTER theme switch)
              _buildSubscriptionCard(context),

              // 🔥 Theme Toggle
              _buildThemeToggle(context, isDark),

              // Section 1
              _buildSectionHeader(
                context,
                'Support & Community',
                Icons.support_rounded,
              ),

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
                onTap: () async {
                  await _handleContactUs();
                },
                isDark: isDark,
              ),

              _buildMenuItem(
                context,
                icon: Icons.telegram_rounded,
                iconColor: const Color(0xFF0088cc),
                title: 'Join Our Community',
                subtitle: 'Connect with us on Telegram',
                onTap: () => _launchURL(
                  splashController
                          .remoteConfigModel
                          .value
                          ?.config
                          .telegramUrl ??
                      'https://t.me/',
                ),
                isDark: isDark,
                showExternalIcon: true,
              ),

              _buildMenuItem(
                context,
                icon: Icons.camera_alt_rounded,
                iconColor: const Color(0xFFE1306C),
                title: 'Follow us on Instagram',
                subtitle: '@CinemaFlix_App',
                onTap: () => _launchURL(
                  splashController
                          .remoteConfigModel
                          .value
                          ?.config
                          .instagramUrl ??
                      'https://instagram.com/',
                ),
                isDark: isDark,
                showExternalIcon: true,
              ),

              _buildMenuItem(
                context,
                icon: Icons.facebook_rounded,
                iconColor: const Color(0xFF1877F2),
                title: 'Follow us on Facebook',
                subtitle: '@CinemaFlix_App',
                onTap: () => _launchURL(
                  splashController
                          .remoteConfigModel
                          .value
                          ?.config
                          .facebookUrl ??
                      'https://facebook.com/',
                ),
                isDark: isDark,
                showExternalIcon: true,
              ),

              _buildMenuItem(
                context,
                icon: Icons.privacy_tip_rounded,
                iconColor: const Color(0xFF8B5CF6),
                title: 'Privacy Policy',
                subtitle: 'Data & security',
                onTap: () => _launchURL(
                  splashController
                          .remoteConfigModel
                          .value
                          ?.config
                          .privacyPolicyUrl ??
                      "https://www.google.com",
                ),
                isDark: isDark,
              ),

              // Section 2
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
                onTap: () => {showCopyrightDialog(context)},
                isDark: isDark,
              ),

              _buildMenuItem(
                context,
                icon: Icons.info_outline_rounded,
                iconColor: const Color(0xFF3B82F6),
                title: 'App Version',
                subtitle: 'V$version',
                onTap: () => _showVersionDialog(context),
                isDark: isDark,
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 60)),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------- PREMIUM CARD -------------------- //
  Widget _buildSubscriptionCard(BuildContext context) {
    final splash = Get.find<SplashController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bool isPremium = splash.userModel.value?.user.planActive ?? false;
    int trialLeft = splash.userModel.value?.user.trialCount ?? 0;
    final String? expiryRaw = splash.userModel.value?.user.planExpiryDate;

    String expiryText = "";
    if (isPremium && expiryRaw != null) {
      final expiryDate = DateTime.tryParse(expiryRaw);
      if (expiryDate != null) {
        final daysLeft = expiryDate.difference(DateTime.now()).inDays;
        expiryText = daysLeft > 0
            ? "Expires in $daysLeft days"
            : "Expires today";
      }
    }

    return SliverToBoxAdapter(
      child: Obx(() {
        trialLeft = splash.userModel.value?.user.trialCount ?? 0;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: isPremium
                  ? const LinearGradient(
                      colors: [Color(0xFFFFD57E), Color(0xFFC89D0A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              border: Border.all(
                color: isPremium
                    ? Colors.amber.withOpacity(0.6)
                    : Colors.grey.withOpacity(0.15),
              ),
              color: isPremium
                  ? null
                  : (isDark ? AppColors.darkCardBackground : Colors.white),
              boxShadow: isPremium
                  ? [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.4),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              children: [
                Icon(
                  isPremium
                      ? Icons.workspace_premium_rounded
                      : Icons.lock_open_rounded,
                  color: isPremium ? Colors.black : Colors.grey,
                  size: 28,
                ),
                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isPremium ? "Premium Active" : "Free Trial Account",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: isPremium
                              ? Colors.black
                              : isDark
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isPremium
                            ? expiryText
                            : "Trial remaining: $trialLeft plays",
                        style: TextStyle(
                          fontSize: 12,
                          color: isPremium
                              ? Colors.black.withOpacity(0.7)
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                // Button
                ElevatedButton(
                  onPressed: () => Get.to(() => PremiumPlansPage()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPremium
                        ? Colors.black
                        : Get.theme.primaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    isPremium ? "Manage" : "Upgrade",
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // -------------------- REUSABLES BELOW --------------------
  Widget _buildThemeToggle(BuildContext context, bool isDark) {
    return SliverToBoxAdapter(
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
                    Obx(
                      () => Text(
                        themeController.isDarkMode.value
                            ? 'Enabled'
                            : 'Disabled',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
              Obx(
                () => Switch(
                  value: themeController.isDarkMode.value,
                  onChanged: (value) => themeController.toggleTheme(),
                  activeThumbColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -----------------------------------------
  Widget _buildHeader(BuildContext context, bool isDark) {
    /* unchanged */
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
                ? [
                    AppColors.darkBackground,
                    AppColors.darkBackground.withOpacity(0.95),
                  ]
                : [
                    AppColors.lightBackground,
                    AppColors.lightBackground.withOpacity(0.95),
                  ],
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
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profile & Settings',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    Text(
                      'Manage your preferences',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.color?.withOpacity(0.6),
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

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    /* unchanged */
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
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
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
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
                        showExternalIcon
                            ? Icons.open_in_new_rounded
                            : Icons.chevron_right_rounded,
                        color: Theme.of(
                          context,
                        ).iconTheme.color?.withOpacity(0.5),
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ------------------- Utilities -------------------
  void _handleRequestMovie(BuildContext context) {
    showRequestMovieDialog(context);
  }

  _handleContactUs() async {
    final splash = Get.find<SplashController>();

    // Safely read user id
    final userId = splash.userModel.value?.user.userId;

    // Default message if id is null or does not contain "_"
    String message = "";

    if (userId != null && userId.contains("_")) {
      final parts = userId.split("_");
      if (parts.length > 1) {
        message = parts[1];
      }
    }

    final phone = splash.remoteConfigModel.value?.config.contactUs ?? "";

    final Uri whatsappUrl = Uri.parse(
      "https://wa.me/$phone?text=${Uri.encodeComponent(message)}",
    );

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(
        whatsappUrl,
        mode: LaunchMode.externalApplication, // <-- required on Android 12+
      );
    } else {
      throw 'Could not launch WhatsApp';
    }
  }

  void _handleShareApp() =>
      Share.share("Download CinemaFlix: Best movie streaming app!");

  void _showVersionDialog(BuildContext context) {}

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
