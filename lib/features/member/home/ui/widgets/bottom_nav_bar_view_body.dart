import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/skin/app_skin_cubit.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/neo_theme.dart';
import '../../../../../generated/l10n.dart';
import '../../manager/bottom_nav_bar_cubit.dart';

class BottomNavBarViewBody extends StatelessWidget {
  const BottomNavBarViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppSkinCubit, AppSkin>(
      builder: (context, skin) {
        if (skin == AppSkin.neo) return const _NeoBottomNav();
        return const _ClassicBottomNav();
      },
    );
  }
}

class _ClassicBottomNav extends StatelessWidget {
  const _ClassicBottomNav();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BottomNavBarCubit, BottomNavBarState>(
      builder: (context, state) {
        final cubit = context.read<BottomNavBarCubit>();
        final s = S.of(context);
        return BottomNavigationBar(
          showUnselectedLabels: true,
          showSelectedLabels: true,
          iconSize: 40,
          elevation: 0,
          currentIndex: cubit.currentIndex,
          onTap: cubit.changeIndex,
          backgroundColor: AppColors.primary,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.teal,
          unselectedItemColor: AppColors.grey,
          items: [
            BottomNavigationBarItem(icon: const Icon(Icons.home_outlined), label: s.home),
            BottomNavigationBarItem(icon: const Icon(Icons.sports_gymnastics), label: s.train),
            BottomNavigationBarItem(icon: const Icon(Icons.smart_toy_outlined), label: s.ai_coach),
            BottomNavigationBarItem(icon: const Icon(Icons.restaurant), label: s.eat),
            const BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), label: 'Market'),
          ],
        );
      },
    );
  }
}

class _NeoBottomNav extends StatelessWidget {
  const _NeoBottomNav();

  static const _items = [
    (Icons.home_outlined, 'HOME'),
    (Icons.sports_gymnastics, 'TRAIN'),
    (Icons.smart_toy_outlined, 'AI'),
    (Icons.restaurant, 'EAT'),
    (Icons.storefront_outlined, 'MARKET'),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BottomNavBarCubit, BottomNavBarState>(
      builder: (context, state) {
        final cubit = context.read<BottomNavBarCubit>();
        return ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xCC0E0E10),
                border: Border(
                  top: BorderSide(color: NeoColors.cyan.withValues(alpha: 0.20)),
                ),
                boxShadow: [
                  BoxShadow(
                    color: NeoColors.cyan.withValues(alpha: 0.12),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  height: 60.h,
                  child: Row(
                    children: List.generate(_items.length, (i) {
                      final active = cubit.currentIndex == i;
                      final (icon, label) = _items[i];
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => cubit.changeIndex(i),
                          behavior: HitTestBehavior.opaque,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                icon,
                                size: 22.r,
                                color: active ? NeoColors.cyan : NeoColors.onSurfaceVariant.withValues(alpha: 0.6),
                                shadows: active
                                    ? [Shadow(color: NeoColors.cyan.withValues(alpha: 0.8), blurRadius: 8)]
                                    : null,
                              ),
                              SizedBox(height: 3.h),
                              Text(
                                label,
                                style: GoogleFonts.inter(
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w700,
                                  color: active ? NeoColors.cyan : NeoColors.onSurfaceVariant.withValues(alpha: 0.6),
                                  letterSpacing: 0.08,
                                ),
                              ),
                              SizedBox(height: 3.h),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                height: 2.h,
                                width: active ? 24.w : 0,
                                color: NeoColors.cyan,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

