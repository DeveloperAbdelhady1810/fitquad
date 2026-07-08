import 'package:flutter/material.dart';
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
import 'package:gym_app/features/member/inbody/ui/inbody_form_screen.dart';
import 'package:gym_app/features/member/inbody/ui/progress_photos_tab.dart';
import 'package:intl/intl.dart';

class InBodyScreen extends StatelessWidget {
  static const routeName = '/inbody';

  const InBodyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InBodyCubit()..load(),
      child: const _InBodyView(),
    );
  }
}

class _InBodyView extends StatelessWidget {
  const _InBodyView();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.primary,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          title: Text('InBody & Progress', style: AppTextStyles.font16WhiteBold),
          actions: [
            Builder(builder: (ctx) {
              final tabCtrl = DefaultTabController.of(ctx);
              return AnimatedBuilder(
                animation: tabCtrl,
                builder: (_, __) => tabCtrl.index == 0
                    ? IconButton(
                        icon: const Icon(Icons.add, color: AppColors.teal),
                        onPressed: () {
                          context.push(InBodyFormScreen.routeName).then((_) {
                            if (context.mounted) {
                              context.read<InBodyCubit>().load();
                            }
                          });
                        },
                      )
                    : const SizedBox.shrink(),
              );
            }),
          ],
          bottom: TabBar(
            indicatorColor: AppColors.teal,
            labelColor: AppColors.teal,
            unselectedLabelColor: AppColors.grey,
            labelStyle: AppTextStyles.font14GreyRegular
                .copyWith(fontWeight: FontWeight.w600),
            tabs: const [
              Tab(text: 'Records'),
              Tab(text: 'Progress Photos'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _RecordsTab(),
            const ProgressPhotosTab(),
          ],
        ),
      ),
    );
  }
}

class _RecordsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InBodyCubit, InBodyState>(
      builder: (context, state) {
        if (state is InBodyLoading || state is InBodyInitial) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.teal));
        }
        if (state is InBodyError) {
          return Center(
            child: Text(state.message,
                style: AppTextStyles.font14GreyRegular,
                textAlign: TextAlign.center),
          );
        }
        if (state is InBodyLoaded) {
          if (state.records.isEmpty) return _EmptyState();
          return ListView.separated(
            padding: EdgeInsets.all(16.w),
            itemCount: state.records.length,
            separatorBuilder: (_, __) => vGap(12),
            itemBuilder: (context, i) =>
                _InBodyCard(record: state.records[i]),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.monitor_weight_outlined,
                size: 80.r, color: AppColors.grey),
            vGap(16),
            Text(
              'No InBody records yet.',
              style: AppTextStyles.font16WhiteBold,
              textAlign: TextAlign.center,
            ),
            vGap(8),
            Text(
              'Add your first scan to track your progress.',
              style: AppTextStyles.font14GreyRegular,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _InBodyCard extends StatelessWidget {
  final InBodyModel record;
  const _InBodyCard({required this.record});

  Color _scoreColor(double? score) {
    if (score == null) return AppColors.grey;
    if (score >= 80) return AppColors.emerald;
    if (score >= 60) return const Color(0xFFFFD700);
    return AppColors.red;
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = record.recordedAt != null
        ? DateFormat('MMM d, yyyy').format(record.recordedAt!)
        : 'Unknown date';

    return Container(
      decoration: AppDecorations.containerDecoration,
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(dateStr, style: AppTextStyles.font14GreyRegular),
              if (record.inbodyScore != null)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color:
                        _scoreColor(record.inbodyScore).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: _scoreColor(record.inbodyScore)),
                  ),
                  child: Text(
                    'Score: ${record.inbodyScore!.toStringAsFixed(1)}',
                    style: AppTextStyles.font14GreyRegular.copyWith(
                        color: _scoreColor(record.inbodyScore),
                        fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          vGap(12),
          // Key metrics row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MetricChip(
                  label: 'Weight',
                  value: record.weight != null
                      ? '${record.weight!.toStringAsFixed(1)} kg'
                      : '--'),
              _MetricChip(
                  label: 'Body Fat',
                  value: record.bodyFatPct != null
                      ? '${record.bodyFatPct!.toStringAsFixed(1)}%'
                      : '--'),
              _MetricChip(
                  label: 'Muscle',
                  value: record.muscleMass != null
                      ? '${record.muscleMass!.toStringAsFixed(1)} kg'
                      : '--'),
              if (record.bmi != null)
                _MetricChip(
                    label: 'BMI',
                    value: record.bmi!.toStringAsFixed(1)),
            ],
          ),
          vGap(12),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.teal),
                    foregroundColor: AppColors.teal,
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r)),
                  ),
                  icon: const Icon(Icons.send_outlined, size: 16),
                  label: Text('Send to Coach',
                      style: AppTextStyles.font14GreyRegular
                          .copyWith(color: AppColors.teal, fontSize: 12.sp)),
                  onPressed: () => _sendToCoach(context, record),
                ),
              ),
              hGap(8),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.blue),
                    foregroundColor: AppColors.blue,
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r)),
                  ),
                  icon: const Icon(Icons.psychology_outlined, size: 16),
                  label: Text('Attach to AI',
                      style: AppTextStyles.font14GreyRegular
                          .copyWith(color: AppColors.blue, fontSize: 12.sp)),
                  onPressed: () => _attachToAI(context, record),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _sendToCoach(BuildContext context, InBodyModel r) async {
    final dateStr = r.recordedAt != null
        ? DateFormat('MMM d, yyyy').format(r.recordedAt!)
        : 'Unknown date';

    final lines = <String>[
      'InBody Results — $dateStr',
      if (r.weight != null) 'Weight: ${r.weight} kg',
      if (r.bodyFatPct != null) 'Body Fat: ${r.bodyFatPct}%',
      if (r.muscleMass != null) 'Muscle Mass: ${r.muscleMass} kg',
      if (r.bmi != null) 'BMI: ${r.bmi}',
      if (r.bmr != null) 'BMR: ${r.bmr} kcal',
      if (r.visceralFat != null) 'Visceral Fat: ${r.visceralFat}',
      if (r.inbodyScore != null) 'InBody Score: ${r.inbodyScore}/100',
      if (r.fatMass != null) 'Fat Mass: ${r.fatMass} kg',
      if (r.fatFreeMass != null) 'Fat-Free Mass: ${r.fatFreeMass} kg',
      if (r.notes != null && r.notes!.isNotEmpty) 'Notes: ${r.notes}',
    ];

    try {
      await MemberRepository.sendMessageToCoach(lines.join('\n'));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('InBody results sent to coach!'),
            backgroundColor: AppColors.emerald,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r)),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to send to coach.'),
            backgroundColor: AppColors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r)),
          ),
        );
      }
    }
  }

  void _attachToAI(BuildContext context, InBodyModel r) {
    _showAiQuestionDialog(context, r);
  }

  void _showAiQuestionDialog(BuildContext context, InBodyModel r) {
    final ctrl = TextEditingController(
      text: 'Based on my InBody results, create a personalized workout and nutrition plan for me.',
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.secondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            Icon(Icons.psychology_outlined, color: AppColors.blue, size: 22.sp),
            hGap(8),
            Text('Ask AI Coach', style: AppTextStyles.font16WhiteBold),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your InBody data will be attached automatically.',
              style: AppTextStyles.font14GreyRegular.copyWith(fontSize: 12.sp),
            ),
            vGap(12),
            TextField(
              controller: ctrl,
              maxLines: 3,
              style: AppTextStyles.font14WhiteRegular,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.primary,
                hintText: 'Type your question...',
                hintStyle: AppTextStyles.font14GreyRegular,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: const BorderSide(color: AppColors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: const BorderSide(color: AppColors.blue),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: const BorderSide(color: AppColors.grey),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: AppTextStyles.font14GreyRegular),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r)),
            ),
            onPressed: () async {
              final question = ctrl.text.trim();
              Navigator.pop(ctx);
              if (question.isEmpty) return;
              _sendToAiWithInBody(context, r, question);
            },
            child: Text('Ask', style: AppTextStyles.font14WhiteRegular),
          ),
        ],
      ),
    );
  }

  Future<void> _sendToAiWithInBody(
      BuildContext context, InBodyModel r, String question) async {
    if (!await AiConsent.ensure(context)) return;
    if (!context.mounted) return;

    // Show loading
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [
            const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.white)),
            hGap(12),
            Text('Getting AI response...', style: AppTextStyles.font14GreyRegular.copyWith(color: AppColors.white)),
          ]),
          duration: const Duration(seconds: 30),
          backgroundColor: AppColors.secondary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    try {
      final reply = await MemberRepository.getInBodyInsight(
        question,
        inBodyRecordId: int.tryParse(r.id ?? ''),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        _showAiResponseDialog(context, reply);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('AI error: ${e.toString()}'),
            backgroundColor: AppColors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showAiResponseDialog(BuildContext context, String reply) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.secondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            Image.asset('assets/images/FitQuad.png', width: 24.r, height: 24.r,
                errorBuilder: (_, __, ___) =>
                    Icon(Icons.smart_toy_outlined, color: AppColors.teal, size: 22.sp)),
            hGap(8),
            Text('AI Coach', style: AppTextStyles.font16WhiteBold),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(reply, style: AppTextStyles.font14GreyRegular.copyWith(height: 1.5)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: AppTextStyles.font14GreyRegular.copyWith(color: AppColors.teal)),
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;

  const _MetricChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: AppTextStyles.font16WhiteBold.copyWith(fontSize: 14.sp)),
        vGap(2),
        Text(label,
            style:
                AppTextStyles.font14GreyRegular.copyWith(fontSize: 11.sp)),
      ],
    );
  }
}
