import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../services/cart_provider.dart';
import 'order_success_screen.dart';

// ============================================================================
// CHECKOUT SCREEN
//
// Flow: Cart → PROCEED TO CHECKOUT → YE SCREEN → PLACE ORDER → Success
// ============================================================================

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // ==========================================================================
  // 1. DELIVERY ADDRESS (editable — Change button se update hoti hai)
  // ==========================================================================

  String _addressName = 'Ahmed Khan';
  String _addressPhone = '+92 300 1234567';
  String _addressLine = 'Haq Bahu Farm, Chak 45-SB, Sargodha, Punjab';

  // ==========================================================================
  // 2. HELPERS
  // ==========================================================================

  String _formatPrice(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }

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
  // 2b. CHANGE ADDRESS — sheet kholta hai
  //
  // Sheet ka content alag widget (_ChangeAddressSheet) hai — file
  // ke end par. Controllers/keyboard uske apne lifecycle mein hain.
  // ==========================================================================

  Future<void> _changeAddress() async {
    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,

      // Keyboard khulne par sheet upar uth ti hai
      isScrollControlled: true,

      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),

      builder: (sheetContext) {
        return _ChangeAddressSheet(
          currentName: _addressName,
          currentPhone: _addressPhone,
          currentAddress: _addressLine,
        );
      },
    );

    // SAVE hua → address update
    if (result != null) {
      setState(() {
        _addressName = result['name']!;
        _addressPhone = result['phone']!;
        _addressLine = result['address']!;
      });

      _showMessage('Delivery address updated');
    }
  }

  // ==========================================================================
  // 3. PLACE ORDER
  //
  // ORDER: COPY → TOTAL → CLEAR → OrderSuccess
  // (COPY hamesha CLEAR se PEHLE!)
  // ==========================================================================

  void _placeOrder() {
    final CartProvider cart = context.read<CartProvider>();

    if (cart.items.isEmpty) return;

    // (1) COPY — cart items ki snapshot
    final List<CartItem> orderedItems = List<CartItem>.from(cart.items);

    // (2) TOTAL
    final int orderTotal = cart.subtotal + cart.deliveryFee;

    // (3) CLEAR — order complete
    cart.clearCart();

    // (4) OrderSuccess — real data ke saath
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            OrderSuccessScreen(items: orderedItems, totalAmount: orderTotal),
      ),
    );
  }

  // ==========================================================================
  // 4. ITEM ROW (Order Summary ke andar)
  // ==========================================================================

  Widget _buildItemRow(CartItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          // --- Product Image ---
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              item.image,
              width: 52,
              height: 52,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(width: 12),

          // --- Name + Qty ---
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

          // --- Line Total ---
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
  // 5. PRICE ROW (Subtotal / Delivery / Total)
  // ==========================================================================

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
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
  // 6. PAYMENT OPTION (radio style)
  // ==========================================================================

  Widget _buildPaymentOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),

      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        margin: const EdgeInsets.only(bottom: 10),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF087524)
                : const Color(0xFFD5E2D3),
          ),
        ),

        child: Row(
          children: [
            // Icon
            Icon(icon, size: 22, color: const Color(0xFF087524)),

            const SizedBox(width: 14),

            // Title + Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF303030),
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: const Color(0xFF777777),
                    ),
                  ),
                ],
              ),
            ),

            // Radio Circle (selected = green dot)
            Container(
              width: 20,
              height: 20,

              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF087524), width: 2),
              ),

              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFF087524),
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // 7. CARD DECORATION (sab cards same style)
  // ==========================================================================

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  // ==========================================================================
  // 8. MAIN UI
  //
  // Scroll: [Header] → [Address] → [Order Summary] → [Payment]
  // Fixed bottom: [Subtotal/Delivery/Total] → [PLACE ORDER]
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    // LIVE cart data — screen khud CartProvider se parhti hai
    final CartProvider cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F7),

      body: SafeArea(
        child: Column(
          children: [
            // ================================================================
            // SCROLLABLE PART
            // ================================================================
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),

                    // --- Header: Back + Title ---
                    Row(
                      children: [
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(30),
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(
                              Icons.arrow_back,
                              size: 25,
                              color: Color(0xFF087524),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Text(
                          'Checkout',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1B1C1C),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ==========================================================
                    // DELIVERY ADDRESS CARD
                    // ==========================================================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: _cardDecoration(),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title + Change
                          Row(
                            children: [
                              // Location icon circle
                              Container(
                                width: 36,
                                height: 36,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFDCE8DA),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.location_on_outlined,
                                  size: 19,
                                  color: Color(0xFF087524),
                                ),
                              ),

                              const SizedBox(width: 12),

                              Text(
                                'Delivery Address',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF303030),
                                ),
                              ),

                              const Spacer(),

                              // Change → address edit sheet
                              InkWell(
                                onTap: _changeAddress,
                                child: Text(
                                  'Change',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF087524),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // Name + Phone
                          Row(
                            children: [
                              Text(
                                _addressName,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1B1C1C),
                                ),
                              ),

                              const SizedBox(width: 10),

                              Text(
                                _addressPhone,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: const Color(0xFF777777),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 4),

                          // Address line
                          Text(
                            _addressLine,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              height: 1.4,
                              color: const Color(0xFF666666),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ==========================================================
                    // ORDER SUMMARY CARD (REAL cart items)
                    // ==========================================================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 6),
                      decoration: _cardDecoration(),

                      child: cart.items.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                'Your cart is empty',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  color: const Color(0xFF666666),
                                ),
                              ),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title
                                Text(
                                  'Order Summary (${cart.totalItems} items)',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF303030),
                                  ),
                                ),

                                // Items + dividers
                                for (int i = 0; i < cart.items.length; i++) ...[
                                  _buildItemRow(cart.items[i]),

                                  if (i < cart.items.length - 1)
                                    const Divider(
                                      height: 1,
                                      color: Color(0xFFF0EEEE),
                                    ),
                                ],
                              ],
                            ),
                    ),

                    const SizedBox(height: 16),

                    // ==========================================================
                    // PAYMENT METHOD
                    // ==========================================================
                    Text(
                      'Payment Method',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF303030),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // COD — selected
                    _buildPaymentOption(
                      icon: Icons.payments_outlined,
                      title: 'Cash on Delivery (COD)',
                      subtitle: 'Pay cash when order arrives',
                      isSelected: true,
                      onTap: () {},
                    ),

                    // JazzCash — coming soon
                    _buildPaymentOption(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'JazzCash',
                      subtitle: 'Coming soon',
                      isSelected: false,
                      onTap: () {
                        _showMessage('JazzCash coming soon');
                      },
                    ),

                    // Easypaisa — coming soon
                    _buildPaymentOption(
                      icon: Icons.account_balance_outlined,
                      title: 'Easypaisa',
                      subtitle: 'Coming soon',
                      isSelected: false,
                      onTap: () {
                        _showMessage('Easypaisa coming soon');
                      },
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // ================================================================
            // FIXED BOTTOM — Price Summary + PLACE ORDER
            // ================================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 16),

              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFF0EEEE))),
              ),

              child: Column(
                children: [
                  // Subtotal
                  _buildPriceRow(
                    'Subtotal (${cart.totalItems} items)',
                    'Rs ${_formatPrice(cart.subtotal)}',
                  ),

                  // Delivery Charges (Rs 2000+ = FREE)
                  _buildPriceRow(
                    'Delivery Charges',
                    cart.deliveryFee == 0
                        ? 'FREE'
                        : 'Rs ${_formatPrice(cart.deliveryFee)}',
                  ),

                  const Divider(color: Color(0xFFF0EEEE)),

                  // Total
                  _buildPriceRow(
                    'Total',
                    'Rs ${_formatPrice(cart.totalAmount)}',
                    isTotal: true,
                  ),

                  const SizedBox(height: 14),

                  // --- PLACE ORDER BUTTON ---
                  SizedBox(
                    width: double.infinity,
                    height: 52,

                    child: ElevatedButton(
                      onPressed: cart.items.isEmpty ? null : _placeOrder,

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF087524),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFFD5E2D3),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),

                      child: Text(
                        'PLACE ORDER',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// CHANGE ADDRESS SHEET (bottom sheet ka content — alag widget)
//
// Alag widget isliye: controllers + keyboard ka lifecycle apne
// control mein → framework assertion bug (red error) se bachav
// ============================================================================

class _ChangeAddressSheet extends StatefulWidget {
  final String currentName;
  final String currentPhone;
  final String currentAddress;

  const _ChangeAddressSheet({
    required this.currentName,
    required this.currentPhone,
    required this.currentAddress,
  });

  @override
  State<_ChangeAddressSheet> createState() => _ChangeAddressSheetState();
}

class _ChangeAddressSheetState extends State<_ChangeAddressSheet> {
  // ==========================================================================
  // 1. CONTROLLERS (current values se pre-filled)
  // ==========================================================================

  late final TextEditingController _nameController = TextEditingController(
    text: widget.currentName,
  );

  late final TextEditingController _phoneController = TextEditingController(
    text: widget.currentPhone,
  );

  late final TextEditingController _addressController = TextEditingController(
    text: widget.currentAddress,
  );

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // ==========================================================================
  // 2. DISPOSE — controllers cleanup (widget ke saath)
  // ==========================================================================

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();

    super.dispose();
  }

  // ==========================================================================
  // 3. SAVE — validate → keyboard band → values wapas
  // ==========================================================================

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    // Keyboard PEHLE band — race condition se bachav
    FocusScope.of(context).unfocus();

    Navigator.pop(context, {
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'address': _addressController.text.trim(),
    });
  }

  // ==========================================================================
  // 4. TEXT FIELD
  // ==========================================================================

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required TextInputType keyboardType,
    int maxLines = 1,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,

      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF087524)),

        filled: true,
        fillColor: const Color(0xFFFCF9F7),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD5E2D3)),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD5E2D3)),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF087524)),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFC62828)),
        ),
      ),
    );
  }

  // ==========================================================================
  // 5. MAIN UI — handle → title → 3 fields → SAVE
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Keyboard-aware padding — APNE context se (safe)
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),

      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),

        child: Form(
          key: _formKey,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Drag handle ---
              Center(
                child: Container(
                  width: 45,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD0D0D0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // --- Title ---
              Text(
                'Change Delivery Address',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 20),

              // --- Full Name ---
              _buildField(
                controller: _nameController,
                label: 'Full Name',
                icon: Icons.person_outline,
                keyboardType: TextInputType.name,
                validator: (value) {
                  if (value == null || value.trim().length < 3) {
                    return 'Please enter a valid name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 14),

              // --- Phone ---
              _buildField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().length < 10) {
                    return 'Phone must be at least 10 digits';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 14),

              // --- Address (multi-line) ---
              _buildField(
                controller: _addressController,
                label: 'Complete Address',
                icon: Icons.location_on_outlined,
                keyboardType: TextInputType.streetAddress,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().length < 10) {
                    return 'Please enter complete address';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // --- SAVE button ---
              SizedBox(
                width: double.infinity,
                height: 52,

                child: ElevatedButton(
                  onPressed: _save,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF087524),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  child: Text(
                    'SAVE ADDRESS',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
