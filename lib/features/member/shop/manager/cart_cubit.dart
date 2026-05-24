import 'package:bloc/bloc.dart';

import '../../../../features/member/data/repositories/member_repository.dart';
import '../data/models/cart_item_model.dart';
import '../data/models/product_model.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  static final CartCubit _singleton = CartCubit._internal();

  factory CartCubit() => _singleton;

  CartCubit._internal() : super(const CartLoaded([]));

  void addToCart(ProductModel product) {
    final items = List<CartItemModel>.from(
        state is CartLoaded ? (state as CartLoaded).items : []);

    final index = items.indexWhere((item) => item.productModel.title == product.title);

    if (index != -1) {
      // لو المنتج موجود، نزود quantity باستخدام copyWith
      final oldItem = items[index];
      items[index] = oldItem.copyWith(quantity: oldItem.quantity + 1);
    } else {
      items.add(CartItemModel(productModel: product, quantity: 1));
    }

    emit(CartLoaded(items));
  }

  void removeItem(CartItemModel item) {
    final items = List<CartItemModel>.from(state.items)
      ..remove(item);

    emit(CartLoaded(items));
  }

  void clearCart() {
    emit(const CartLoaded([]));
  }

  void updateCart(List<CartItemModel> updatedItems) {
    emit(CartLoaded(updatedItems));
  }

  Future<bool> placeOrder({String? promoCode}) async {
    final items = (state as CartLoaded).items;
    if (items.isEmpty) return false;

    try {
      await MemberRepository.placeOrder(
        items: items.map((i) => {
          'product_id': int.tryParse(i.productModel.id ?? '') ?? 0,
          'quantity': i.quantity,
        }).toList(),
        promoCode: promoCode,
      );
      clearCart();
      return true;
    } catch (_) {
      return false;
    }
  }
}
