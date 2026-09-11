/// Central place for all app-wide configuration values.
/// Change [baseUrl] here if the domain ever changes.
class AppConfig {
  AppConfig._(); // prevent instantiation

  // ---------- API ----------
  static const String baseUrl = 'https://zamindar.co';

  // WooCommerce Store API (public, no keys needed)
  static const String _storeApi = '/wp-json/wc/store/v1';

  // ---------- Endpoints ----------
  static String get products => '$baseUrl$_storeApi/products';
  static String get categories => '$baseUrl$_storeApi/products/categories';

  /// Single product by ID.
  static String productById(int id) => '$baseUrl$_storeApi/products/$id';

  /// Products filtered by category ID.
  static String productsByCategory(int categoryId) =>
      '$baseUrl$_storeApi/products?category=$categoryId';
}
