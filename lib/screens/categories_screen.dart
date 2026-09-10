import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../services/cart_provider.dart';
import 'account_screen.dart';
import 'search_screen.dart';

// ============================================================================
// CATEGORIES SCREEN
//
// Category chips + Company filters + Price slider + Sort
// + Explore More (scroll ke saath — CustomScrollView)
// ============================================================================

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  // ==========================================================================
  // 1. PRODUCTS DATA
  // ==========================================================================

  final List<Map<String, dynamic>> products = [
    // ---- INSECTICIDES ----
    {
      'id': 'confidor-200-sl',
      'name': 'Confidor 200 SL',
      'brand': 'Bayer',
      'category': 'Insecticides',
      'price': 1850,
      'oldPrice': 2100,
      'image': 'assets/images/whats_new3img.png',
    },
    {
      'id': 'belt-480-sc',
      'name': 'Belt 480 SC',
      'brand': 'Bayer',
      'category': 'Insecticides',
      'price': 1240,
      'image': 'assets/images/whats_new4img.png',
    },
    {
      'id': 'movento-240-sc',
      'name': 'Movento 240 SC',
      'brand': 'Bayer',
      'category': 'Insecticides',
      'price': 980,
      'image': 'assets/images/whats_new5img.png',
    },
    {
      'id': 'decis-100-ec',
      'name': 'Decis 100 EC',
      'brand': 'Bayer',
      'category': 'Insecticides',
      'price': 650,
      'image': 'assets/images/whats_new2img (1).png',
    },
    {
      'id': 'actara-25-wg',
      'name': 'ACTARA 25 WG (24 GM)',
      'brand': 'Syngenta',
      'category': 'Insecticides',
      'price': 500,
      'image': 'assets/images/whats_new5img.png',
    },
    {
      'id': 'ampligo-150-zc',
      'name': 'AMPLIGO 150 ZC (160 Ml)',
      'brand': 'Syngenta',
      'category': 'Insecticides',
      'price': 2800,
      'image': 'assets/images/whats_new2img (2).png',
    },

    // ---- HERBICIDES ----
    {
      'id': 'orange-amine-500ml',
      'name': 'Orange Amine – 500 Mls',
      'brand': 'Orange Production',
      'category': 'Herbicides',
      'price': 880,
      'image': 'assets/images/whats_new2img (1).png',
    },
    {
      'id': 'adengo-xtra-132ml',
      'name': 'Adengo Xtra 132ml',
      'brand': 'Bayer',
      'category': 'Herbicides',
      'price': 2700,
      'image': 'assets/images/whats_new4img.png',
    },

    // ---- FUNGICIDES ----
    {
      'id': 'aliette-250g',
      'name': 'Aliette 80% WP 250g',
      'brand': 'Bayer',
      'category': 'Fungicides',
      'price': 1250,
      'image': 'assets/images/whats_new3img.png',
    },
    {
      'id': 'amistar-top-200ml',
      'name': 'Amistar Top 325 SC',
      'brand': 'Syngenta',
      'category': 'Fungicides',
      'price': 1550,
      'image': 'assets/images/whats_new5img.png',
    },

    // ---- PGRs ----
    {
      'id': 'ambition-500ml',
      'name': 'Ambition 500ml',
      'brand': 'Bayer',
      'category': 'PGRs',
      'price': 1900,
      'image': 'assets/images/whats_new2img (2).png',
    },
    {
      'id': 'subah-800ml',
      'name': 'Subah – 800 Mls',
      'brand': 'Sohni Dharti',
      'category': 'PGRs',
      'price': 780,
      'image': 'assets/images/whats_new4img.png',
    },

    // ---- SEED CARE ----
    {
      'id': 'hybrid-corn-seeds',
      'name': 'Hybrid Corn Seeds (1kg)',
      'brand': 'Sakata Seeds',
      'category': 'Seed Care',
      'price': 3500,
      'image': 'assets/images/whats_new5img.png',
    },
    {
      'id': 'wheat-seeds',
      'name': 'Wheat Seeds (Certified)',
      'brand': 'Sohni Dharti',
      'category': 'Seed Care',
      'price': 1200,
      'image': 'assets/images/whats_new2img (1).png',
    },
  ];

  // ==========================================================================
  // 1b. MORE PRODUCTS (Explore More)
  // ==========================================================================

  final List<Map<String, dynamic>> _nextBatch = [
    {
      'id': 'mithu-800ml',
      'name': 'Mithu – 800 Mls',
      'brand': 'Orange Production',
      'category': 'Insecticides',
      'price': 1499,
      'image': 'assets/images/whats_new4img.png',
    },
    {
      'id': 'zehrelli-400ml',
      'name': 'Zehrelli – 400 Mls',
      'brand': 'Sohni Dharti',
      'category': 'Insecticides',
      'price': 640,
      'image': 'assets/images/whats_new2img (1).png',
    },
    {
      'id': 'acetamiprid-20-sl',
      'name': 'Acetamiprid 20% SL 250ml',
      'brand': 'Evyol Group',
      'category': 'Insecticides',
      'price': 1540,
      'image': 'assets/images/whats_new5img.png',
    },
    {
      'id': 'orange-amine-1ltr',
      'name': 'Orange Amine – 1 Ltr',
      'brand': 'Orange Production',
      'category': 'Herbicides',
      'price': 1450,
      'image': 'assets/images/whats_new3img.png',
    },
    {
      'id': 'antracol-70wp',
      'name': 'Antracol 70 WP 1kg',
      'brand': 'Bayer',
      'category': 'Fungicides',
      'price': 3800,
      'image': 'assets/images/whats_new4img.png',
    },
    {
      'id': 'agroquat-20-sl',
      'name': 'Agroquat 20 SL 1L',
      'brand': 'Evyol Group',
      'category': 'Herbicides',
      'price': 875,
      'image': 'assets/images/whats_new5img.png',
    },
  ];

  bool get _hasMoreProducts => _nextBatch.isNotEmpty;

  // ==========================================================================
  // 2. FILTER / SORT DATA
  // ==========================================================================

  String selectedSort = 'Popularity';

  final List<String> selectedFilters = [];

  final List<String> companyFilters = [
    'Bayer',
    'Syngenta',
    'Evyol Group',
    'Orange Production',
    'Haji Sons',
    'Kanzo AG',
    'Sakata Seeds',
    'Sohni Dharti',
  ];

  // ==========================================================================
  // 2b. CATEGORY STATE
  // ==========================================================================

  String _selectedCategory = 'All';

  // ==========================================================================
  // 2c. PRICE RANGE STATE
  // ==========================================================================

  static const double _priceMinLimit = 0;
  static const double _priceMaxLimit = 5000;

  RangeValues _priceRange = const RangeValues(_priceMinLimit, _priceMaxLimit);

  bool get _isPriceFilterActive =>
      _priceRange.start > _priceMinLimit || _priceRange.end < _priceMaxLimit;

  // ==========================================================================
  // 3. FILTERED + SORTED PRODUCTS
  // ==========================================================================

  List<Map<String, dynamic>> get filteredProducts {
    List<Map<String, dynamic>> result = List<Map<String, dynamic>>.from(
      products,
    );

    // ---- Category Filter ----
    if (_selectedCategory != 'All') {
      result = result.where((p) => p['category'] == _selectedCategory).toList();
    }

    // ---- Company Filter ----
    final selectedCompanies = selectedFilters
        .where((filter) => companyFilters.contains(filter))
        .toList();

    if (selectedCompanies.isNotEmpty) {
      result = result
          .where((p) => selectedCompanies.contains(p['brand']))
          .toList();
    }

    // ---- Price Filter (slider) ----
    if (_isPriceFilterActive) {
      result = result.where((product) {
        final int price = product['price'] as int;

        return price >= _priceRange.start && price <= _priceRange.end;
      }).toList();
    }

    // ---- Sort ----
    if (selectedSort == 'Price Low') {
      result.sort((a, b) => (a['price'] as int).compareTo(b['price'] as int));
    }

    if (selectedSort == 'Price High') {
      result.sort((a, b) => (b['price'] as int).compareTo(a['price'] as int));
    }

    return result;
  }

  // ==========================================================================
  // 4. SNACKBAR
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
  // 5. ADD TO CART
  // ==========================================================================

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
  // 5b. LOAD MORE
  // ==========================================================================

  void _loadMoreProducts() {
    if (_nextBatch.isEmpty) {
      _showMessage('All products loaded');
      return;
    }

    setState(() {
      products.addAll(_nextBatch);
      _nextBatch.clear();
    });

    _showMessage('More products loaded');
  }

  // ==========================================================================
  // 6. CATEGORY CHIP
  // ==========================================================================

  Widget _buildCategoryChip(String name) {
    final bool isSelected = _selectedCategory == name;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedCategory = name;
        });
      },

      borderRadius: BorderRadius.circular(30),

      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),

        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF087524) : const Color(0xFFF0EEEE),
          borderRadius: BorderRadius.circular(30),
        ),

        child: Text(
          name,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? Colors.white : const Color(0xFF1B1C1C),
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // 6b. FILTER CHIP
  // ==========================================================================

  Widget _buildFilterChip({
    required String text,
    required VoidCallback onRemove,
  }) {
    return Container(
      height: 32,
      padding: const EdgeInsets.only(left: 12, right: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFDCE8DA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: const Color(0xFF087524),
            ),
          ),

          const SizedBox(width: 4),

          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(20),
            child: const Icon(Icons.close, size: 16, color: Color(0xFF087524)),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // 6c. PRICE CHIP
  // ==========================================================================

  Widget _buildPriceChip() {
    return Container(
      height: 32,
      padding: const EdgeInsets.only(left: 12, right: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFDCE8DA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Rs ${_priceRange.start.round()} - ${_priceRange.end.round()}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: const Color(0xFF087524),
            ),
          ),

          const SizedBox(width: 4),

          InkWell(
            onTap: () {
              setState(() {
                _priceRange = const RangeValues(_priceMinLimit, _priceMaxLimit);
              });
            },
            borderRadius: BorderRadius.circular(20),
            child: const Icon(Icons.close, size: 16, color: Color(0xFF087524)),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // 7. FILTER OPTION (sheet)
  // ==========================================================================

  Widget _filterOption(
    String text,
    void Function(VoidCallback fn) setSheetState,
  ) {
    final bool isSelected = selectedFilters.contains(text);

    return InkWell(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedFilters.remove(text);
          } else {
            selectedFilters.add(text);
          }
        });

        setSheetState(() {});
      },

      borderRadius: BorderRadius.circular(20),

      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),

        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFDCE8DA) : const Color(0xFFF0F3EE),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF087524)
                : const Color(0xFFD5E2D3),
          ),
        ),

        child: Text(
          text,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: isSelected
                ? const Color(0xFF087524)
                : const Color(0xFF333333),
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // 8. PRODUCT CARD
  // ==========================================================================

  Widget _buildProductCard(Map<String, dynamic> product) {
    final CartProvider cart = context.watch<CartProvider>();

    int quantityInCart = 0;

    for (final item in cart.items) {
      if (item.id == product['id']) {
        quantityInCart = item.quantity;
        break;
      }
    }

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Image ---
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.asset(
              product['image'],
              width: double.infinity,
              height: 150,
              fit: BoxFit.cover,
            ),
          ),

          // --- Details ---
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand
                Text(
                  product['brand'].toString().toUpperCase(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: const Color(0xFF555555),
                  ),
                ),

                const SizedBox(height: 3),

                // Name
                Text(
                  product['name'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF303030),
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    // --- Price ---
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rs ${product['price']}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF087524),
                            ),
                          ),

                          if (product['oldPrice'] != null)
                            Text(
                              'Rs ${product['oldPrice']}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                color: const Color(0xFF777777),
                                decoration: TextDecoration.lineThrough,
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
                        width: 38,
                        height: 38,
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
                            : const Icon(
                                Icons.add,
                                size: 22,
                                color: Color(0xFF202020),
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
  // 9. FILTER SHEET
  // ==========================================================================

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Handle ---
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

                    const SizedBox(height: 20),

                    // --- Title ---
                    Row(
                      children: [
                        Text(
                          'Filters',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const Spacer(),

                        if (selectedFilters.isNotEmpty)
                          Text(
                            '${selectedFilters.length} selected',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: const Color(0xFF087524),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // --- Company ---
                    Text(
                      'Company',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: companyFilters
                          .map((f) => _filterOption(f, setSheetState))
                          .toList(),
                    ),

                    const SizedBox(height: 26),

                    // --- Price Slider ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Price Range',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        Text(
                          'Rs ${_priceRange.start.round()}'
                          ' - Rs ${_priceRange.end.round()}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF087524),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    RangeSlider(
                      values: _priceRange,
                      min: _priceMinLimit,
                      max: _priceMaxLimit,
                      divisions: 50,
                      activeColor: const Color(0xFF087524),
                      inactiveColor: const Color(0xFFD5E2D3),
                      labels: RangeLabels(
                        'Rs ${_priceRange.start.round()}',
                        'Rs ${_priceRange.end.round()}',
                      ),
                      onChanged: (values) {
                        setSheetState(() {});
                        setState(() {
                          _priceRange = values;
                        });
                      },
                    ),

                    const SizedBox(height: 26),

                    // --- Clear All + Done ---
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                selectedFilters.clear();
                                _priceRange = const RangeValues(
                                  _priceMinLimit,
                                  _priceMaxLimit,
                                );
                              });

                              setSheetState(() {});
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF333333),
                              side: const BorderSide(color: Color(0xFFD5E2D3)),
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Clear All',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(sheetContext),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF087524),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              selectedFilters.isEmpty
                                  ? 'Done'
                                  : 'Done (${selectedFilters.length})',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ==========================================================================
  // 10. MAIN UI
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    final visibleProducts = filteredProducts;

    final String screenTitle = _selectedCategory == 'All'
        ? 'All Products'
        : _selectedCategory;

    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F7),

      body: SafeArea(
        child: Column(
          children: [
            // ================================================================
            // APP BAR
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
                    'Categories',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF087524),
                    ),
                  ),

                  const Spacer(),

                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SearchScreen()),
                      );
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
            // HEADER — Centered Title + Count
            // ================================================================
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),

              child: Column(
                children: [
                  Text(
                    screenTitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1B1C1C),
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    '${visibleProducts.length} Products available',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: const Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ================================================================
            // CATEGORY CHIPS
            // ================================================================
            SizedBox(
              height: 42,

              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),

                padding: const EdgeInsets.symmetric(horizontal: 24),

                children: [
                  _buildCategoryChip('All'),
                  const SizedBox(width: 10),
                  _buildCategoryChip('Insecticides'),
                  const SizedBox(width: 10),
                  _buildCategoryChip('Herbicides'),
                  const SizedBox(width: 10),
                  _buildCategoryChip('Fungicides'),
                  const SizedBox(width: 10),
                  _buildCategoryChip('PGRs'),
                  const SizedBox(width: 10),
                  _buildCategoryChip('Seed Care'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ================================================================
            // FILTER + SORT ROW
            // ================================================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: _showFilterSheet,
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          height: 42,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F3F1),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.tune,
                                color: Color(0xFF087524),
                                size: 20,
                              ),

                              const SizedBox(width: 8),

                              Text(
                                'Filters',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF087524),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Container(
                          height: 42,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F3F1),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedSort,
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: const Color(0xFF555555),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'Popularity',
                                  child: Text('Sort by: Popularity'),
                                ),
                                DropdownMenuItem(
                                  value: 'Price Low',
                                  child: Text('Price: Low to High'),
                                ),
                                DropdownMenuItem(
                                  value: 'Price High',
                                  child: Text('Price: High to Low'),
                                ),
                                DropdownMenuItem(
                                  value: 'Newest',
                                  child: Text('Sort by: Newest'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value == null) return;

                                setState(() {
                                  selectedSort = value;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // ---- Active Filter Chips ----
                  if (selectedFilters.isNotEmpty || _isPriceFilterActive) ...[
                    const SizedBox(height: 14),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (_isPriceFilterActive) _buildPriceChip(),

                              ...selectedFilters.map((filter) {
                                return _buildFilterChip(
                                  text: filter,
                                  onRemove: () {
                                    setState(() {
                                      selectedFilters.remove(filter);
                                    });
                                  },
                                );
                              }),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        InkWell(
                          onTap: () {
                            setState(() {
                              selectedFilters.clear();
                              _priceRange = const RangeValues(
                                _priceMinLimit,
                                _priceMaxLimit,
                              );
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 7),
                            child: Text(
                              'Clear all',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: const Color(0xFF087524),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ================================================================
            // PRODUCTS GRID + EXPLORE MORE (scroll ke saath)
            // ================================================================
            Expanded(
              child: visibleProducts.isEmpty
                  ? Center(
                      child: Text(
                        'No products found',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          color: const Color(0xFF666666),
                        ),
                      ),
                    )
                  : CustomScrollView(
                      slivers: [
                        // ---- Products Grid ----
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 15),

                          sliver: SliverGrid(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 14,
                                  mainAxisSpacing: 14,
                                  mainAxisExtent: 270,
                                ),

                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              return _buildProductCard(visibleProducts[index]);
                            }, childCount: visibleProducts.length),
                          ),
                        ),

                        // ---- Explore More (scroll ke END mein) ----
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(42, 0, 42, 12),

                            child: SizedBox(
                              width: double.infinity,
                              height: 52,

                              child: OutlinedButton(
                                onPressed: _hasMoreProducts
                                    ? _loadMoreProducts
                                    : null,

                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF087524),
                                  side: BorderSide(
                                    color: _hasMoreProducts
                                        ? const Color(0xFF087524)
                                        : const Color(0xFFD5E2D3),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),

                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _hasMoreProducts
                                          ? 'Explore More Products'
                                          : 'All Products Loaded',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: _hasMoreProducts
                                            ? const Color(0xFF087524)
                                            : const Color(0xFF999999),
                                      ),
                                    ),

                                    const SizedBox(width: 8),

                                    Icon(
                                      _hasMoreProducts
                                          ? Icons.keyboard_arrow_down
                                          : Icons.check_circle_outline,
                                      size: 20,
                                      color: _hasMoreProducts
                                          ? const Color(0xFF087524)
                                          : const Color(0xFF999999),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // ---- Results Count ----
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16),

                            child: Center(
                              child: Text(
                                'Showing ${visibleProducts.length} of ${products.length} results',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: const Color(0xFF666666),
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
