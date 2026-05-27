import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';
class MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool hasInBody;
  final bool inBodyAttached;
  final VoidCallback? onToggleInBody;

  const MessageInput({
    required this.controller,
    required this.onSend,
    this.hasInBody = false,
    this.inBodyAttached = false,
    this.onToggleInBody,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.fromLTRB(12.w, 6.h, 12.w, 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InBodyToggle(
            attached: inBodyAttached,
            hasData: hasInBody,
            onTap: onToggleInBody,
          ),
          SizedBox(height: 6.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  cursorColor: AppColors.teal,
                  style: TextStyle(color: Colors.white, fontSize: 14.sp),
                  maxLines: 4,
                  minLines: 1,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: 'Ask your AI coach anything…',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14.sp,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    filled: true,
                    fillColor: AppColors.secondary,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24.r),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24.r),
                      borderSide:
                          BorderSide(color: AppColors.teal, width: 1.5),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              _SendButton(onTap: onSend),
            ],
          ),
        ],
      ),
    );
  }
}

class _InBodyToggle extends StatelessWidget {
  final bool attached;
  final bool hasData;
  final VoidCallback? onTap;

  const _InBodyToggle({
    required this.attached,
    required this.hasData,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Three visual states:
    // hasData + attached  → teal filled chip
    // hasData + !attached → dark bordered chip
    // !hasData            → greyed chip with "add" hint
    final Color color = attached
        ? AppColors.teal
        : hasData
            ? Colors.grey.shade500
            : Colors.grey.shade700;

    final String label = attached
        ? 'InBody attached'
        : hasData
            ? 'Attach InBody'
            : 'Attach InBody (no scan yet)';

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: attached
              ? AppColors.teal.withValues(alpha: 0.15)
              : AppColors.secondary,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: attached
                ? AppColors.teal
                : hasData
                    ? Colors.grey.shade700
                    : Colors.grey.shade800,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 15.r,
              color: color,
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: color,
                fontWeight: attached ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            if (attached) ...[
              SizedBox(width: 4.w),
              Icon(Icons.check_circle, size: 13.r, color: AppColors.teal),
            ],
          ],
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  final VoidCallback onTap;
  const _SendButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44.r,
        height: 44.r,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.teal, AppColors.emerald],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.send_rounded, color: Colors.white, size: 20.r),
      ),
    );
  }
}
