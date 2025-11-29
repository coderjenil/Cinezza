part of apsl_api_call;

/// Represents a custom exception for API calls.
///
/// This exception is thrown when an API call encounters an error. It provides
/// detailed information about the type of error, the status code returned by the server,
/// and the response body.
class AppException implements Exception {
  final String? message;
  final String? title;
  final ExceptionType type;
  final int statusCode;
  final String responseBody;

  AppException({
    this.title,
    this.message,
    this.type = ExceptionType.none,
    this.statusCode = 404,
    this.responseBody = "",
  });

  AlertInfo get alertInfo {
    String alertTitle;
    String msg;
    switch (type) {
      case ExceptionType.noInternet:
        alertTitle = ApiErrorMessage.noInternet;
        msg = ApiErrorMessage.noInternetMessage;
        break;
      // Add more specific types as needed
      default:
        alertTitle = ApiErrorMessage.defaultErrorTitle;
        msg = ApiErrorMessage.somethingWentWrong;
    }
    return AlertInfo(title: alertTitle, message: msg);
  }

  @override
  String toString() {
    return message ?? 'Unknown error';
  }
}

/// Enumerates the types of exceptions that can occur during an API call.
///
/// This helps in categorizing the errors and handling them appropriately.
enum ExceptionType {
  noInternet, // Indicates no internet connectivity.
  httpException, // Indicates a generic HTTP error.
  formatException, // Indicates an error in the response format.
  unAuthorised, // Indicates unauthorized access.
  underMaintainance, // Indicates the server is under maintenance.
  timeOut, // Indicates the request timed out.
  none, // Indicates an unspecified error.
}

/// Represents alert information with a title and message.
///
/// This class is used to encapsulate user-friendly error messages that can be displayed
/// as alerts to the user.
class AlertInfo {
  /// The title of the alert.
  final String title;

  /// The message or description of the alert.
  final String message;

  const AlertInfo({required this.title, required this.message});
}

/// Enumerates the types of HTTP requests that can be made.
///
/// This helps in specifying the type of request (e.g., GET, POST) when making an API call.
enum HTTPRequestType {
  post, // Represents an HTTP POST request.
  get, // Represents an HTTP GET request.
  delete, // Represents an HTTP DELETE request.
  put, // Represents an HTTP PUT request.
  patch, // Represents an HTTP PUT request.
}
