import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_app/core/theme/neo_theme.dart';

/// Neo-styled role selector tab bar (Member/Coach/Admin), used in place of
/// [CustomTabBar] on login/signup when the Neo skin is active.
class NeoRoleTabBar extends StatelessWidget {
  final List<Widget> tabs;
  final bool isScrollable;
  final void Function(int)? onTap;

  const NeoRoleTabBar({
    super.key,
    required this.tabs,
    this.isScrollable = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(6.r),
      width: double.infinity,
      decoration: BoxDecoration(
        color: NeoColors.surface,
        border: Border.all(color: NeoColors.cyan.withValues(alpha: 0.2)),
      ),
      child: TabBar(
        onTap: onTap,
        isScrollable: isScrollable,
        dividerColor: Colors.transparent,
        tabAlignment: isScrollable ? TabAlignment.center : TabAlignment.fill,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: NeoTextStyles.labelCaps.copyWith(color: NeoColors.bg, fontSize: 11.sp),
        unselectedLabelStyle: NeoTextStyles.labelCaps.copyWith(fontSize: 11.sp),
        labelColor: NeoColors.bg,
        unselectedLabelColor: NeoColors.outline,
        indicator: BoxDecoration(color: NeoColors.cyan),
        tabs: tabs,
      ),
    );
  }
}
