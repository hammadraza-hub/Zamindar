import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../services/api/checkout_service.dart';
import '../services/auth/auth_service.dart';
import '../services/cart_provider.dart';
import '../widgets/custom_button.dart';
import 'order_success_screen.dart';
import '../services/address_service.dart';

// ============================================================================
// CHECKOUT SCREEN — ASLI ORDER (WooCommerce Store API)
//
// Flow: Cart → YE SCREEN → PLACE ORDER → asli order website par → Success
// ============================================================================

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // ==========================================================================
  // 1. DELIVERY ADDRESS (complete — order ke liye zaroori fields)
  // ==========================================================================

  String _addressName = '';
  String _addressPhone = '';
  String _addressEmail = '';
  String _addressLine = '';
  String _addressCity = '';
  String _addressState = 'Punjab';
  String _addressPostcode = '';

  /// Selected payment — 'bank_transfer' ya 'cod'
  String _selectedPayment = 'bank_transfer';

  bool _isPlacingOrder = false;
  bool _orderPlaced = false; // ek hi order per screen
  @override
  void initState() {
    super.initState();

    // Saved address + login info load karo
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // ---- (1) Saved address (pehle se bhari rahe!) ----
      final saved = await AddressService.load();

      if (!mounted) return;

      // ---- (2) Login user ka naam/email (fallback) ----
      final auth = context.read<AuthProvider>();

      setState(() {
        if (saved != null) {
          _addressName = saved['name']!;
          _addressPhone = saved['phone']!;
          _addressEmail = saved['email']!;
          _addressLine = saved['address']!;
          _addressCity = saved['city']!;
          _addressState = saved['state']!;
          _addressPostcode = saved['postcode']!;
        } else if (auth.isLoggedIn) {
          // Saved nahi → kam az kam naam/email to bhar do
          _addressName = auth.userName;
          _addressEmail = auth.userEmail;
        }
      });
    });
  }

  // ==========================================================================
  // 2. HELPERS
  // ==========================================================================

  String _formatPrice(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.plusJakartaSans(color: Colors.white),
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: isError
            ? const Color(0xFFC62828)
            : const Color(0xFF087524),
      ),
    );
  }

  // ==========================================================================
  // 2b. CHANGE ADDRESS — complete address sheet
  // ==========================================================================

  Future<void> _changeAddress() async {
    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return _ChangeAddressSheet(
          currentName: _addressName,
          currentPhone: _addressPhone,
          currentEmail: _addressEmail,
          currentAddress: _addressLine,
          currentCity: _addressCity,
          currentState: _addressState,
          currentPostcode: _addressPostcode,
        );
      },
    );

    if (result != null) {
      setState(() {
        _addressName = result['name']!;
        _addressPhone = result['phone']!;
        _addressEmail = result['email']!;
        _addressLine = result['address']!;
        _addressCity = result['city']!;
        _addressState = result['state']!;
        _addressPostcode = result['postcode']!;
      });

      // ---- PERMANENT SAVE (agli baar pehle se bhari rahe!) ----
      await AddressService.save(
        name: _addressName,
        phone: _addressPhone,
        email: _addressEmail,
        addressLine: _addressLine,
        city: _addressCity,
        state: _addressState,
        postcode: _addressPostcode,
      );

      _showMessage('Delivery address saved');
    }
  }

  // ==========================================================================
  // 3. PLACE ORDER — ASLI WooCommerce ORDER!
  // ==========================================================================

  Future<void> _placeOrder() async {
    // --- GUARD: order chal raha hai YA ho chuka ---
    if (_isPlacingOrder || _orderPlaced) return;

    setState(() => _isPlacingOrder = true);

    // --- GUARD 2: cart reference pehle le lo ---
    final CartProvider cart = context.read<CartProvider>();

    if (cart.items.isEmpty) {
      setState(() => _isPlacingOrder = false);
      return;
    }

    try {
      // ---- Naam first/last mein ----
      final nameParts = _addressName.trim().split(RegExp(r'\s+'));
      final String firstName = nameParts.isNotEmpty ? nameParts.first : '';
      final String lastName = nameParts.length > 1
          ? nameParts.sublist(1).join(' ')
          : '';

      // ---- Address object ----
      final address = BillingAddress(
        firstName: firstName,
        lastName: lastName,
        phone: _addressPhone,
        email: _addressEmail,
        address1: _addressLine,
        city: _addressCity,
        state: _addressState,
        postcode: _addressPostcode,
      );

      // ---- JWT token (login user ho to order uske naam) ----
      final token = await AuthService.getToken();

      // ---- ASLI ORDER! ----
      final result = await CheckoutService.placeOrder(
        items: cart.items,
        address: address,
        paymentMethod: _selectedPayment == 'cod' ? 'cod' : 'bacs',
        jwtToken: token,
      );

      if (!mounted) return;

      // ---- ORDER PLACED flag (dobara kabhi na chale!) ----
      _orderPlaced = true;

      // ---- Cart snapshot (success screen ke liye) ----
      final List<CartItem> orderedItems = List<CartItem>.from(cart.items);

      // ---- ORDER PLACED flag (rebuild par dobara na chale!) ----
      _orderPlaced = true;

      // ---- Local total capture (server total nahi bhejta!) ----
      final int localTotal = cart.totalAmount;

      // ---- Cart clear ----
      cart.clearCart();
      // ---- SUCCESS — ASLI order number ke sath! ----
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OrderSuccessScreen(
            items: orderedItems,
            totalAmount: result.totalRs > 0 ? result.totalRs : localTotal,
            paymentMethod: _selectedPayment == 'cod'
                ? 'Cash on Delivery'
                : 'Direct Bank Transfer',
            realOrderNumber: result.orderNumber.toString(),
            orderStatus: result.statusDisplay,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => _isPlacingOrder = false);
      _showMessage(e.toString(), isError: true);
    }
  }

  // ==========================================================================
  // 3b. SMART ITEM IMAGE (network + asset dono support)
  // ==========================================================================

  Widget _buildItemImage(String image) {
    if (image.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: image,
        width: 52,
        height: 52,
        fit: BoxFit.cover,
        placeholder: (_, _) => _imagePlaceholder(),
        errorWidget: (_, _, _) => _imagePlaceholder(),
      );
    }

    if (image.isNotEmpty) {
      return Image.asset(
        image,
        width: 52,
        height: 52,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _imagePlaceholder(),
      );
    }

    return _imagePlaceholder();
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 52,
      height: 52,
      color: const Color(0xFFF0EEEE),
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_outlined,
        size: 20,
        color: Color(0xFFBBBBBB),
      ),
    );
  }

  // ==========================================================================
  // 4. ITEM ROW
  // ==========================================================================

  Widget _buildItemRow(CartItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: _buildItemImage(item.image),
          ),

          const SizedBox(width: 12),

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
  // 5. PRICE ROW
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
  // 6. PAYMENT OPTION
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
            Icon(icon, size: 22, color: const Color(0xFF087524)),
            const SizedBox(width: 14),
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
  // 7. CARD DECORATION
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
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
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

                    // --- Header ---
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
                          Row(
                            children: [
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
                              InkWell(
                                onTap: _changeAddress,
                                child: Text(
                                  _addressName.isEmpty ? 'Add' : 'Change',
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

                          if (_addressName.isEmpty)
                            Text(
                              'Please add your delivery address to place the order.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                height: 1.4,
                                color: const Color(0xFF999999),
                              ),
                            )
                          else ...[
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _addressName,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1B1C1C),
                                    ),
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
                            Text(
                              '$_addressLine, $_addressCity, $_addressState'
                              '${_addressPostcode.isNotEmpty ? ', $_addressPostcode' : ''}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                height: 1.4,
                                color: const Color(0xFF666666),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _addressEmail,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: const Color(0xFF999999),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ==========================================================
                    // ORDER SUMMARY
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
                                Text(
                                  'Order Summary (${cart.totalItems} items)',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF303030),
                                  ),
                                ),
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

                    _buildPaymentOption(
                      icon: Icons.account_balance_outlined,
                      title: 'Direct Bank Transfer',
                      subtitle: 'Pay directly into our bank account — use Order ID as reference',
                      isSelected: _selectedPayment == 'bank_transfer',
                      onTap: () {
                        setState(() {
                          _selectedPayment = 'bank_transfer';
                        });
                      },
                    ),

                    _buildPaymentOption(
                      icon: Icons.payments_outlined,
                      title: 'Cash on Delivery',
                      subtitle: 'Pay with cash upon delivery',
                      isSelected: _selectedPayment == 'cod',
                      onTap: () {
                        setState(() {
                          _selectedPayment = 'cod';
                        });
                      },
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // ================================================================
            // FIXED BOTTOM — Summary + PLACE ORDER (loading ke sath!)
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
                  _buildPriceRow(
                    'Subtotal (${cart.totalItems} items)',
                    'Rs ${_formatPrice(cart.subtotal)}',
                  ),
                  _buildPriceRow(
                    'Delivery Charges',
                    cart.deliveryFee == 0
                        ? 'FREE'
                        : 'Rs ${_formatPrice(cart.deliveryFee)}',
                  ),
                  const Divider(color: Color(0xFFF0EEEE)),
                  _buildPriceRow(
                    'Total',
                    'Rs ${_formatPrice(cart.totalAmount)}',
                    isTotal: true,
                  ),
                  const SizedBox(height: 14),

                  // PLACE ORDER — CustomButton (M0 ka button ab kaam aaya!)
                  CustomButton(
                    text: _isPlacingOrder ? 'PLACING ORDER...' : 'PLACE ORDER',
                    isLoading: _isPlacingOrder,
                    onPressed:
                        cart.items.isEmpty ||
                            _addressName.isEmpty ||
                            _isPlacingOrder
                        ? null
                        : _placeOrder,
                    backgroundColor: const Color(0xFF087524),
                    height: 52,
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
// CHANGE ADDRESS SHEET — complete form (order ke liye saare fields)
// ============================================================================

class _ChangeAddressSheet extends StatefulWidget {
  final String currentName;
  final String currentPhone;
  final String currentEmail;
  final String currentAddress;
  final String currentCity;
  final String currentState;
  final String currentPostcode;

  const _ChangeAddressSheet({
    required this.currentName,
    required this.currentPhone,
    required this.currentEmail,
    required this.currentAddress,
    required this.currentCity,
    required this.currentState,
    required this.currentPostcode,
  });

  @override
  State<_ChangeAddressSheet> createState() => _ChangeAddressSheetState();
}

class _ChangeAddressSheetState extends State<_ChangeAddressSheet> {
  static const List<String> _provinces = [
    'Punjab',
    'Sindh',
    'Khyber Pakhtunkhwa',
    'Balochistan',
    'Islamabad Capital Territory',
    'Gilgit-Baltistan',
    'Azad Jammu & Kashmir',
  ];

  late final TextEditingController _nameController = TextEditingController(
    text: widget.currentName,
  );
  late final TextEditingController _phoneController = TextEditingController(
    text: widget.currentPhone,
  );
  late final TextEditingController _emailController = TextEditingController(
    text: widget.currentEmail,
  );
  late final TextEditingController _addressController = TextEditingController(
    text: widget.currentAddress,
  );
  late final TextEditingController _cityController = TextEditingController(
    text: widget.currentCity,
  );
  late final TextEditingController _postcodeController = TextEditingController(
    text: widget.currentPostcode,
  );

  late String _selectedProvince = _provinces.contains(widget.currentState)
      ? widget.currentState
      : 'Punjab';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postcodeController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    Navigator.pop(context, {
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'email': _emailController.text.trim(),
      'address': _addressController.text.trim(),
      'city': _cityController.text.trim(),
      'state': _selectedProvince,
      'postcode': _postcodeController.text.trim(),
    });
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required TextInputType keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: GoogleFonts.plusJakartaSans(fontSize: 14),
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

  @override
  Widget build(BuildContext context) {
    return Padding(
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
              Text(
                'Delivery Address',
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
                validator: (v) => (v == null || v.trim().length < 3)
                    ? 'Enter a valid name'
                    : null,
              ),
              const SizedBox(height: 14),

              // --- Phone ---
              _buildField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (v) => (v == null || v.trim().length < 10)
                    ? 'Enter a valid phone number'
                    : null,
              ),
              const SizedBox(height: 14),

              // --- Email (order ke liye zaroori) ---
              _buildField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Email is required';
                  if (!RegExp(r'^[\w\.\-]+@[\w\-]+\.[\w\.]+$')
                      .hasMatch(v.trim())) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // --- Address ---
              _buildField(
                controller: _addressController,
                label: 'Complete Address',
                icon: Icons.location_on_outlined,
                keyboardType: TextInputType.streetAddress,
                maxLines: 2,
                validator: (v) => (v == null || v.trim().length < 10)
                    ? 'Enter complete address'
                    : null,
              ),
              const SizedBox(height: 14),

              // --- City ---
              _buildField(
                controller: _cityController,
                label: 'City',
                icon: Icons.location_city_outlined,
                keyboardType: TextInputType.text,
                validator: (v) =>
                    (v == null || v.trim().length < 2) ? 'Enter city' : null,
              ),
              const SizedBox(height: 14),

              // --- Province dropdown ---
              DropdownButtonFormField<String>(
                initialValue: _selectedProvince,
                decoration: InputDecoration(
                  labelText: 'Province',
                  prefixIcon: const Icon(
                    Icons.map_outlined,
                    color: Color(0xFF087524),
                  ),
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
                ),
                items: _provinces
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedProvince = value);
                  }
                },
              ),
              const SizedBox(height: 14),

              // --- Postcode (optional) ---
              _buildField(
                controller: _postcodeController,
                label: 'Postal Code (optional)',
                icon: Icons.markunread_mailbox_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),

              // --- SAVE ---
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
