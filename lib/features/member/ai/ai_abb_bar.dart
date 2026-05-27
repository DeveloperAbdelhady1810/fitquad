import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'manager/ai_cubit.dart';

class AiAbbBar extends StatelessWidget {
  const AiAbbBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        border: Border(
          bottom: BorderSide(color: Colors.white10),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.teal.withValues(alpha: 0.15),
              border: Border.all(
                  color: AppColors.teal.withValues(alpha: 0.4)),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/FitQuad.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.smart_toy_outlined,
                  size: 22.sp,
                  color: AppColors.teal,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('FitQuad AI Coach',
                    style: AppTextStyles.font16GreyBold),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Container(
                      width: 7.r,
                      height: 7.r,
                      decoration: BoxDecoration(
                        color: AppColors.emerald,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      'Gemini · Online · Personalised',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.emerald,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          BlocBuilder<AiAssistantCubit, AiChatState>(
            builder: (context, chatState) {
              if (chatState.messages.length <= 1) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: Icon(Icons.refresh_rounded,
                    color: AppColors.grey, size: 20.sp),
                tooltip: 'Clear chat',
                onPressed: () =>
                    context.read<AiAssistantCubit>().clearChat(),
              );
            },
          ),
        ],
      ),
    );
  }
}
