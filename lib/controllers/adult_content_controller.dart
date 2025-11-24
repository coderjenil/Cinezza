import 'package:get/get.dart';

class AdultContentController extends GetxController {
  final RxList<Map<String, dynamic>> adultSeries = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> adultMovies = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> popularAdult = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> newReleases = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool ageVerified = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAdultContent();
  }

  void loadAdultContent() {
    // Adult Series
    adultSeries.value = [
      {
        'id': 'adult_series_1',
        'title': 'Bridgerton',
        'poster': 'https://image.tmdb.org/t/p/w500/luoKpgVwi1E5nQsi7W0UuKHu2Rq.jpg',
        'rating': 8.2,
        'year': 2024,
        'type': 'Series',
      },
      {
        'id': 'adult_series_2',
        'title': 'Euphoria',
        'poster': 'https://image.tmdb.org/t/p/w500/3Q0hd3heuWwDWpwcDkhQOA6TYWI.jpg',
        'rating': 8.4,
        'year': 2024,
        'type': 'Series',
      },
      {
        'id': 'adult_series_3',
        'title': 'The Witcher',
        'poster': 'https://image.tmdb.org/t/p/w500/7vjaCdMw15FEbXyLQTVa04URsPm.jpg',
        'rating': 8.0,
        'year': 2023,
        'type': 'Series',
      },
      {
        'id': 'adult_series_4',
        'title': 'Game of Thrones',
        'poster': 'https://image.tmdb.org/t/p/w500/1XS1oqL89opfnbLl8WnZY1O1uJx.jpg',
        'rating': 9.2,
        'year': 2019,
        'type': 'Series',
      },
      {
        'id': 'adult_series_5',
        'title': 'Sex Education',
        'poster': 'https://image.tmdb.org/t/p/w500/8j12tohv1NBZNmpw0nJzP9t2WmV.jpg',
        'rating': 8.3,
        'year': 2023,
        'type': 'Series',
      },
      {
        'id': 'adult_series_6',
        'title': 'The Boys',
        'poster': 'https://image.tmdb.org/t/p/w500/2zmTngn1tYC1AvfnrFLhxeD82hz.jpg',
        'rating': 8.7,
        'year': 2024,
        'type': 'Series',
      },
    ];

    // Adult Movies
    adultMovies.value = [
      {
        'id': 'adult_movie_1',
        'title': 'Fifty Shades of Grey',
        'poster': 'https://image.tmdb.org/t/p/w500/63kGofUkt1Mx0SIL4XI4Z5AoSgt.jpg',
        'rating': 4.2,
        'year': 2015,
        'type': 'Movie',
      },
      {
        'id': 'adult_movie_2',
        'title': '365 Days',
        'poster': 'https://image.tmdb.org/t/p/w500/2QNFbrr5gK7NzoXQlKE3Yqhcja8.jpg',
        'rating': 3.5,
        'year': 2020,
        'type': 'Movie',
      },
      {
        'id': 'adult_movie_3',
        'title': 'Basic Instinct',
        'poster': 'https://image.tmdb.org/t/p/w500/iDOlEBOh1SN97EZdYlPVpwxJM3K.jpg',
        'rating': 7.0,
        'year': 1992,
        'type': 'Movie',
      },
      {
        'id': 'adult_movie_4',
        'title': 'Fatal Attraction',
        'poster': 'https://image.tmdb.org/t/p/w500/3NeEKHJVmUi6pOXr2lQYXMDfFuS.jpg',
        'rating': 6.9,
        'year': 1987,
        'type': 'Movie',
      },
      {
        'id': 'adult_movie_5',
        'title': 'American Pie',
        'poster': 'https://image.tmdb.org/t/p/w500/5P68by2Thn8wNjhr1qf42K4роро.jpg',
        'rating': 7.0,
        'year': 1999,
        'type': 'Movie',
      },
      {
        'id': 'adult_movie_6',
        'title': 'Cruel Intentions',
        'poster': 'https://image.tmdb.org/t/p/w500/rn4CPWkZsGpHbBa6Z3NlJYJp5iE.jpg',
        'rating': 6.8,
        'year': 1999,
        'type': 'Movie',
      },
    ];

    // Popular Adult Content
    popularAdult.value = [
      {
        'id': 'popular_1',
        'title': 'House of the Dragon',
        'poster': 'https://image.tmdb.org/t/p/w500/7QMsOTMUswlwxJP0rTTZfmz2tX2.jpg',
        'rating': 8.5,
        'year': 2024,
        'type': 'Series',
      },
      {
        'id': 'popular_2',
        'title': 'True Blood',
        'poster': 'https://image.tmdb.org/t/p/w500/r9p3zCsbbkP9wmBhMvmVj06vVHK.jpg',
        'rating': 7.9,
        'year': 2014,
        'type': 'Series',
      },
      {
        'id': 'popular_3',
        'title': 'Spartacus',
        'poster': 'https://image.tmdb.org/t/p/w500/iJdHKaHj6a3JVYdD8dLWpIGSfPV.jpg',
        'rating': 8.5,
        'year': 2013,
        'type': 'Series',
      },
      {
        'id': 'popular_4',
        'title': 'Outlander',
        'poster': 'https://image.tmdb.org/t/p/w500/sNiJVT3QGe8dHkYk9KdXzPVxGJh.jpg',
        'rating': 8.4,
        'year': 2023,
        'type': 'Series',
      },
      {
        'id': 'popular_5',
        'title': 'Sense8',
        'poster': 'https://image.tmdb.org/t/p/w500/xJPMo1BDIPnNt8F90WD2SywdOcV.jpg',
        'rating': 8.3,
        'year': 2018,
        'type': 'Series',
      },
      {
        'id': 'popular_6',
        'title': 'Orange Is the New Black',
        'poster': 'https://image.tmdb.org/t/p/w500/koADAtc6Kq93XsRPqWF3QCwkzv2.jpg',
        'rating': 7.9,
        'year': 2019,
        'type': 'Series',
      },
    ];

    // New Releases
    newReleases.value = [
      {
        'id': 'new_1',
        'title': 'The Idol',
        'poster': 'https://image.tmdb.org/t/p/w500/qXlTBcGgRz9T2mY8hNb1YK4H3xu.jpg',
        'rating': 5.3,
        'year': 2023,
        'type': 'Series',
      },
      {
        'id': 'new_2',
        'title': 'White Lotus',
        'poster': 'https://image.tmdb.org/t/p/w500/gH5i3JbnLsyTvcImlofNvXtH3i5.jpg',
        'rating': 7.9,
        'year': 2023,
        'type': 'Series',
      },
      {
        'id': 'new_3',
        'title': 'Succession',
        'poster': 'https://image.tmdb.org/t/p/w500/7HW47XbkNQ5fiwQFYGWdw9gs144.jpg',
        'rating': 8.9,
        'year': 2023,
        'type': 'Series',
      },
      {
        'id': 'new_4',
        'title': 'You',
        'poster': 'https://image.tmdb.org/t/p/w500/7bEYwjUvlJW7GerM8GYmqwl4oS3.jpg',
        'rating': 7.7,
        'year': 2023,
        'type': 'Series',
      },
      {
        'id': 'new_5',
        'title': 'Elite',
        'poster': 'https://image.tmdb.org/t/p/w500/3NTAbAiao4JLzFQw6YxP1YZppM8.jpg',
        'rating': 7.5,
        'year': 2023,
        'type': 'Series',
      },
      {
        'id': 'new_6',
        'title': 'Minx',
        'poster': 'https://image.tmdb.org/t/p/w500/3NVpLxdW6z3KyNdPBnF8XwGYGmz.jpg',
        'rating': 7.5,
        'year': 2023,
        'type': 'Series',
      },
    ];

    isLoading.value = false;
  }

  void verifyAge(bool verified) {
    ageVerified.value = verified;
  }

  void onContentTapped(Map<String, dynamic> content) {
    print('Adult content tapped: ${content['title']}');
  }
}
