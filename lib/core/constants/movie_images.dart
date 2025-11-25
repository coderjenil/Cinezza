class MovieImages {
  static const String tmdbImageBaseUrl = 'https://image.tmdb.org/t/p/w500';
  static const String tmdbOriginalImageBaseUrl = 'https://image.tmdb.org/t/p/original';

  // Real Movie Posters from TMDB
  static const List<Map<String, dynamic>> featuredMovies = [
    {
      'id': '1',
      'title': 'Dune: Part Two',
      'poster': 'https://image.tmdb.org/t/p/w500/8b8R8l88Qje9dn9OE8PY05Nxl1X.jpg',
      'backdrop': 'https://image.tmdb.org/t/p/original/xOMo8BRK7PfcJv9JCnx7s5hj0PX.jpg',
      'rating': 8.5,
      'year': 2024,
      'genre': 'Sci-Fi, Adventure',
    },
    {
      'id': '2',
      'title': 'Oppenheimer',
      'poster': 'https://image.tmdb.org/t/p/w500/8Gxv8gSFCU0XGDykEGv7zR1n2ua.jpg',
      'backdrop': 'https://image.tmdb.org/t/p/original/fm6KqXpk3M2HVveHwCrBSSBaO0V.jpg',
      'rating': 8.8,
      'year': 2023,
      'genre': 'Biography, Drama',
    },
    {
      'id': '3',
      'title': 'Deadpool & Wolverine',
      'poster': 'https://image.tmdb.org/t/p/w500/8cdWjvZQUExUUTzyp4t6EDMubfO.jpg',
      'backdrop': 'https://image.tmdb.org/t/p/original/yDHYTfA3R0jFYba16jBB1ef8oIt.jpg',
      'rating': 7.9,
      'year': 2024,
      'genre': 'Action, Comedy',
    },
  ];

  static const List<Map<String, dynamic>> latestMovies = [
    {
      'id': 'latest_1',
      'title': 'The Marvels',
      'poster': 'https://image.tmdb.org/t/p/w500/9GBhzXMFjgcZ3FdR9w3bUMMTps5.jpg',
      'rating': 7.2,
      'year': 2024,
    },
    {
      'id': 'latest_2',
      'title': 'Napoleon',
      'poster': 'https://image.tmdb.org/t/p/w500/jE5o7y9K6pZtWNNMEw3IdpHuncR.jpg',
      'rating': 7.5,
      'year': 2024,
    },
    {
      'id': 'latest_3',
      'title': 'Wonka',
      'poster': 'https://image.tmdb.org/t/p/w500/qhb1qOilapbapxWQn9jtRCMwXJF.jpg',
      'rating': 7.8,
      'year': 2023,
    },
    {
      'id': 'latest_4',
      'title': 'Aquaman 2',
      'poster': 'https://image.tmdb.org/t/p/w500/8xV47NDrjdZDpkVcCFqkdHa3T0C.jpg',
      'rating': 7.0,
      'year': 2023,
    },
    {
      'id': 'latest_5',
      'title': 'The Hunger Games',
      'poster': 'https://image.tmdb.org/t/p/w500/7LTyd0JKD5GJVYVaT9qDkJPfNUb.jpg',
      'rating': 7.6,
      'year': 2023,
    },
    {
      'id': 'latest_6',
      'title': 'Spider-Man: Across',
      'poster': 'https://image.tmdb.org/t/p/w500/8Vt6mWEReuy4Of61Lnj5Xj704m8.jpg',
      'rating': 8.9,
      'year': 2023,
    },
    {
      'id': 'trending_1',
      'title': 'Avatar: The Way of Water',
      'poster': 'https://image.tmdb.org/t/p/w500/t6HIqrRAclMCA60NsSmeqe9RmNV.jpg',
      'rating': 8.2,
      'year': 2022,
    },
    {
      'id': 'trending_2',
      'title': 'Barbie',
      'poster': 'https://image.tmdb.org/t/p/w500/iuFNMS8U5cb6xfzi51Dbkovj7vM.jpg',
      'rating': 7.8,
      'year': 2023,
    },
    {
      'id': 'trending_3',
      'title': 'Guardians of the Galaxy Vol. 3',
      'poster': 'https://image.tmdb.org/t/p/w500/r2J02Z2OpNTctfOSN1Ydgii51I3.jpg',
      'rating': 8.1,
      'year': 2023,
    },
    {
      'id': 'trending_4',
      'title': 'Fast X',
      'poster': 'https://image.tmdb.org/t/p/w500/fiVW06jE7z9YnO4trhaMEdclSiC.jpg',
      'rating': 7.3,
      'year': 2023,
    },
    {
      'id': 'trending_5',
      'title': 'Mission: Impossible',
      'poster': 'https://image.tmdb.org/t/p/w500/NNxYkU70HPurnNCSiCjYAmacwm.jpg',
      'rating': 8.0,
      'year': 2023,
    },
    {
      'id': 'trending_6',
      'title': 'Elemental',
      'poster': 'https://image.tmdb.org/t/p/w500/4Y1WNkd88JXmGfhtWR7dmDAo1T2.jpg',
      'rating': 7.7,
      'year': 2023,
    },
    {
      'id': 'trending_1',
      'title': 'Avatar: The Way of Water',
      'poster': 'https://image.tmdb.org/t/p/w500/t6HIqrRAclMCA60NsSmeqe9RmNV.jpg',
      'rating': 8.2,
      'year': 2022,
    },
    {
      'id': 'trending_2',
      'title': 'Barbie',
      'poster': 'https://image.tmdb.org/t/p/w500/iuFNMS8U5cb6xfzi51Dbkovj7vM.jpg',
      'rating': 7.8,
      'year': 2023,
    },
    {
      'id': 'trending_3',
      'title': 'Guardians of the Galaxy Vol. 3',
      'poster': 'https://image.tmdb.org/t/p/w500/r2J02Z2OpNTctfOSN1Ydgii51I3.jpg',
      'rating': 8.1,
      'year': 2023,
    },
    {
      'id': 'trending_4',
      'title': 'Fast X',
      'poster': 'https://image.tmdb.org/t/p/w500/fiVW06jE7z9YnO4trhaMEdclSiC.jpg',
      'rating': 7.3,
      'year': 2023,
    },
    {
      'id': 'trending_5',
      'title': 'Mission: Impossible',
      'poster': 'https://image.tmdb.org/t/p/w500/NNxYkU70HPurnNCSiCjYAmacwm.jpg',
      'rating': 8.0,
      'year': 2023,
    },
    {
      'id': 'trending_6',
      'title': 'Elemental',
      'poster': 'https://image.tmdb.org/t/p/w500/4Y1WNkd88JXmGfhtWR7dmDAo1T2.jpg',
      'rating': 7.7,
      'year': 2023,
    },
  ];

  static const List<Map<String, dynamic>> trendingMovies = [
    {
      'id': 'trending_1',
      'title': 'Avatar: The Way of Water',
      'poster': 'https://image.tmdb.org/t/p/w500/t6HIqrRAclMCA60NsSmeqe9RmNV.jpg',
      'rating': 8.2,
      'year': 2022,
    },
    {
      'id': 'trending_2',
      'title': 'Barbie',
      'poster': 'https://image.tmdb.org/t/p/w500/iuFNMS8U5cb6xfzi51Dbkovj7vM.jpg',
      'rating': 7.8,
      'year': 2023,
    },
    {
      'id': 'trending_3',
      'title': 'Guardians of the Galaxy Vol. 3',
      'poster': 'https://image.tmdb.org/t/p/w500/r2J02Z2OpNTctfOSN1Ydgii51I3.jpg',
      'rating': 8.1,
      'year': 2023,
    },
    {
      'id': 'trending_4',
      'title': 'Fast X',
      'poster': 'https://image.tmdb.org/t/p/w500/fiVW06jE7z9YnO4trhaMEdclSiC.jpg',
      'rating': 7.3,
      'year': 2023,
    },
    {
      'id': 'trending_5',
      'title': 'Mission: Impossible',
      'poster': 'https://image.tmdb.org/t/p/w500/NNxYkU70HPurnNCSiCjYAmacwm.jpg',
      'rating': 8.0,
      'year': 2023,
    },
    {
      'id': 'trending_6',
      'title': 'Elemental',
      'poster': 'https://image.tmdb.org/t/p/w500/4Y1WNkd88JXmGfhtWR7dmDAo1T2.jpg',
      'rating': 7.7,
      'year': 2023,
    },
  ];

  static const List<Map<String, dynamic>> upcomingMovies = [
    {
      'id': 'upcoming_1',
      'title': 'Furiosa',
      'poster': 'https://image.tmdb.org/t/p/w500/iADOJ8Zymht2JPMoy3R7xceZprc.jpg',
      'rating': 0.0,
      'year': 2024,
    },
    {
      'id': 'upcoming_2',
      'title': 'Kingdom of the Planet',
      'poster': 'https://image.tmdb.org/t/p/w500/gKkl37BQuKTanygYQG1pyYgLVgf.jpg',
      'rating': 0.0,
      'year': 2024,
    },
    {
      'id': 'upcoming_3',
      'title': 'Joker: Folie à Deux',
      'poster': 'https://image.tmdb.org/t/p/w500/aciP8Km0waTLXEYf5ybFK5CSUxl.jpg',
      'rating': 0.0,
      'year': 2024,
    },
    {
      'id': 'upcoming_4',
      'title': 'Deadpool 3',
      'poster': 'https://image.tmdb.org/t/p/w500/4V2nTPfeB59TcqJcUfQ9ziTi7VN.jpg',
      'rating': 0.0,
      'year': 2024,
    },
    {
      'id': 'upcoming_5',
      'title': 'Inside Out 2',
      'poster': 'https://image.tmdb.org/t/p/w500/vpnVM9B6NMmQpWeZvzLvDESb2QY.jpg',
      'rating': 0.0,
      'year': 2024,
    },
    {
      'id': 'upcoming_6',
      'title': 'A Quiet Place',
      'poster': 'https://image.tmdb.org/t/p/w500/yrpPYKijwdMHyTGIOd1iK1h0Xno.jpg',
      'rating': 0.0,
      'year': 2024,
    },
  ];

  static const List<Map<String, dynamic>> recommendedMovies = [
    {
      'id': 'recommended_1',
      'title': 'Interstellar',
      'poster': 'https://image.tmdb.org/t/p/w500/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg',
      'rating': 8.7,
      'year': 2014,
    },
    {
      'id': 'recommended_2',
      'title': 'Inception',
      'poster': 'https://image.tmdb.org/t/p/w500/ljsZTbVsrQSqZgWeep2B1QiDKuh.jpg',
      'rating': 8.8,
      'year': 2010,
    },
    {
      'id': 'recommended_3',
      'title': 'The Dark Knight',
      'poster': 'https://image.tmdb.org/t/p/w500/qJ2tW6WMUDux911r6m7haRef0WH.jpg',
      'rating': 9.0,
      'year': 2008,
    },
    {
      'id': 'recommended_4',
      'title': 'Pulp Fiction',
      'poster': 'https://image.tmdb.org/t/p/w500/d5iIlFn5s0ImszYzBPb8JPIfbXD.jpg',
      'rating': 8.9,
      'year': 1994,
    },
    {
      'id': 'recommended_5',
      'title': 'Fight Club',
      'poster': 'https://image.tmdb.org/t/p/w500/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg',
      'rating': 8.8,
      'year': 1999,
    },
    {
      'id': 'recommended_6',
      'title': 'The Matrix',
      'poster': 'https://image.tmdb.org/t/p/w500/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg',
      'rating': 8.7,
      'year': 1999,
    },
  ];
}
