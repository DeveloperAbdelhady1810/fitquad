import '../../../../core/enums/food_enum.dart';

class FoodModel {
  final String id;
  final String nameAr;
  final String nameEn;
  final int calories;
  final int protein;
  final String quantity;
  final FoodCategory category;
  bool isLogged;

  FoodModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.calories,
    required this.protein,
    required this.quantity,
    required this.category,
    this.isLogged = false,
  });

  factory FoodModel.fromJson(Map<String, dynamic> json) {
    return FoodModel(
      id: json['id']?.toString() ?? '',
      nameAr: json['name_ar'] as String? ?? json['name'] as String? ?? '',
      nameEn: json['name_en'] as String? ?? json['name'] as String? ?? '',
      calories: (json['calories'] as num?)?.toInt() ?? 0,
      protein: (json['protein'] as num?)?.toInt() ?? 0,
      quantity: '${json['serving_size'] ?? 100} ${json['serving_unit'] ?? 'g'}',
      category: _parseCategory(json['category'] as String?),
    );
  }

  static FoodCategory _parseCategory(String? c) {
    switch (c) {
      case 'breakfast': return FoodCategory.breakfast;
      case 'lunch': return FoodCategory.lunch;
      case 'dinner': return FoodCategory.dinner;
      case 'snacks': return FoodCategory.snacks;
      case 'dessert': return FoodCategory.dessert;
      default: return FoodCategory.all;
    }
  }
}
