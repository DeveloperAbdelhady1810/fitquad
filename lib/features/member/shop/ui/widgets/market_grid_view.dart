import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';

import '../../../../../generated/l10n.dart';
import '../../manager/cart_cubit.dart';
import '../../manager/market_cubit.dart';
import '../../manager/market_state.dart';
import 'product_card.dart';

class MarketGridView extends StatelessWidget {
  const MarketGridView({super.key});

  @override
  Widget build(BuildContext context) {
    final s=S.of(context);
    return BlocBuilder<MarketCubit, MarketState>(
      builder: (context, state) {
        if (state is MarketLoading) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.emerald),
          );
        }

        if (state is MarketEmpty) {
          return  Center(child: Text( s.no_products , style: AppTextStyles.font16GreyRegular,));
        }

        if (state is MarketLoaded) {
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 0.6,
            ),
            itemCount: state.products.length,
            itemBuilder: (context, index) {
              return ProductCard(
                product: state.products[index],
                onAdd: () =>
                    context.read<CartCubit>().addToCart(state.products[index]),
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
