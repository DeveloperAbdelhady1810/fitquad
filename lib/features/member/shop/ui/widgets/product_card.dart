import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_app/core/enums/categories.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';

import '../../data/models/product_model.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, required this.onAdd});

  final ProductModel product;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: LinearGradient(
          colors: [AppColors.secondary, AppColors.primary],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (product.isOnSale)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF416C),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    'SALE',
                    style: AppTextStyles.font14GreyRegular.copyWith(
                        color: Colors.white,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.bold),
                  ),
                )
              else
                const SizedBox.shrink(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 14),
                  hGap(5),
                  Text(
                    product.rating.toString(),
                    style: AppTextStyles.font14WhiteRegular,
                  ),
                ],
              ),
            ],
          ),

          const Spacer(),

          Center(
            child:product.image==null?SizedBox(height: 100.h,): Image.network(
              product.image ?? '',
              fit: BoxFit.fill,
              height: 100.h,
              width: double.infinity,
            ),
          ),

          const Spacer(),

          Text(
            product.category?.title(context) ?? '',
            style: AppTextStyles.font14GreyRegular,
          ),

          vGap(5),
          Text(product.title ?? '', style: AppTextStyles.font14WhiteRegular),

          vGap(5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.isOnSale)
                    Text(
                      'EGP ${product.price?.toStringAsFixed(0)}',
                      style: AppTextStyles.font14GreyRegular.copyWith(
                        fontSize: 10.sp,
                        decoration: TextDecoration.lineThrough,
                        color: Colors.white38,
                      ),
                    ),
                  Text(
                    'EGP ${product.effectivePrice.toStringAsFixed(0)}',
                    style: AppTextStyles.font16WhiteBold.copyWith(
                      fontSize: 14.sp,
                      color: product.isOnSale
                          ? const Color(0xFFFF416C)
                          : Colors.white,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: onAdd,
                child: Container(
                  padding: EdgeInsets.all(6.r),
                  decoration:  BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.secondary,
                  ),
                  child:  Icon(Icons.add, color: AppColors.emerald, size: 18.sp),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
