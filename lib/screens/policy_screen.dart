import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ============================================================================
// POLICY SCREEN (Privacy Policy + Terms & Conditions)
//
// 2 tabs:
//   1. Privacy Policy — data collection/use/sharing
//   2. Terms & Conditions — orders/pricing/returns
//
// Website (zamindar.co) ke real content se
// ============================================================================

class PolicyScreen extends StatefulWidget {
  /// Konsi tab pehle khulni hai: 'privacy' ya 'terms'
  final String initialTab;

  const PolicyScreen({super.key, this.initialTab = 'privacy'});

  @override
  State<PolicyScreen> createState() => _PolicyScreenState();
}

class _PolicyScreenState extends State<PolicyScreen>
    with SingleTickerProviderStateMixin {
  // ==========================================================================
  // 1. TAB CONTROLLER
  // ==========================================================================

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();

    // initialTab ke hisaab se default tab
    final int initialIndex = widget.initialTab == 'terms' ? 1 : 0;

    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: initialIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ==========================================================================
  // 2. SECTION BUILDER (policy ka ek section — icon + title + text)
  // ==========================================================================

  Widget _buildSection({
    required IconData icon,
    required String title,
    required List<String> paragraphs,
    List<String>? bullets,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
          // --- Title + Icon ---
          Row(
            children: [
              Container(
                width: 36,
                height: 36,

                decoration: const BoxDecoration(
                  color: Color(0xFFDCE8DA),
                  shape: BoxShape.circle,
                ),

                child: Icon(icon, size: 18, color: const Color(0xFF087524)),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF303030),
                  ),
                ),
              ),
            ],
          ),

          // --- Paragraphs ---
          for (final para in paragraphs) ...[
            const SizedBox(height: 12),

            Text(
              para,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                height: 1.6,
                color: const Color(0xFF666666),
              ),
            ),
          ],

          // --- Bullets ---
          if (bullets != null) ...[
            const SizedBox(height: 8),

            for (final bullet in bullets) ...[
              const SizedBox(height: 6),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Green dot
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Color(0xFF087524),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Bullet text
                  Expanded(
                    child: Text(
                      bullet,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        height: 1.5,
                        color: const Color(0xFF666666),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  // ==========================================================================
  // 3. PRIVACY POLICY TAB (website ke mutabiq)
  // ==========================================================================

  Widget _buildPrivacyTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),

      children: [
        // --- Intro ---
        _buildSection(
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy Policy',
          paragraphs: [
            'At Zamindar, we are committed to protecting your privacy. '
                'This policy explains how we collect, use, and safeguard '
                'your personal information.',
          ],
        ),

        // --- 1. Information We Collect ---
        _buildSection(
          icon: Icons.data_usage_outlined,
          title: 'Information We Collect',
          paragraphs: [
            'We collect information when you place an order, register '
                'an account, or contact customer service:',
          ],
          bullets: [
            'Name, email address, and phone number',
            'Delivery address and order details',
            'Communication preferences',
          ],
        ),

        // --- 2. How We Use ---
        _buildSection(
          icon: Icons.settings_outlined,
          title: 'How We Use Your Information',
          paragraphs: ['Your information is used to:'],
          bullets: [
            'Process and deliver your orders',
            'Send order confirmations and updates',
            'Provide customer support',
            'Improve our products and services',
          ],
        ),

        // --- 3. Sharing ---
        _buildSection(
          icon: Icons.share_outlined,
          title: 'Sharing of Information',
          paragraphs: ['We share your information only with:'],
          bullets: [
            'Delivery partners to ship your order',
            'Service providers who assist our operations',
            'We never sell your personal data to third parties',
          ],
        ),

        // --- 4. Data Security ---
        _buildSection(
          icon: Icons.lock_outlined,
          title: 'Data Security',
          paragraphs: [
            'We use secure servers and encryption to protect your '
                'personal information from unauthorized access, '
                'alteration, or destruction.',
          ],
        ),

        // --- 5. Your Rights ---
        _buildSection(
          icon: Icons.person_outline,
          title: 'Your Rights',
          paragraphs: [
            'You have the right to access, correct, or delete your '
                'personal information at any time. Contact us to '
                'exercise these rights.',
          ],
        ),

        // --- 6. Contact ---
        _buildSection(
          icon: Icons.contact_support_outlined,
          title: 'Contact Us',
          paragraphs: [
            'If you have questions about this privacy policy, '
                'please contact us at:',
          ],
          bullets: [
            'Phone: 0312 7628410',
            'Address: Ada Tam Tam, Jalal Pur Jattan',
          ],
        ),
      ],
    );
  }

  // ==========================================================================
  // 4. TERMS & CONDITIONS TAB (website ke mutabiq)
  // ==========================================================================

  Widget _buildTermsTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),

      children: [
        // --- Intro ---
        _buildSection(
          icon: Icons.description_outlined,
          title: 'Terms & Conditions',
          paragraphs: [
            'By using Zamindar app or placing an order, you agree to '
                'these terms and conditions. Please read them carefully.',
          ],
        ),

        // --- 1. General ---
        _buildSection(
          icon: Icons.agriculture_outlined,
          title: '1. General Terms',
          paragraphs: [
            'Zamindar provides agricultural products and services to '
                'farmers and agriculture professionals.',
            'You must be at least 18 years old to place orders.',
          ],
        ),

        // --- 2. Product Info ---
        _buildSection(
          icon: Icons.inventory_2_outlined,
          title: '2. Product Information & Orders',
          paragraphs: [
            'We make every effort to display products accurately. '
                'However, actual products may vary slightly from '
                'images shown.',
            'We reserve the right to cancel orders if products are '
                'unavailable or incorrectly priced.',
          ],
        ),

        // --- 3. Pricing ---
        _buildSection(
          icon: Icons.payments_outlined,
          title: '3. Pricing & Payment',
          paragraphs: [
            'All prices are in Pakistani Rupees (PKR) and include '
                'applicable taxes.',
          ],
          bullets: [
            'Cash on Delivery (COD) available',
            'Direct Bank Transfer available',
            'Delivery charges may apply on orders below Rs 2,000',
          ],
        ),

        // --- 4. Delivery ---
        _buildSection(
          icon: Icons.local_shipping_outlined,
          title: '4. Delivery & Shipping',
          paragraphs: [
            'We deliver across Pakistan. Delivery timelines vary by '
                'location — typically 2-3 business days.',
          ],
          bullets: [
            'Free delivery on orders above Rs 2,000',
            'Delivery address cannot be changed after dispatch',
            'Please verify your order upon delivery',
          ],
        ),

        // --- 5. Returns ---
        _buildSection(
          icon: Icons.assignment_return_outlined,
          title: '5. Returns & Refunds',
          paragraphs: [
            'Due to the nature of agricultural products, we generally '
                'do not accept returns. However:',
          ],
          bullets: [
            'Damaged or defective products can be returned within 3 days',
            'Refunds are issued to the original payment method',
            'Contact customer service for return requests',
          ],
        ),

        // --- 6. Liability ---
        _buildSection(
          icon: Icons.gavel_outlined,
          title: '6. Limitation of Liability',
          paragraphs: [
            'Zamindar shall not be liable for any indirect or '
                'consequential damages arising from the use of our '
                'products or services.',
          ],
        ),

        // --- 7. Governing Law ---
        _buildSection(
          icon: Icons.account_balance_outlined,
          title: '7. Governing Law',
          paragraphs: [
            'These terms are governed by the laws of Pakistan. '
                'Any disputes shall be resolved in Pakistani courts.',
          ],
        ),

        // --- 8. Contact ---
        _buildSection(
          icon: Icons.contact_support_outlined,
          title: '8. Contact Us',
          paragraphs: ['For questions about these terms:'],
          bullets: [
            'Phone: 0312 7628410',
            'Address: Ada Tam Tam, Jalal Pur Jattan',
          ],
        ),
      ],
    );
  }

  // ==========================================================================
  // 5. MAIN UI
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F7),

      body: SafeArea(
        child: Column(
          children: [
            // --- Header: Back + Title ---
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 24, 0),

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

                  Text(
                    'Privacy & Terms',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1B1C1C),
                    ),
                  ),
                ],
              ),
            ),

            // --- Tabs ---
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),

              child: Container(
                height: 48,

                decoration: BoxDecoration(
                  color: const Color(0xFFF4F3F1),
                  borderRadius: BorderRadius.circular(14),
                ),

                child: TabBar(
                  controller: _tabController,

                  // Selected tab = green | Unselected = grey
                  labelColor: Colors.white,
                  unselectedLabelColor: const Color(0xFF666666),

                  indicator: BoxDecoration(
                    color: const Color(0xFF087524),
                    borderRadius: BorderRadius.circular(12),
                  ),

                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,

                  labelStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),

                  unselectedLabelStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),

                  tabs: const [
                    Tab(text: 'Privacy Policy'),
                    Tab(text: 'Terms & Conditions'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // --- Content ---
            Expanded(
              child: TabBarView(
                controller: _tabController,

                children: [
                  // Tab 1: Privacy Policy
                  _buildPrivacyTab(),

                  // Tab 2: Terms & Conditions
                  _buildTermsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
