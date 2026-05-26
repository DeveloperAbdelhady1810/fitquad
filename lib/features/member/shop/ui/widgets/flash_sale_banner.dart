import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';

import '../../manager/market_cubit.dart';
import '../../manager/market_state.dart';

class FlashSaleBanner extends StatelessWidget {
  const FlashSaleBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MarketCubit, MarketState>(
      builder: (context, state) {
        if (state is! MarketLoaded) return const SizedBox.shrink();

        // Find products on sale
        final onSale = state.products
            .where((p) => p.isOnSale)
            .toList();

        if (onSale.isEmpty) return const SizedBox.shrink();

        return _FlashSaleBannerContent(saleCount: onSale.length);
      },
    );
  }
}

class _FlashSaleBannerContent extends StatefulWidget {
  final int saleCount;
  const _FlashSaleBannerContent({required this.saleCount});

  @override
  State<_FlashSaleBannerContent> createState() =>
      _FlashSaleBannerContentState();
}

class _FlashSaleBannerContentState extends State<_FlashSaleBannerContent> {
  late Timer _timer;
  // Flash sale ends at midnight — countdown to end of day
  Duration _remaining = _calcRemaining();

  static Duration _calcRemaining() {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    return midnight.difference(now);
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _remaining = _calcRemaining());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _fmt(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final h = _fmt(_remaining.inHours);
    final m = _fmt(_remaining.inMinutes.remainder(60));
    final s = _fmt(_remaining.inSeconds.remainder(60));

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF4B2B), Color(0xFFFF416C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          Text('⚡', style: TextStyle(fontSize: 24.sp)),
          hGap(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Flash Sale — ${widget.saleCount} item${widget.saleCount == 1 ? '' : 's'}',
                  style: AppTextStyles.font16WhiteBold.copyWith(fontSize: 13.sp),
                ),
                vGap(2),
                Text(
                  'Deals end in $h:$m:$s',
                  style: AppTextStyles.font14GreyRegular.copyWith(
                      color: Colors.white70, fontSize: 11.sp),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              'SHOP NOW',
              style: AppTextStyles.font14WhiteRegular.copyWith(
                  fontWeight: FontWeight.bold, fontSize: 11.sp),
            ),
          ),
        ],
      ),
    );
  }
}
