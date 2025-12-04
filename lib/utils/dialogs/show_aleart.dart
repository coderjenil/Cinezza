import 'dart:convert';

import 'package:flutter/material.dart';

import '../../api/apsl_api_call.dart';

void showAlert({required BuildContext context, required Object message}) async {
  String errorTitle = "Error";
  String errorMessage = "Something went wrong";

  if (message is AppException) {
    errorTitle = message.title ?? "HTTP Error";
    try {
      // 1. Try to extract error from response body
      if (message.responseBody.isNotEmpty) {
        final body = message.responseBody.trim();
        if (body.startsWith('<')) {
          errorMessage =
              "Server responded with an unexpected error (HTML content). Please try again or contact support.";
        } else {
          try {
            final decodedBody = jsonDecode(body);
            if (decodedBody is Map) {
              if (decodedBody.containsKey('message')) {
                errorMessage = decodedBody['message'].toString();
              } else if (decodedBody.containsKey('error')) {
                errorMessage = decodedBody['error'].toString();
              } else if (message.message != null &&
                  message.message!.isNotEmpty) {
                errorMessage = message.message!;
              } else {
                errorMessage = "HTTP Error: ${message.statusCode}";
              }
            } else {
              errorMessage = body; // Fallback to raw string error
            }
          } catch (e) {
            // If response body is not JSON, fallback to raw text
            errorMessage = body;
          }
        }
      }
      // 2. Custom status code overrides (after body parsing)
      if (message.statusCode == 413) {
        errorMessage =
            "The uploaded file is too large. Please upload a smaller image.";
      } else if (message.statusCode == 500 &&
          (errorMessage == "Something went wrong" || errorMessage.isEmpty)) {
        errorMessage = "Wrong email or password";
      } else if (message.statusCode == 401) {
        errorMessage = "Please Login Again!";
      }
      // 3. Fallbacks if message missing
      if ((errorMessage.isEmpty || errorMessage == "Something went wrong") &&
          message.message != null &&
          message.message!.isNotEmpty) {
        errorMessage = message.message!;
      } else if (errorMessage.isEmpty) {
        errorMessage =
            "Empty response body - HTTP Error: ${message.statusCode}";
      }
    } catch (e) {
      if (message.message != null && message.message!.isNotEmpty) {
        errorMessage = message.message!;
      } else {
        errorMessage =
            "Failed to parse error - HTTP Error: ${message.statusCode}";
      }
    }
  }
}
