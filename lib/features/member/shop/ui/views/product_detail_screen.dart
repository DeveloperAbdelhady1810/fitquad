import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/helpers/app_decoration.dart';
import '../../../../../core/helpers/spacing.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../data/models/product_model.dart';
import '../../manager/cart_cubit.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key, required this.product});

  final ProductModel product;

  static const routeName = '/product-detail';

  @override
  Widget build(BuildContext context) {
    final hasImage = product.image != null && product.image!.isNotEmpty;
    final inStock = product.stock == null || product.stock! > 0;

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(product.title ?? 'Product',
            style: AppTextStyles.font16WhiteBold),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Product Image ─────────────────────────────────
            Container(
              width: double.infinity,
              height: 280.h,
              color: AppColors.secondary,
              child: hasImage
                  ? Image.network(
                      product.image!,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => _PlaceholderImage(),
                    )
                  : _PlaceholderImage(),
            ),

            // ── Info Card ─────────────────────────────────────
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category + rating row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: AppColors.teal.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                              color: AppColors.teal.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          product.category?.name ?? 'Product',
                          style: AppTextStyles.font14GreyRegular.copyWith(
                              color: AppColors.teal, fontSize: 11.sp),
                        ),
                      ),
                      if (product.rating != null && product.rating! > 0)
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 16.r),
                            hGap(4),
                            Text(product.rating!.toStringAsFixed(1),
                                style: AppTextStyles.font14WhiteRegular),
                          ],
                        ),
                    ],
                  ),
                  vGap(12),

                  // Title
                  Text(product.title ?? '',
                      style: AppTextStyles.font16WhiteBold
                          .copyWith(fontSize: 20.sp)),
                  vGap(8),

                  // Price row
                  Row(
                    children: [
                      Text(
                        'EGP ${product.effectivePrice.toStringAsFixed(0)}',
                        style: AppTextStyles.font16WhiteBold.copyWith(
                          color: AppColors.emerald,
                          fontSize: 22.sp,
                        ),
                      ),
                      if (product.isOnSale) ...[
                        hGap(10),
                        Text(
                          'EGP ${product.price!.toStringAsFixed(0)}',
                          style: AppTextStyles.font14GreyRegular.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: AppColors.grey,
                            fontSize: 14.sp,
                          ),
                        ),
                        hGap(6),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            '${(((product.price! - product.salePrice!) / product.price!) * 100).toInt()}% OFF',
                            style: AppTextStyles.font14GreyRegular.copyWith(
                              color: Colors.red,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  vGap(8),

                  // Stock badge
                  Row(
                    children: [
                      Icon(
                        inStock
                            ? Icons.check_circle_outline
                            : Icons.cancel_outlined,
                        color: inStock ? AppColors.emerald : AppColors.red,
                        size: 16.r,
                      ),
                      hGap(6),
                      Text(
                        inStock
                            ? (product.stock != null
                                ? '${product.stock} in stock'
                                : 'In Stock')
                            : 'Out of Stock',
                        style: AppTextStyles.font14GreyRegular.copyWith(
                          color: inStock ? AppColors.emerald : AppColors.red,
                        ),
                      ),
                    ],
                  ),

                  vGap(20),

                  // Description
                  if (product.description != null &&
                      product.description!.isNotEmpty) ...[
                    Text('Description',
                        style: AppTextStyles.font16WhiteBold
                            .copyWith(fontSize: 14.sp)),
                    vGap(8),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(14.r),
                      decoration: AppDecorations.containerDecoration.copyWith(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        product.description!,
                        style: AppTextStyles.font14GreyRegular
                            .copyWith(height: 1.6),
                      ),
                    ),
                    vGap(20),
                  ],

                  // Benefits section (static for now)
                  Text('Why Choose This?',
                      style: AppTextStyles.font16WhiteBold
                          .copyWith(fontSize: 14.sp)),
                  vGap(8),
                  ...[
                    '✅ High quality, gym-tested product',
                    '🚚 Fast delivery to your door',
                    '🔒 Secure checkout via Paymob',
                    '↩️ Easy returns within 7 days',
                  ].map((b) => Padding(
                        padding: EdgeInsets.only(bottom: 6.h),
                        child: Text(b,
                            style: AppTextStyles.font14GreyRegular
                                .copyWith(height: 1.4)),
                      )),

                  vGap(80.h),
                ],
              ),
            ),
          ],
        ),
      ),

      // ── Add to Cart FAB ───────────────────────────────────
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w,
            MediaQuery.paddingOf(context).bottom + 12.h),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          border:
              const Border(top: BorderSide(color: Colors.white12)),
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      inStock ? AppColors.emerald : AppColors.grey,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r)),
                ),
                onPressed: inStock
                    ? () {
                        context.read<CartCubit>().addToCart(product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                '${product.title} added to cart!'),
                            backgroundColor: AppColors.emerald,
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(8.r)),
                          ),
                        );
                      }
                    : null,
                icon: const Icon(Icons.shopping_cart_outlined,
                    color: Colors.white),
                label: Text(
                  inStock ? 'Add to Cart' : 'Out of Stock',
                  style: AppTextStyles.font16WhiteBold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(Icons.shopping_bag_outlined,
          size: 80.r, color: AppColors.grey),
    );
  }
}
