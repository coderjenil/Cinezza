import 'package:get/get.dart';
import '../../views/main_navigation.dart';
import '../../views/search/search_page.dart';
import '../../views/see_all/see_all_page.dart';
import '../../views/video_player/video_player_page.dart';

class AppRoutes {
  static const String mainNavigation = '/';
  static const String search = '/search';
  static const String seeAll = '/see-all';
  static const String videoPlayer = '/video-player';

  static List<GetPage> routes = [
    GetPage(
      name: mainNavigation,
      page: () => MainNavigation(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: search,
      page: () => SearchPage(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: seeAll,
      page: () => SeeAllPage(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.videoPlayer,
      page: () =>  VideoPlayerPage(),
    )
  ];
}
