import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';

import '../../../../core/enums/admin_tab.dart';
import '../../../../generated/l10n.dart';
import '../widgets/admin_view_body.dart';
import '../widgets/analytics_body.dart';
import '../widgets/check_ins_body.dart';
import '../widgets/coaches_body.dart';
import '../widgets/market_body.dart';
import '../widgets/marketing_body.dart';
import '../widgets/members_body.dart';
import '../widgets/plans_body.dart';
import '../widgets/settings_body.dart';
import '../widgets/staff_body.dart';

class AdminView extends StatefulWidget {
  const AdminView({super.key});
  static const String routeName = '/admin';

  @override
  State<AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends State<AdminView> {

  AdminTab _currentTab = AdminTab.dashboard;

  Widget _buildBody() {
    switch (_currentTab) {
      case AdminTab.dashboard:
        return const AdminViewBody();

      case AdminTab.members:
        return const MembersBody();

      case AdminTab.coaches:
        return CoachesBody();

      case AdminTab.plan:
        return PlansBody();

      case AdminTab.check:
        return CheckInsBody();

      case AdminTab.market:
        return const MarketBody();

      case AdminTab.analytics:
        return AnalyticsBody();

      case AdminTab.marketing:
        return MarketingBody();

      case AdminTab.staff:
        return const StaffBody();
      case AdminTab.settings:
        return SettingsBody();
    }
  }



  @override
  Widget build(BuildContext context) {
    final s=S.of(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: AppColors.grey),
          toolbarHeight: 70.h,
          backgroundColor: AppColors.primary,

          title: ListTile(
            title: Text(s.overview, style: AppTextStyles.font16WhiteBold),
            subtitle: Text(
              s.welcome_back,
              style: AppTextStyles.font14GreyRegular,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.notifications_none, color: AppColors.grey),
              onPressed: () {},
            ),
          ],
        ),

        drawer: _AppDrawer(
          currentTab: _currentTab,
          onSelect: (tab) {
            setState(() => _currentTab = tab);
            Navigator.pop(context);
          },
        ),
        backgroundColor: AppColors.primary,
        body: _buildBody(),
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  final AdminTab currentTab;
  final Function(AdminTab) onSelect;
  const _AppDrawer({
    required this.currentTab,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final s=S.of(context);
    return Drawer(
      backgroundColor: AppColors.secondary,
      child: ListView(
        children: [
          DrawerHeader(
            child: Text(
              s.gym_admin,
              style: AppTextStyles.font16WhiteBold.copyWith(
                color: AppColors.purple,
              ),
            ),
          ),

          _item(Icons.dashboard,s.dashboard, AdminTab.dashboard),
          _item(Icons.people, s.members, AdminTab.members),
          _item(Icons.card_giftcard, s.coaches, AdminTab.coaches),
          _item(Icons.credit_card, s.plans, AdminTab.plan),
          _item(Icons.person_add_alt, s.check_ins, AdminTab.check),
          _item(Icons.receipt_long, s.market, AdminTab.market),
          _item(Icons.bar_chart_rounded, s.analytics, AdminTab.analytics),
          _item(Icons.percent, s.marketing, AdminTab.marketing),
          _item(Icons.label_outline_rounded, s.staff, AdminTab.staff),
          _item(Icons.settings, s.settings, AdminTab.settings),
        ],
      ),
    );
  }

  Widget _item(IconData icon, String title, AdminTab tab) {
    final isSelected = tab == currentTab;

    return ListTile(
      leading: Icon(icon, color: isSelected ? AppColors.purple : Colors.white54),
      title: Text(
        title,
        style: AppTextStyles.font14GreyRegular.copyWith(
          color: isSelected ? AppColors.purple : Colors.white54,
        ),
      ),
      tileColor: isSelected ? AppColors.purple.withValues(alpha: .12) : null,
      onTap: () => onSelect(tab),
    );
  }
}
