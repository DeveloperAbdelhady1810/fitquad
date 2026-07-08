import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';
import 'package:gym_app/core/widgets/custom_button.dart';
import 'package:gym_app/features/member/data/repositories/member_repository.dart';
import 'package:gym_app/features/member/home/manager/member_cubit.dart';

/// Generates an AI workout/nutrition plan (Gemini strict-JSON, with a
/// deterministic fallback), previews it in the same visual language as a
/// coach-sent plan, and lets the member Save & Apply it into the app.
class AiPlanPreviewScreen extends StatefulWidget {
  final String type; // 'workout' | 'nutrition'
  final String? prompt;
  final bool attachInBody;

  const AiPlanPreviewScreen({
    super.key,
    required this.type,
    this.prompt,
    this.attachInBody = false,
  });

  @override
  State<AiPlanPreviewScreen> createState() => _AiPlanPreviewScreenState();
}

class _AiPlanPreviewScreenState extends State<AiPlanPreviewScreen> {
  bool _loading = true;
  bool _saving = false;
  String? _error;
  Map<String, dynamic>? _plan;
  String? _prompt;

  @override
  void initState() {
    super.initState();
    _prompt = widget.prompt;
    _generate();
  }

  Future<void> _generate() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await MemberRepository.generateAiPlan(
        type: widget.type,
        prompt: _prompt,
        attachInBody: widget.attachInBody,
      );
      if (mounted) setState(() { _plan = result; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _regenerate() async {
    final ctrl = TextEditingController(text: _prompt ?? '');
    final newPrompt = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.secondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text('Regenerate Plan', style: AppTextStyles.font16WhiteBold),
        content: TextField(
          controller: ctrl,
          maxLines: 3,
          style: AppTextStyles.font14WhiteRegular,
          decoration: InputDecoration(
            hintText: 'Anything to change?',
            hintStyle: AppTextStyles.font14GreyRegular,
            filled: true,
            fillColor: AppColors.primary,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: AppColors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text),
            child: Text('Regenerate', style: TextStyle(color: AppColors.teal, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (newPrompt == null || !mounted) return;
    _prompt = newPrompt.trim().isEmpty ? null : newPrompt.trim();
    _generate();
  }

  Future<void> _saveAndApply() async {
    final plan = _plan;
    if (plan == null) return;

    setState(() => _saving = true);
    try {
      await MemberRepository.applyAiPlan(
        type: widget.type,
        title: plan['title'] as String? ??
            (widget.type == 'workout' ? 'AI Workout Plan' : 'AI Nutrition Plan'),
        description: plan['description'] as String?,
        payload: Map<String, dynamic>.from(plan['payload'] as Map),
      );
      if (!mounted) return;
      context.read<MemberCubit>().loadAll();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(widget.type == 'workout'
            ? '✅ Workout plan applied! Check the Train tab.'
            : '✅ Nutrition plan applied! Check the Eat tab.'),
        backgroundColor: AppColors.emerald,
        behavior: SnackBarBehavior.floating,
      ));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Save failed: $e'),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text('AI Plan Preview', style: AppTextStyles.font16WhiteBold),
        actions: [
          if (!_loading)
            IconButton(
              icon: Icon(Icons.refresh, color: AppColors.teal),
              onPressed: _regenerate,
              tooltip: 'Regenerate',
            ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: AppColors.teal))
          : _error != null
              ? _errorView()
              : _planView(),
      bottomNavigationBar: (_plan == null || _loading || _error != null)
          ? null
          : SafeArea(
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: CustomButton(
                  text: _saving ? 'Saving...' : 'Save & Apply',
                  iconData: _saving ? null : Icons.check_circle_outline,
                  iconBeforeText: true,
                  onPressed: _saving ? null : _saveAndApply,
                ),
              ),
            ),
    );
  }

  Widget _errorView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: AppColors.red, size: 40.r),
            vGap(12),
            Text('Could not generate a plan', style: AppTextStyles.font16WhiteBold),
            vGap(6),
            Text(_error ?? '', style: AppTextStyles.font14GreyRegular, textAlign: TextAlign.center),
            vGap(16),
            CustomButton(text: 'Try Again', onPressed: _generate),
          ],
        ),
      ),
    );
  }

  Widget _planView() {
    final plan = _plan!;
    final source = plan['source'] as String? ?? 'gemini';
    final title = plan['title'] as String? ?? '';
    final description = plan['description'] as String? ?? '';
    final payload = Map<String, dynamic>.from(plan['payload'] as Map);

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, color: AppColors.teal, size: 14.r),
                    hGap(4),
                    Text('Generated by AI',
                        style: AppTextStyles.font14GreyRegular
                            .copyWith(color: AppColors.teal, fontSize: 11.sp, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          if (source == 'fallback') ...[
            vGap(6),
            Text(
              'Estimated from your profile data — AI service was unavailable.',
              style: AppTextStyles.font14GreyRegular.copyWith(fontSize: 11.sp),
            ),
          ],
          vGap(12),
          Text(title, style: AppTextStyles.font16WhiteBold.copyWith(fontSize: 20.sp)),
          if (description.isNotEmpty) ...[
            vGap(6),
            Text(description, style: AppTextStyles.font14GreyRegular),
          ],
          vGap(20),
          if (widget.type == 'workout') ..._workoutBody(payload) else ..._nutritionBody(payload),
        ],
      ),
    );
  }

  List<Widget> _workoutBody(Map<String, dynamic> payload) {
    final days = (payload['days'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    return [
      for (final day in days) ...[
        Text(day['day_name'] as String? ?? 'Day', style: AppTextStyles.font16WhiteBold),
        vGap(8),
        ...((day['exercises'] as List?)?.cast<Map<String, dynamic>>() ?? []).map((ex) => Container(
              margin: EdgeInsets.only(bottom: 8.h),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(ex['name'] as String? ?? '',
                        style: AppTextStyles.font14WhiteRegular.copyWith(fontWeight: FontWeight.w600)),
                  ),
                  Text('${ex['sets']} x ${ex['reps']}',
                      style: AppTextStyles.font14GreyRegular.copyWith(color: AppColors.teal)),
                  hGap(10),
                  Text('${ex['rest_seconds']}s rest',
                      style: AppTextStyles.font14GreyRegular.copyWith(fontSize: 11.sp)),
                ],
              ),
            )),
        vGap(16),
      ],
    ];
  }

  List<Widget> _nutritionBody(Map<String, dynamic> payload) {
    final calories = (payload['daily_calories'] as num?)?.toInt() ?? 0;
    final protein  = (payload['protein_g'] as num?)?.toInt() ?? 0;
    final carbs    = (payload['carbs_g'] as num?)?.toInt() ?? 0;
    final fat      = (payload['fat_g'] as num?)?.toInt() ?? 0;
    final meals    = (payload['meals'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return [
      Row(
        children: [
          _macroBox('Calories', '$calories kcal', AppColors.red),
          hGap(8),
          _macroBox('Protein', '${protein}g', AppColors.blue),
          hGap(8),
          _macroBox('Carbs', '${carbs}g', AppColors.emerald),
          hGap(8),
          _macroBox('Fat', '${fat}g', AppColors.purple),
        ],
      ),
      vGap(20),
      Text('Meals', style: AppTextStyles.font16WhiteBold),
      vGap(8),
      for (final meal in meals)
        Container(
          margin: EdgeInsets.only(bottom: 8.h),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(meal['name'] as String? ?? 'Meal',
                        style: AppTextStyles.font14WhiteRegular.copyWith(fontWeight: FontWeight.w600)),
                  ),
                  Text(meal['time_of_day'] as String? ?? '',
                      style: AppTextStyles.font14GreyRegular.copyWith(color: AppColors.teal, fontSize: 11.sp)),
                ],
              ),
              if ((meal['foods'] as String?)?.isNotEmpty == true) ...[
                vGap(4),
                Text(meal['foods'] as String, style: AppTextStyles.font14GreyRegular),
              ],
            ],
          ),
        ),
    ];
  }

  Widget _macroBox(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Text(value,
                style: AppTextStyles.font14WhiteRegular
                    .copyWith(color: color, fontWeight: FontWeight.bold, fontSize: 12.sp),
                textAlign: TextAlign.center),
            vGap(2),
            Text(label, style: AppTextStyles.font14GreyRegular.copyWith(fontSize: 9.sp), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
