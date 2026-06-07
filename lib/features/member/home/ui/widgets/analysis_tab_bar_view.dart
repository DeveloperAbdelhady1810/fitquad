import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';
import 'package:gym_app/features/member/home/ui/widgets/line_chart.dart';
import 'package:gym_app/features/member/inbody/models/inbody_model.dart';
import 'package:intl/intl.dart';

import '../../../../../core/helpers/app_decoration.dart';
import '../../../../../core/helpers/spacing.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../features/member/data/repositories/member_repository.dart';
import '../../manager/member_cubit.dart';
import '../../manager/member_state.dart';

class AnalysisTabBarView extends StatefulWidget {
  const AnalysisTabBarView({super.key});

  @override
  State<AnalysisTabBarView> createState() => _AnalysisTabBarViewState();
}

class _AnalysisTabBarViewState extends State<AnalysisTabBarView> {
  late Future<List<InBodyModel>> _recordsFuture;

  @override
  void initState() {
    super.initState();
    _recordsFuture = _fetchRecords();
  }

  Future<List<InBodyModel>> _fetchRecords() async {
    final raw = await MemberRepository.getInBodyRecords();
    return raw
        .map((e) => InBodyModel.fromJson(e as Map<String, dynamic>))
        .where((r) => r.weight != null && r.recordedAt != null)
        .toList()
      ..sort((a, b) => a.recordedAt!.compareTo(b.recordedAt!));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemberCubit, MemberState>(
      builder: (context, state) {
        if (state is MemberLoading) {
          return const Center(child: CircularProgressIndicator(color: AppColors.teal));
        }

        if (state is MemberLoaded) {
          return FutureBuilder<List<InBodyModel>>(
            future: _recordsFuture,
            builder: (context, snap) {
              final currentWeight = state.member.weight ?? 70.0;
              final records = snap.data ?? [];

              // Build chart spots from real InBody records
              // If fewer than 2, seed with current weight so chart is still visible
              List<FlSpot> spots;
              Map<double, String> labels;

              if (records.length >= 2) {
                final dateFormat = DateFormat('d/M');
                spots = records.asMap().entries.map((e) {
                  return FlSpot(e.key.toDouble(), e.value.weight!);
                }).toList();
                labels = {
                  for (var e in records.asMap().entries)
                    e.key.toDouble(): dateFormat.format(e.value.recordedAt!)
                };
              } else if (records.length == 1) {
                // One real point + projection
                final w = records.first.weight!;
                spots = [FlSpot(0, w), FlSpot(1, w)];
                labels = {0: DateFormat('d/M').format(records.first.recordedAt!), 1: 'Now'};
              } else {
                // No InBody data — show flat line at current weight
                final now = DateTime.now();
                spots = [FlSpot(0, currentWeight), FlSpot(1, currentWeight)];
                labels = {0: DateFormat('d/M').format(now.subtract(const Duration(days: 30))), 1: 'Now'};
              }

              final allY = spots.map((s) => s.y).toList();
              final minY = (allY.reduce((a, b) => a < b ? a : b) - 2).floorToDouble();
              final maxY = (allY.reduce((a, b) => a > b ? a : b) + 2).ceilToDouble();

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: AppDecorations.containerDecoration.copyWith(
                        border: Border(
                          top: BorderSide(color: AppColors.emerald, width: 7),
                        ),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: snap.connectionState == ConnectionState.waiting
                          ? const SizedBox(
                              height: 120,
                              child: Center(
                                child: CircularProgressIndicator(color: AppColors.teal),
                              ),
                            )
                          : LineChartWidget(
                              spots: spots,
                              minX: 0,
                              maxX: (spots.length - 1).toDouble(),
                              minY: minY,
                              maxY: maxY,
                              bottomTitles: labels,
                            ),
                    ),
                    vGap(10),
                    Container(
                      decoration: AppDecorations.containerDecoration,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.emerald.withValues(alpha: 0.3),
                          child: const Icon(Icons.calendar_month, color: AppColors.emerald),
                        ),
                        title: Text(
                          'Current: ${currentWeight.toStringAsFixed(1)} kg',
                          style: AppTextStyles.font16WhiteBold,
                        ),
                        subtitle: Text(
                          records.length >= 2
                              ? 'Based on ${records.length} InBody scans — keep logging to track progress.'
                              : records.length == 1
                                  ? 'Add more InBody scans to see your weight trend over time.'
                                  : 'No InBody scans yet. Add one from the InBody tab to track your progress.',
                          style: AppTextStyles.font14GreyRegular,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
