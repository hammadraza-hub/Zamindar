import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../repositories/product_repository.dart';
import '../services/cart_provider.dart';
import 'cart_screen.dart';

// ============================================================================
// PRODUCT DETAIL SCREEN
//
// Home / Categories ke product card par tap karne par khulti hai.
//
//   - Bari product image (API se)
//   - Naam + category + price (sale par purani price bhi)
//   - Stock status
//   - Description (HTML saaf kar ke)
//   - Quantity stepper + ADD TO CART
//
// Data pehle list se aata hai (foran dikhta hai),
// phir background mein fresh data bhi laate hain.
// ============================================================================

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  // ==========================================================================
  // 1. STATE
  // ==========================================================================

  late Product _product;

  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _refreshProduct(); // background mein taza data
  }

  /// Single product API se dobara laata hai (full description ke liye).
  Future<void> _refreshProduct() async {
    try {
      final fresh = await ProductRepository().getProductById(widget.product.id);

      if (!mounted) return;

      setState(() => _product = fresh);
    } catch (_) {
      // Fail ho jaye to list wala data dikhate rahenge — koi masla nahi
    }
  }

  // ==========================================================================
  // 2. HELPERS
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

  void _addToCart() {
    final cart = context.read<CartProvider>();
    final String image = _product.imageThumbnailUrl ?? _product.imageUrl ?? '';

    for (int i = 0; i < _quantity; i++) {
      cart.addProduct(
        id: _product.id.toString(),
        name: _product.name,
        price: _product.price.round(),
        image: image,
      );
    }

    _showMessage('${_product.name} (x$_quantity) added to cart');
  }

  void _openCart() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CartScreen()),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: const Color(0xFFF0EEEE),
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_outlined,
        size: 48,
        color: Color(0xFFBBBBBB),
      ),
    );
  }

  // ==========================================================================
  // 3. QUANTITY BUTTON (gol - / +)
  // ==========================================================================

  Widget _buildQtyButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Color(0xFFF0EEEE),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF333333)),
      ),
    );
  }

  // ==========================================================================
  // 4. MAIN UI
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    final CartProvider cart = context.watch<CartProvider>();

    final String? imageUrl = _product.imageThumbnailUrl ?? _product.imageUrl;

    // Description — pehle full, warna short
    final String description = _product.plainDescription.isNotEmpty
        ? _product.plainDescription
        : _product.plainShortDescription;

    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F7),

      body: SafeArea(
        child: Column(
          children: [
            // ================================================================
            // TOP BAR — Back + Cart (badge ke sath)
            // ================================================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(30),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.arrow_back,
                        size: 25,
                        color: Color(0xFF087524),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // --- Cart button + badge ---
                  Stack(
                    children: [
                      InkWell(
                        onTap: _openCart,
                        borderRadius: BorderRadius.circular(30),
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            Icons.shopping_cart_outlined,
                            size: 25,
                            color: Color(0xFF087524),
                          ),
                        ),
                      ),

                      if (cart.totalItems > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF7900),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${cart.totalItems}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF202020),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // ================================================================
            // SCROLLABLE CONTENT
            // ================================================================
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---- Product Image (barai card mein) ----
                    Container(
                      width: double.infinity,
                      height: 300,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: imageUrl != null && imageUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.contain,
                                placeholder: (_, _) => _imagePlaceholder(),
                                errorWidget: (_, _, _) => _imagePlaceholder(),
                              )
                            : _imagePlaceholder(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ---- Category chips + Stock ----
                    Row(
                      children: [
                        // Category
                        if (_product.categoryNames.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCE8DA),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _product.categoryNames.first,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF087524),
                              ),
                            ),
                          ),

                        const Spacer(),

                        // Stock badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _product.inStock
                                ? const Color(0xFFDCE8DA)
                                : const Color(0xFFF6DADA),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _product.inStock
                                    ? Icons.check_circle_outline
                                    : Icons.cancel_outlined,
                                size: 14,
                                color: _product.inStock
                                    ? const Color(0xFF087524)
                                    : const Color(0xFFC62828),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                _product.inStock ? 'In Stock' : 'Out of Stock',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _product.inStock
                                      ? const Color(0xFF087524)
                                      : const Color(0xFFC62828),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // ---- Naam ----
                    Text(
                      _product.name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                        color: const Color(0xFF1B1C1C),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ---- Price + old price ----
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _product.displayPrice,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF087524),
                          ),
                        ),

                        if (_product.onSale) ...[
                          const SizedBox(width: 10),

                          Text(
                            _product.displayRegularPrice,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              color: const Color(0xFF999999),
                              decoration: TextDecoration.lineThrough,
                              decorationColor: const Color(0xFF999999),
                            ),
                          ),

                          const SizedBox(width: 8),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF7900),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'SALE',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF202020),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 8),

                    // ---- Rating / Reviews (agar hain) ----
                    if (_product.reviewCount > 0)
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 15,
                            color: Color(0xFFA54B00),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_product.averageRating.toStringAsFixed(1)} '
                            '(${_product.reviewCount} reviews)',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: const Color(0xFF777777),
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 20),
                    const Divider(color: Color(0xFFF0EEEE)),

                    // ---- Description ----
                    const SizedBox(height: 8),

                    Text(
                      'Description',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF303030),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      description.isNotEmpty
                          ? description
                          : 'No description available for this product.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        height: 1.6,
                        color: const Color(0xFF555555),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ================================================================
            // FIXED BOTTOM — Quantity + ADD TO CART
            // ================================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFF0EEEE))),
              ),
              child: Row(
                children: [
                  // ---- Quantity Stepper ----
                  Row(
                    children: [
                      _buildQtyButton(
                        icon: Icons.remove,
                        onTap: () {
                          if (_quantity > 1) {
                            setState(() => _quantity--);
                          }
                        },
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Text(
                          '$_quantity',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF303030),
                          ),
                        ),
                      ),

                      _buildQtyButton(
                        icon: Icons.add,
                        onTap: () {
                          setState(() => _quantity++);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(width: 16),

                  // ---- ADD TO CART ----
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _addToCart,

                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF087524),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),

                        child: Text(
                          'ADD TO CART',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
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
