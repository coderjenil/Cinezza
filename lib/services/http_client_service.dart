import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:flutter/foundation.dart';

class RobustHttpClientManager {
  static http.Client? _client;
  static DateTime? _lastNetworkChange;

  static http.Client getClient() {
    final now = DateTime.now();
    if (_client == null ||
        (_lastNetworkChange != null &&
            now.difference(_lastNetworkChange!).inSeconds < 30)) {
      _client?.close();
      final httpClient = HttpClient()
        ..connectionTimeout = const Duration(seconds: 10)
        ..idleTimeout = const Duration(seconds: 5)
        ..maxConnectionsPerHost = 1;

      _client = IOClient(httpClient);
      debugPrint('Created fresh HTTP client');
    }
    return _client!;
  }

  static void onNetworkChange() {
    _lastNetworkChange = DateTime.now();
    _client?.close();
    _client = null;
    debugPrint('Network change detected - will create fresh HTTP client');
  }

  static Future<http.Response> safeGet(
    Uri uri,
    Map<String, String> headers,
  ) async {
    const maxRetries = 5;

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        final client = getClient();
        final safeHeaders = Map<String, String>.from(headers);
        safeHeaders['Connection'] = 'close';
        safeHeaders['Cache-Control'] = 'no-cache, no-store, must-revalidate';
        safeHeaders['Pragma'] = 'no-cache';

        final response = await client
            .get(uri, headers: safeHeaders)
            .timeout(const Duration(seconds: 12));

        debugPrint('HTTP request successful on attempt ${attempt + 1}');
        return response;
      } on SocketException catch (e) {
        debugPrint('SocketException on attempt ${attempt + 1}: $e');
        if (attempt < maxRetries - 1) {
          _client?.close();
          _client = null;
          final delay = attempt == 0 ? 200 : (attempt * 400);
          await Future.delayed(Duration(milliseconds: delay));
          continue;
        }
        rethrow;
      } on TimeoutException catch (e) {
        debugPrint('TimeoutException on attempt ${attempt + 1}: $e');
        if (attempt < maxRetries - 1) {
          _client?.close();
          _client = null;
          await Future.delayed(Duration(milliseconds: attempt * 300));
          continue;
        }
        rethrow;
      } on http.ClientException catch (e) {
        debugPrint('ClientException on attempt ${attempt + 1}: $e');
        if (attempt < maxRetries - 1) {
          _client?.close();
          _client = null;
          await Future.delayed(Duration(milliseconds: attempt * 400));
          continue;
        }
        rethrow;
      } catch (e) {
        debugPrint('Other exception on attempt ${attempt + 1}: $e');
        if (attempt < maxRetries - 1) {
          await Future.delayed(Duration(milliseconds: attempt * 300));
          continue;
        }
        rethrow;
      }
    }
    throw Exception('Max retries exceeded');
  }

  static void dispose() {
    _client?.close();
    _client = null;
  }

    static Future<http.Response> safePost(
    Uri uri,
    Map<String, String> headers,
    String body,
  ) async {
    const maxRetries = 5;

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        final client = getClient();
        final safeHeaders = Map<String, String>.from(headers);
        safeHeaders['Connection'] = 'close';
        safeHeaders['Cache-Control'] = 'no-cache, no-store, must-revalidate';
        safeHeaders['Pragma'] = 'no-cache';

        final response = await client
            .post(uri, headers: safeHeaders, body: body)
            .timeout(const Duration(seconds: 45));

        debugPrint('HTTP POST request successful on attempt ${attempt + 1}');
        return response;
      } catch (e) {
        debugPrint('HTTP POST error on attempt ${attempt + 1}: $e');
        if (attempt < maxRetries - 1) {
          _client?.close();
          _client = null;
          final delay = attempt == 0 ? 200 : (attempt * 400);
          await Future.delayed(Duration(milliseconds: delay));
          continue;
        }
        rethrow;
      }
    }
    throw Exception('Max POST retries exceeded');
  }
}
