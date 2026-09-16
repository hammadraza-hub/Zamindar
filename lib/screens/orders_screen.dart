import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/order_model.dart';
import '../providers/auth_provider.dart';
import '../repositories/order_repository.dart';
import 'login_screen.dart';
import 'order_detail_screen.dart';

// ============================================================================
// ORDERS SCREEN — user ki saari orders ki list
//
// Guest      → "Login to see your orders"
// Logged-in  → orders list (order #, status, total)
// Card tap   → Order Detail screen
// ============================================================================

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final OrderRepository _repository = OrderRepository();

  List<OrderModel> _orders = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final orders = await _repository.getUserOrders();

      if (!mounted) return;

      setState(() {
        _orders = orders;
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

  // ==========================================================================
  // 1. ORDER CARD
  // ==========================================================================

  Widget _buildOrderCard(OrderModel order) {
    return InkWell(
      // ---- Tap → DETAIL ----
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OrderDetailScreen(orderId: order.id),
          ),
        );
      },

      borderRadius: BorderRadius.circular(12),

      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),

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
            // ---- Row 1: Order # + Status badge ----
            Row(
              children: [
                Text(
                  'Order #${order.id}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1B1C1C),
                  ),
                ),

                const Spacer(),

                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: order.statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.statusDisplay,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: order.statusColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // ---- Row 2: Date + Items count ----
            Text(
              '${order.formattedDate}  •  ${order.totalQuantity} item(s)',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: const Color(0xFF777777),
              ),
            ),

            const SizedBox(height: 8),

            // ---- Row 3: Products preview ----
            Text(
              order.itemsPreview,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: const Color(0xFF555555),
              ),
            ),

            const SizedBox(height: 10),

            // ---- Row 4: Total + Chevron ----
            Row(
              children: [
                Text(
                  order.displayTotal,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF087524),
                  ),
                ),

                const Spacer(),

                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Color(0xFFAAAAAA),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // 2. STATES
  // ==========================================================================

  // ---- Guest state ----
  Widget _buildLoginRequired() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
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
                Icons.login_outlined,
                size: 38,
                color: Color(0xFF087524),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'Login Required',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF303030),
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Login to see your orders\nand track their status',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: const Color(0xFF666666),
              ),
            ),

            const SizedBox(height: 18),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF087524),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'LOGIN',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- Error state ----
  Widget _buildError() {
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
              onPressed: _loadOrders,
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

  // ---- Empty state ----
  Widget _buildEmpty() {
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
              Icons.receipt_long_outlined,
              size: 38,
              color: Color(0xFF087524),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'No Orders Yet',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF303030),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Your orders will appear here\nafter you place them',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: const Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // 3. MAIN UI
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    // Auth state — login hai ya guest?
    final bool isLoggedIn = context.watch<AuthProvider>().isLoggedIn;

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
                  // Back (agar push hui hai)
                  if (Navigator.canPop(context))
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
                    )
                  else
                    const SizedBox(width: 12),

                  const SizedBox(width: 12),

                  Text(
                    'My Orders',
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

            // ---- Body ----
            Expanded(
              child: !isLoggedIn
                  ? _buildLoginRequired()
                  : _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF087524),
                      ),
                    )
                  : _error != null
                  ? _buildError()
                  : _orders.isEmpty
                  ? _buildEmpty()
                  : RefreshIndicator(
                      color: const Color(0xFF087524),
                      onRefresh: _loadOrders,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(24, 18, 24, 20),
                        children: [
                          for (final order in _orders) _buildOrderCard(order),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
