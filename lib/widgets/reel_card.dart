import 'package:flutter/material.dart';

class ReelCard extends StatelessWidget {
  final Map<String, dynamic> reel;
  final bool isLiked;
  final bool isSaved;
  final VoidCallback onLike;
  final VoidCallback onSave;
  final VoidCallback onShare;

  const ReelCard({
    Key? key,
    required this.reel,
    required this.isLiked,
    required this.isSaved,
    required this.onLike,
    required this.onSave,
    required this.onShare,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Video/Thumbnail Background
        Image.network(
          reel['thumbnail'] ?? '',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.black,
            child: const Icon(
              Icons.video_library,
              size: 80,
              color: Colors.grey,
            ),
          ),
        ),

        // Gradient Overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
              stops: const [0.5, 1.0],
            ),
          ),
        ),

        // Right Side Actions
        Positioned(
          right: 16,
          bottom: 100,
          child: Column(
            children: [
              _buildActionButton(
                context,
                icon: isLiked ? Icons.favorite : Icons.favorite_border,
                label: _formatCount(reel['likes'] ?? 0),
                onTap: onLike,
                isActive: isLiked,
                isDark: isDark,
                primaryColor: primaryColor,
              ),
              const SizedBox(height: 24),
              _buildActionButton(
                context,
                icon: Icons.comment_rounded,
                label: '${reel['comments'] ?? 234}',
                onTap: () {},
                isDark: isDark,
                primaryColor: primaryColor,
              ),
              const SizedBox(height: 24),
              _buildActionButton(
                context,
                icon: isSaved ? Icons.bookmark : Icons.bookmark_border,
                label: 'Save',
                onTap: onSave,
                isActive: isSaved,
                isDark: isDark,
                primaryColor: primaryColor,
              ),
              const SizedBox(height: 24),
              _buildActionButton(
                context,
                icon: Icons.share_rounded,
                label: 'Share',
                onTap: onShare,
                isDark: isDark,
                primaryColor: primaryColor,
              ),
            ],
          ),
        ),

        // Bottom Content Info
        Positioned(
          left: 16,
          right: 80,
          bottom: 40,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Info
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: primaryColor, width: 2),
                      image: DecorationImage(
                        image: NetworkImage(reel['userAvatar'] ?? ''),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reel['username'] ?? 'User',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${_formatCount(reel['views'] ?? 0)} views',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: isDark
                          ? const LinearGradient(colors: [Color(0xFFFF0080), Color(0xFFFF8C00)])
                          : const LinearGradient(colors: [Color(0xFFE91E63), Color(0xFFFF6090)]),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Follow',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Reel Title
              Text(
                reel['title'] ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
      BuildContext context, {
        required IconData icon,
        required String label,
        required VoidCallback onTap,
        bool isActive = false,
        required bool isDark,
        required Color primaryColor,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: isActive
                  ? (isDark
                  ? const LinearGradient(colors: [Color(0xFFFF0080), Color(0xFFFF8C00)])
                  : const LinearGradient(colors: [Color(0xFFE91E63), Color(0xFFFF6090)]))
                  : null,
              color: isActive ? null : Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive ? Colors.transparent : Colors.white.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: isActive
                  ? [
                BoxShadow(
                  color: primaryColor.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ]
                  : null,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}
