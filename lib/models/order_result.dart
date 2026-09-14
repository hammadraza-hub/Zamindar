/// Asli WooCommerce order ka natija (checkout API ka jawab).
class OrderResult {
  final int orderNumber; // asli order ID — website wala!
  final String orderKey; // tracking/debug ke liye
  final String rawStatus; // pending / processing / on-hold...
  final int totalRs; // website se calculated ASLI total

  const OrderResult({
    required this.orderNumber,
    required this.orderKey,
    required this.rawStatus,
    required this.totalRs,
  });

  factory OrderResult.fromJson(Map<String, dynamic> json) {
    // ---- Order ID: har version alag jagah rakhta hai ----
    int orderNumber = (json['order_id'] as num?)?.toInt() ?? 0;

    if (orderNumber == 0) {
      orderNumber = (json['id'] as num?)?.toInt() ?? 0;
    }

    if (orderNumber == 0) {
      // nested_order_data kisi version mein hota hai
      final nested = json['nested_order_data'];
      if (nested is Map) {
        orderNumber = (nested['id'] as num?)?.toInt() ?? 0;
      }
    }

    if (orderNumber == 0) {
      // numeric_order_id field
      orderNumber =
          int.tryParse(json['numeric_order_id']?.toString() ?? '') ?? 0;
    }

    // ---- Order key ----
    String orderKey = json['order_key']?.toString() ?? '';
    if (orderKey.isEmpty) {
      orderKey = json['order_number']?.toString() ?? '';
    }

    // ---- Status ----
    String rawStatus = json['status']?.toString() ?? '';

    // ---- Totals: upar YA neeche dono dhoondo ----
    Map<String, dynamic> totals =
        (json['totals'] as Map<String, dynamic>?) ?? {};

    if (totals.isEmpty) {
      // checkout response kabhi kabhi seedha fields deta hai
      final totalRaw = json['total']?.toString();
      if (totalRaw != null) totals = {'total': totalRaw};
    }

    // ---- Minor units handle (78000 = Rs 780) ----
    double divisor = 1;
    final minorUnit =
        int.tryParse(totals['currency_minor_unit']?.toString() ?? '0') ?? 0;
    for (var i = 0; i < minorUnit; i++) {
      divisor *= 10;
    }

    double totalRaw = double.tryParse(totals['total']?.toString() ?? '0') ?? 0;

    // Agar total bohat bara hai aur minor_unit nahi mila → 2 decimal assume
    if (totalRaw > 100000 && divisor == 1) {
      divisor = 100;
    }

    return OrderResult(
      orderNumber: orderNumber,
      orderKey: orderKey,
      rawStatus: rawStatus,
      totalRs: (totalRaw / divisor).round(),
    );
  }

  /// Status ko user-friendly text mein.
  String get statusDisplay {
    switch (rawStatus) {
      case 'pending':
        return 'Pending';
      case 'processing':
        return 'Processing';
      case 'on-hold':
        return 'On Hold — awaiting payment';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return rawStatus.isNotEmpty ? rawStatus : 'Unknown';
    }
  }
}
