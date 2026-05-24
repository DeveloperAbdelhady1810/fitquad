import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/enums/categories.dart';
import '../../manager/market_cubit.dart';
import '../../manager/market_state.dart';
import 'market_tab_bar.dart';

class MarketTabs extends StatelessWidget {
  const MarketTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MarketCubit, MarketState>(
      builder: (context, state) {
        ProductCategory selected = ProductCategory.all;

        if (state is MarketLoaded) {
          selected = state.selectedCategory;
        } else if (state is MarketEmpty) {
          selected = state.selectedCategory;
        }

        return MarketTabBar(
          tabs: ProductCategory.values.map((e) => e.title(context)).toList(),
          selectedIndex: selected.index,
          onTap: (index) {
            context
                .read<MarketCubit>()
                .filterByCategory(ProductCategory.values[index]);
          },
        );
      },
    );

  }
}
