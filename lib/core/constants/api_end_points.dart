class ApiEndPoints {
  // static const String baseURL = "http://192.168.1.139:8080/api/";
  static const String baseURL = "https://www.quizonline.live/api/";
  static const String registerUser = "${baseURL}auth/login";
  static const String getAllCategories = "${baseURL}categories/";
  static const String getMoviesByCategory = "${baseURL}movies/category/";
}

class ApiHeaders {
  static Map<String, String> getHeaders() {
    // Example: Getting a token from shared preferences
    return {
      // 'Content-Type': 'application/json',
      'x-api-key': "fRAoOLsCBIGK8Jq1ZMPMLaAEVQMFJW23",
    };
  }
}
