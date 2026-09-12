import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ============================================================================
// CART ITEM
//
// Cart ka ek product. Product dobara add hone par naya item nahi
// banta — sirf quantity barhti hai.
// ============================================================================

class CartItem {
  final String id;
  final String name;
  final int price;
  final String image;
  final int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.quantity,
  });

  /// Is item ki total price (price × quantity)
  int get lineTotal => price * quantity;

  /// JSON banata hai (cart save karne ke liye).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'image': image,
      'quantity': quantity,
    };
  }

  /// JSON se CartItem banata hai (cart load karne ke liye).
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toInt() ?? 0,
      image: json['image'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );
  }
}

// ============================================================================
// CART PROVIDER
//
// Poore app ka SHARED cart:
//   Home + Categories + Cart + Checkout — sab isi se read/write karte hain
//
// NAYA: Cart ab PERMANENT hai —
//   har change par phone par save hota hai,
//   app khulte hi wapas load ho jata hai.
// ============================================================================

class CartProvider extends ChangeNotifier {
  // ==========================================================================
  // 1. DATA
  // ==========================================================================

  static const String _storageKey = 'zamindar_cart_v1';

  final List<CartItem> _items = [];

  /// Cart ke saare items (read-only — bahar se modify nahi ho sakte)
  List<CartItem> get items => List.unmodifiable(_items);

  /// Cart kya save ki hui cheezein load kar chuka hai?
  bool _isLoaded = false;

  // ==========================================================================
  // 2. LOAD (app start par — main.dart se call hota hai)
  // ==========================================================================

  /// Pehli baar cart parhne par phone ki storage se
  /// purani cart load karta hai.
  Future<void> ensureLoaded() async {
    if (_isLoaded) return;
    _isLoaded = true;

    try {
      final prefs = await SharedPreferences.getInstance();

      final String? raw = prefs.getString(_storageKey);

      if (raw == null || raw.isEmpty) return;

      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;

      _items
        ..clear()
        ..addAll(
          decoded.map(
            (item) => CartItem.fromJson(item as Map<String, dynamic>),
          ),
        );
    } catch (_) {
      // Kharab data mila → khaali cart se shuru karenge
    }

    notifyListeners();
  }

  /// Cart ko phone par save karta hai (har change ke baad).
  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final String raw = jsonEncode(
        _items.map((item) => item.toJson()).toList(),
      );

      await prefs.setString(_storageKey, raw);
    } catch (_) {
      // Save fail ho jaye to crash nahi — cart memory mein chalta rahega
    }
  }

  // ==========================================================================
  // 3. TOTALS
  // ==========================================================================

  /// Kitne alag-alag products hain
  int get totalItems => _items.length;

  /// Saari quantities ka total (e.g. 2 + 3 = 5)
  int get totalQuantity => _items.fold(0, (sum, item) => sum + item.quantity);

  /// Subtotal — sirf items ki price (delivery ke baghair)
  int get subtotal => _items.fold(0, (sum, item) => sum + item.lineTotal);

  /// Delivery fee — Rs 2000 se upar FREE, warna Rs 150
  int get deliveryFee => (subtotal >= 2000 || _items.isEmpty) ? 0 : 150;

  /// Grand total = subtotal + delivery
  int get totalAmount => subtotal + deliveryFee;

  // ==========================================================================
  // 4. ADD PRODUCT
  //
  // Id already cart mein hai → quantity +1
  // Naya product → quantity 1 ke saath add
  // (har change ke baad SAVE bhi hota hai)
  // ==========================================================================

  void addProduct({
    required String id,
    required String name,
    required int price,
    required String image,
  }) {
    final int index = _items.indexWhere((item) => item.id == id);

    if (index >= 0) {
      final CartItem old = _items[index];

      _items[index] = CartItem(
        id: old.id,
        name: old.name,
        price: old.price,
        image: old.image,
        quantity: old.quantity + 1,
      );
    } else {
      _items.add(
        CartItem(id: id, name: name, price: price, image: image, quantity: 1),
      );
    }

    notifyListeners();
    _save();
  }

  // ==========================================================================
  // 5. QUANTITY CONTROLS (Cart screen ke - / + buttons)
  // ==========================================================================

  /// Quantity +1
  void increaseQuantity(String id) {
    final int index = _items.indexWhere((item) => item.id == id);
    if (index < 0) return;

    final CartItem old = _items[index];

    _items[index] = CartItem(
      id: old.id,
      name: old.name,
      price: old.price,
      image: old.image,
      quantity: old.quantity + 1,
    );

    notifyListeners();
    _save();
  }

  /// Quantity -1 (quantity 1 thi → poora item remove)
  void decreaseQuantity(String id) {
    final int index = _items.indexWhere((item) => item.id == id);
    if (index < 0) return;

    final CartItem old = _items[index];

    if (old.quantity > 1) {
      _items[index] = CartItem(
        id: old.id,
        name: old.name,
        price: old.price,
        image: old.image,
        quantity: old.quantity - 1,
      );
    } else {
      _items.removeAt(index);
    }

    notifyListeners();
    _save();
  }

  // ==========================================================================
  // 6. REMOVE / CLEAR
  // ==========================================================================

  /// Ek item cart se remove
  void removeProduct(String id) {
    _items.removeWhere((item) => item.id == id);

    notifyListeners();
    _save();
  }

  /// Poora cart khali — order complete hone ke baad
  void clearCart() {
    _items.clear();

    notifyListeners();
    _save();
  }
}
