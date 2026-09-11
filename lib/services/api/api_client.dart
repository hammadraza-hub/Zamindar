import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// A thin wrapper around the [http] package used for all API calls.
/// Gives us one place to handle timeouts and errors consistently.
class ApiClient {
  ApiClient._(); // static-only class

  static const Duration _timeout = Duration(seconds: 20);
  static final http.Client _client = http.Client();

  /// Performs a GET request and returns the parsed JSON
  /// (a List or a Map, depending on the endpoint).
  ///
  /// Throws [ApiException] with a friendly message on failure.
  static Future<dynamic> get(String url) async {
    try {
      final response = await _client.get(Uri.parse(url)).timeout(_timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      throw ApiException('Server responded with status ${response.statusCode}');
    } on SocketException {
      throw ApiException('No internet connection. Please check your network.');
    } on TimeoutException {
      throw ApiException('Request timed out. Please try again.');
    } on FormatException {
      throw ApiException('Received invalid data from the server.');
    }
  }
}

/// Custom exception for API errors with a human-readable message.
class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}
