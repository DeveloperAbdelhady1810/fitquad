import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';
import 'package:gym_app/features/member/home/manager/member_cubit.dart';
import 'package:gym_app/features/member/home/manager/member_state.dart';
import 'package:qr_flutter/qr_flutter.dart';

void showQrSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => BlocProvider.value(
      value: context.read<MemberCubit>(),
      child: const _QrSheet(),
    ),
  );
}

class _QrSheet extends StatelessWidget {
  const _QrSheet();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemberCubit, MemberState>(
      builder: (context, state) {
        final memberId = state is MemberLoaded
            ? (state.member.id?.toString() ?? 'MEMBER')
            : 'MEMBER';
        final name =
            state is MemberLoaded ? (state.member.name ?? 'Member') : 'Member';

        return Container(
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          padding: EdgeInsets.all(32.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              vGap(24),
              Text('Your Gym QR Code', style: AppTextStyles.font16WhiteBold),
              vGap(4),
              Text(name, style: AppTextStyles.font14GreyRegular),
              vGap(24),
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: QrImageView(
                  data: memberId,
                  version: QrVersions.auto,
                  size: 200.r,
                ),
              ),
              vGap(20),
              Text(
                'Show this at the gym reception',
                style: AppTextStyles.font14GreyRegular,
                textAlign: TextAlign.center,
              ),
              vGap(6),
              Text(
                'Member ID: $memberId',
                style:
                    AppTextStyles.font14GreyRegular.copyWith(color: AppColors.teal),
              ),
              vGap(24),
            ],
          ),
        );
      },
    );
  }
}
