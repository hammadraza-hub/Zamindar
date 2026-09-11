import '../config/app_config.dart';
import '../models/product.dart';
import '../services/api/api_client.dart';

/// All product data operations in one place.
class ProductRepository {
  /// Latest products (newest first) — used on the Home screen.
  Future<List<Product>> getLatestProducts({int perPage = 20}) async {
    final data = await ApiClient.get(
      '${AppConfig.products}?per_page=$perPage&orderby=date&order=desc',
    );
    return _toList(data);
  }

  /// A single product by ID — used on the Product Detail screen.
  Future<Product> getProductById(int id) async {
    final data = await ApiClient.get(AppConfig.productById(id));
    return Product.fromJson(data as Map<String, dynamic>);
  }

  /// All products of one category — used on the Categories screen.
  Future<List<Product>> getProductsByCategory(
    int categoryId, {
    int perPage = 50,
  }) async {
    final data = await ApiClient.get(
      '${AppConfig.productsByCategory(categoryId)}&per_page=$perPage',
    );
    return _toList(data);
  }

  /// Search products by keyword.
  Future<List<Product>> searchProducts(String term, {int perPage = 20}) async {
    final data = await ApiClient.get(
      '${AppConfig.products}?search=${Uri.encodeComponent(term)}'
      '&per_page=$perPage',
    );
    return _toList(data);
  }

  // ---------- private ----------

  List<Product> _toList(dynamic data) {
    final list = data as List? ?? const [];
    return list
        .map((item) => Product.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
