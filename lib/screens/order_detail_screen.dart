import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/order_model.dart';
import '../repositories/order_repository.dart';

// ============================================================================
// ORDER DETAIL SCREEN — ek order ki poori detail
//
//   - Status (bara colored badge)
//   - Items list (images ke sath)
//   - Delivery address
//   - Payment method
//   - Totals (shipping + grand total)
//
// Order ID se fetch karta hai (OrdersScreen / TRACK ORDER se aata hai)
// ============================================================================

class OrderDetailScreen extends StatefulWidget {
  final int orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final OrderRepository _repository = OrderRepository();

  OrderModel? _order;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final order = await _repository.getOrder(widget.orderId);

      if (!mounted) return;

      setState(() {
        _order = order;
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
  // 1. HELPERS
  // ==========================================================================

  Widget _imagePlaceholder() {
    return Container(
      color: const Color(0xFFF0EEEE),
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_outlined,
        size: 22,
        color: Color(0xFFBBBBBB),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  // ==========================================================================
  // 2. STATUS CARD — bara colored badge
  // ==========================================================================

  Widget _buildStatusCard(OrderModel order) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration().copyWith(
        border: Border.all(color: order.statusColor.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          // ---- Icon circle ----
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: order.statusColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              order.status == 'completed'
                  ? Icons.check_circle_outline
                  : order.status == 'cancelled' || order.status == 'failed'
                  ? Icons.cancel_outlined
                  : Icons.local_shipping_outlined,
              size: 30,
              color: order.statusColor,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            order.statusDisplay,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: order.statusColor,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            order.status == 'on-hold'
                ? 'Your order is awaiting payment'
                : order.status == 'processing'
                ? 'Your order is being prepared'
                : order.status == 'completed'
                ? 'Your order was delivered!'
                : 'Order #${order.id}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: const Color(0xFF777777),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // 3. ITEM ROW
  // ==========================================================================

  Widget _buildItemRow(OrderLineItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // ---- Image ----
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 56,
              height: 56,
              child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: item.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => _imagePlaceholder(),
                      errorWidget: (_, _, _) => _imagePlaceholder(),
                    )
                  : _imagePlaceholder(),
            ),
          ),

          const SizedBox(width: 12),

          // ---- Name + qty ----
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF303030),
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  'Qty ${item.quantity} × ${item.displayPrice}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: const Color(0xFF777777),
                  ),
                ),
              ],
            ),
          ),

          // ---- Line total ----
          Text(
            item.lineTotal,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF087524),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // 4. SECTION TITLE
  // ==========================================================================

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF303030),
      ),
    );
  }

  // ==========================================================================
  // 5. DETAIL ROW (label + value)
  // ==========================================================================

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: const Color(0xFF666666),
            ),
          ),

          const Spacer(),

          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF303030),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // 6. MAIN UI
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
                    _order != null
                        ? 'Order #${_order!.id}'
                        : 'Order #${widget.orderId}',
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
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF087524),
                      ),
                    )
                  : _error != null
                  ? _buildError()
                  : _buildContent(_order!),
            ),
          ],
        ),
      ),
    );
  }

  // ---- Error ----
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
              onPressed: _loadOrder,
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

  // ---- Content ----
  Widget _buildContent(OrderModel order) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 18),

          // ---- 1. Status card ----
          _buildStatusCard(order),

          const SizedBox(height: 16),

          // ---- 2. Items card ----
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
            decoration: _cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('Items (${order.totalQuantity})'),

                for (int i = 0; i < order.items.length; i++) ...[
                  _buildItemRow(order.items[i]),
                  if (i < order.items.length - 1)
                    const Divider(height: 1, color: Color(0xFFF0EEEE)),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ---- 3. Delivery address card ----
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: _cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('Delivery Address'),

                const SizedBox(height: 10),

                _detailRow('Name', order.billingName),
                _detailRow('Phone', order.billingPhone),
                _detailRow('Address', order.billingAddress),
                _detailRow('Email', order.billingEmail),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ---- 4. Payment + totals card ----
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: _cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('Payment & Totals'),

                const SizedBox(height: 10),

                _detailRow('Payment Method', order.paymentMethodTitle),
                _detailRow('Order Date', order.formattedDate),
                _detailRow('Delivery Fee', order.displayShipping),

                if (order.customerNote.isNotEmpty)
                  _detailRow('Note', order.customerNote),

                const Divider(color: Color(0xFFF0EEEE)),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        'Total',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF303030),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        order.displayTotal,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF087524),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
