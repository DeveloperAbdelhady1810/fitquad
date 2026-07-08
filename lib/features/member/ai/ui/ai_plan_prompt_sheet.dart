import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/services/ai_consent.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';
import 'package:gym_app/core/widgets/custom_button.dart';
import 'package:gym_app/features/member/ai/ui/ai_plan_preview_screen.dart';

/// Bottom sheet collecting an optional free-text prompt + "attach InBody"
/// toggle before generating an AI workout/nutrition plan. On confirm, pushes
/// [AiPlanPreviewScreen] which does the actual generation + preview + apply.
Future<void> showAiPlanGeneratorSheet(
  BuildContext context, {
  required String type, // 'workout' | 'nutrition'
}) async {
  final promptCtrl = TextEditingController();
  bool attachInBody = false;

  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: AppColors.secondary,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheetState) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 24, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.smart_toy_outlined, color: AppColors.teal, size: 22.sp),
                hGap(8),
                Text(
                  type == 'workout' ? 'Generate AI Workout Plan' : 'Generate AI Nutrition Plan',
                  style: AppTextStyles.font16WhiteBold,
                ),
              ],
            ),
            vGap(6),
            Text(
              'Optionally tell the AI anything specific — days available, equipment, dietary restrictions. Leave blank for a plan based on your profile.',
              style: AppTextStyles.font14GreyRegular,
            ),
            vGap(14),
            TextField(
              controller: promptCtrl,
              maxLines: 3,
              style: AppTextStyles.font14WhiteRegular,
              decoration: InputDecoration(
                hintText: type == 'workout'
                    ? 'e.g. I can train 4 days a week, home gym only'
                    : 'e.g. vegetarian, no dairy, 3 meals a day',
                hintStyle: AppTextStyles.font14GreyRegular,
                filled: true,
                fillColor: AppColors.primary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              ),
            ),
            vGap(10),
            InkWell(
              onTap: () => setSheetState(() => attachInBody = !attachInBody),
              child: Row(
                children: [
                  Checkbox(
                    value: attachInBody,
                    activeColor: AppColors.teal,
                    onChanged: (v) => setSheetState(() => attachInBody = v ?? false),
                  ),
                  Expanded(
                    child: Text('Use my latest InBody scan for precise calculations',
                        style: AppTextStyles.font14GreyRegular),
                  ),
                ],
              ),
            ),
            vGap(10),
            CustomButton(
              text: 'Generate Plan',
              iconData: Icons.auto_awesome,
              iconBeforeText: true,
              onPressed: () => Navigator.pop(ctx, true),
            ),
          ],
        ),
      ),
    ),
  );

  if (confirmed != true || !context.mounted) return;
  if (!await AiConsent.ensure(context)) return;
  if (!context.mounted) return;

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => AiPlanPreviewScreen(
        type: type,
        prompt: promptCtrl.text.trim().isEmpty ? null : promptCtrl.text.trim(),
        attachInBody: attachInBody,
      ),
    ),
  );
}
