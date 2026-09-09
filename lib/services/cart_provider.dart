import 'package:flutter/foundation.dart';

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
}

// ============================================================================
// CART PROVIDER
//
// Poore app ka SHARED cart:
//   Home + Categories + Cart + Checkout — sab isi se read/write karte hain
// ============================================================================

class CartProvider extends ChangeNotifier {
  // ==========================================================================
  // 1. DATA
  // ==========================================================================

  final List<CartItem> _items = [];

  /// Cart ke saare items (read-only — bahar se modify nahi ho sakte)
  List<CartItem> get items => List.unmodifiable(_items);

  // ==========================================================================
  // 2. TOTALS
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
  // 3. ADD PRODUCT
  //
  // Id already cart mein hai → quantity +1
  // Naya product → quantity 1 ke saath add
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
  }

  // ==========================================================================
  // 4. QUANTITY CONTROLS (Cart screen ke - / + buttons)
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
  }

  // ==========================================================================
  // 5. REMOVE / CLEAR
  // ==========================================================================

  /// Ek item cart se remove
  void removeProduct(String id) {
    _items.removeWhere((item) => item.id == id);

    notifyListeners();
  }

  /// Poora cart khali — order complete hone ke baad
  void clearCart() {
    _items.clear();

    notifyListeners();
  }
}
