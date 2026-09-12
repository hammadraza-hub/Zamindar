/// A product category fetched from the WooCommerce Store API.
class Category {
  final int id;
  final String name; // API ka raw naam
  final String slug;
  final int count; // is category mein kitne products hain
  final String permalink;

  const Category({
    required this.id,
    required this.name,
    required this.slug,
    required this.count,
    required this.permalink,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0,
      permalink: json['permalink']?.toString() ?? '',
    );
  }

  /// Clean display naam.
  ///
  /// API ke naam ajeeb ho sakte hain, jaise:
  ///   "I N S E C T I C I D E S" (har harf ke beech space)
  ///   "FERTILIZER" (sab capital)
  /// Yeh sab normal karta hai.
  String get displayName {
    final n = name.trim();

    // Pattern: "I N S E C T..." → "Insecticides"
    if (RegExp(r'^([A-Za-z] )+[A-Za-z]$').hasMatch(n)) {
      final collapsed = n.replaceAll(' ', '');
      return collapsed[0].toUpperCase() + collapsed.substring(1).toLowerCase();
    }

    // "FERTILIZER" → "Fertilizer"
    if (n == n.toUpperCase() && n.length > 2 && !n.contains(' ')) {
      return n[0] + n.substring(1).toLowerCase();
    }

    return n;
  }
}
