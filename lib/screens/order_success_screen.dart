import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/cart_provider.dart';
import 'main_navigation_screen.dart';

// ============================================================================
// ORDER SUCCESS SCREEN
//
// Checkout complete hone par ye screen dikhti hai.
// REAL cart data show karti hai jo Cart screen se pass hua:
//   - Unique Order ID      (har order ka apna ID)
//   - Order Date
//   - Estimated Delivery   (2-3 days)
//   - Payment Method       (Cash on Delivery)
//   - Items + images + quantities + prices
//   - Total Amount
//
// Cart pehle hi clear ho chuka hota hai — data constructor
// mein snapshot ki tarah aata hai.
// ============================================================================

class OrderSuccessScreen extends StatefulWidget {
  final List<CartItem> items;
  final int totalAmount;
  final String paymentMethod; // ← NAYA

  const OrderSuccessScreen({
    super.key,
    required this.items,
    required this.totalAmount,
    this.paymentMethod = 'Cash on Delivery', // ← NAYA
  });

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> {
  // ==========================================================================
  // 1. ORDER ID + DATE
  //
  // late final → sirf ek baar banta hai, har rebuild par naya ID nahi
  // ==========================================================================

  /// Unique Order ID — example: ZM20250115-8421
  late final String _orderId = _generateOrderId();

  /// Order ki date
  late final DateTime _orderDate = DateTime.now();

  String _generateOrderId() {
    final now = DateTime.now();

    // 5 → "05" (2 digits)
    String two(int n) => n.toString().padLeft(2, '0');

    return 'ZM${now.year}${two(now.month)}${two(now.day)}'
        '-${now.millisecondsSinceEpoch % 10000}';
  }

  /// 15/01/2025 format
  String get _formattedDate {
    String two(int n) => n.toString().padLeft(2, '0');

    return '${two(_orderDate.day)}/${two(_orderDate.month)}/${_orderDate.year}';
  }

  // ==========================================================================
  // 2. PRICE FORMATTER — 1250 → "1,250"
  // ==========================================================================

  String _formatPrice(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }

  // ==========================================================================
  // 3. SNACKBAR MESSAGE
  //
  // Abhi sirf TRACK ORDER ke liye — tracking screen abhi nahi bani.
  // (Order History step mein is ko real screen se replace karenge)
  // ==========================================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.plusJakartaSans(color: Colors.white),
        ),
        duration: const Duration(seconds: 1),
        backgroundColor: const Color(0xFF087524),
      ),
    );
  }

  // ==========================================================================
  // 4. DETAIL ROW (Order Details card ke andar ek row)
  //
  // [Icon] → Label → ......... → Value
  // ==========================================================================

  Widget _detailRow({
    required String label,
    required String value,
    IconData? icon,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // ---- Optional icon (left) ----
          if (icon != null) ...[
            Icon(icon, size: 18, color: const Color(0xFF087524)),
            const SizedBox(width: 10),
          ],

          // ---- Label ----
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: const Color(0xFF666666),
            ),
          ),

          const Spacer(),

          // ---- Value (right) ----
          Flexible(
            child: Text(
              value,
              style: isTotal
                  ? GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF087524),
                    )
                  : GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF303030),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // 4b. SMART ITEM IMAGE (network + asset dono support)
  //
  // API products ki image internet URL hoti hai (http...),
  // purane hardcoded products ki local asset (assets/...).
  // Yeh widget dono handle karta hai + empty case bhi.
  // ==========================================================================

  Widget _buildItemImage(String image) {
    // ---- Internet image (API product) ----
    if (image.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: image,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        placeholder: (_, _) => _imagePlaceholder(),
        errorWidget: (_, _, _) => _imagePlaceholder(),
      );
    }

    // ---- Local asset image (purana hardcoded product) ----
    if (image.isNotEmpty) {
      return Image.asset(
        image,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _imagePlaceholder(),
      );
    }

    // ---- Koi image nahi ----
    return _imagePlaceholder();
  }

  /// Jab image load na ho / exist na kare.
  Widget _imagePlaceholder() {
    return Container(
      width: 56,
      height: 56,
      color: const Color(0xFFF0EEEE),
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_outlined,
        size: 22,
        color: Color(0xFFBBBBBB),
      ),
    );
  }

  // ==========================================================================
  // 5. ITEM ROW (Items card ke andar ek product)
  //
  // [Image] → [Name + Qty × Price] → [Line Total]
  // ==========================================================================

  Widget _buildItemRow(CartItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          // ---- Product Image (network + asset dono support) ----
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: _buildItemImage(item.image),
          ),

          const SizedBox(width: 12),

          // ---- Name + Quantity ----
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF303030),
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  'Qty ${item.quantity} × Rs ${_formatPrice(item.price)}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: const Color(0xFF777777),
                  ),
                ),
              ],
            ),
          ),

          // ---- Line Total (price × quantity) ----
          Text(
            'Rs ${_formatPrice(item.price * item.quantity)}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF087524),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // 6. MAIN UI
  //
  // Structure (upar se neeche):
  //   Green Check → Title → Order Details Card (ID / Date / Delivery /
  //   Payment / Total) → Items Card → [TRACK ORDER upar + CONTINUE
  //   SHOPPING neeche] → Tagline
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Back button se ye screen nahi chhutti —
      // user sirf "CONTINUE SHOPPING" se aage barhe
      canPop: false,

      child: Scaffold(
        backgroundColor: const Color(0xFFFCF9F7),

        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 36),

                // ================================================================
                // GREEN SUCCESS CHECK (pop animation ke saath)
                // ================================================================
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.elasticOut,

                  builder: (context, value, child) {
                    return Transform.scale(scale: value, child: child);
                  },

                  child: Container(
                    width: 92,
                    height: 92,
                    decoration: const BoxDecoration(
                      color: Color(0xFF087524),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ================================================================
                // TITLE + SUBTITLE
                // ================================================================
                Text(
                  'Order Placed Successfully!',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1B1C1C),
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Thank you for shopping with us',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: const Color(0xFF666666),
                  ),
                ),

                const SizedBox(height: 28),

                // ================================================================
                // CARD 1: ORDER DETAILS
                //
                // Delivery estimate is card ke ANDAR hai
                // (design ke mutabiq)
                // ================================================================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Order ID
                      _detailRow(
                        label: 'Order ID',
                        value: _orderId,
                        icon: Icons.receipt_long_outlined,
                      ),

                      // Order Date
                      _detailRow(
                        label: 'Order Date',
                        value: _formattedDate,
                        icon: Icons.calendar_today_outlined,
                      ),

                      // Estimated Delivery (2-3 days — design ke mutabiq)
                      _detailRow(
                        label: 'Estimated Delivery',
                        value: '2-3 days',
                        icon: Icons.local_shipping_outlined,
                      ),

                      // Payment Method
                      _detailRow(
                        label: 'Payment Method',
                        value: widget.paymentMethod, // ← fixed value ki jagah
                        icon: Icons.payments_outlined,
                      ),

                      const Divider(height: 1, color: Color(0xFFF0EEEE)),

                      // Total — green, bold
                      _detailRow(
                        label: 'Total (${widget.items.length} items)',
                        value: 'Rs ${_formatPrice(widget.totalAmount)}',
                        icon: Icons.shopping_bag_outlined,
                        isTotal: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ================================================================
                // CARD 2: ITEMS IN ORDER (REAL CART DATA)
                // ================================================================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Text(
                        'Items in Your Order (${widget.items.length})',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF303030),
                        ),
                      ),

                      // Har item + beech mein divider
                      for (int i = 0; i < widget.items.length; i++) ...[
                        _buildItemRow(widget.items[i]),

                        if (i < widget.items.length - 1)
                          const Divider(height: 1, color: Color(0xFFF0EEEE)),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ================================================================
                // BUTTONS — TRACK ORDER + CONTINUE SHOPPING
                // (upar neeche — ek column mein)
                // ================================================================

                // ---- 1) TRACK ORDER (outlined — secondary) ----
                //
                // NOTE: Tracking screen abhi nahi bani.
                // Order History step mein is ko real screen
                // se connect karenge. Filhal snackbar.
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      _showMessage('Order tracking coming soon');
                    },

                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF087524),
                      side: const BorderSide(color: Color(0xFF087524)),
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    child: Text(
                      'TRACK ORDER',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // ---- 2) CONTINUE SHOPPING (filled green — primary) ----
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Fresh start — MainNavigationScreen (Home tab)
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MainNavigationScreen(),
                        ),
                        (route) => false,
                      );
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF087524),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    child: Text(
                      'CONTINUE SHOPPING',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ================================================================
                // TAGLINE (design ke mutabiq)
                // ================================================================
                Text(
                  'Growing the future, one order at a time',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: const Color(0xFF777777),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
