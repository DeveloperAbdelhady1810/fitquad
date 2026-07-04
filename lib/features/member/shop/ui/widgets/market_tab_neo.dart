import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/core/enums/categories.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/theme/neo_theme.dart';
import 'package:gym_app/features/member/shop/data/models/product_model.dart';
import 'package:gym_app/features/member/shop/manager/cart_cubit.dart';
import 'package:gym_app/features/member/shop/manager/cart_state.dart';
import 'package:gym_app/features/member/shop/manager/market_cubit.dart';
import 'package:gym_app/features/member/shop/manager/market_state.dart';
import 'package:gym_app/features/member/shop/ui/views/cart_view.dart';
import 'package:gym_app/features/member/shop/ui/views/product_detail_screen.dart';

class MarketTabNeo extends StatefulWidget {
  const MarketTabNeo({super.key});

  @override
  State<MarketTabNeo> createState() => _MarketTabNeoState();
}

class _MarketTabNeoState extends State<MarketTabNeo> {
  ProductCategory _selected = ProductCategory.all;
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  static const _chips = [
    (label: 'ALL ITEMS',  cat: ProductCategory.all),
    (label: 'SUPPS',      cat: ProductCategory.supplements),
    (label: 'APPAREL',    cat: ProductCategory.apparel),
    (label: 'GEAR',       cat: ProductCategory.gear),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 4.h, 8.w, 0),
          child: Row(
            children: [
              Text('MARKET', style: NeoTextStyles.headlineLg.copyWith(color: NeoColors.cyan)),
              const Spacer(),
              BlocBuilder<CartCubit, CartState>(
                builder: (context, cartState) {
                  final count = cartState is CartLoaded
                      ? cartState.items.fold<int>(0, (s, i) => s + i.quantity)
                      : 0;
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        onPressed: () => context.push(CartView.routeName),
                        icon: Icon(Icons.shopping_cart_outlined, color: NeoColors.cyan, size: 22.r),
                      ),
                      if (count > 0)
                        Positioned(
                          right: 4, top: 4,
                          child: Container(
                            width: 16.r, height: 16.r,
                            decoration: const BoxDecoration(
                              color: NeoColors.magenta,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(count.toString(),
                                style: TextStyle(color: Colors.black, fontSize: 9.sp, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        // Search field
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                height: 40.h,
                decoration: BoxDecoration(
                  color: const Color(0x66201F21),
                  border: Border.all(color: const Color(0x2600DCE6)),
                ),
                child: Row(
                  children: [
                    SizedBox(width: 12.w),
                    Icon(Icons.search, color: NeoColors.outline, size: 16.r),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        style: NeoTextStyles.bodySm.copyWith(color: NeoColors.onSurface),
                        decoration: InputDecoration(
                          hintText: 'SEARCH PRODUCTS...',
                          hintStyle: NeoTextStyles.labelCaps.copyWith(color: NeoColors.outline, fontSize: 10.sp),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (v) => context.read<MarketCubit>().searchProducts(v),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        vGap(10),
        // Category chips
        SizedBox(
          height: 32.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            children: _chips.map((c) {
              final active = _selected == c.cat;
              return Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selected = c.cat);
                    context.read<MarketCubit>().filterByCategory(c.cat);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(horizontal: 14.w),
                    decoration: BoxDecoration(
                      color: active ? NeoColors.cyan : const Color(0x1A00DCE6),
                      border: Border.all(
                        color: active ? NeoColors.cyan : const Color(0x3300DCE6),
                      ),
                      boxShadow: active
                          ? [BoxShadow(color: NeoColors.cyan.withValues(alpha: 0.3), blurRadius: 8)]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        c.label,
                        style: NeoTextStyles.labelCaps.copyWith(
                          color: active ? Colors.black : NeoColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        vGap(12),
        // Product grid
        Expanded(
          child: BlocBuilder<MarketCubit, MarketState>(
            builder: (context, state) {
              if (state is MarketLoading) {
                return Center(child: CircularProgressIndicator(color: NeoColors.cyan, strokeWidth: 2));
              }
              if (state is MarketEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.storefront_outlined, color: NeoColors.outline, size: 40.r),
                      vGap(12),
                      Text('NO PRODUCTS FOUND', style: NeoTextStyles.headlineSm.copyWith(color: NeoColors.outline)),
                    ],
                  ),
                );
              }
              if (state is MarketLoaded) {
                final products = state.products;
                final featured = products.where((p) => p.isOnSale).take(3).toList();
                return CustomScrollView(
                  slivers: [
                    // Featured drops carousel
                    if (featured.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Row(
                            children: [
                              Text('FEATURED DROPS', style: NeoTextStyles.labelCaps.copyWith(color: NeoColors.cyan)),
                              const Spacer(),
                              Text('LIMITED QUANTITY',
                                  style: NeoTextStyles.labelCaps.copyWith(color: NeoColors.lime, fontSize: 9.sp)),
                            ],
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(child: vGap(8)),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 140.h,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            itemCount: featured.length,
                            itemBuilder: (_, i) => _FeaturedCard(
                              product: featured[i],
                              onTap: () => Navigator.push(context, MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: context.read<CartCubit>(),
                                  child: ProductDetailScreen(product: featured[i]),
                                ),
                              )),
                            ),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(child: vGap(16)),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Row(children: [
                            Container(width: 3.w, height: 16.h, color: NeoColors.cyan),
                            hGap(8),
                            Text('ALL PRODUCTS', style: NeoTextStyles.labelCaps.copyWith(color: NeoColors.cyan)),
                          ]),
                        ),
                      ),
                      SliverToBoxAdapter(child: vGap(10)),
                    ],
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (context, i) => _NeoProductCard(
                            product: products[i],
                            onTap: () => Navigator.push(context, MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: context.read<CartCubit>(),
                                child: ProductDetailScreen(product: products[i]),
                              ),
                            )),
                            onAdd: () => context.read<CartCubit>().addToCart(products[i]),
                          ),
                          childCount: products.length,
                        ),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10.w,
                          mainAxisSpacing: 10.h,
                          childAspectRatio: 0.62,
                        ),
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}

// Featured horizontal card
class _FeaturedCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;
  const _FeaturedCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 260.w,
        margin: EdgeInsets.only(right: 10.w),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0x66201F21),
                border: Border.all(color: const Color(0x3300DCE6)),
              ),
              child: Stack(
                children: [
                  if (product.image != null)
                    Positioned.fill(
                      child: Image.network(product.image!, fit: BoxFit.cover, errorBuilder: (_, __, ___) =>
                          Container(color: NeoColors.surfaceHigh)),
                    ),
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter, end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Color(0xCC131315)],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8, left: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      color: NeoColors.lime,
                      child: Text('NEW DROP', style: NeoTextStyles.labelCaps.copyWith(
                          color: Colors.black, fontSize: 8.sp)),
                    ),
                  ),
                  Positioned(
                    bottom: 10, left: 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text((product.title ?? '').toUpperCase(),
                            style: NeoTextStyles.headlineSm.copyWith(color: Colors.white)),
                        Text('${product.effectivePrice.toStringAsFixed(0)} EGP',
                            style: GoogleFonts.jetBrainsMono(fontSize: 13.sp,
                                color: NeoColors.cyan, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Product grid card
class _NeoProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  const _NeoProductCard({required this.product, required this.onTap, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0x66201F21),
              border: Border.all(color: const Color(0x2200DCE6)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                Expanded(
                  child: Stack(
                    children: [
                      if (product.image != null)
                        Positioned.fill(
                          child: Image.network(product.image!, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                  color: NeoColors.surfaceHigh,
                                  child: Icon(Icons.fitness_center, color: NeoColors.outline, size: 24.r))),
                        )
                      else
                        Positioned.fill(
                          child: Container(
                            color: NeoColors.surfaceHigh,
                            child: Icon(Icons.fitness_center, color: NeoColors.outline, size: 24.r),
                          ),
                        ),
                      if (product.isOnSale)
                        Positioned(
                          top: 6, right: 6,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                            color: NeoColors.lime,
                            child: Text('SALE', style: NeoTextStyles.labelCaps.copyWith(
                                color: Colors.black, fontSize: 8.sp)),
                          ),
                        ),
                    ],
                  ),
                ),
                // Info
                Padding(
                  padding: EdgeInsets.all(10.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (product.title ?? 'PRODUCT').toUpperCase(),
                        style: NeoTextStyles.headlineSm.copyWith(fontSize: 13.sp),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      vGap(6),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${product.effectivePrice.toStringAsFixed(0)} EGP',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 13.sp, color: NeoColors.cyan, fontWeight: FontWeight.w700,
                                    shadows: [Shadow(color: NeoColors.cyan.withValues(alpha: 0.4), blurRadius: 6)],
                                  ),
                                ),
                                if (product.isOnSale)
                                  Text(
                                    '${product.price?.toStringAsFixed(0)} EGP',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 10.sp, color: NeoColors.outline,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: onAdd,
                            child: Container(
                              width: 28.r, height: 28.r,
                              color: NeoColors.cyan,
                              child: Icon(Icons.add, color: Colors.black, size: 16.r),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
