import 'package:flutter/material.dart';

/// Ek order ka ek product (line item).
class OrderLineItem {
  final String name;
  final int quantity;
  final double price; // unit price
  final String? imageUrl;

  const OrderLineItem({
    required this.name,
    required this.quantity,
    required this.price,
    this.imageUrl,
  });

  factory OrderLineItem.fromJson(Map<String, dynamic> json) {
    final image = json['image'] as Map<String, dynamic>?;

    return OrderLineItem(
      name: json['name']?.toString() ?? 'Product',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      price: (double.tryParse(json['price']?.toString() ?? '0') ?? 0),
      imageUrl: image?['src']?.toString(),
    );
  }

  String get displayPrice {
    final value = price == price.roundToDouble()
        ? price.round().toString()
        : price.toStringAsFixed(2);
    return 'Rs $value';
  }

  String get lineTotal => 'Rs ${(price * quantity).round()}';
}

/// Ek poori order (WooCommerce REST API se).
class OrderModel {
  final int id;
  final String status; // processing / on-hold / completed ...
  final DateTime? dateCreated;
  final double total; // grand total (shipping included)
  final double shippingTotal;
  final String paymentMethodTitle;
  final String customerNote;
  final List<OrderLineItem> items;

  // Billing info
  final String billingName;
  final String billingPhone;
  final String billingAddress;
  final String billingEmail;

  const OrderModel({
    required this.id,
    required this.status,
    required this.dateCreated,
    required this.total,
    required this.shippingTotal,
    required this.paymentMethodTitle,
    required this.customerNote,
    required this.items,
    required this.billingName,
    required this.billingPhone,
    required this.billingAddress,
    required this.billingEmail,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final billing = (json['billing'] as Map<String, dynamic>?) ?? {};

    final items = ((json['line_items'] as List?) ?? const [])
        .map((item) => OrderLineItem.fromJson(item as Map<String, dynamic>))
        .toList();

    DateTime? date;
    final rawDate = json['date_created']?.toString() ?? '';
    if (rawDate.isNotEmpty) {
      date = DateTime.tryParse(rawDate);
    }

    final String address = [
      billing['address_1']?.toString(),
      billing['city']?.toString(),
      billing['state']?.toString(),
    ].where((part) => part != null && part.trim().isNotEmpty).join(', ');

    return OrderModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString() ?? '',
      dateCreated: date,
      total: double.tryParse(json['total']?.toString() ?? '0') ?? 0,
      shippingTotal:
          double.tryParse(json['shipping_total']?.toString() ?? '0') ?? 0,
      paymentMethodTitle: json['payment_method_title']?.toString() ?? '',
      customerNote: json['customer_note']?.toString() ?? '',
      items: items,
      billingName:
          '${billing['first_name']?.toString() ?? ''} ${billing['last_name']?.toString() ?? ''}'
              .trim(),
      billingPhone: billing['phone']?.toString() ?? '',
      billingAddress: address,
      billingEmail: billing['email']?.toString() ?? '',
    );
  }

  // ================== HELPERS ==================

  /// User-friendly status text.
  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'processing':
        return 'Processing';
      case 'on-hold':
        return 'On Hold';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'failed':
        return 'Failed';
      case 'refunded':
        return 'Refunded';
      default:
        return status.isNotEmpty ? status : 'Unknown';
    }
  }

  /// Status ka rang (badge ke liye).
  Color get statusColor {
    switch (status) {
      case 'processing':
        return const Color(0xFF087524); // green
      case 'completed':
        return const Color(0xFF1565C0); // blue
      case 'on-hold':
      case 'pending':
        return const Color(0xFFEF6C00); // orange
      case 'cancelled':
      case 'failed':
        return const Color(0xFFC62828); // red
      case 'refunded':
        return const Color(0xFF757575); // grey
      default:
        return const Color(0xFF757575);
    }
  }

  /// Total display ke liye — "Rs 1,650".
  String get displayTotal {
    final int value = total.round();
    final formatted = value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
    return 'Rs $formatted';
  }

  /// Shipping display — "Free" ya "Rs 150".
  String get displayShipping {
    if (shippingTotal <= 0) return 'Free';
    return 'Rs ${shippingTotal.round()}';
  }

  /// "14/09/2026" format.
  String get formattedDate {
    if (dateCreated == null) return '';

    String two(int n) => n.toString().padLeft(2, '0');

    return '${two(dateCreated!.day)}/${two(dateCreated!.month)}/${dateCreated!.year}';
  }

  /// Items ki tadaad (total quantity).
  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);

  /// Pehle 2 product ke naam (card preview ke liye).
  String get itemsPreview {
    if (items.isEmpty) return 'No items';

    final names = items.take(2).map((i) => i.name).join(', ');

    if (items.length > 2) {
      return '$names +${items.length - 2} more';
    }

    return names;
  }
}
