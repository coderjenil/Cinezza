class ApiEndPoints {
  // static const String baseURL = "http://192.168.1.85:3000/api/";

  static const String baseURL = "https://www.quizonline.live/api/";
  static const String registerUser = "${baseURL}auth/login";
  static const String getAllCategories = "${baseURL}categories/";
  static const String getMoviesByCategory = "${baseURL}movies/category/";
  static const String registerUserUrl = "${baseURL}users/register";
  static const String updateUserByDevice = "${baseURL}users/";
  static const String fetchPremiumPlans = "${baseURL}plans";
  static const String fetchRemoteConfig = "${baseURL}remote-config";
  static const String movieSearch = "${baseURL}movies/search?q=";
  static const String requestMovie = "${baseURL}request-movie";
  static const String increaseMovieViewCount = "${baseURL}movies/";
  static const String upgradePlan = "${baseURL}users/upgrade-plan";
}

class ApiHeaders {
  static Map<String, String> getHeaders() {
    return {
      'Content-Type': 'application/json',
      'x-api-key': "fRAoOLsCBIGK8Jq1ZMPMLaAEVQMFJW23",
    };
  }
}
