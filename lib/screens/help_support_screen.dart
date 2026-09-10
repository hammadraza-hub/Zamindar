import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'policy_screen.dart';

// ============================================================================
// HELP & SUPPORT SCREEN
//
// [Call Us] [FAQ] [Location] [Quick Links]
// ============================================================================

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  // ==========================================================================
  // 1. CONTACT INFO (website se)
  // ==========================================================================

  final String _phone = '03127628410';
  final String _address = 'Ada Tam Tam, Jalal Pur Jattan';

  // ==========================================================================
  // 2. CALL NOW — dialer khulta hai
  // ==========================================================================

  Future<void> _callNow() async {
    final Uri url = Uri.parse('tel:$_phone');

    try {
      await launchUrl(url);
    } catch (_) {
      _showMessage('Call nahi ho saka — manually dial karein');
    }
  }

  // ==========================================================================
  // 3. HELPERS
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
  // 4. CONTACT CARD (Call Us)
  // ==========================================================================

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onTap,
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
          // --- Icon + Title + Subtitle ---
          Row(
            children: [
              Container(
                width: 44,
                height: 44,

                decoration: const BoxDecoration(
                  color: Color(0xFFDCE8DA),
                  shape: BoxShape.circle,
                ),

                child: Icon(icon, size: 22, color: const Color(0xFF087524)),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF303030),
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: const Color(0xFF777777),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // --- Action Button ---
          SizedBox(
            width: double.infinity,
            height: 46,

            child: ElevatedButton.icon(
              onPressed: onTap,

              icon: Icon(icon, size: 18),

              label: Text(
                buttonText,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF087524),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // 5. FAQ ITEM (tap kar ke answer khulta hai)
  // ==========================================================================

  Widget _buildFaqItem({required String question, required String answer}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),

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

      child: Theme(
        // Default divider hatane ke liye
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),

        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),

          // Q icon + Question
          leading: Container(
            width: 32,
            height: 32,

            decoration: const BoxDecoration(
              color: Color(0xFFDCE8DA),
              shape: BoxShape.circle,
            ),

            child: Icon(
              Icons.help_outline,
              size: 16,
              color: const Color(0xFF087524),
            ),
          ),

          title: Text(
            question,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF303030),
            ),
          ),

          iconColor: const Color(0xFF087524),
          collapsedIconColor: const Color(0xFF087524),

          // Answer
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),

          children: [
            Text(
              answer,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                height: 1.6,
                color: const Color(0xFF666666),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // 6. INFO CARD (Location / Quick Links)
  // ==========================================================================

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
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
          // Title
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

              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF303030),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Content
          ...children,
        ],
      ),
    );
  }

  // ==========================================================================
  // 7. MAIN UI
  //
  // [Call] → [FAQ] → [Location] → [Quick Links]
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F7),

      body: SafeArea(
        child: Column(
          children: [
            // --- Header ---
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
                    'Help & Support',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1B1C1C),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- Content ---
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),

                children: [
                  // ============ CALL US ============
                  _buildContactCard(
                    icon: Icons.phone_outlined,
                    title: 'Call Us',
                    subtitle: '$_phone — Mon-Sat, 9 AM to 6 PM',
                    buttonText: 'CALL NOW',
                    onTap: _callNow,
                  ),

                  // ============ FAQ ============
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),

                    child: Text(
                      'Frequently Asked Questions',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF303030),
                      ),
                    ),
                  ),

                  _buildFaqItem(
                    question: 'How do I place an order?',
                    answer:
                        'Browse products from Home or Categories, tap the '
                        'orange [+] button to add items to your cart, then '
                        'tap "Proceed to Checkout" from the Cart tab. '
                        'Select your delivery address and payment method, '
                        'then tap "Place Order".',
                  ),

                  _buildFaqItem(
                    question: 'What are the delivery charges?',
                    answer:
                        'Delivery is FREE on orders above Rs 2,000. '
                        'For orders below Rs 2,000, a flat delivery fee of '
                        'Rs 150 applies. Delivery typically takes 2-3 '
                        'business days.',
                  ),

                  _buildFaqItem(
                    question: 'What payment methods are available?',
                    answer:
                        'We accept:\n'
                        '• Cash on Delivery (COD) — pay when your order '
                        'arrives\n'
                        '• Direct Bank Transfer — pay into our account '
                        'using your Order ID as reference',
                  ),

                  _buildFaqItem(
                    question: 'How do I change my delivery address?',
                    answer:
                        'On the Checkout screen, tap "Change" next to your '
                        'delivery address. You can update the name, phone '
                        'number, and complete address before placing '
                        'your order.',
                  ),

                  _buildFaqItem(
                    question: 'What is the return policy?',
                    answer:
                        'Due to the nature of agricultural products, we '
                        'generally do not accept returns. However, damaged '
                        'or defective products can be returned within 3 '
                        'days of delivery. Contact us to request a return.',
                  ),

                  _buildFaqItem(
                    question: 'How do I track my order?',
                    answer:
                        'Order tracking is coming soon! Once available, '
                        'you will be able to track your orders from '
                        '"My Orders" in your Account section.',
                  ),

                  const SizedBox(height: 10),

                  // ============ LOCATION ============
                  _buildInfoCard(
                    icon: Icons.location_on_outlined,
                    title: 'Our Location',
                    children: [
                      Text(
                        _address,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          height: 1.5,
                          color: const Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),

                  // ============ QUICK LINKS ============
                  _buildInfoCard(
                    icon: Icons.link_outlined,
                    title: 'Quick Links',
                    children: [
                      // Privacy Policy
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const PolicyScreen(initialTab: 'privacy'),
                            ),
                          );
                        },

                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),

                          child: Row(
                            children: [
                              const Icon(
                                Icons.privacy_tip_outlined,
                                size: 20,
                                color: Color(0xFF087524),
                              ),

                              const SizedBox(width: 12),

                              Text(
                                'Privacy Policy',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  color: const Color(0xFF303030),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Divider(color: Color(0xFFF0EEEE)),

                      // Terms & Conditions
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const PolicyScreen(initialTab: 'terms'),
                            ),
                          );
                        },

                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),

                          child: Row(
                            children: [
                              const Icon(
                                Icons.description_outlined,
                                size: 20,
                                color: Color(0xFF087524),
                              ),

                              const SizedBox(width: 12),

                              Text(
                                'Terms & Conditions',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  color: const Color(0xFF303030),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
