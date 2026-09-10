import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../services/cart_provider.dart';
import 'account_screen.dart';
import 'cart_screen.dart';
import 'categories_screen.dart';
import 'checkout_screen.dart';

// ============================================================================
// SEARCH SCREEN (GLOBAL)
//
// Do type ke results:
//   1. PAGES — app ke features (Account, Cart, Settings...)
//   2. PRODUCTS — naam ya brand se match
//
// Kuch bhi likho — jo match ho wo dikhta hai!
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

  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ==========================================================================
  // 2. APP PAGES (searchable features)
  //
  // title/subtitle match → result dikhta hai
  // action → navigation
  // ==========================================================================

  final List<Map<String, dynamic>> _appPages = [
    {
      'title': 'My Account',
      'subtitle': 'Profile, orders & settings',
      'icon': Icons.person_outline,
      'action': 'account',
    },
    {
      'title': 'Edit Profile',
      'subtitle': 'Change name, phone & photo',
      'icon': Icons.edit_outlined,
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
      'title': 'Saved Addresses',
      'subtitle': 'Manage delivery addresses',
      'icon': Icons.location_on_outlined,
      'action': 'coming_soon',
    },
    {
      'title': 'Notifications',
      'subtitle': 'Offers & order updates',
      'icon': Icons.notifications_outlined,
      'action': 'coming_soon',
    },
    {
      'title': 'Payment Methods',
      'subtitle': 'COD & bank transfer',
      'icon': Icons.credit_card_outlined,
      'action': 'coming_soon',
    },
    {
      'title': 'Help & Support',
      'subtitle': 'FAQs & contact us',
      'icon': Icons.help_outline,
      'action': 'coming_soon',
    },
    {
      'title': 'Settings',
      'subtitle': 'App preferences',
      'icon': Icons.settings_outlined,
      'action': 'coming_soon',
    },
  ];

  // ==========================================================================
  // 3. PRODUCTS DATA
  // ==========================================================================

  final List<Map<String, dynamic>> _allProducts = [
    // ---- INSECTICIDES ----
    {
      'id': 'confidor-200-sl',
      'name': 'Confidor 200 SL',
      'brand': 'Bayer',
      'price': 1850,
      'image': 'assets/images/whats_new3img.png',
    },
    {
      'id': 'belt-480-sc',
      'name': 'Belt 480 SC',
      'brand': 'Bayer',
      'price': 1240,
      'image': 'assets/images/whats_new4img.png',
    },
    {
      'id': 'movento-240-sc',
      'name': 'Movento 240 SC',
      'brand': 'Bayer',
      'price': 980,
      'image': 'assets/images/whats_new5img.png',
    },
    {
      'id': 'decis-100-ec',
      'name': 'Decis 100 EC',
      'brand': 'Bayer',
      'price': 650,
      'image': 'assets/images/whats_new2img (1).png',
    },
    {
      'id': 'actara-25-wg',
      'name': 'ACTARA 25 WG (24 GM)',
      'brand': 'Syngenta',
      'price': 500,
      'image': 'assets/images/whats_new5img.png',
    },
    {
      'id': 'ampligo-150-zc',
      'name': 'AMPLIGO 150 ZC (160 Ml)',
      'brand': 'Syngenta',
      'price': 2800,
      'image': 'assets/images/whats_new2img (2).png',
    },
    {
      'id': 'mithu-800ml',
      'name': 'Mithu – 800 Mls',
      'brand': 'Orange Production',
      'price': 1499,
      'image': 'assets/images/whats_new4img.png',
    },
    {
      'id': 'zehrelli-400ml',
      'name': 'Zehrelli – 400 Mls',
      'brand': 'Sohni Dharti',
      'price': 640,
      'image': 'assets/images/whats_new2img (1).png',
    },

    // ---- HERBICIDES ----
    {
      'id': 'orange-amine-500ml',
      'name': 'Orange Amine – 500 Mls',
      'brand': 'Orange Production',
      'price': 880,
      'image': 'assets/images/whats_new2img (1).png',
    },
    {
      'id': 'orange-amine-1ltr',
      'name': 'Orange Amine – 1 Ltr',
      'brand': 'Orange Production',
      'price': 1450,
      'image': 'assets/images/whats_new3img.png',
    },
    {
      'id': 'adengo-xtra-132ml',
      'name': 'Adengo Xtra 132ml',
      'brand': 'Bayer',
      'price': 2700,
      'image': 'assets/images/whats_new4img.png',
    },

    // ---- FUNGICIDES ----
    {
      'id': 'aliette-250g',
      'name': 'Aliette 80% WP 250g',
      'brand': 'Bayer',
      'price': 1250,
      'image': 'assets/images/whats_new3img.png',
    },
    {
      'id': 'amistar-top-200ml',
      'name': 'Amistar Top 325 SC',
      'brand': 'Syngenta',
      'price': 1550,
      'image': 'assets/images/whats_new5img.png',
    },
    {
      'id': 'antracol-70wp',
      'name': 'Antracol 70 WP 1kg',
      'brand': 'Bayer',
      'price': 3800,
      'image': 'assets/images/whats_new4img.png',
    },

    // ---- PGRs ----
    {
      'id': 'ambition-500ml',
      'name': 'Ambition 500ml',
      'brand': 'Bayer',
      'price': 1900,
      'image': 'assets/images/whats_new2img (2).png',
    },
    {
      'id': 'subah-800ml',
      'name': 'Subah – 800 Mls',
      'brand': 'Sohni Dharti',
      'price': 780,
      'image': 'assets/images/whats_new4img.png',
    },

    // ---- SEED CARE ----
    {
      'id': 'hybrid-corn-seeds',
      'name': 'Hybrid Corn Seeds (1kg)',
      'brand': 'Sakata Seeds',
      'price': 3500,
      'image': 'assets/images/whats_new5img.png',
    },
    {
      'id': 'wheat-seeds',
      'name': 'Wheat Seeds (Certified)',
      'brand': 'Sohni Dharti',
      'price': 1200,
      'image': 'assets/images/whats_new2img (1).png',
    },
  ];

  // ==========================================================================
  // 4. SEARCH LOGIC
  // ==========================================================================

  /// Khali search → koi page result nahi (sirf products)
  List<Map<String, dynamic>> get _pageResults {
    if (_searchQuery.isEmpty) return [];

    final String query = _searchQuery.toLowerCase();

    return _appPages.where((page) {
      final String title = page['title'].toString().toLowerCase();
      final String subtitle = page['subtitle'].toString().toLowerCase();

      return title.contains(query) || subtitle.contains(query);
    }).toList();
  }

  /// Products — naam ya brand se match
  List<Map<String, dynamic>> get _searchResults {
    if (_searchQuery.isEmpty) return _allProducts;

    final String query = _searchQuery.toLowerCase();

    return _allProducts.where((product) {
      final String name = product['name'].toString().toLowerCase();
      final String brand = product['brand'].toString().toLowerCase();

      return name.contains(query) || brand.contains(query);
    }).toList();
  }

  // ==========================================================================
  // 5. NAVIGATION — page result tap par
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
        // Coming soon pages
        _showMessage('${page['title']} — coming soon');
        break;
    }
  }

  // ==========================================================================
  // 6. HELPERS
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

  void _addToCart(Map<String, dynamic> product) {
    context.read<CartProvider>().addProduct(
      id: product['id'] as String,
      name: product['name'] as String,
      price: product['price'] as int,
      image: product['image'] as String,
    );

    _showMessage('${product['name']} added to cart');
  }

  // ==========================================================================
  // 7. SEARCH BAR
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
              autofocus: true,

              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim();
                });
              },

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

          if (_searchQuery.isNotEmpty)
            IconButton(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
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
  // 8. PAGE RESULT ROW (icon + title + subtitle + chevron)
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
            // --- Icon circle ---
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

            // --- Title + Subtitle ---
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

            // --- Chevron (>) ---
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
  // 9. PRODUCT RESULT ROW
  // ==========================================================================

  Widget _buildResultRow(Map<String, dynamic> product) {
    final CartProvider cart = context.watch<CartProvider>();

    int quantityInCart = 0;

    for (final item in cart.items) {
      if (item.id == product['id']) {
        quantityInCart = item.quantity;
        break;
      }
    }

    return Container(
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
          // --- Image ---
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              product['image'],
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(width: 14),

          // --- Details ---
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['brand'].toString().toUpperCase(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    color: const Color(0xFF999999),
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  product['name'],
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
                  'Rs ${_formatPrice(product['price'] as int)}',
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
    );
  }

  // ==========================================================================
  // 10. SECTION HEADER (chhota label — "Pages" ya "Products")
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
  // 11. MAIN UI
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    final pages = _pageResults;
    final products = _searchResults;

    final bool hasAnyResult = pages.isNotEmpty || products.isNotEmpty;

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

            // --- Results ---
            Expanded(
              // Khali search + no results → empty state
              // warna → list
              child: !hasAnyResult
                  ? _buildEmptyState()
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),

                      children: [
                        // ---- PAGES section ----
                        if (pages.isNotEmpty) ...[
                          _buildSectionLabel('PAGES & FEATURES'),

                          for (final page in pages) _buildPageRow(page),

                          const SizedBox(height: 16),
                        ],

                        // ---- PRODUCTS section ----
                        if (products.isNotEmpty) ...[
                          _buildSectionLabel(
                            _searchQuery.isEmpty
                                ? 'ALL PRODUCTS (${products.length})'
                                : 'PRODUCTS (${products.length})',
                          ),

                          for (final product in products)
                            _buildResultRow(product),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // 12. EMPTY STATE
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
            'Try a product name, brand or feature',
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
}
