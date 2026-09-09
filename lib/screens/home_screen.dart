import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../services/cart_provider.dart';
import 'account_screen.dart';

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
  // 2. WHAT'S NEW PRODUCTS DATA
  // ==========================================================================

  final List<Map<String, dynamic>> _whatsNewProducts = [
    {
      'id': 'evergrow-bio',
      'name': 'EverGrow Bio',
      'price': 1250,
      'image': 'assets/images/whats_new2img (1).png',
    },
    {
      'id': 'hybrid-gold-corn',
      'name': 'Hybrid Gold Corn',
      'price': 3400,
      'image': 'assets/images/whats_new2img (2).png',
    },
    {
      'id': 'Acephate 75% SP(1kg)',
      'name': 'Acephate 75% SP (1kg)',
      'price': 2500,
      'image': 'assets/images/whats_new3img.png',
    },
  ];

  // ==========================================================================
  // 3. AUTO BANNER TIMER — har 3 sec forward slide
  //
  // Copy page par: invisible jump + FORAN aage animate
  // (ek hi tick mein — har banner equal time rehta hai)
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
  // 5. PRICE FORMATTER — 1250 → "1,250"
  // ==========================================================================

  String _formatPrice(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }

  // ==========================================================================
  // 6. SNACKBAR MESSAGE
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
  // 7. ADD TO CART — shared CartProvider
  // ==========================================================================

  void _addToCart({
    required String id,
    required String name,
    required int price,
    required String imagePath,
  }) {
    context.read<CartProvider>().addProduct(
      id: id,
      name: name,
      price: price,
      image: imagePath,
    );

    _showMessage('$name added to cart');
  }

  // ==========================================================================
  // 8. CATEGORY CLICK
  // ==========================================================================

  void _showCategoryMessage(String category) {
    _showMessage('$category selected');
  }

  // ==========================================================================
  // 9. CATEGORY WIDGET — icon circle + name
  // ==========================================================================

  Widget _buildCategory({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),

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
  // 10. PRODUCT CARD — image + name + price + Add button
  //
  // ⚠️ Yahan sirf PRODUCT IMAGE hoti hai (Image.asset) —
  // banner ka PageView yahan kabhi nahi aata!
  // ==========================================================================

  Widget _buildProductCard({
    required String id,
    required String imagePath,
    required String name,
    required int price,
  }) {
    // Cart watch — quantity live update ke liye
    final CartProvider cart = context.watch<CartProvider>();

    int quantityInCart = 0;

    for (final item in cart.items) {
      if (item.id == id) {
        quantityInCart = item.quantity;
        break;
      }
    }

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
          // --- Product Image (FIXED: Image.asset, PageView NAHI) ---
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              imagePath,
              width: double.infinity,
              height: 135,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(height: 10),

          // --- Product Name ---
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: const Color(0xFF303030),
            ),
          ),

          const SizedBox(height: 4),

          // --- Product Price ---
          Text(
            'Rs ${_formatPrice(price)}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF087524),
            ),
          ),

          const SizedBox(height: 10),

          // --- Add To Cart Button (+ quantity) ---
          SizedBox(
            width: double.infinity,
            height: 38,

            child: ElevatedButton(
              onPressed: () {
                _addToCart(
                  id: id,
                  name: name,
                  price: price,
                  imagePath: imagePath,
                );
              },

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
                '"High quality products that really\n'
                'improved my crop yield. The delivery was\n'
                'fast and professional."',
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
  // 13. MAIN UI — build method
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
              // 14. HEADER — logo + title + search + profile
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
                      _showMessage('Search icon clicked');
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
              // 15. HERO BANNER SLIDER — infinite forward loop
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

                        // Padosi pages pre-built — smooth
                        allowImplicitScrolling: true,

                        // 4 pages: 3 asli + 1 copy
                        itemCount: _pageCount,

                        // Sirf dots update — jump ka kaam TIMER karta hai
                        onPageChanged: (index) {
                          setState(() {
                            _currentBanner = index % _banners.length;
                          });
                        },

                        itemBuilder: (context, index) {
                          // index 3 par _banners[0] (copy) dikhegi
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
              // 16. CHOOSE BY CATEGORY — 4 categories
              // =================================================================
              Text(
                'Choose by Category',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  color: const Color(0xFF252525),
                ),
              ),

              const SizedBox(height: 16),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                ],
              ),

              const SizedBox(height: 30),

              // =================================================================
              // 17. WHAT'S NEW HEADER — title + See All
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

                  // See All
                  InkWell(
                    onTap: () {
                      _showMessage('See All clicked');
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
              // 18. WHAT'S NEW PRODUCTS — horizontal list
              // =================================================================
              SizedBox(
                height: 270,

                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),

                  itemCount: _whatsNewProducts.length,

                  // Cards ke beech 12px gap
                  separatorBuilder: (context, index) {
                    return const SizedBox(width: 12);
                  },

                  itemBuilder: (context, index) {
                    final Map<String, dynamic> product =
                        _whatsNewProducts[index];

                    return _buildProductCard(
                      id: product['id'] as String,
                      imagePath: product['image'] as String,
                      name: product['name'] as String,
                      price: product['price'] as int,
                    );
                  },
                ),
              ),

              const SizedBox(height: 30),

              // =================================================================
              // 19. OUR BRANDS — horizontal chips
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
                    _buildBrandChip('AgroPlus'),
                    const SizedBox(width: 12),
                    _buildBrandChip('GreenField'),
                    const SizedBox(width: 12),
                    _buildBrandChip('SeedCo'),
                    const SizedBox(width: 12),
                    _buildBrandChip('FarmGrow'),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // =================================================================
              // 20. CUSTOMER REVIEW
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
