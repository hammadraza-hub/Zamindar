import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../services/cart_provider.dart';
import 'checkout_screen.dart';
import 'account_screen.dart';

// ============================================================================
// CART SCREEN
//
// Structure:
//   [App Bar] → [Items List] → [Price Summary] → [PROCEED TO CHECKOUT]
//
// BottomNavigationBar yahan intentional nahi hai —
// MainNavigationScreen handle karta hai
// ============================================================================

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // ==========================================================================
  // 1. HELPERS
  // ==========================================================================

  /// 1250 → "1,250"
  String _formatPrice(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }

  /// Snackbar message
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
  // 2. PROCEED TO CHECKOUT
  //
  // Ab pehle CHECKOUT screen khulti hai:
  //   Cart → Checkout (address + summary + payment)
  //   → PLACE ORDER → OrderSuccess
  //
  // Cart clear YAHAN nahi — PLACE ORDER par hota hai!
  // ==========================================================================

  void _proceedToCheckout() {
    final CartProvider cart = context.read<CartProvider>();

    // Cart khali → checkout nahi
    if (cart.items.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CheckoutScreen()),
    );
  }
  // ==========================================================================
  // 3. QUANTITY BUTTON (gol chhota - / + button)
  // ==========================================================================

  Widget _buildQtyButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Color(0xFFF0EEEE),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: const Color(0xFF333333)),
      ),
    );
  }

  // ==========================================================================
  // 4. CART ITEM CARD
  //
  // [Image] → [Name + Price + (qty -/+ ... trash)]
  // ==========================================================================

  Widget _buildCartItemCard(CartItem item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- Product Image ----
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              item.image,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(width: 12),

          // ---- Details ----
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF303030),
                  ),
                ),

                const SizedBox(height: 4),

                // Unit price
                Text(
                  'Rs ${_formatPrice(item.price)}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF087524),
                  ),
                ),

                const SizedBox(height: 10),

                // Qty stepper + remove
                Row(
                  children: [
                    // ---- (-) Minus ----
                    _buildQtyButton(
                      icon: Icons.remove,
                      onTap: () {
                        context.read<CartProvider>().decreaseQuantity(item.id);
                      },
                    ),

                    // ---- Quantity ----
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '${item.quantity}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF303030),
                        ),
                      ),
                    ),

                    // ---- (+) Plus ----
                    _buildQtyButton(
                      icon: Icons.add,
                      onTap: () {
                        context.read<CartProvider>().increaseQuantity(item.id);
                      },
                    ),

                    const Spacer(),

                    // ---- Remove (trash) ----
                    InkWell(
                      onTap: () {
                        context.read<CartProvider>().removeProduct(item.id);

                        _showMessage('${item.name} removed');
                      },
                      borderRadius: BorderRadius.circular(50),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.delete_outline,
                          size: 22,
                          color: Color(0xFF777777),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // 5. SUMMARY ROW (Subtotal / Delivery / Total)
  // ==========================================================================

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: isTotal ? 15 : 13,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
              color: isTotal
                  ? const Color(0xFF303030)
                  : const Color(0xFF666666),
            ),
          ),

          Text(
            value,
            style: isTotal
                ? GoogleFonts.plusJakartaSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF087524),
                  )
                : GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: const Color(0xFF303030),
                  ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // 6. EMPTY CART STATE
  // ==========================================================================

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Color(0xFFF0EEEE),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              size: 38,
              color: Color(0xFF087524),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Your cart is empty',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF303030),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Add products from Home or Categories',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: const Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // 7. MAIN UI
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    // Cart WATCH — koi bhi change par khud rebuild
    final CartProvider cart = context.watch<CartProvider>();

    final bool isEmpty = cart.items.isEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F7),

      body: SafeArea(
        child: Column(
          children: [
            // ================================================================
            // APP BAR — Logo + Title + Search + Profile
            // ================================================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/zamindar_logo.png',
                    width: 70,
                    height: 45,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(width: 8),

                  Text(
                    'Cart',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF087524),
                    ),
                  ),

                  const Spacer(),

                  IconButton(
                    onPressed: () {
                      _showMessage('Search clicked');
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                    icon: const Icon(
                      Icons.search,
                      size: 27,
                      color: Color(0xFF333333),
                    ),
                  ),

                  const SizedBox(width: 14),

                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AccountScreen(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                        color: Color(0xFF087524),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 1, color: Color(0xFFF0EEEE)),

            // ================================================================
            // ITEMS LIST / EMPTY STATE
            // ================================================================
            Expanded(
              child: isEmpty
                  ? _buildEmptyCart()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(24, 18, 24, 6),
                      itemCount: cart.items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _buildCartItemCard(cart.items[index]);
                      },
                    ),
            ),

            // ================================================================
            // SUMMARY + PROCEED BUTTON (sirf items hone par)
            // ================================================================
            if (!isEmpty) ...[
              // ---- Summary Card ----
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
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
                      _buildSummaryRow(
                        'Subtotal (${cart.totalItems} items)',
                        'Rs ${_formatPrice(cart.subtotal)}',
                      ),

                      _buildSummaryRow(
                        'Delivery Fee',
                        cart.deliveryFee == 0
                            ? 'Free'
                            : 'Rs ${_formatPrice(cart.deliveryFee)}',
                      ),

                      const Divider(color: Color(0xFFF0EEEE)),

                      _buildSummaryRow(
                        'Total',
                        'Rs ${_formatPrice(cart.totalAmount)}',
                        isTotal: true,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ---- PROCEED TO CHECKOUT ----
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _proceedToCheckout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF087524),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'PROCEED TO CHECKOUT',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
