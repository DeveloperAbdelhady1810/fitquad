import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/core/helpers/app_decoration.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';
import 'package:gym_app/core/services/ai_consent.dart';
import 'package:gym_app/features/member/data/repositories/member_repository.dart';
import 'package:gym_app/features/member/inbody/manager/inbody_cubit.dart';
import 'package:gym_app/features/member/inbody/models/inbody_model.dart';
import 'package:intl/intl.dart';

class InBodyFormScreen extends StatefulWidget {
  static const routeName = '/inbody-form';

  const InBodyFormScreen({super.key});

  @override
  State<InBodyFormScreen> createState() => _InBodyFormScreenState();
}

class _InBodyFormScreenState extends State<InBodyFormScreen> {
  DateTime _selectedDate = DateTime.now();

  // Body Composition controllers
  final _weightCtrl = TextEditingController();
  final _bmiCtrl = TextEditingController();
  final _bodyFatCtrl = TextEditingController();
  final _muscleMassCtrl = TextEditingController();
  final _fatMassCtrl = TextEditingController();
  final _fatFreeCtrl = TextEditingController();

  // Body Water controllers
  final _totalWaterCtrl = TextEditingController();
  final _intraCtrl = TextEditingController();
  final _extraCtrl = TextEditingController();

  // Nutrition & Metabolic controllers
  final _proteinCtrl = TextEditingController();
  final _mineralCtrl = TextEditingController();
  final _bmrCtrl = TextEditingController();
  final _visceralFatCtrl = TextEditingController();

  // Score & Notes controllers
  final _inbodyScoreCtrl = TextEditingController();
  final _targetWeightCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _weightCtrl.dispose();
    _bmiCtrl.dispose();
    _bodyFatCtrl.dispose();
    _muscleMassCtrl.dispose();
    _fatMassCtrl.dispose();
    _fatFreeCtrl.dispose();
    _totalWaterCtrl.dispose();
    _intraCtrl.dispose();
    _extraCtrl.dispose();
    _proteinCtrl.dispose();
    _mineralCtrl.dispose();
    _bmrCtrl.dispose();
    _visceralFatCtrl.dispose();
    _inbodyScoreCtrl.dispose();
    _targetWeightCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  double? _parse(TextEditingController ctrl) {
    final t = ctrl.text.trim();
    if (t.isEmpty) return null;
    return double.tryParse(t);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.teal,
            surface: AppColors.secondary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _save() async {
    if (_weightCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter at least the weight.'),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        ),
      );
      return;
    }

    final model = InBodyModel(
      recordedAt: _selectedDate,
      weight: _parse(_weightCtrl),
      bmi: _parse(_bmiCtrl),
      bodyFatPct: _parse(_bodyFatCtrl),
      muscleMass: _parse(_muscleMassCtrl),
      fatMass: _parse(_fatMassCtrl),
      fatFreeMass: _parse(_fatFreeCtrl),
      totalBodyWater: _parse(_totalWaterCtrl),
      intracellularWater: _parse(_intraCtrl),
      extracellularWater: _parse(_extraCtrl),
      protein: _parse(_proteinCtrl),
      mineral: _parse(_mineralCtrl),
      bmr: _parse(_bmrCtrl),
      visceralFat: _parse(_visceralFatCtrl),
      inbodyScore: _parse(_inbodyScoreCtrl),
      targetWeight: _parse(_targetWeightCtrl),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );

    await context.read<InBodyCubit>().save(model);

    if (!mounted) return;

    if (!await AiConsent.ensure(context)) {
      if (mounted) context.pop();
      return;
    }
    if (!mounted) return;

    // Show success and immediately fetch AI insight in background
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('InBody results saved! Getting AI insight...'),
        backgroundColor: AppColors.emerald,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    );

    try {
      final insight = await MemberRepository.getInBodyInsight(
        'Give me a brief 2-sentence analysis of my InBody results and one specific recommendation.',
      );
      if (mounted) _showAiInsightDialog(insight);
    } catch (_) {
      if (mounted) context.pop();
    }
  }

  void _showAiInsightDialog(String insight) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.secondary,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            Icon(Icons.psychology_outlined,
                color: AppColors.teal, size: 22.sp),
            hGap(8),
            Text('AI Insight', style: AppTextStyles.font16WhiteBold),
          ],
        ),
        content: Text(insight,
            style: AppTextStyles.font14GreyRegular.copyWith(height: 1.5)),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.teal,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r)),
            ),
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            child: Text('Got it!', style: AppTextStyles.font14WhiteRegular),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        title: Text('Add InBody Scan', style: AppTextStyles.font16WhiteBold),
      ),
      body: BlocListener<InBodyCubit, InBodyState>(
        listener: (context, state) {
          if (state is InBodyError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Picker Row
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  decoration: AppDecorations.containerDecoration,
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: AppColors.teal),
                      hGap(12),
                      Text(
                        'Scan Date: ${DateFormat('MMM d, yyyy').format(_selectedDate)}',
                        style: AppTextStyles.font16WhiteRegular,
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_drop_down, color: AppColors.grey),
                    ],
                  ),
                ),
              ),
              vGap(16),

              // Section 1: Body Composition
              _SectionTile(
                title: 'Body Composition',
                initiallyExpanded: true,
                children: [
                  _FormField(
                      ctrl: _weightCtrl,
                      label: 'Weight (45–120 kg)',
                      hint: 'e.g. 75.5'),
                  _FormField(
                      ctrl: _bmiCtrl, label: 'BMI (16–40)', hint: 'e.g. 22.4'),
                  _FormField(
                      ctrl: _bodyFatCtrl,
                      label: 'Body Fat % (5–50%)',
                      hint: 'e.g. 18.0'),
                  _FormField(
                      ctrl: _muscleMassCtrl,
                      label: 'Skeletal Muscle Mass (20–60 kg)',
                      hint: 'e.g. 34.2'),
                  _FormField(
                      ctrl: _fatMassCtrl,
                      label: 'Fat Mass (5–50 kg)',
                      hint: 'e.g. 12.5'),
                  _FormField(
                      ctrl: _fatFreeCtrl,
                      label: 'Fat-Free Mass (40–80 kg)',
                      hint: 'e.g. 62.0'),
                ],
              ),
              vGap(8),

              // Section 2: Body Water
              _SectionTile(
                title: 'Body Water',
                children: [
                  _FormField(
                      ctrl: _totalWaterCtrl,
                      label: 'Total Body Water (25–60 kg)',
                      hint: 'e.g. 40.0'),
                  _FormField(
                      ctrl: _intraCtrl,
                      label: 'Intracellular Water (15–40 kg)',
                      hint: 'e.g. 25.0'),
                  _FormField(
                      ctrl: _extraCtrl,
                      label: 'Extracellular Water (10–25 kg)',
                      hint: 'e.g. 15.0'),
                ],
              ),
              vGap(8),

              // Section 3: Nutrition & Metabolic
              _SectionTile(
                title: 'Nutrition & Metabolic',
                children: [
                  _FormField(
                      ctrl: _proteinCtrl,
                      label: 'Protein (5–20 kg)',
                      hint: 'e.g. 10.5'),
                  _FormField(
                      ctrl: _mineralCtrl,
                      label: 'Mineral (1–5 kg)',
                      hint: 'e.g. 3.2'),
                  _FormField(
                      ctrl: _bmrCtrl,
                      label: 'BMR (1000–3000 kcal)',
                      hint: 'e.g. 1800'),
                  _FormField(
                      ctrl: _visceralFatCtrl,
                      label: 'Visceral Fat Level (1–20)',
                      hint: 'e.g. 5'),
                ],
              ),
              vGap(8),

              // Section 4: Score & Notes
              _SectionTile(
                title: 'Score & Notes',
                children: [
                  _FormField(
                      ctrl: _inbodyScoreCtrl,
                      label: 'InBody Score (0–100)',
                      hint: 'e.g. 72'),
                  _FormField(
                      ctrl: _targetWeightCtrl,
                      label: 'Target Weight (kg)',
                      hint: 'e.g. 70.0'),
                  Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: TextField(
                      controller: _notesCtrl,
                      maxLines: 4,
                      style: AppTextStyles.font14WhiteRegular,
                      decoration: InputDecoration(
                        labelText: 'Notes',
                        hintText: 'Any additional notes...',
                        labelStyle: AppTextStyles.font14GreyRegular,
                        hintStyle: AppTextStyles.font14GreyRegular
                            .copyWith(fontSize: 12.sp),
                        filled: true,
                        fillColor: AppColors.primary,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: const BorderSide(color: AppColors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: const BorderSide(color: AppColors.teal),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: const BorderSide(color: AppColors.grey),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              vGap(24),

              // Save button
              BlocBuilder<InBodyCubit, InBodyState>(
                builder: (context, state) {
                  final isSaving = state is InBodySaving;
                  return SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.emerald,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r)),
                      ),
                      onPressed: isSaving ? null : _save,
                      child: isSaving
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: AppColors.white),
                            )
                          : Text('Save Results',
                              style: AppTextStyles.font16WhiteBold),
                    ),
                  );
                },
              ),
              vGap(32),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTile extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final bool initiallyExpanded;

  const _SectionTile({
    required this.title,
    required this.children,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.containerDecoration,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          childrenPadding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          title: Text(title,
              style: AppTextStyles.font16WhiteBold
                  .copyWith(color: AppColors.teal)),
          iconColor: AppColors.teal,
          collapsedIconColor: AppColors.grey,
          children: children,
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final String hint;

  const _FormField({
    required this.ctrl,
    required this.label,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: TextField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
        ],
        style: AppTextStyles.font14WhiteRegular,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: AppTextStyles.font14GreyRegular,
          hintStyle:
              AppTextStyles.font14GreyRegular.copyWith(fontSize: 12.sp),
          filled: true,
          fillColor: AppColors.primary,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: const BorderSide(color: AppColors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: const BorderSide(color: AppColors.teal),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: const BorderSide(color: AppColors.grey),
          ),
        ),
      ),
    );
  }
}
