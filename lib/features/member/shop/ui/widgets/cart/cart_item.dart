import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_app/core/enums/categories.dart';

import '../../../../../../core/helpers/localization.dart';
import '../../../../../../core/helpers/spacing.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';

import '../../../data/models/cart_item_model.dart';

class CartItem extends StatelessWidget {
  final CartItemModel item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;
  const CartItem({
    super.key,
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 8.h),
      color: AppColors.secondary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 80.w,
                  height: 100.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    image: DecorationImage(
                      image: AssetImage(item.productModel.image ?? ''),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
            hGap(12.w),

            Expanded(
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        item.productModel.title ?? '',
                        style: AppTextStyles.font16WhiteBold,
                      ),
                      vGap(20),
                      Text(
                        item.productModel.category?.title(context) ?? '',
                        style: AppTextStyles.font14GreyRegular,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${item.totalPrice} EGP',
                            style: AppTextStyles.font14GreyRegular.copyWith(
                              color: Colors.green,
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              _quantityButton(
                                icon: Icons.remove,
                                onTap: onDecrease,
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 6.h,
                                ),
                                child: Text(
                                  item.quantity.toString(),
                                  style: AppTextStyles.font16WhiteBold,
                                ),
                              ),
                              _quantityButton(
                                icon: Icons.add,
                                onTap: onIncrease,
                              ),
                            ],
                          ),

                          hGap(8.w),
                        ],
                      ),
                    ],
                  ),
                  Positioned(
                    top: 2,
                    left: isArabicLocale(context) ? 0 : null,
                    right: isArabicLocale(context) ? null : 0,
                    child: IconButton(
                      icon: Icon(Icons.delete_sharp, color: AppColors.grey),
                      onPressed: onRemove,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quantityButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      hoverColor: Colors.grey.shade200,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: AppColors.primary,
        ),
        child: Icon(icon, size: 18.sp, color: Colors.grey),
      ),
    );
  }
}
