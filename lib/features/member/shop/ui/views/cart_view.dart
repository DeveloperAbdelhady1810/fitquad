import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_app/core/theme/app_colors.dart';

import '../../manager/cart_cubit.dart';
import '../../manager/cart_state.dart';
import '../widgets/cart/cart_view_body.dart';
import '../widgets/cart/empty_cart_widget.dart';

class CartView extends StatelessWidget {
  const CartView({super.key});
  static const String routeName= '/cart';

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: BlocBuilder<CartCubit, CartState>(
        bloc: CartCubit(),
        builder: (context, state) {
          if (state.items.isEmpty) {
            return const EmptyCartWidget();
          }

          return CartViewBody(
            cartItems: state.items,
            onUpdate: (updatedList) {
              CartCubit().updateCart(updatedList);
            },
          );
        },
      ),
    );
  }
}
