import 'package:gym_app/features/member/shop/data/models/product_model.dart';

class CartItemModel {
  final ProductModel productModel;
  final int quantity;

  const CartItemModel({
    required this.productModel,
    required this.quantity,
  });

  double get itemPrice => productModel.price??0;

  double get totalPrice => itemPrice * quantity;

  CartItemModel copyWith({
    ProductModel? productModel,
    int? quantity,
  }) {
    return CartItemModel(
      productModel: productModel ?? this.productModel,
      quantity: quantity ?? this.quantity,
    );
  }
}
