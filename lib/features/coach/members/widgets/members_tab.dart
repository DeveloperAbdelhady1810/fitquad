import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_app/core/enums/member_type.dart';
import 'package:gym_app/core/widgets/app_avatar.dart';
import 'package:gym_app/core/helpers/spacing.dart';

import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';
import 'package:gym_app/core/widgets/custom_tab_bar.dart';
import 'package:gym_app/features/coach/home/ui/widgets/member_profile_screen.dart';
import 'package:gym_app/features/member/data/models/member_model.dart';

import '../../home/manager/coach_cubit.dart';

class MembersTab extends StatefulWidget {
  const MembersTab({super.key});

  @override
  State<MembersTab> createState() => _MembersTabState();
}

class _MembersTabState extends State<MembersTab> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: MemberType.values.length,
      child: Column(
        children: [
          // ── Search bar ──────────────────────────────────────────
          TextField(
            controller: _search,
            style: const TextStyle(color: Colors.white),
            onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
            decoration: InputDecoration(
              hintText: 'Search members…',
              hintStyle: AppTextStyles.font14GreyRegular,
              prefixIcon: Icon(Icons.search, color: AppColors.grey, size: 20.r),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: AppColors.grey, size: 18.r),
                      onPressed: () {
                        _search.clear();
                        setState(() => _query = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.secondary,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none),
            ),
          ),
          vGap(10),

          // ── Type filter tabs ────────────────────────────────────
          CustomTabBar(
            isScrollable: true,
            isSecondary: true,
            tabs: MemberType.values
                .map((t) => Tab(text: t.label(context)))
                .toList(),
            onTap: (index) {
              final type = MemberType.values[index];
              final cubit = context.read<CoachCubit>();
              cubit.filterMembers(type == MemberType.all ? null : type);
            },
          ),
          vGap(8),

          // ── Member list ─────────────────────────────────────────
          BlocBuilder<CoachCubit, CoachState>(
            builder: (context, state) {
              if (state is! CoachesLoaded) {
                return const Expanded(
                    child: Center(
                        child: CircularProgressIndicator(
                            color: AppColors.teal)));
              }

              final members = state.filteredMembers
                  .where((m) =>
                      _query.isEmpty ||
                      (m.name?.toLowerCase().contains(_query) ?? false))
                  .toList();

              if (members.isEmpty) {
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline,
                          color: AppColors.grey, size: 48.r),
                      vGap(12),
                      Text(
                        _query.isNotEmpty
                            ? 'No members match "$_query"'
                            : 'No members yet',
                        style: AppTextStyles.font14GreyRegular,
                      ),
                    ],
                  ),
                );
              }

              return Expanded(
                child: ListView.separated(
                  itemCount: members.length,
                  separatorBuilder: (_, __) => vGap(8),
                  itemBuilder: (ctx, i) =>
                      _MemberCard(member: members[i]),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  final MemberModel member;
  const _MemberCard({required this.member});

  @override
  Widget build(BuildContext context) {
    final goal     = member.type?.label(context) ?? 'Member';
    final status   = member.status;

    Color statusColor = switch (status?.name ?? '') {
      'active'    => AppColors.emerald,
      'inactive'  => AppColors.grey,
      'expiring'  => Colors.orange,
      _           => AppColors.grey,
    };

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MemberProfileScreen(member: member),
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            AppAvatar(name: member.name ?? '', url: member.avatarUrl, radius: 22),
            hGap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(member.name ?? 'Member',
                      style: AppTextStyles.font14WhiteRegular
                          .copyWith(fontWeight: FontWeight.w600)),
                  vGap(3),
                  Row(
                    children: [
                      _Chip(goal, AppColors.blue),
                      hGap(6),
                      if (member.weight != null)
                        _Chip('${member.weight} kg', AppColors.grey),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 8.r,
                  height: 8.r,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: statusColor),
                ),
                vGap(4),
                Icon(Icons.chevron_right,
                    color: AppColors.grey, size: 18.r),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(label,
          style: AppTextStyles.font14GreyRegular
              .copyWith(color: color, fontSize: 10.sp, fontWeight: FontWeight.w600)),
    );
  }
}
