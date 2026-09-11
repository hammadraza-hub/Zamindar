import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../repositories/product_repository.dart';
import '../services/cart_provider.dart';
import 'account_screen.dart';
import 'categories_screen.dart';
import 'search_screen.dart';

// ============================================================================
// HOME SCREEN
// ============================================================================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ==========================================================================
  // 1. BANNER STATE — controller, timer, images
  // ==========================================================================

  final PageController _pageController = PageController();

  int _currentBanner = 0;

  Timer? _bannerTimer;

  final List<String> _banners = [
    'assets/images/banner1.png',
    'assets/images/banner2.png',
    'assets/images/banner3.png',
  ];

  /// Total pages = 3 asli + 1 copy (infinite loop ke liye)
  int get _pageCount => _banners.length + 1;

  // ==========================================================================
  // 2. WHAT'S NEW PRODUCTS — zamindar.co API se LIVE data
  // ==========================================================================

  final ProductRepository _productRepository = ProductRepository();

  List<Product> _whatsNewProducts = [];
  bool _isLoadingProducts = true;
  String? _productsError;

  // ==========================================================================
  // 3. INIT — banner timer start + products load
  // ==========================================================================

  @override
  void initState() {
    super.initState();

    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!_pageController.hasClients) {
        return;
      }

      int currentPage = _pageController.page?.round() ?? 0;

      // Copy page (last) par? → invisible jump to page 0
      if (currentPage >= _banners.length) {
        _pageController.jumpToPage(0);
        currentPage = 0;
      }

      // Hamesha forward animate — return NAHI
      _pageController.animateToPage(
        currentPage + 1,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });

    // API se latest products load karo
    _loadProducts();
  }

  /// zamindar.co se latest products fetch karta hai.
  Future<void> _loadProducts() async {
    setState(() {
      _isLoadingProducts = true;
      _productsError = null;
    });

    try {
      final products = await _productRepository.getLatestProducts(perPage: 10);

      if (!mounted) return;

      setState(() {
        _whatsNewProducts = products;
        _isLoadingProducts = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _productsError = e.toString();
        _isLoadingProducts = false;
      });
    }
  }

  // ==========================================================================
  // 4. DISPOSE — timer + controller cleanup
  // ==========================================================================

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _pageController.dispose();

    super.dispose();
  }

  // ==========================================================================
  // 5. SNACKBAR MESSAGE
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
  // 6. ADD TO CART — API product se
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
  // 7. CATEGORY CLICK
  // ==========================================================================

  void _showCategoryMessage(String category) {
    _showMessage('$category selected');
  }

  // ==========================================================================
  // 8. CATEGORY WIDGET — fixed width (horizontal scroll ke liye)
  // ==========================================================================

  Widget _buildCategory({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),

      child: SizedBox(
        width: 84,

        child: Column(
          children: [
            // --- Icon Circle ---
            Container(
              width: 64,
              height: 64,

              decoration: const BoxDecoration(
                color: Color(0xFFF0EEEE),
                shape: BoxShape.circle,
              ),

              child: Icon(icon, size: 27, color: const Color(0xFF087524)),
            ),

            const SizedBox(height: 10),

            // --- Category Name ---
            Text(
              title,
              textAlign: TextAlign.center,

              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                height: 1.25,
                color: const Color(0xFF303030),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // 9. IMAGE PLACEHOLDER — jab image na ho / load na ho
  // ==========================================================================

  Widget _imagePlaceholder() {
    return Container(
      color: const Color(0xFFF0EEEE),
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_outlined,
        size: 36,
        color: Color(0xFFBBBBBB),
      ),
    );
  }

  // ==========================================================================
  // 10. PRODUCT CARD — API product + network image
  // ==========================================================================

  Widget _buildProductCard(Product product) {
    // Cart watch — quantity live update ke liye
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

    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Product Image (API se — network image) ---
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: double.infinity,
              height: 135,
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

          const SizedBox(height: 10),

          // --- Product Name ---
          Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: const Color(0xFF303030),
            ),
          ),

          const SizedBox(height: 4),

          // --- Product Price (sale par purani price bhi dikhti hai) ---
          Text.rich(
            TextSpan(
              children: [
                if (product.onSale) ...[
                  TextSpan(
                    text: product.displayRegularPrice,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: const Color(0xFF999999),
                      decoration: TextDecoration.lineThrough,
                      decorationColor: const Color(0xFF999999),
                    ),
                  ),
                  const TextSpan(text: '  '),
                ],
                TextSpan(
                  text: product.displayPrice,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF087524),
                  ),
                ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 10),

          // --- Add To Cart Button (+ quantity) ---
          SizedBox(
            width: double.infinity,
            height: 38,

            child: ElevatedButton(
              onPressed: () => _addToCart(product),

              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFFFF7900),
                foregroundColor: const Color(0xFF222222),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
              ),

              child: Text(
                quantityInCart > 0 ? '+ Add ($quantityInCart)' : '+ Add',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // 11. BRAND CHIP
  // ==========================================================================

  Widget _buildBrandChip(String name) {
    return InkWell(
      onTap: () {
        _showMessage('$name selected');
      },

      borderRadius: BorderRadius.circular(30),

      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),

        decoration: BoxDecoration(
          color: const Color(0xFFF0EEEE),
          borderRadius: BorderRadius.circular(30),
        ),

        child: Text(
          name,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF1B1C1C),
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // 12. CUSTOMER REVIEW CARD
  // ==========================================================================

  Widget _buildReviewCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: const Color(0xFFF1F3EE),
        borderRadius: BorderRadius.circular(14),
      ),

      child: Stack(
        children: [
          // --- Decorative Quote ---
          Positioned(
            top: -18,
            right: -5,
            child: Text(
              '”',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 90,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFD8E7D8),
                height: 1,
              ),
            ),
          ),

          // --- Review Content ---
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rating Stars
              Row(
                children: List.generate(
                  5,
                  (index) => const Icon(
                    Icons.star,
                    size: 20,
                    color: Color(0xFFA54B00),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Review Text
              Text(
                '"Zamindar\'s agricultural medicines have\n'
                'truly transformed my farm. My crops are\n'
                'healthier, and the free delivery is a plus!"',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  height: 1.6,
                  color: const Color(0xFF555555),
                ),
              ),

              const SizedBox(height: 16),

              // Reviewer — Avatar + Name
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2E913E),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      'AK',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Text(
                    'Ahmed Khan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: const Color(0xFF333333),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // 13. PRODUCTS ERROR — message + Retry button
  // ==========================================================================

  Widget _buildProductsError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
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
              onPressed: _loadProducts,
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
  // 14. MAIN UI — build method
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F7),

      // BottomNavigationBar MainNavigationScreen handle karta hai
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // =================================================================
              // 15. HEADER — logo + title + search + profile
              // =================================================================
              Row(
                children: [
                  // Logo
                  Image.asset(
                    'assets/images/zamindar_logo.png',
                    width: 70,
                    height: 45,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(width: 8),

                  // Home Title
                  Text(
                    'Home',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF087524),
                    ),
                  ),

                  const Spacer(),

                  // Search Button
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

                  // Profile Button → Account Screen
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

              const SizedBox(height: 16),

              // =================================================================
              // 16. HERO BANNER SLIDER — infinite forward loop
              // =================================================================
              SizedBox(
                width: double.infinity,
                height: 200,

                child: Stack(
                  children: [
                    // --- Banner PageView (sirf YAHAN, kahin aur nahi!) ---
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),

                      child: PageView.builder(
                        controller: _pageController,

                        allowImplicitScrolling: true,

                        itemCount: _pageCount,

                        onPageChanged: (index) {
                          setState(() {
                            _currentBanner = index % _banners.length;
                          });
                        },

                        itemBuilder: (context, index) {
                          return Image.asset(
                            _banners[index % _banners.length],
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),

                    // --- Slider Dots ---
                    Positioned(
                      bottom: 12,
                      left: 0,
                      right: 0,

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: List.generate(_banners.length, (index) {
                          final bool isActive = index == _currentBanner;

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: isActive ? 9 : 7,
                            height: isActive ? 9 : 7,

                            decoration: BoxDecoration(
                              color: isActive
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // =================================================================
              // 17. CHOOSE BY CATEGORY — 5 categories
              // =================================================================
              Text(
                'Choose by Category',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  color: const Color(0xFF252525),
                ),
              ),

              SizedBox(
                height: 120,

                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),

                  children: [
                    _buildCategory(
                      icon: Icons.eco_outlined,
                      title: 'PGRs &\nMicronutrients',
                      onTap: () {
                        _showCategoryMessage('PGRs & Micronutrients');
                      },
                    ),

                    _buildCategory(
                      icon: Icons.agriculture_outlined,
                      title: 'Herbicides',
                      onTap: () {
                        _showCategoryMessage('Herbicides');
                      },
                    ),

                    _buildCategory(
                      icon: Icons.science_outlined,
                      title: 'Fungicides',
                      onTap: () {
                        _showCategoryMessage('Fungicides');
                      },
                    ),

                    _buildCategory(
                      icon: Icons.bug_report_outlined,
                      title: 'Insecticides',
                      onTap: () {
                        _showCategoryMessage('Insecticides');
                      },
                    ),

                    _buildCategory(
                      icon: Icons.grass,
                      title: 'Seed Care',
                      onTap: () {
                        _showCategoryMessage('Seed Care');
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // =================================================================
              // 18. WHAT'S NEW HEADER — title + See All
              // =================================================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "What's New",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      color: const Color(0xFF252525),
                    ),
                  ),

                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CategoriesScreen(),
                        ),
                      );
                    },

                    child: Text(
                      'See All',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: const Color(0xFF087524),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // =================================================================
              // 19. WHAT'S NEW PRODUCTS — LIVE API + loading + error states
              // =================================================================
              SizedBox(
                height: 270,

                child: _isLoadingProducts
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF087524),
                        ),
                      )
                    : _productsError != null
                    ? _buildProductsError()
                    : _whatsNewProducts.isEmpty
                    ? Center(
                        child: Text(
                          'No products found.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: const Color(0xFF555555),
                          ),
                        ),
                      )
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),

                        itemCount: _whatsNewProducts.length,

                        separatorBuilder: (context, index) {
                          return const SizedBox(width: 12);
                        },

                        itemBuilder: (context, index) {
                          return _buildProductCard(_whatsNewProducts[index]);
                        },
                      ),
              ),

              const SizedBox(height: 30),

              // =================================================================
              // 20. OUR BRANDS — horizontal chips
              // =================================================================
              Text(
                'Our Brands',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  color: const Color(0xFF252525),
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                height: 45,

                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),

                  children: [
                    _buildBrandChip('Bayer'),
                    const SizedBox(width: 12),
                    _buildBrandChip('Syngenta'),
                    const SizedBox(width: 12),
                    _buildBrandChip('Evyol Group'),
                    const SizedBox(width: 12),
                    _buildBrandChip('Orange Production'),
                    const SizedBox(width: 12),
                    _buildBrandChip('Haji Sons'),
                    const SizedBox(width: 12),
                    _buildBrandChip('Kanzo AG'),
                    const SizedBox(width: 12),
                    _buildBrandChip('Sakata Seeds'),
                    const SizedBox(width: 12),
                    _buildBrandChip('Sohni Dharti'),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // =================================================================
              // 21. CUSTOMER REVIEW
              // =================================================================
              _buildReviewCard(),

              const SizedBox(height: 35),
            ],
          ),
        ),
      ),
    );
  }
}
