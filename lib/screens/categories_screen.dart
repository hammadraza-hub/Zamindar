import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../config/app_config.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../repositories/product_repository.dart';
import '../services/cart_provider.dart';

import 'search_screen.dart';
import '../widgets/profile_app_bar_icon.dart';
import 'product_detail_screen.dart';

// ============================================================================
// CATEGORIES SCREEN — API + BRAND FILTER!
//
//   - Category chips API se
//   - Brand filter (17 brands live!)
//   - Price filter (slider) + Sort
//   - Pagination — "Explore More"
//   - Card tap → Product Detail screen
// ============================================================================

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  // ==========================================================================
  // 1. STATE — API data + filters
  // ==========================================================================

  final ProductRepository _repository = ProductRepository();

  static const int _perPage = 20;

  // ---- Categories (API) ----
  List<Category> _categories = [];
  bool _isLoadingCategories = true;
  String? _categoriesError;

  Category? _selectedCategory;

  // ---- Products (API) ----
  List<Product> _products = [];
  bool _isLoadingProducts = true;
  bool _isLoadingMore = false;
  String? _productsError;
  int _currentPage = 0;
  bool _hasMore = true;

  // ---- Brands (API — custom endpoint!) ----
  Map<String, String> _brandsMap = {}; // productId → brandName
  List<String> _allBrands = []; // unique brand names
  final List<String> _selectedBrands = []; // selected for filter

  // ---- Sort ----
  String selectedSort = 'Popularity';

  // ---- Price Range ----
  static const double _priceMinLimit = 0;
  static const double _priceMaxLimit = 10000;

  RangeValues _priceRange = const RangeValues(_priceMinLimit, _priceMaxLimit);

  bool get _isPriceFilterActive =>
      _priceRange.start > _priceMinLimit || _priceRange.end < _priceMaxLimit;

  bool get _isBrandFilterActive => _selectedBrands.isNotEmpty;

  // ==========================================================================
  // 2. FILTERED + SORTED PRODUCTS
  // ==========================================================================

  List<Product> get filteredProducts {
    List<Product> result = List<Product>.from(_products);

    // ---- BRAND Filter ----
    if (_selectedBrands.isNotEmpty) {
      result = result.where((p) {
        final brand = _brandsMap[p.id.toString()] ?? '';
        return _selectedBrands.contains(brand);
      }).toList();
    }

    // ---- Price Filter (slider) ----
    if (_isPriceFilterActive) {
      result = result
          .where(
            (p) => p.price >= _priceRange.start && p.price <= _priceRange.end,
          )
          .toList();
    }

    // ---- Sort ----
    if (selectedSort == 'Price Low') {
      result.sort((a, b) => a.price.compareTo(b.price));
    } else if (selectedSort == 'Price High') {
      result.sort((a, b) => b.price.compareTo(a.price));
    }

    return result;
  }

  // ==========================================================================
  // 3. INIT
  // ==========================================================================

  @override
  void initState() {
    super.initState();

    _loadCategories();
    _loadProducts();
  }

  // ==========================================================================
  // 4. DATA LOADERS (API)
  // ==========================================================================

  Future<void> _loadCategories() async {
    setState(() {
      _isLoadingCategories = true;
      _categoriesError = null;
    });

    try {
      final categories = await _repository.getCategories();

      if (!mounted) return;

      setState(() {
        _categories = categories;
        _isLoadingCategories = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _categoriesError = e.toString();
        _isLoadingCategories = false;
      });
    }
  }

  /// Category chip tap par — "All" ke liye [category] = null.
  Future<void> _selectCategory(Category? category) async {
    if (_selectedCategory?.id == category?.id && _products.isNotEmpty) {
      return;
    }

    setState(() {
      _selectedCategory = category;
      _products = [];
      _currentPage = 0;
      _hasMore = true;
    });

    await _loadProducts();
  }

  /// Products fetch — [loadMore] = true ho to next page append hoti hai.
  Future<void> _loadProducts({bool loadMore = false}) async {
    if (loadMore && _isLoadingMore) return;

    if (loadMore) {
      setState(() => _isLoadingMore = true);
    } else {
      setState(() {
        _isLoadingProducts = true;
        _productsError = null;
      });
    }

    try {
      final int page = loadMore ? _currentPage + 1 : 1;

      final List<Product> fetched;

      if (_selectedCategory == null) {
        fetched = await _repository.getLatestProducts(
          perPage: _perPage,
          page: page,
        );
      } else {
        fetched = await _repository.getProductsByCategory(
          _selectedCategory!.id,
          perPage: _perPage,
          page: page,
        );
      }

      // ---- Brands bhi load karo (sirf pehli baar) ----
      if (_allBrands.isEmpty) {
        await _loadBrands();
      }

      if (!mounted) return;

      setState(() {
        if (loadMore) {
          _products.addAll(fetched);
          _isLoadingMore = false;
        } else {
          _products = fetched;
          _isLoadingProducts = false;
        }

        _currentPage = page;
        _hasMore = fetched.length >= _perPage;
      });
    } catch (e) {
      if (!mounted) return;

      if (loadMore) {
        setState(() => _isLoadingMore = false);
        _showMessage('Could not load more products');
      } else {
        setState(() {
          _productsError = e.toString();
          _isLoadingProducts = false;
        });
      }
    }
  }

  /// Brands data fetch (custom endpoint: /wp-json/zamindar/v1/brands)
  Future<void> _loadBrands() async {
    try {
      final response = await http
          .get(Uri.parse('${AppConfig.baseUrl}/wp-json/zamindar/v1/brands'))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        // Product → Brand map
        final rawMap = data['product_brands'] as Map<String, dynamic>? ?? {};
        _brandsMap = rawMap.map((k, v) => MapEntry(k, v.toString()));

        // Unique brand names (sorted alphabetically)
        _allBrands = _brandsMap.values.toSet().toList()..sort();
      }
    } catch (_) {
      // Brands load fail → brand filter kaam nahi karega, but app chalegi
    }
  }

  // ==========================================================================
  // 5. SNACKBAR
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
  // 6. ADD TO CART
  // ==========================================================================

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

  // ==========================================================================
  // 7. IMAGE PLACEHOLDER
  // ==========================================================================

  Widget _imagePlaceholder() {
    return Container(
      color: const Color(0xFFF0EEEE),
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_outlined,
        size: 32,
        color: Color(0xFFBBBBBB),
      ),
    );
  }

  // ==========================================================================
  // 8. CATEGORY CHIP
  // ==========================================================================

  Widget _buildCategoryChip(
    String name, {
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
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
  // 9. PRICE CHIP
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
  // 10. BRAND CHIP (selected brand ka chip — filters row ke liye)
  // ==========================================================================

  Widget _buildBrandChip(String brand) {
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
            brand,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: const Color(0xFF087524),
            ),
          ),

          const SizedBox(width: 4),

          InkWell(
            onTap: () {
              setState(() {
                _selectedBrands.remove(brand);
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
  // 11. PRODUCT CARD
  // ==========================================================================

  Widget _buildProductCard(Product product) {
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

    // ---- BRAND dikhaao (API se!) ----
    final String brand = _brandsMap[product.id.toString()] ?? '';

    return InkWell(
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
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 150,
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

            // --- Details ---
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // BRAND (live data!)
                  if (brand.isNotEmpty)
                    Text(
                      brand.toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: const Color(0xFF555555),
                      ),
                    ),

                  const SizedBox(height: 3),

                  // Name
                  Text(
                    product.name,
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
                              product.displayPrice,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF087524),
                              ),
                            ),

                            if (product.onSale)
                              Text(
                                product.displayRegularPrice,
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
      ),
    );
  }

  // ==========================================================================
  // 12. PRODUCTS ERROR
  // ==========================================================================

  Widget _buildProductsError() {
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
              _productsError ?? 'Could not load products.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: const Color(0xFF555555),
              ),
            ),

            const SizedBox(height: 14),

            ElevatedButton.icon(
              onPressed: () => _loadProducts(),
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

  // ==========================================================================
  // 13. FILTER SHEET — BRAND + PRICE!
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
              child: SingleChildScrollView(
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

                        if (_selectedBrands.isNotEmpty)
                          Text(
                            '${_selectedBrands.length} brand(s)',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: const Color(0xFF087524),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ---- BRAND FILTER ----
                    if (_allBrands.isNotEmpty) ...[
                      Text(
                        'Brand',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Brand chips (horizontal scroll)
                      SizedBox(
                        height: 38,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _allBrands.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final brand = _allBrands[index];
                            final isSelected = _selectedBrands.contains(brand);

                            return InkWell(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedBrands.remove(brand);
                                  } else {
                                    _selectedBrands.add(brand);
                                  }
                                });
                                setSheetState(() {});
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF087524)
                                      : const Color(0xFFF0F3EE),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF087524)
                                        : const Color(0xFFD5E2D3),
                                  ),
                                ),
                                child: Text(
                                  brand,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xFF333333),
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],

                    // ---- PRICE SLIDER ----
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

                    // ---- Clear All + Done ----
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _selectedBrands.clear();
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
                              'Done',
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
  // 14. MAIN UI
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    final visibleProducts = filteredProducts;

    final String screenTitle = _selectedCategory?.displayName ?? 'All Products';

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

                  // Profile Button (LIVE PHOTO!)
                  const ProfileAppBarIcon(),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 1, color: Color(0xFFF0EEEE)),

            // ================================================================
            // HEADER
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
                    _selectedCategory == null
                        ? '${_products.length}${_hasMore ? '+' : ''} Products available'
                        : '${_selectedCategory!.count} Products available',
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

              child: _isLoadingCategories
                  ? const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF087524),
                        ),
                      ),
                    )
                  : _categoriesError != null
                  ? Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 16,
                            color: Color(0xFFC62828),
                          ),

                          const SizedBox(width: 6),

                          Text(
                            'Categories failed',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: const Color(0xFF666666),
                            ),
                          ),

                          TextButton(
                            onPressed: _loadCategories,
                            child: Text(
                              'Retry',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF087524),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),

                      padding: const EdgeInsets.symmetric(horizontal: 24),

                      children: [
                        _buildCategoryChip(
                          'All',
                          isSelected: _selectedCategory == null,
                          onTap: () => _selectCategory(null),
                        ),

                        for (final category in _categories) ...[
                          const SizedBox(width: 10),

                          _buildCategoryChip(
                            category.displayName,
                            isSelected: _selectedCategory?.id == category.id,
                            onTap: () => _selectCategory(category),
                          ),
                        ],
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

                              // Brand count badge!
                              if (_selectedBrands.isNotEmpty) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF087524),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${_selectedBrands.length}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
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

                  // ---- Active Filter Chips (Brand + Price) ----
                  if (_isBrandFilterActive || _isPriceFilterActive) ...[
                    const SizedBox(height: 14),

                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        // Brand chips
                        for (final brand in _selectedBrands)
                          _buildBrandChip(brand),

                        // Price chip
                        if (_isPriceFilterActive) _buildPriceChip(),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ================================================================
            // PRODUCTS GRID + EXPLORE MORE
            // ================================================================
            Expanded(
              child: _isLoadingProducts
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF087524),
                      ),
                    )
                  : _productsError != null
                  ? _buildProductsError()
                  : visibleProducts.isEmpty
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

                        // ---- Explore More ----
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(42, 0, 42, 12),
                            child: SizedBox(
                              width: double.infinity,
                              height: 52,

                              child: _isLoadingMore
                                  ? const Center(
                                      child: SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Color(0xFF087524),
                                        ),
                                      ),
                                    )
                                  : OutlinedButton(
                                      onPressed: _hasMore
                                          ? () => _loadProducts(loadMore: true)
                                          : null,

                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: const Color(
                                          0xFF087524,
                                        ),
                                        side: BorderSide(
                                          color: _hasMore
                                              ? const Color(0xFF087524)
                                              : const Color(0xFFD5E2D3),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),

                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            _hasMore
                                                ? 'Explore More Products'
                                                : 'All Products Loaded',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: _hasMore
                                                  ? const Color(0xFF087524)
                                                  : const Color(0xFF999999),
                                            ),
                                          ),

                                          const SizedBox(width: 8),

                                          Icon(
                                            _hasMore
                                                ? Icons.keyboard_arrow_down
                                                : Icons.check_circle_outline,
                                            size: 20,
                                            color: _hasMore
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
                                'Showing ${visibleProducts.length} results',
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
