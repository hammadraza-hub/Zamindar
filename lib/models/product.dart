import '../utils/html_utils.dart';

/// A single product fetched from the WooCommerce Store API (zamindar.co).
class Product {
  final int id;
  final String name;
  final String slug;
  final String permalink;
  final String type;

  final String description; // raw HTML
  final String shortDescription; // raw HTML

  final double price; // current selling price
  final double regularPrice; // price before sale
  final bool onSale;

  final bool inStock;
  final double averageRating;
  final int reviewCount;

  final String? imageUrl; // main image (full size)
  final String? imageThumbnailUrl; // main image (small size)

  final List<int> categoryIds;
  final List<String> categoryNames;

  const Product({
    required this.id,
    required this.name,
    required this.slug,
    required this.permalink,
    required this.type,
    required this.description,
    required this.shortDescription,
    required this.price,
    required this.regularPrice,
    required this.onSale,
    required this.inStock,
    required this.averageRating,
    required this.reviewCount,
    required this.imageUrl,
    required this.imageThumbnailUrl,
    required this.categoryIds,
    required this.categoryNames,
  });

  /// Builds a [Product] from the JSON returned by the Store API.
  factory Product.fromJson(Map<String, dynamic> json) {
    // ---------- Prices ----------
    final prices = (json['prices'] as Map<String, dynamic>?) ?? {};

    double toPrice(dynamic value, double divisor) {
      if (value == null || value.toString().isEmpty) return 0;
      return (double.tryParse(value.toString()) ?? 0) / divisor;
    }

    double salePrice = 0;
    double regular = 0;
    double current = 0;

    if (prices.isNotEmpty) {
      final minorUnit =
          int.tryParse(prices['currency_minor_unit']?.toString() ?? '0') ?? 0;
      final divisor = _pow10(minorUnit);

      salePrice = toPrice(prices['sale_price'], divisor);
      regular = toPrice(prices['regular_price'], divisor);
      current = toPrice(prices['price'], divisor);
    } else {
      salePrice = toPrice(json['sale_price'], 1);
      regular = toPrice(json['regular_price'], 1);
      current = toPrice(json['price'], 1);
    }

    final bool onSale = salePrice > 0 && regular > salePrice;

    // ---------- Images ----------
    final images = (json['images'] as List?) ?? const [];
    final String? imageUrl = images.isNotEmpty
        ? images.first['src']?.toString()
        : null;
    final String? imageThumbnailUrl = images.isNotEmpty
        ? images.first['thumbnail']?.toString()
        : null;

    // ---------- Categories ----------
    final categories = (json['categories'] as List?) ?? const [];
    final categoryIds = categories
        .map((c) => (c['id'] as num?)?.toInt() ?? 0)
        .toList();
    final categoryNames = categories
        .map((c) => c['name']?.toString() ?? '')
        .toList();

    return Product(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      permalink: json['permalink']?.toString() ?? '',
      type: json['type']?.toString() ?? 'simple',
      description: json['description']?.toString() ?? '',
      shortDescription: json['short_description']?.toString() ?? '',
      price: current > 0 ? current : regular,
      regularPrice: regular > 0 ? regular : current,
      onSale: onSale,
      inStock: json['is_in_stock'] == true || json['stock_status'] == 'instock',
      averageRating:
          double.tryParse(json['average_rating']?.toString() ?? '0') ?? 0,
      reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
      imageUrl: imageUrl,
      imageThumbnailUrl: imageThumbnailUrl,
      categoryIds: categoryIds,
      categoryNames: categoryNames,
    );
  }

  // ---------- Helpers ----------

  String get plainShortDescription => HtmlUtils.stripTags(shortDescription);

  String get plainDescription => HtmlUtils.stripTags(description);

  String get displayPrice => 'Rs ${_formatAmount(price)}';

  String get displayRegularPrice => 'Rs ${_formatAmount(regularPrice)}';

  static String _formatAmount(double amount) {
    if (amount == amount.roundToDouble()) {
      return amount.round().toString();
    }
    return amount.toStringAsFixed(2);
  }

  static double _pow10(int exponent) {
    var result = 1.0;
    for (var i = 0; i < exponent; i++) {
      result *= 10;
    }
    return result;
  }
}
