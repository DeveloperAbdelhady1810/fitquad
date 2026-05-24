import 'package:flutter/material.dart';
import 'package:gym_app/core/widgets/custom_tab_bar.dart';
import 'package:gym_app/features/admin/ui/widgets/orders_table.dart';
import 'package:gym_app/features/admin/ui/widgets/products_table.dart';

class MarketBody extends StatelessWidget {
  const MarketBody({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(length: 2,
        child: Column(
          children: [
            CustomTabBar(tabs: [
              Tab(text: 'Products',),
              Tab(text: 'Orders',),
            ]),
            Expanded(child: TabBarView(children: [
              ProductsTable(),
              OrdersTable()

            ]))
          ],
        ),
    );
  }
}
