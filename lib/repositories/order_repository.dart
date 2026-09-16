import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/api_credentials.dart';
import '../config/app_config.dart';
import '../models/order_model.dart';
import '../services/api/api_client.dart';
import '../services/auth/auth_service.dart';

/// User ki orders ka data (WooCommerce REST API + ck/cs keys).
class OrderRepository {
  /// Login user ki saari orders (newest first).
  Future<List<OrderModel>> getUserOrders({int perPage = 20}) async {
    // ---- 1. User ki WordPress ID (JWT se) ----
    final profile = await AuthService.fetchUserProfile();

    if (profile == null) {
      throw const ApiException(
        'Could not load your profile. Please login again.',
      );
    }

    final userId = (profile['id'] as num?)?.toInt() ?? 0;

    if (userId <= 0) {
      throw const ApiException('Could not identify your account.');
    }

    // ---- 2. Orders fetch ----
    http.Response response;

    try {
      response = await http
          .get(
            Uri.parse(
              '${AppConfig.baseUrl}/wp-json/wc/v3/orders'
              '?customer=$userId&per_page=$perPage'
              '&orderby=date&order=desc',
            ),
            headers: {'Authorization': _basicAuth()},
          )
          .timeout(const Duration(seconds: 20));
    } on SocketException {
      throw ApiException('No internet connection. Please check your network.');
    } on TimeoutException {
      throw ApiException('Request timed out. Please try again.');
    }

    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List;

      return list
          .map((o) => OrderModel.fromJson(o as Map<String, dynamic>))
          .toList();
    }

    throw ApiException('Could not load orders (${response.statusCode}).');
  }

  /// Ek order ki poori detail — TRACK ORDER ke liye.
  Future<OrderModel> getOrder(int orderId) async {
    http.Response response;

    try {
      response = await http
          .get(
            Uri.parse('${AppConfig.baseUrl}/wp-json/wc/v3/orders/$orderId'),
            headers: {'Authorization': _basicAuth()},
          )
          .timeout(const Duration(seconds: 20));
    } on SocketException {
      throw ApiException('No internet connection. Please check your network.');
    } on TimeoutException {
      throw ApiException('Request timed out. Please try again.');
    }

    if (response.statusCode == 200) {
      return OrderModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    throw ApiException('Could not load order #$orderId.');
  }

  /// ck/cs keys se Basic Auth header.
  static String _basicAuth() {
    final credentials =
        '${ApiCredentials.consumerKey}:${ApiCredentials.consumerSecret}';

    return 'Basic ${base64Encode(utf8.encode(credentials))}';
  }
}
