import '../data/models/cart_item_model.dart';

abstract class CartState {
  final List<CartItemModel> items;
  const CartState(this.items);
}

class CartLoaded extends CartState {
  const CartLoaded(super.items);
}
