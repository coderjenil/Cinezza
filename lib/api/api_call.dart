part of apsl_api_call;

class ApiCall {
  static Future<http.Response> callService({
    required APIRequestInfoObj requestInfo,
  }) async {
    try {
      await _checkConnectivity();
      _printApiDetail(requestInfo);

      http.Response response = requestInfo.docList.isEmpty
          ? await _callAPI(
              requestInfo: requestInfo,
            ).timeout(Duration(seconds: requestInfo.timeSecond))
          : await _callMultipartAPI(
              requestInfo: requestInfo,
            ).timeout(Duration(seconds: requestInfo.timeSecond));

      // ✅ Validate status code after the call:
      _validateResponse(response);

      return response;
    } on SocketException catch (e) {
      throw AppException(message: e.message, type: ExceptionType.noInternet);
    } on HttpException catch (e) {
      throw AppException(message: e.message, type: ExceptionType.httpException);
    } on FormatException catch (e) {
      throw AppException(
        message: e.source?.toString(),
        type: ExceptionType.formatException,
      );
    } on TimeoutException {
      throw AppException(
        title: ApiErrorMessage.requestTimeoutTitle,
        message: ApiErrorMessage.requestTimeoutMessage,
        type: ExceptionType.timeOut,
      );
    } catch (error) {
      rethrow;
    }
  }

  static Future<bool> _checkConnectivity() async {
    List<ConnectivityResult> connectivity = await Connectivity()
        .checkConnectivity();
    if (connectivity.isEmpty) {
      throw AppException(
        title: ApiErrorMessage.noInternet,
        message: ApiErrorMessage.noInternetMessage,
        type: ExceptionType.noInternet,
      );
    }
    return true;
  }

  static Future<http.Response> _callAPI({
    required APIRequestInfoObj requestInfo,
  }) async {
    String url = requestInfo.url;
    http.Response response;
    Map<String, String>? apiHeader = requestInfo.headers;

    switch (requestInfo.requestType) {
      case HTTPRequestType.post:
        response = await http.post(
          Uri.parse(url),
          body: requestInfo.parameter == null
              ? null
              : json.encode(requestInfo.parameter),
          headers: apiHeader,
        );
        break;
      case HTTPRequestType.get:
        response = await http.get(Uri.parse(url), headers: apiHeader);
        break;
      case HTTPRequestType.delete:
        response = await http.delete(Uri.parse(url), headers: apiHeader);
        break;
      case HTTPRequestType.put:
        response = await http.put(
          Uri.parse(url),
          body: requestInfo.parameter == null
              ? null
              : json.encode(requestInfo.parameter),
          headers: apiHeader,
        );
      case HTTPRequestType.patch:
        response = await http.patch(
          Uri.parse(url),
          body: requestInfo.parameter == null
              ? null
              : json.encode(requestInfo.parameter),
          headers: apiHeader,
        );
        break;
    }

    _printResponse(response, requestInfo.serviceName);

    // ✅ Validate status code:
    _validateResponse(response);

    return response;
  }

  static Future<http.Response> _callMultipartAPI({
    required APIRequestInfoObj requestInfo,
  }) async {
    Uri uri = Uri.parse(requestInfo.url);
    http.MultipartRequest request = http.MultipartRequest(
      describeEnum(requestInfo.requestType),
      uri,
    );

    // Add parameters and headers to the request.
    requestInfo.parameter?.forEach((key, value) => request.fields[key] = value);
    Map<String, String>? apiHeader = requestInfo.headers;
    apiHeader?.forEach((key, value) => request.headers[key] = value);

    // Process and add files to the request.
    List<http.MultipartFile> successfulFiles = [];
    List<String> failedFiles = [];

    List<Future<void>> filesFutures = requestInfo.docList
        .expand(
          (docInfo) => docInfo.docPathList.map((docPath) async {
            try {
              http.MultipartFile file = await http.MultipartFile.fromPath(
                docInfo.docKey,
                docPath,
                filename: basename(docPath),
              );
              successfulFiles.add(file);
            } catch (error) {
              debugPrint(
                "Error While uploading Image: $docPath, Error: $error",
              );
              failedFiles.add(docPath);
            }
          }),
        )
        .toList();

    await Future.wait(filesFutures);
    request.files.addAll(successfulFiles);

    // Send the multipart request and get the response.
    http.Response response = await http.Response.fromStream(
      await request.send(),
    );

    // Print the API response details for debugging purposes.
    _printResponse(response, requestInfo.serviceName);
    return response;
  }

  /// ✅ Centralized Response Validator
  static void _validateResponse(http.Response response) {
    if (response.statusCode >= 400) {
      throw AppException(
        title: ApiErrorMessage.defaultErrorTitle,
        message: 'HTTP Error: ${response.statusCode}',
        type: ExceptionType.httpException,
        statusCode: response.statusCode,
        responseBody: response.body,
      );
    }
  }

  static void _printApiDetail(APIRequestInfoObj info) {
    if (kReleaseMode) return;
    String apiLog =
        """
        ${info.serviceName} Service Parameters
        |-------------------------------------------------------------------------------------------------------------------------
        | ApiType :- ${describeEnum(info.requestType)}
        | URL     :- ${info.url}
        | Params  :- ${info.parameter}
        |-------------------------------------------------------------------------------------------------------------------------
        """;
    debugPrint(apiLog);
  }

  static void _printResponse(http.Response response, String serviceName) {
    if (kReleaseMode) return;
    String apiLog =
        """
        $serviceName Service Response
        |--------------------------------------------------------------------------------------------------------------------------
        | API        :- $serviceName
        | StatusCode :- ${response.statusCode}
        | Message    :- ${response.body}
        |--------------------------------------------------------------------------------------------------------------------------
       """;
    debugPrint(apiLog);
  }
}

/// Represents the information required for an API request.
///
/// This class encapsulates all the necessary details needed to make an API call.
/// It includes the type of HTTP request (GET, POST, PUT, DELETE), the request URL,
/// any parameters to be sent with the request, headers, documents for multipart requests,
/// the name of the service being called, and a timeout duration for the request.
class APIRequestInfoObj {
  /// Type of the HTTP request (e.g., POST, GET, DELETE, PUT).
  HTTPRequestType requestType;

  /// The endpoint URL for the API call.
  String url;

  /// Parameters to be sent with the API request.
  Map<String, dynamic>? parameter;

  /// Headers to be included in the API request.
  Map<String, String>? headers;

  /// List of documents to be uploaded in case of a multipart request.
  List<UploadDocumentObj> docList;

  /// Name of the service or API being called (used for debugging purposes).
  String serviceName;

  /// Timeout duration for the API call.
  int timeSecond;

  /// Constructor for the `APIRequestInfoObj` class.
  ///
  /// Initializes the class with the provided details for the API call.
  APIRequestInfoObj({
    this.requestType = HTTPRequestType.post,
    this.parameter,
    this.headers,
    this.docList = const [],
    required this.url,
    this.serviceName = "",
    this.timeSecond = 90,
  });
}

/// Represents the information required for uploading a document.
///
/// This class is used in conjunction with the `APIRequestInfoObj` class for making
/// multipart API requests. It specifies the key for the document and a list of paths
/// to the documents to be uploaded.
class UploadDocumentObj {
  /// Key for the document in the multipart request.
  String docKey;

  /// List of paths to the documents to be uploaded.
  List<String> docPathList;

  /// Constructor for the `UploadDocumentObj` class.
  ///
  /// Initializes the class with the provided key and list of document paths.
  UploadDocumentObj({this.docKey = "", this.docPathList = const []});
}
