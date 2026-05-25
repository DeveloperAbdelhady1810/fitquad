import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../generated/l10n.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'package:gym_app/features/member/data/models/message_model.dart';
import 'manager/ai_cubit.dart';

class AiAbbBar extends StatelessWidget {
  const AiAbbBar({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Container(
      padding: EdgeInsets.all(16),
      color: AppColors.primary,
      child: Row(
        children: [
          CircleAvatar(
            radius: 25.r,
            backgroundColor: AppColors.emerald.withValues(alpha: 0.3),
            child: Image.asset(
              'assets/images/FitQuad.png',
              width: 34.r,
              height: 34.r,
              errorBuilder: (_, __, ___) => Icon(
                Icons.smart_toy_outlined,
                size: 30.sp,
                color: AppColors.teal,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.ai_coach, style: AppTextStyles.font16GreyBold),
                Row(
                  children: [
                    Container(
                      width: 8.r,
                      height: 8.r,
                      decoration: BoxDecoration(
                        color: AppColors.emerald,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Gemini · Online',
                      style: AppTextStyles.font14GreyRegular.copyWith(
                        fontSize: 11.sp,
                        color: AppColors.emerald,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          BlocBuilder<AiAssistantCubit, List<ChatMessage>>(
            builder: (context, messages) {
              if (messages.length <= 1) return const SizedBox.shrink();
              return IconButton(
                icon: Icon(Icons.refresh, color: AppColors.grey, size: 20.sp),
                tooltip: 'Clear chat',
                onPressed: () => context.read<AiAssistantCubit>().clearChat(),
              );
            },
          ),
        ],
      ),
    );
  }
}
