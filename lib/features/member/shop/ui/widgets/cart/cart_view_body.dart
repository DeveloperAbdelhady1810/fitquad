import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_app/core/helpers/app_decoration.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';

import '../../../../../../core/widgets/custom_button.dart';
import '../../../../../../generated/l10n.dart';
import '../../../data/models/cart_item_model.dart';
import '../../../manager/cart_cubit.dart';
import 'cart_app_bar.dart';
import 'cart_item.dart';

class CartViewBody extends StatefulWidget {
  final List<CartItemModel> cartItems;
  final Function(List<CartItemModel>) onUpdate;
  const CartViewBody({
    super.key,
    required this.cartItems,
    required this.onUpdate,
  });

  @override
  State<CartViewBody> createState() => _CartViewBodyState();
}

class _CartViewBodyState extends State<CartViewBody> {
  String? appliedPromoCode;
  bool _isCheckingOut = false;

  double get total =>
      widget.cartItems.fold(0, (sum, item) => sum + item.totalPrice);



  void increaseQuantity(int index) {
    setState(() {
      widget.cartItems[index] = widget.cartItems[index].copyWith(
        quantity: widget.cartItems[index].quantity + 1,
      );
    });
    widget.onUpdate(widget.cartItems);
  }

  void decreaseQuantity(int index) {
    setState(() {
      if (widget.cartItems[index].quantity > 1) {
        widget.cartItems[index] = widget.cartItems[index].copyWith(
          quantity: widget.cartItems[index].quantity - 1,
        );
      }
    });
    widget.onUpdate(widget.cartItems);
  }

  void _removeItem(int index) {
    setState(() {
      widget.cartItems.removeAt(index);
    });
    widget.onUpdate(widget.cartItems);
  }

  Future<void> _checkout() async {
    setState(() => _isCheckingOut = true);
    final success = await context.read<CartCubit>().placeOrder(promoCode: appliedPromoCode);
    if (!mounted) return;
    setState(() => _isCheckingOut = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(success ? 'Order placed successfully!' : 'Failed to place order. Try again.'),
      backgroundColor: success ? Colors.green : Colors.red,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CartAppBar(),
            ListView.builder(
              itemCount: widget.cartItems.length,
              shrinkWrap: true,
              itemBuilder: (context, index) => CartItem(
                item: widget.cartItems[index],
                onIncrease: () => increaseQuantity(index),
                onDecrease: () => decreaseQuantity(index),
                onRemove: () => _removeItem(index),
              ),
            ),
            const Spacer(),
            Container(
              decoration: AppDecorations.containerDecoration,
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(s.total, style: AppTextStyles.font14GreyRegular),
                      Text('$total EGP', style: AppTextStyles.font16WhiteBold),
                    ],
                  ),
                  vGap(20),
                  _isCheckingOut
                      ? const CircularProgressIndicator()
                      : CustomButton(
                          text: s.checkout,
                          onPressed: _checkout,
                          iconData: Icons.arrow_forward_ios_outlined,
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
