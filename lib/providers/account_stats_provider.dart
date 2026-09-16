import 'dart:async';

import 'package:flutter/foundation.dart';

import '../repositories/order_repository.dart';

/// Account screen ke LIVE stats (orders count waghera).
class AccountStatsProvider extends ChangeNotifier {
  int _ordersCount = 0;
  bool _isLoading = false;
  String? _error;
  bool _initialized = false;

  int get ordersCount => _ordersCount;
  bool get isLoading => _isLoading;
  bool get hasError => _error != null;

  /// Account screen khulne par stats load karo
  /// (sirf ek dafa per app session — refresh option bhi hai).
  Future<void> loadStats({bool forceRefresh = false}) async {
    if (_initialized && !forceRefresh) return;

    _isLoading = true;
    notifyListeners();

    try {
      final orders = await OrderRepository().getUserOrders(perPage: 50);
      _ordersCount = orders.length;
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    _initialized = true;
    notifyListeners();
  }

  /// Logout par reset
  void reset() {
    _ordersCount = 0;
    _error = null;
    _initialized = false;
    notifyListeners();
  }
}
