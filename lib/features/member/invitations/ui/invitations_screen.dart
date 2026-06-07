import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/helpers/spacing.dart';
import '../../partner_gyms/data/partner_gym_repository.dart';

class InvitationsScreen extends StatefulWidget {
  static const routeName = '/invitations';

  const InvitationsScreen({super.key});

  @override
  State<InvitationsScreen> createState() => _InvitationsScreenState();
}

class _InvitationsScreenState extends State<InvitationsScreen> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = PartnerGymRepository.getInvitations();
  }

  void _reload() => setState(() {
        _future = PartnerGymRepository.getInvitations();
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        title: Text('My Invites', style: AppTextStyles.font16WhiteBold),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _reload,
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.teal));
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, color: AppColors.grey, size: 48.r),
                  vGap(12),
                  Text(
                    snapshot.error
                        .toString()
                        .replaceFirst('Exception: ', ''),
                    style: AppTextStyles.font14GreyRegular,
                    textAlign: TextAlign.center,
                  ),
                  vGap(16),
                  TextButton(
                    onPressed: _reload,
                    child: Text('Retry',
                        style: TextStyle(color: AppColors.teal)),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data ?? {};
          final code = data['referral_code'] as String? ?? '—';
          final message = data['invite_message'] as String? ?? '';
          final total = (data['total_invites'] as num?)?.toInt() ?? 0;
          final referrals = (data['referrals'] as List?) ?? [];

          return SingleChildScrollView(
            padding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Code card ────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.r),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1B3A6B), Color(0xFF0D2545)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                        color: AppColors.blue.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(Icons.card_giftcard_outlined,
                            color: AppColors.blue, size: 22.r),
                        hGap(8),
                        Text('Invite Friends',
                            style: AppTextStyles.font16WhiteBold),
                      ]),
                      vGap(6),
                      Text(
                        'Share your code. When a friend signs up with your code, their account gets linked to you!',
                        style: AppTextStyles.font14GreyRegular
                            .copyWith(fontSize: 12.sp, height: 1.4),
                      ),
                      vGap(14),
                      // Code display + copy
                      Row(children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 10.h),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius:
                                  BorderRadius.circular(10.r),
                              border: Border.all(
                                  color: AppColors.blue
                                      .withValues(alpha: 0.4)),
                            ),
                            child: Text(
                              code,
                              style: AppTextStyles.font16WhiteBold
                                  .copyWith(
                                      letterSpacing: 3,
                                      color: AppColors.blue),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        hGap(10),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(
                                ClipboardData(text: code));
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text('Code copied!'),
                              behavior: SnackBarBehavior.floating,
                              duration: Duration(seconds: 1),
                            ));
                          },
                          child: Container(
                            padding: EdgeInsets.all(10.r),
                            decoration: BoxDecoration(
                              color: AppColors.blue
                                  .withValues(alpha: 0.15),
                              borderRadius:
                                  BorderRadius.circular(10.r),
                            ),
                            child: Icon(Icons.copy_outlined,
                                color: AppColors.blue, size: 20.r),
                          ),
                        ),
                      ]),
                      vGap(12),
                      // Share button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.blue,
                            padding: EdgeInsets.symmetric(
                                vertical: 12.h),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(10.r)),
                          ),
                          onPressed: () {
                            if (message.isNotEmpty) {
                              Share.share(message,
                                  subject: 'Join FitQuad!');
                            }
                          },
                          icon: Icon(Icons.share_outlined,
                              size: 18.r),
                          label: Text('Share Invite',
                              style: AppTextStyles
                                  .font14WhiteRegular),
                        ),
                      ),
                    ],
                  ),
                ),

                vGap(24),
                // ── Stats ─────────────────────────────────────────
                Text('Friends Invited',
                    style: AppTextStyles.font16WhiteBold),
                vGap(4),
                Text('$total friend${total == 1 ? '' : 's'} joined using your code',
                    style: AppTextStyles.font14GreyRegular
                        .copyWith(fontSize: 12.sp)),

                vGap(16),
                // ── Referrals list ────────────────────────────────
                if (referrals.isEmpty)
                  Container(
                    padding: EdgeInsets.all(20.r),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Text('🤝',
                              style: TextStyle(fontSize: 40.sp)),
                          vGap(8),
                          Text(
                            'No invites yet.\nShare your code to get started!',
                            style: AppTextStyles.font14GreyRegular,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...referrals.map((r) {
                    final map = r as Map<String, dynamic>;
                    return Container(
                      margin: EdgeInsets.only(bottom: 8.h),
                      padding: EdgeInsets.all(14.r),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                            color:
                                AppColors.teal.withValues(alpha: 0.2)),
                      ),
                      child: Row(children: [
                        CircleAvatar(
                          radius: 20.r,
                          backgroundColor:
                              AppColors.teal.withValues(alpha: 0.2),
                          child: Text(
                            (map['name'] as String? ?? 'M')
                                .substring(0, 1)
                                .toUpperCase(),
                            style: TextStyle(
                                color: AppColors.teal,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        hGap(12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(map['name'] as String? ?? 'Member',
                                  style: AppTextStyles.font14WhiteRegular
                                      .copyWith(
                                          fontWeight: FontWeight.w600)),
                              if (map['joined_at'] != null)
                                Text(
                                  'Joined ${map['joined_at']}',
                                  style: AppTextStyles.font14GreyRegular
                                      .copyWith(fontSize: 11.sp),
                                ),
                            ],
                          ),
                        ),
                        Icon(Icons.check_circle,
                            color: AppColors.teal, size: 18.r),
                      ]),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }
}
