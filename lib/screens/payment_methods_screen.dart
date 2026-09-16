import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ============================================================================
// PAYMENT METHODS SCREEN — 3D Cards Design
//
//   - COD (1 card)
//   - Bank Transfer (har detail apne alag 3D card mein!)
// ============================================================================

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  // ==========================================================================
  // 1. DECORATIONS
  // ==========================================================================

  BoxDecoration _mainCard() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  BoxDecoration _detailCardDecoration() {
    return BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF8FBF8), Color(0xFFFFFFFF)],
      ),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFD5E2D3), width: 1),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF087524).withValues(alpha: 0.08),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  // ==========================================================================
  // 2. BADGE
  // ==========================================================================

  Widget _availableBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF087524),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF087524).withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        'Available',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  // ==========================================================================
  // 3. METHOD HEADER (icon + title + badge)
  // ==========================================================================

  Widget _methodHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF087524), Color(0xFF2E913E)],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF087524).withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, size: 26, color: Colors.white),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1B1C1C),
                ),
              ),

              const SizedBox(height: 3),

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

        _availableBadge(),
      ],
    );
  }

  // ==========================================================================
  // 4. DETAIL CARD (3D look — label + value + copy button)
  // ==========================================================================

  Widget _detailCard({
    required IconData icon,
    required String label,
    required String value,
    bool copyable = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: _detailCardDecoration(),

      child: Row(
        children: [
          // ---- Icon circle (3D) ----
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFDCE8DA), Color(0xFFC8E0C8)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF087524).withValues(alpha: 0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF087524)),
          ),

          const SizedBox(width: 12),

          // ---- Label + Value ----
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    color: const Color(0xFF999999),
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1B1C1C),
                  ),
                ),
              ],
            ),
          ),

          // ---- Copy button ----
          if (copyable)
            InkWell(
              onTap: () {
                Clipboard.setData(ClipboardData(text: value));
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF087524).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.copy,
                  size: 14,
                  color: Color(0xFF087524),
                ),
              ),
            ),
        ],
      ),
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
            // ---- Header ----
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 24, 14),
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
                    'Payment Methods',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1B1C1C),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 1, color: Color(0xFFF0EEEE)),

            // ---- Content ----
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 20),
                children: [
                  // ==========================================================
                  // 1. CASH ON DELIVERY (main card)
                  // ==========================================================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: _mainCard(),

                    child: Column(
                      children: [
                        _methodHeader(
                          icon: Icons.payments_outlined,
                          title: 'Cash on Delivery',
                          subtitle: 'Pay with cash upon delivery',
                        ),

                        const SizedBox(height: 14),

                        const Divider(color: Color(0xFFF0EEEE)),

                        const SizedBox(height: 10),

                        Row(
                          children: [
                            const Icon(
                              Icons.check_circle_outline,
                              size: 15,
                              color: Color(0xFF087524),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'No extra charges',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: const Color(0xFF666666),
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.check_circle_outline,
                              size: 15,
                              color: Color(0xFF087524),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Most popular',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: const Color(0xFF666666),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ==========================================================
                  // 2. BANK TRANSFER (header card)
                  // ==========================================================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: _mainCard(),

                    child: Column(
                      children: [
                        _methodHeader(
                          icon: Icons.account_balance_outlined,
                          title: 'Direct Bank Transfer',
                          subtitle: 'Transfer payment to our account',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ---- Bank details: HAR DETAIL ALAG 3D CARD ----
                  Text(
                    'BANK DETAILS',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF999999),
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(height: 10),

                  _detailCard(
                    icon: Icons.account_balance,
                    label: 'BANK NAME',
                    value: 'Meezan Bank',
                  ),

                  const SizedBox(height: 10),

                  _detailCard(
                    icon: Icons.person,
                    label: 'ACCOUNT TITLE',
                    value: 'Zamindar Agri Solutions',
                  ),

                  const SizedBox(height: 10),

                  _detailCard(
                    icon: Icons.credit_card,
                    label: 'ACCOUNT NUMBER',
                    value: 'PK00 XXXX XXXX XXXX',
                    copyable: true,
                  ),

                  const SizedBox(height: 10),

                  _detailCard(
                    icon: Icons.tag,
                    label: 'IBAN',
                    value: 'PK00 XXXX 0000 0000 0000',
                    copyable: true,
                  ),

                  const SizedBox(height: 16),

                  // ---- Warning note (3D style) ----
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFFFF8E1), Color(0xFFFFF3E0)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFFFB74D).withValues(alpha: 0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFEF6C00)
                              .withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFB74D),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.warning_amber,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Text(
                            'Order ID ko payment reference mein likhein. '
                            'Payment confirm hone par order process hogi.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              height: 1.4,
                              color: const Color(0xFF8D6E63),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
