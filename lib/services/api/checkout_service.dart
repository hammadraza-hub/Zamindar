import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../config/app_config.dart';
import '../../models/order_result.dart';
import '../api/api_client.dart';
import '../cart_provider.dart';

/// Order ka pata (billing/shipping dono isi se bante hain).
class BillingAddress {
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String address1;
  final String city;
  final String state;
  final String postcode;
  final String country;

  const BillingAddress({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.address1,
    required this.city,
    required this.state,
    required this.postcode,
    this.country = 'PK',
  });

  Map<String, dynamic> toJson() => {
    'first_name': firstName,
    'last_name': lastName.isEmpty ? '.' : lastName,
    'address_1': address1,
    'address_2': '',
    'city': city,
    'state': state,
    'postcode': postcode.isEmpty ? '00000' : postcode,
    'country': country,
    'phone': phone,
  };
}

/// WooCommerce Store API se ASLI order banata hai:
///   1) cart session  2) items add  3) checkout
class CheckoutService {
  CheckoutService._();

  static Future<OrderResult> placeOrder({
    required List<CartItem> items,
    required BillingAddress address,
    required String paymentMethod, // 'cod' ya 'bacs'
    String? jwtToken, // login user ho to order uska hoga
  }) async {
    final client = http.Client();

    try {
      // ---- 1. CART SESSION (token + nonce lena) ----
      final initResponse = await client
          .get(
            Uri.parse(
              '${AppConfig.baseUrl}/wp-json/wc/store/v1/cart'
              '?_=${DateTime.now().millisecondsSinceEpoch}', // cache-buster
            ),
          )
          .timeout(const Duration(seconds: 20));

      if (initResponse.statusCode != 200) {
        throw ApiException(
          'Cart session fail (${initResponse.statusCode}): '
          '${_snippet(initResponse.body)}',
        );
      }

      final String? cartToken = initResponse.headers['cart-token'];
      final String? nonce = initResponse.headers['nonce'];

      if (cartToken == null || cartToken.isEmpty) {
        throw ApiException(
          'Server ne cart token nahi diya! Response: '
          '${_snippet(initResponse.body)}',
        );
      }

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Cart-Token': cartToken,
        if (nonce != null && nonce.isNotEmpty) 'Nonce': nonce,
        if (jwtToken != null && jwtToken.isNotEmpty)
          'Authorization': 'Bearer $jwtToken',
      };

      // ---- 2. HAR ITEM SERVER CART MEIN ADD ----
      for (final item in items) {
        final productId = int.tryParse(item.id);

        if (productId == null || productId <= 0) {
          throw ApiException('Invalid product: ${item.name}');
        }

        final addResponse = await client
            .post(
              Uri.parse(
                '${AppConfig.baseUrl}/wp-json/wc/store/v1/cart/add-item',
              ),
              headers: headers,
              body: jsonEncode({'id': productId, 'quantity': item.quantity}),
            )
            .timeout(const Duration(seconds: 20));

        if (addResponse.statusCode != 200 && addResponse.statusCode != 201) {
          throw ApiException(
            'ADD FAIL (${addResponse.statusCode}): '
            '${_snippet(addResponse.body)}',
          );
        }
      }

      // ---- 3. CHECKOUT — ASLI ORDER! ----
      final checkoutResponse = await client
          .post(
            Uri.parse('${AppConfig.baseUrl}/wp-json/wc/store/v1/checkout'),
            headers: headers,
            body: jsonEncode({
              'billing_address': address.toJson(),
              'shipping_address': address.toJson(),
              'payment_method': paymentMethod,
              'payment_result': {
                'payment_method': paymentMethod,
                'payment_data': [],
              },
              'additional_fields': {
                'email': address.email,
                'phone': address.phone,
              },
              'create_account': false,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (checkoutResponse.statusCode == 200 ||
          checkoutResponse.statusCode == 201) {
        final data = jsonDecode(checkoutResponse.body) as Map<String, dynamic>;

        return OrderResult.fromJson(data);
      }

      throw ApiException(
        'CHECKOUT FAIL (${checkoutResponse.statusCode}): '
        '${_snippet(checkoutResponse.body)}',
      );
    } on SocketException {
      throw ApiException('No internet connection. Please check your network.');
    } on TimeoutException {
      throw ApiException('Order request timed out. Please try again.');
    } finally {
      client.close();
    }
  }

  /// Server ke response ka pehla hissa (debug ke liye).
  static String _snippet(String body) {
    final clean = body.replaceAll(RegExp(r'\s+'), ' ').trim();
    return clean.length > 200 ? '${clean.substring(0, 200)}...' : clean;
  }
}
