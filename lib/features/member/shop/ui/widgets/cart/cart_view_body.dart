import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';
import 'package:gym_app/features/member/payment/data/payment_repository.dart';
import 'package:gym_app/features/member/payment/ui/payment_webview_screen.dart';

import '../../../data/models/cart_item_model.dart';
import '../../../manager/cart_cubit.dart';
import 'cart_app_bar.dart';
import 'cart_item.dart';

const double _kPlatformFeePct = 5.0;
const double _kProcessingFee = 5.0;

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
  
  double get subtotal =>
      widget.cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  double get platformFee => subtotal * _kPlatformFeePct / 100;
  double get total => subtotal + platformFee + _kProcessingFee;

  void increaseQuantity(int index) {
    setState(() {
      widget.cartItems[index] = widget.cartItems[index]
          .copyWith(quantity: widget.cartItems[index].quantity + 1);
    });
    widget.onUpdate(widget.cartItems);
  }

  void decreaseQuantity(int index) {
    setState(() {
      if (widget.cartItems[index].quantity > 1) {
        widget.cartItems[index] = widget.cartItems[index]
            .copyWith(quantity: widget.cartItems[index].quantity - 1);
      }
    });
    widget.onUpdate(widget.cartItems);
  }

  void _removeItem(int index) {
    setState(() => widget.cartItems.removeAt(index));
    widget.onUpdate(widget.cartItems);
  }

  void _showOrderSummary() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.secondary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (_) => _OrderSummarySheet(
        items: widget.cartItems,
        subtotal: subtotal,
        platformFee: platformFee,
        processingFee: _kProcessingFee,
        total: total,
        onConfirm: _initiatePayment,
      ),
    );
  }

  Future<void> _initiatePayment() async {
    Navigator.pop(context); // close the sheet

    final overlay = _LoadingOverlay(context);
    overlay.show();

    try {
      final result = await PaymentRepository.initiateOrderPayment(
        items: widget.cartItems
            .map((i) => {
                  'product_id': int.tryParse(i.productModel.id ?? '') ?? 0,
                  'quantity': i.quantity,
                })
            .toList(),
      );

      overlay.hide();

      if (!mounted) return;

      final paymentUrl = result['payment_url'] as String?;
      if (paymentUrl == null) throw Exception('No payment URL returned');

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentWebviewScreen(
            paymentUrl: paymentUrl,
            totalAmount: (result['total_amount'] as num).toDouble(),
            isOrder: true,
            onSuccess: () => context.read<CartCubit>().clearCart(),
          ),
        ),
      );
    } catch (e) {
      overlay.hide();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Could not initiate payment: ${e.toString()}'),
        backgroundColor: AppColors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CartAppBar(),
            Expanded(
              child: ListView.builder(
                itemCount: widget.cartItems.length,
                itemBuilder: (context, index) => CartItem(
                  item: widget.cartItems[index],
                  onIncrease: () => increaseQuantity(index),
                  onDecrease: () => decreaseQuantity(index),
                  onRemove: () => _removeItem(index),
                ),
              ),
            ),
            _SummaryFooter(
              subtotal: subtotal,
              platformFee: platformFee,
              processingFee: _kProcessingFee,
              total: total,
              onCheckout: _showOrderSummary,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Summary footer (always visible at bottom) ───────────────────────────────

class _SummaryFooter extends StatelessWidget {
  final double subtotal, platformFee, processingFee, total;
  final VoidCallback onCheckout;

  const _SummaryFooter({
    required this.subtotal,
    required this.platformFee,
    required this.processingFee,
    required this.total,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          _FeeRow('Subtotal', subtotal),
          vGap(6),
          _FeeRow('Platform fee (${_kPlatformFeePct.toInt()}%)',
              platformFee, muted: true),
          _FeeRow('Processing fee', processingFee, muted: true),
          Divider(color: Colors.white12, height: 20.h),
          _FeeRow('Total', total, bold: true),
          vGap(14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onCheckout,
              icon: Icon(Icons.lock_outline, size: 18.r),
              label: Text(
                'Pay Now — ${total.toStringAsFixed(0)} EGP',
                style: TextStyle(
                    fontSize: 15.sp, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeeRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool muted;
  final bool bold;

  const _FeeRow(this.label, this.amount,
      {this.muted = false, this.bold = false});

  @override
  Widget build(BuildContext context) {
    final style = bold
        ? AppTextStyles.font16WhiteBold
        : muted
            ? AppTextStyles.font14GreyRegular
            : AppTextStyles.font14GreyRegular
                .copyWith(color: Colors.white70);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text('${amount.toStringAsFixed(2)} EGP', style: style),
      ],
    );
  }
}

// ─── Order summary bottom sheet ──────────────────────────────────────────────

class _OrderSummarySheet extends StatelessWidget {
  final List<CartItemModel> items;
  final double subtotal, platformFee, processingFee, total;
  final VoidCallback onConfirm;

  const _OrderSummarySheet({
    required this.items,
    required this.subtotal,
    required this.platformFee,
    required this.processingFee,
    required this.total,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          vGap(16),
          Text('Order Summary', style: AppTextStyles.font16WhiteBold),
          vGap(14),

          // Items
          ...items.map((item) => Padding(
                padding: EdgeInsets.only(bottom: 6.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${item.productModel.title ?? 'Item'} × ${item.quantity}',
                        style: TextStyle(
                            color: Colors.white70, fontSize: 13.sp),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${item.totalPrice.toStringAsFixed(2)} EGP',
                      style: TextStyle(
                          color: Colors.white, fontSize: 13.sp),
                    ),
                  ],
                ),
              )),

          Divider(color: Colors.white12, height: 20.h),

          _FeeRow('Subtotal', subtotal),
          vGap(4),
          _FeeRow(
              'Platform fee (${_kPlatformFeePct.toInt()}%)',
              platformFee,
              muted: true),
          _FeeRow('Processing fee', processingFee, muted: true),
          Divider(color: Colors.white12, height: 20.h),
          _FeeRow('Total (online)', total, bold: true),

          vGap(16),

          // Delivery info card
          Container(
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: AppColors.teal.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                  color: AppColors.teal.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.local_shipping_outlined,
                        color: AppColors.teal, size: 18.r),
                    SizedBox(width: 8.w),
                    Text('Delivery · Cash on Delivery',
                        style: TextStyle(
                            color: AppColors.teal,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
                vGap(6),
                Text(
                  'Delivery fees will be collected upon delivery and are not included in the online payment.',
                  style: TextStyle(
                      color: Colors.white54, fontSize: 12.sp, height: 1.4),
                ),
                vGap(4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.phone_outlined,
                        color: Colors.white38, size: 14.r),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        'Your order will be confirmed by a phone call from our supplier.',
                        style: TextStyle(
                            color: Colors.white38,
                            fontSize: 12.sp,
                            height: 1.4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          vGap(20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onConfirm,
              icon: Icon(Icons.lock_outline, size: 18.r),
              label: Text(
                'Confirm & Pay — ${total.toStringAsFixed(0)} EGP',
                style: TextStyle(
                    fontSize: 15.sp, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Loading overlay helper ───────────────────────────────────────────────────

class _LoadingOverlay {
  final BuildContext context;
  OverlayEntry? _entry;

  _LoadingOverlay(this.context);

  void show() {
    _entry = OverlayEntry(
      builder: (_) => Container(
        color: Colors.black54,
        alignment: Alignment.center,
        child: CircularProgressIndicator(color: AppColors.teal),
      ),
    );
    Overlay.of(context).insert(_entry!);
  }

  void hide() => _entry?.remove();
}
