/// Simple product model used across the app.
class Product {
  final String id;
  final String name;
  final String category; // phone, laptop, accessory
  final String description;
  final double price;
  final String imageUrl;
  final bool onSale;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.onSale = false,
  });

  Product copyWith({
    String? id,
    String? name,
    String? category,
    String? description,
    double? price,
    String? imageUrl,
    bool? onSale,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      onSale: onSale ?? this.onSale,
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: (json['price'] as num).toDouble(),
      imageUrl:
          json['image_url']?.toString() ?? json['imageUrl']?.toString() ?? '',
      onSale: json['on_sale'] == true || json['on_sale'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'on_sale': onSale ? 1 : 0,
    };
  }
}
