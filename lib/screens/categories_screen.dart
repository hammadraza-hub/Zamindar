import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../services/cart_provider.dart';
import 'account_screen.dart';

// ============================================================================
// CATEGORIES SCREEN
//
// Category (Insecticides) ke products grid format mein dikhte hain.
// Har product ka [+] button product ko SHARED CartProvider mein add
// karta hai — yani Home aur Categories ka cart EK hi hai.
// ============================================================================

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  // ==========================================================================
  // 1. PRODUCTS DATA
  //
  // Har product ka unique 'id' zaroori hai:
  // - CartProvider id se product ko pehchanta hai
  // - Same product dobara add karne par naya card nahi banta,
  //   sirf uski quantity barh jati hai
  // ==========================================================================

  final List<Map<String, dynamic>> products = [
    {
      'id': 'confidor-200-sl',
      'name': 'Confidor 200 SL',
      'brand': 'Bayer',
      'price': 1850,
      'oldPrice': 2100,
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
  ];

  // ==========================================================================
  // 2. FILTER / SORT DATA
  // ==========================================================================

  /// Dropdown ki current sort value
  String selectedSort = 'Popularity';

  /// User ke selected (active) filters
  final List<String> selectedFilters = [];

  /// Company filter options
  final List<String> companyFilters = [
    'Bayer',
    'Syngenta',
    'FMC',
    'BASF',
    'Corteva',
  ];

  /// Price range filter options
  final List<String> priceFilters = [
    'Rs 0 - 500',
    'Rs 500 - 2000',
    'Rs 2000 - 5000',
    'Rs 5000+',
  ];

  // ==========================================================================
  // 3. FILTERED + SORTED PRODUCTS
  //
  // Har rebuild par fresh result:
  //   1) Company filter  →  2) Price filter  →  3) Sort
  // ==========================================================================

  List<Map<String, dynamic>> get filteredProducts {
    List<Map<String, dynamic>> result = List<Map<String, dynamic>>.from(
      products,
    );

    // ---- Company Filter ----
    final selectedCompanies = selectedFilters
        .where((filter) => companyFilters.contains(filter))
        .toList();

    if (selectedCompanies.isNotEmpty) {
      result = result
          .where((p) => selectedCompanies.contains(p['brand']))
          .toList();
    }

    // ---- Price Filter ----
    final selectedPrices = selectedFilters
        .where((filter) => priceFilters.contains(filter))
        .toList();

    if (selectedPrices.isNotEmpty) {
      result = result.where((product) {
        final int price = product['price'] as int;

        return selectedPrices.any((filter) {
          if (filter == 'Rs 0 - 500') {
            return price >= 0 && price <= 500;
          }
          if (filter == 'Rs 500 - 2000') {
            return price >= 500 && price <= 2000;
          }
          if (filter == 'Rs 2000 - 5000') {
            return price >= 2000 && price <= 5000;
          }
          if (filter == 'Rs 5000+') {
            return price >= 5000;
          }
          return false;
        });
      }).toList();
    }

    // ---- Sort: Price Low → High ----
    if (selectedSort == 'Price Low') {
      result.sort((a, b) => (a['price'] as int).compareTo(b['price'] as int));
    }

    // ---- Sort: Price High → Low ----
    if (selectedSort == 'Price High') {
      result.sort((a, b) => (b['price'] as int).compareTo(a['price'] as int));
    }

    return result;
  }

  // ==========================================================================
  // 4. SNACKBAR MESSAGE
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
  // 5. ADD TO CART (SHARED)
  //
  // context.read<CartProvider>() → tap par hi call hota hai.
  // Home screen ka exactly same pattern.
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
  // 6. ACTIVE FILTER CHIP
  //
  // Selected filter screen par chip ki shakal mein dikhta hai,
  // cross (X) tap karne par remove ho jata hai
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

          // Remove (X) button
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
  // 7. FILTER OPTION (Bottom Sheet ke andar)
  //
  // Tap karne par select/deselect hota hai
  // LEKIN sheet band NAHI hoti — user multiple filters select
  // kar sakta hai, phir khud "Done" button se band kare
  // ==========================================================================

  Widget _filterOption(
    String text,
    void Function(VoidCallback fn) setSheetState,
  ) {
    final bool isSelected = selectedFilters.contains(text);

    return InkWell(
      onTap: () {
        // 1) Screen ki state update (filters live apply hote hain)
        setState(() {
          if (isSelected) {
            selectedFilters.remove(text);
          } else {
            selectedFilters.add(text);
          }
        });

        // 2) Sheet ki state update (highlight refresh)
        //    Ye zaroori hai — sheet parent ke setState
        //    se rebuild nahi hoti
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
  //
  // Layout: [Image] → [Brand] → [Name] → [Price + (+) Button]
  //
  // IMPORTANT: context.watch<CartProvider>() — cart change hone par
  // button par quantity khud update hoti hai
  // ==========================================================================

  Widget _buildProductCard(Map<String, dynamic> product) {
    // Cart ko watch karo (quantity live update ke liye)
    final CartProvider cart = context.watch<CartProvider>();

    // Is product ki current cart quantity
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
          // --------------------------------------------------------------
          // Product Image
          // --------------------------------------------------------------
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.asset(
              product['image'],
              width: double.infinity,
              height: 150,
              fit: BoxFit.cover,
            ),
          ),

          // --------------------------------------------------------------
          // Product Details
          // --------------------------------------------------------------
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
                    // ------------------------------------------------------
                    // Price (new + old)
                    // ------------------------------------------------------
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

                          // Purana price (sirf discount wale par)
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

                    // ------------------------------------------------------
                    // ADD TO CART (+) BUTTON
                    //
                    // Cart mein nahi hai → sirf [+] icon
                    // Cart mein hai       → quantity number
                    // Tap karne par       → quantity +1 (shared cart)
                    // ------------------------------------------------------
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
  // 9. FILTER BOTTOM SHEET
  //
  // Company + Price Range filters. Sheet har tap par band NAHI
  // hoti — user multiple filters select kare, phir:
  //   - "Done" button se band kare
  //   - ya neeche swipe kare / bahar tap kare
  // Filters live apply hote hain (chips + products foran update)
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
        // StatefulBuilder: sheet ke andar selection highlight
        // update karne ke liye (sheet parent ke setState
        // se rebuild nahi hoti)
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag handle
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

                    // Title + selected count
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

                    // ---- Company Filters ----
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

                    // ---- Price Filters ----
                    Text(
                      'Price Range',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: priceFilters
                          .map((f) => _filterOption(f, setSheetState))
                          .toList(),
                    ),

                    const SizedBox(height: 26),

                    // ---- CLEAR ALL + DONE ----
                    Row(
                      children: [
                        // Clear All
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              // Screen state clear
                              setState(() {
                                selectedFilters.clear();
                              });

                              // Sheet highlight reset
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

                        // Done — sheet yahin se band hogi
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
  //
  // Structure (upar se neeche):
  //   App Bar → Category Header → Filter/Sort → Products Grid
  //   → Explore More Button → Results Count
  //
  // NOTE: BottomNavigationBar yahan intentional nahi hai —
  // MainNavigationScreen handle karta hai
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    final visibleProducts = filteredProducts;

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
                  // Logo
                  Image.asset(
                    'assets/images/zamindar_logo.png',
                    width: 70,
                    height: 45,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(width: 8),

                  // Screen title
                  Text(
                    'Categories',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF087524),
                    ),
                  ),

                  const Spacer(),

                  // Search
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

                  // Profile
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
            // CATEGORY HEADER — Back + Title + Product Count
            // ================================================================
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back arrow
                  InkWell(
                    onTap: () {
                      _showMessage('Use Home tab to go back');
                    },
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

                  const SizedBox(width: 18),

                  // Title + count
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Insecticides',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF1B1C1C),
                          ),
                        ),

                        const SizedBox(height: 2),

                        Text(
                          '${visibleProducts.length} Products available',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: const Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Search
                  IconButton(
                    onPressed: () {
                      _showMessage('Search products clicked');
                    },
                    icon: const Icon(Icons.search, size: 27),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // ================================================================
            // FILTER + SORT ROW (aur Active Filter Chips)
            // ================================================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // ---- Filter Button ----
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

                      // ---- Sort Dropdown ----
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

                  // ---- Active Filter Chips + Clear All ----
                  if (selectedFilters.isNotEmpty) ...[
                    const SizedBox(height: 14),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Chips
                        Expanded(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: selectedFilters.map((filter) {
                              return _buildFilterChip(
                                text: filter,
                                onRemove: () {
                                  setState(() {
                                    selectedFilters.remove(filter);
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Clear all
                        InkWell(
                          onTap: () {
                            setState(() {
                              selectedFilters.clear();
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
            // PRODUCTS GRID
            // ================================================================
            Expanded(
              child: Column(
                children: [
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
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: GridView.builder(
                              padding: const EdgeInsets.only(bottom: 15),
                              itemCount: visibleProducts.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 14,
                                    mainAxisSpacing: 14,
                                    mainAxisExtent: 270,
                                  ),
                              itemBuilder: (context, index) {
                                return _buildProductCard(
                                  visibleProducts[index],
                                );
                              },
                            ),
                          ),
                  ),

                  // ==============================================================
                  // EXPLORE MORE + RESULTS COUNT
                  // ==============================================================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 42),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () {
                          _showMessage('Explore more products');
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF087524),
                          side: const BorderSide(color: Color(0xFF087524)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Explore More Products',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF087524),
                              ),
                            ),

                            const SizedBox(width: 8),

                            const Icon(Icons.keyboard_arrow_down, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Results count
                  Text(
                    'Showing ${visibleProducts.length} of ${products.length} results',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: const Color(0xFF666666),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
