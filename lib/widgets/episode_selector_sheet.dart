// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../models/movies_model.dart';
// import '../views/video_player/video_player_page.dart';
// import '../core/theme/app_colors.dart';
// import '../services/watch_history_service.dart';

// class EpisodeSelector extends StatefulWidget {
//   final Movie movie;

//   const EpisodeSelector({super.key, required this.movie});

//   @override
//   State<EpisodeSelector> createState() => _EpisodeSelectorState();
// }

// class _EpisodeSelectorState extends State<EpisodeSelector> {
//   int _selectedSeasonIndex = 0;
//   Map<String, dynamic>? _watchHistory;
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadWatchHistory();
//   }

//   Future<void> _loadWatchHistory() async {
//     final history = await WatchHistoryService.getWatchProgress(
//       widget.movie.id ?? '',
//     );

//     setState(() {
//       _watchHistory = history;
//       _isLoading = false;

//       // Auto-select the season user was watching
//       if (history != null && history['seasonIndex'] != null) {
//         _selectedSeasonIndex = history['seasonIndex'];
//       }
//     });
//   }

//   Future<void> _continueWatching() async {
//     if (_watchHistory == null) return;

//     Navigator.pop(context);
//     Get.to(
//       () => VideoPlayerPage(
//         videoUrl: _watchHistory!['videoUrl'],
//         movie: widget.movie,
//         seasonIndex: _watchHistory!['seasonIndex'],
//         episodeIndex: _watchHistory!['episodeIndex'],
//         startPosition: Duration(
//           seconds: _watchHistory!['positionSeconds'] ?? 0,
//         ),
//       ),
//     );
//   }

//   void _playEpisode(Episode episode, int seasonIndex, int episodeIndex) {
//     Navigator.pop(context);
//     Get.to(
//       () => VideoPlayerPage(
//         videoUrl: episode.videoUrl ?? '',
//         movie: widget.movie,
//         seasonIndex: seasonIndex,
//         episodeIndex: episodeIndex,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final screenHeight = MediaQuery.of(context).size.height;
//     final screenWidth = MediaQuery.of(context).size.width;

//     if (_isLoading) {
//       return Container(
//         height: screenHeight * 0.3,
//         decoration: BoxDecoration(
//           color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
//           borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         child: const Center(child: CircularProgressIndicator()),
//       );
//     }

//     return Container(
//       height: screenHeight * 0.8,
//       decoration: BoxDecoration(
//         color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
//         borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       child: Column(
//         children: [
//           _buildHeader(context, isDark),

//           // Continue Watching Button
//           if (_watchHistory != null) _buildContinueWatchingButton(isDark),

//           _buildSeasonSelector(isDark),

//           Expanded(child: _buildEpisodesGrid(isDark, screenWidth)),
//         ],
//       ),
//     );
//   }

//   Widget _buildHeader(BuildContext context, bool isDark) {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
//       decoration: BoxDecoration(
//         border: Border(
//           bottom: BorderSide(
//             color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
//           ),
//         ),
//       ),
//       child: Column(
//         children: [
//           Container(
//             width: 40,
//             height: 4,
//             margin: const EdgeInsets.only(bottom: 16),
//             decoration: BoxDecoration(
//               color: isDark ? Colors.grey[700] : Colors.grey[400],
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),
//           Row(
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       widget.movie.movieName ?? 'Series',
//                       style: Theme.of(context).textTheme.headlineSmall
//                           ?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       '${widget.movie.seasons?.length ?? 0} Seasons',
//                       style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                         color: isDark ? Colors.grey[400] : Colors.grey[600],
//                         fontSize: 12,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               IconButton(
//                 icon: const Icon(Icons.close_rounded),
//                 onPressed: () => Navigator.pop(context),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildContinueWatchingButton(bool isDark) {
//     final episodeName = _watchHistory!['episodeName'] ?? 'Episode';
//     final percentage = WatchHistoryService.getWatchPercentage(
//       _watchHistory!['positionSeconds'] ?? 0,
//       _watchHistory!['durationSeconds'] ?? 1,
//     );

//     return Container(
//       margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: _continueWatching,
//           borderRadius: BorderRadius.circular(12),
//           child: Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               gradient: AppColors.getPrimaryGradient(context),
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: [
//                 BoxShadow(
//                   color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
//                   blurRadius: 8,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.2),
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Icon(
//                     Icons.play_arrow_rounded,
//                     color: Colors.white,
//                     size: 24,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Continue Watching',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 12,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       const SizedBox(height: 2),
//                       Text(
//                         episodeName,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 14,
//                           fontWeight: FontWeight.bold,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       const SizedBox(height: 4),
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(2),
//                         child: LinearProgressIndicator(
//                           value: percentage / 100,
//                           backgroundColor: Colors.white.withOpacity(0.3),
//                           valueColor: const AlwaysStoppedAnimation<Color>(
//                             Colors.white,
//                           ),
//                           minHeight: 3,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 const Icon(
//                   Icons.arrow_forward_ios_rounded,
//                   color: Colors.white,
//                   size: 16,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSeasonSelector(bool isDark) {
//     if (widget.movie.seasons == null || widget.movie.seasons!.isEmpty) {
//       return const SizedBox();
//     }

//     return Container(
//       height: 50,
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//         itemCount: widget.movie.seasons!.length,
//         itemBuilder: (context, index) {
//           final season = widget.movie.seasons![index];
//           final isSelected = _selectedSeasonIndex == index;

//           return Padding(
//             padding: const EdgeInsets.only(right: 8),
//             child: GestureDetector(
//               onTap: () => setState(() => _selectedSeasonIndex = index),
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 20,
//                   vertical: 8,
//                 ),
//                 decoration: BoxDecoration(
//                   gradient: isSelected
//                       ? AppColors.getPrimaryGradient(context)
//                       : null,
//                   color: isSelected
//                       ? null
//                       : (isDark
//                             ? AppColors.darkCardBackground
//                             : Colors.grey[200]),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Center(
//                   child: Text(
//                     season.seasonName ?? 'Season ${season.seasonNo}',
//                     style: TextStyle(
//                       color: isSelected
//                           ? Colors.white
//                           : (isDark ? Colors.white70 : Colors.black87),
//                       fontWeight: isSelected
//                           ? FontWeight.bold
//                           : FontWeight.w600,
//                       fontSize: 13,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildEpisodesGrid(bool isDark, double screenWidth) {
//     if (widget.movie.seasons == null || widget.movie.seasons!.isEmpty) {
//       return Center(
//         child: Text(
//           'No episodes available',
//           style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
//         ),
//       );
//     }

//     final selectedSeason = widget.movie.seasons![_selectedSeasonIndex];
//     final episodes = selectedSeason.episodes ?? [];

//     if (episodes.isEmpty) {
//       return Center(
//         child: Text(
//           'No episodes in this season',
//           style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
//         ),
//       );
//     }

//     // Calculate grid dimensions (6 columns like your reference)
//     final crossAxisCount = 6;
//     final spacing = 8.0;
//     final horizontalPadding = 16.0;
//     final itemWidth =
//         (screenWidth -
//             (horizontalPadding * 2) -
//             (spacing * (crossAxisCount - 1))) /
//         crossAxisCount;

//     return GridView.builder(
//       padding: const EdgeInsets.all(16),
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: crossAxisCount,
//         crossAxisSpacing: spacing,
//         mainAxisSpacing: spacing,
//         childAspectRatio: 1.0,
//       ),
//       itemCount: episodes.length,
//       itemBuilder: (context, index) {
//         final episode = episodes[index];
//         final episodeNo = episode.episodeNo ?? (index + 1);

//         // Check if this is the currently watching episode
//         final isCurrentEpisode =
//             _watchHistory != null &&
//             _watchHistory!['seasonIndex'] == _selectedSeasonIndex &&
//             _watchHistory!['episodeIndex'] == index;

//         return _buildEpisodeGridItem(
//           episodeNo,
//           episode,
//           index,
//           isDark,
//           isCurrentEpisode,
//         );
//       },
//     );
//   }

//   Widget _buildEpisodeGridItem(
//     int episodeNo,
//     Episode episode,
//     int episodeIndex,
//     bool isDark,
//     bool isCurrentEpisode,
//   ) {
//     return GestureDetector(
//       onTap: () => _playEpisode(episode, _selectedSeasonIndex, episodeIndex),
//       child: Container(
//         decoration: BoxDecoration(
//           color: isDark ? AppColors.darkCardBackground : Colors.grey[200],
//           borderRadius: BorderRadius.circular(8),
//           border: isCurrentEpisode
//               ? Border.all(
//                   color: Theme.of(context).colorScheme.primary,
//                   width: 2,
//                 )
//               : null,
//         ),
//         child: Stack(
//           children: [
//             Center(
//               child: Text(
//                 episodeNo.toString().padLeft(2, '0'),
//                 style: TextStyle(
//                   color: isDark ? Colors.white : Colors.black87,
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             if (isCurrentEpisode)
//               Positioned(
//                 top: 4,
//                 right: 4,
//                 child: Container(
//                   padding: const EdgeInsets.all(3),
//                   decoration: BoxDecoration(
//                     gradient: AppColors.getPrimaryGradient(context),
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Icon(
//                     Icons.play_arrow_rounded,
//                     color: Colors.white,
//                     size: 12,
//                   ),
//                 ),
//               ),
//             if (episode.subscription == 1)
//               Positioned(
//                 bottom: 4,
//                 left: 4,
//                 child: Icon(Icons.lock_rounded, color: Colors.amber, size: 12),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
