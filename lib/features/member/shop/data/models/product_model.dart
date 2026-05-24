import '../../../../../core/enums/categories.dart';

class ProductModel {
  final String? id;
  final String? title;
  final ProductCategory? category;
  final String? image;
  final double? price;
  final double? rating;

  const ProductModel({
    this.id,
    this.title,
    this.category,
    this.image,
    this.price,
    this.rating,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString(),
      title: json['name'] as String?,
      category: _parseCategory(json['category'] as String?),
      image: json['image_url'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      rating: null,
    );
  }

  static ProductCategory _parseCategory(String? c) {
    switch (c) {
      case 'supplements': return ProductCategory.supplements;
      case 'apparel': return ProductCategory.apparel;
      case 'gear': return ProductCategory.gear;
      case 'accessories': return ProductCategory.accessories;
      default: return ProductCategory.supplements;
    }
  }
}
