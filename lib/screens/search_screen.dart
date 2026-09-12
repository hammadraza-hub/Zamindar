import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../repositories/product_repository.dart';
import '../services/cart_provider.dart';
import 'account_screen.dart';
import 'cart_screen.dart';
import 'categories_screen.dart';
import 'checkout_screen.dart';
import 'product_detail_screen.dart';

// ============================================================================
// SEARCH SCREEN (GLOBAL — LIVE API)
//
// Do type ke results:
//   1. PAGES — app ke features (Account, Cart, Settings...)
//   2. PRODUCTS — zamindar.co API se LIVE search
//
// Smart search: type karna band karo → 500ms → API call
// (har harf par nahi — fast aur battery-friendly!)
// ============================================================================

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // ==========================================================================
  // 1. STATE
  // ==========================================================================

  final TextEditingController _searchController = TextEditingController();
  final ProductRepository _repository = ProductRepository();

  String _searchQuery = '';

  // ---- API products state ----
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  /// Debounce — user type karna band kare to hi API call ho.
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // ==========================================================================
  // 2. APP PAGES (searchable features)
  // ==========================================================================

  final List<Map<String, dynamic>> _appPages = [
    {
      'title': 'My Account',
      'subtitle': 'Profile, orders & settings',
      'icon': Icons.person_outline,
      'action': 'account',
    },
    {
      'title': 'My Cart',
      'subtitle': 'View items & checkout',
      'icon': Icons.shopping_cart_outlined,
      'action': 'cart',
    },
    {
      'title': 'Checkout',
      'subtitle': 'Delivery address & payment',
      'icon': Icons.payment_outlined,
      'action': 'checkout',
    },
    {
      'title': 'All Products',
      'subtitle': 'Browse categories & brands',
      'icon': Icons.grid_view_outlined,
      'action': 'categories',
    },
    {
      'title': 'My Orders',
      'subtitle': 'Order history & tracking',
      'icon': Icons.receipt_long_outlined,
      'action': 'coming_soon',
    },
    {
      'title': 'Help & Support',
      'subtitle': 'FAQs & contact us',
      'icon': Icons.help_outline_outlined,
      'action': 'coming_soon',
    },
  ];

  // ==========================================================================
  // 3. SEARCH — debounced API call
  // ==========================================================================

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value.trim();
    });

    // Purana timer cancel
    _debounce?.cancel();

    // Khali → kuch nahi maangna
    if (_searchQuery.isEmpty) {
      setState(() {
        _products = [];
        _error = null;
        _isLoading = false;
      });
      return;
    }

    // 500ms ruk kar API call
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchProducts(_searchQuery);
    });
  }

  /// zamindar.co se products search karta hai.
  Future<void> _searchProducts(String term) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await _repository.searchProducts(term, perPage: 20);

      if (!mounted) return;

      setState(() {
        _products = results;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Search chip par tap → wahi search dobara.
  void _searchFromSuggestion(String term) {
    _searchController.text = term;
    _onSearchChanged(term);
  }

  // ==========================================================================
  // 4. NAVIGATION — page result tap par
  // ==========================================================================

  void _openPage(Map<String, dynamic> page) {
    final String action = page['action'] as String;

    switch (action) {
      case 'account':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AccountScreen()),
        );
        break;

      case 'cart':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CartScreen()),
        );
        break;

      case 'checkout':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CheckoutScreen()),
        );
        break;

      case 'categories':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CategoriesScreen()),
        );
        break;

      default:
        _showMessage('${page['title']} — coming soon');
        break;
    }
  }

  // ==========================================================================
  // 5. HELPERS
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

  void _addToCart(Product product) {
    final String image = product.imageThumbnailUrl ?? product.imageUrl ?? '';

    context.read<CartProvider>().addProduct(
      id: product.id.toString(),
      name: product.name,
      price: product.price.round(),
      image: image,
    );

    _showMessage('${product.name} added to cart');
  }

  Widget _imagePlaceholder() {
    return Container(
      color: const Color(0xFFF0EEEE),
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_outlined,
        size: 24,
        color: Color(0xFFBBBBBB),
      ),
    );
  }

  // ==========================================================================
  // 6. SEARCH BAR
  // ==========================================================================

  Widget _buildSearchBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: Row(
        children: [
          const SizedBox(width: 16),

          const Icon(Icons.search, size: 24, color: Color(0xFF087524)),

          const SizedBox(width: 12),

          Expanded(
            child: TextField(
              controller: _searchController,

              onChanged: _onSearchChanged,

              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                color: const Color(0xFF303030),
              ),

              decoration: InputDecoration(
                hintText: 'Search products, pages...',
                hintStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: const Color(0xFF999999),
                ),
                border: InputBorder.none,
              ),
            ),
          ),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF087524),
                ),
              ),
            )
          else if (_searchQuery.isNotEmpty)
            IconButton(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                  _products = [];
                  _error = null;
                });
              },
              icon: const Icon(Icons.close, size: 20, color: Color(0xFF999999)),
            ),

          const SizedBox(width: 8),
        ],
      ),
    );
  }

  // ==========================================================================
  // 7. PAGE RESULT ROW
  // ==========================================================================

  Widget _buildPageRow(Map<String, dynamic> page) {
    return InkWell(
      onTap: () => _openPage(page),

      borderRadius: BorderRadius.circular(12),

      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
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
          children: [
            Container(
              width: 44,
              height: 44,

              decoration: const BoxDecoration(
                color: Color(0xFFDCE8DA),
                shape: BoxShape.circle,
              ),

              child: Icon(
                page['icon'] as IconData,
                size: 22,
                color: const Color(0xFF087524),
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    page['title'] as String,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF303030),
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    page['subtitle'] as String,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: const Color(0xFF777777),
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Color(0xFFAAAAAA),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // 8. PRODUCT RESULT ROW (API product — tap → detail screen)
  // ==========================================================================

  Widget _buildResultRow(Product product) {
    final CartProvider cart = context.watch<CartProvider>();

    final String cartId = product.id.toString();

    int quantityInCart = 0;

    for (final item in cart.items) {
      if (item.id == cartId) {
        quantityInCart = item.quantity;
        break;
      }
    }

    final String? imageUrl = product.imageThumbnailUrl ?? product.imageUrl;

    return InkWell(
      // ---- Tap → DETAIL SCREEN ----
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        );
      },

      borderRadius: BorderRadius.circular(12),

      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),

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
          children: [
            // --- Image (network) ---
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 60,
                height: 60,
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => _imagePlaceholder(),
                        errorWidget: (_, _, _) => _imagePlaceholder(),
                      )
                    : _imagePlaceholder(),
              ),
            ),

            const SizedBox(width: 14),

            // --- Details ---
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.categoryNames.isNotEmpty)
                    Text(
                      product.categoryNames.first.toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        color: const Color(0xFF999999),
                      ),
                    ),

                  const SizedBox(height: 2),

                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF303030),
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    product.displayPrice,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF087524),
                    ),
                  ),
                ],
              ),
            ),

            // --- (+) Button ---
            InkWell(
              onTap: () => _addToCart(product),
              borderRadius: BorderRadius.circular(50),

              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,

                decoration: const BoxDecoration(
                  color: Color(0xFFFF7900),
                  shape: BoxShape.circle,
                ),

                child: quantityInCart > 0
                    ? Text(
                        '$quantityInCart',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF202020),
                        ),
                      )
                    : const Icon(Icons.add, size: 22, color: Color(0xFF202020)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // 9. SECTION LABEL
  // ==========================================================================

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),

      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF666666),
        ),
      ),
    );
  }

  // ==========================================================================
  // 10. MAIN UI
  // ==========================================================================

  /// Pages jo query se match karte hain.
  List<Map<String, dynamic>> get _pageResults {
    if (_searchQuery.isEmpty) return [];

    final String query = _searchQuery.toLowerCase();

    return _appPages.where((page) {
      final String title = page['title'].toString().toLowerCase();
      final String subtitle = page['subtitle'].toString().toLowerCase();

      return title.contains(query) || subtitle.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final pages = _pageResults;

    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F7),

      body: SafeArea(
        child: Column(
          children: [
            // --- Header: Back + Search Bar ---
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 24, 16),

              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(30),
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(
                        Icons.arrow_back,
                        size: 25,
                        color: Color(0xFF087524),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(child: _buildSearchBar()),
                ],
              ),
            ),

            // --- Body ---
            Expanded(
              child: _searchQuery.isEmpty
                  ? _buildSuggestions()
                  : _buildResults(pages),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // 11. RESULTS (khali na ho to)
  // ==========================================================================

  Widget _buildResults(List<Map<String, dynamic>> pages) {
    final bool noResults =
        pages.isEmpty && _products.isEmpty && !_isLoading && _error == null;

    if (_error != null) return _buildErrorState();
    if (noResults) return _buildEmptyState();

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),

      children: [
        // ---- PAGES ----
        if (pages.isNotEmpty) ...[
          _buildSectionLabel('PAGES & FEATURES'),

          for (final page in pages) _buildPageRow(page),

          const SizedBox(height: 16),
        ],

        // ---- PRODUCTS ----
        if (_products.isNotEmpty) ...[
          _buildSectionLabel('PRODUCTS (${_products.length})'),

          for (final product in _products) _buildResultRow(product),
        ],
      ],
    );
  }

  // ==========================================================================
  // 12. SUGGESTIONS (khali search par)
  // ==========================================================================

  Widget _buildSuggestions() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),

      children: [
        _buildSectionLabel('POPULAR SEARCHES'),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              [
                    'Subah',
                    'Mithu',
                    'Confidor',
                    'Fertilizer',
                    'Insecticide',
                    'Fungicide',
                    'Herbicide',
                    'Seeds',
                  ]
                  .map(
                    (term) => InkWell(
                      onTap: () => _searchFromSuggestion(term),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFD5E2D3)),
                        ),
                        child: Text(
                          term,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: const Color(0xFF303030),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }

  // ==========================================================================
  // 13. EMPTY STATE
  // ==========================================================================

  Widget _buildEmptyState() {
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
              Icons.search_off,
              size: 38,
              color: Color(0xFF087524),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'No results found',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF303030),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Try a product name or category',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: const Color(0xFF666666),
            ),
          ),

          const SizedBox(height: 8),

          TextButton(
            onPressed: () {
              _searchController.clear();
              setState(() {
                _searchQuery = '';
                _products = [];
              });
            },
            child: Text(
              'Clear Search',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF087524),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // 14. ERROR STATE
  // ==========================================================================

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_off_outlined,
              size: 36,
              color: Color(0xFF999999),
            ),

            const SizedBox(height: 12),

            Text(
              _error ?? 'Something went wrong.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: const Color(0xFF555555),
              ),
            ),

            const SizedBox(height: 14),

            ElevatedButton.icon(
              onPressed: () => _searchProducts(_searchQuery),
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(
                'Retry',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF087524),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
