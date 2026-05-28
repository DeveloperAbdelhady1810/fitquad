import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/services/api_client.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';
import 'package:gym_app/features/coach/home/manager/coach_cubit.dart';
import 'package:gym_app/features/member/data/models/member_model.dart';

Future<void> showAddSessionDialog(BuildContext context) async {
  if (!context.mounted) return;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: context.read<CoachCubit>(),
      child: Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: const _AddSessionSheet(),
      ),
    ),
  );
}

class _AddSessionSheet extends StatefulWidget {
  const _AddSessionSheet();

  @override
  State<_AddSessionSheet> createState() => _AddSessionSheetState();
}

class _AddSessionSheetState extends State<_AddSessionSheet> {
  MemberModel? _member;
  DateTime? _date;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String _type     = 'personal_training';
  String _location = '';
  String _notes    = '';
  bool _sending = false;
  String? _error;

  final _typeOptions = [
    ('personal_training', 'Personal Training'),
    ('group', 'Group Session'),
    ('online', 'Online'),
  ];

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _pickTime(bool isStart) async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (t != null) {
      setState(() => isStart ? _startTime = t : _endTime = t);
    }
  }

  Future<void> _save() async {
    if (_member == null) {
      setState(() => _error = 'Please select a member');
      return;
    }
    if (_date == null || _startTime == null || _endTime == null) {
      setState(() => _error = 'Please set date and times');
      return;
    }

    final start = DateTime(_date!.year, _date!.month, _date!.day,
        _startTime!.hour, _startTime!.minute);
    final end = DateTime(_date!.year, _date!.month, _date!.day,
        _endTime!.hour, _endTime!.minute);

    if (!end.isAfter(start)) {
      setState(() => _error = 'End time must be after start time');
      return;
    }

    setState(() {
      _sending = true;
      _error = null;
    });

    try {
      await ApiClient.post('/coach/sessions', {
        'member_id' : int.parse(_member!.id ?? '0'),
        'start_time': start.toIso8601String(),
        'end_time'  : end.toIso8601String(),
        'type'      : _type,
        if (_location.isNotEmpty) 'location': _location,
        if (_notes.isNotEmpty) 'notes': _notes,
      });

      if (mounted) {
        Navigator.pop(context);
        // Reload sessions
        context.read<CoachCubit>().getCoachSessions('1');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Session with ${_member!.name} scheduled! ✅'),
          backgroundColor: AppColors.emerald,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _sending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      padding: EdgeInsets.all(20.r),
      child: BlocBuilder<CoachCubit, CoachState>(
        builder: (context, state) {
          final members = state is CoachesLoaded ? state.allMembers : <MemberModel>[];
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.event_available_outlined,
                      color: AppColors.teal, size: 20.r),
                  hGap(10),
                  Text('Schedule Session',
                      style: AppTextStyles.font16WhiteBold),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: AppColors.grey, size: 20.r),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              vGap(16),

              // Member selector
              Text('Member', style: AppTextStyles.font14GreyRegular
                  .copyWith(color: AppColors.teal, fontSize: 11.sp, fontWeight: FontWeight.w600)),
              vGap(6),
              DropdownButtonFormField<MemberModel>(
                value: _member,
                dropdownColor: AppColors.secondary,
                style: AppTextStyles.font14WhiteRegular,
                hint: Text('Select member',
                    style: AppTextStyles.font14GreyRegular),
                decoration: _inputDec(),
                items: members
                    .map((m) => DropdownMenuItem(
                        value: m,
                        child: Text(m.name ?? 'Member')))
                    .toList(),
                onChanged: (m) => setState(() => _member = m),
              ),
              vGap(12),

              // Type selector
              Text('Session Type', style: AppTextStyles.font14GreyRegular
                  .copyWith(color: AppColors.teal, fontSize: 11.sp, fontWeight: FontWeight.w600)),
              vGap(6),
              DropdownButtonFormField<String>(
                value: _type,
                dropdownColor: AppColors.secondary,
                style: AppTextStyles.font14WhiteRegular,
                decoration: _inputDec(),
                items: _typeOptions
                    .map((t) =>
                        DropdownMenuItem(value: t.$1, child: Text(t.$2)))
                    .toList(),
                onChanged: (v) { if (v != null) setState(() => _type = v); },
              ),
              vGap(12),

              // Date + times
              Row(
                children: [
                  Expanded(
                    child: _TapField(
                      label: 'Date',
                      value: _date == null
                          ? null
                          : '${_date!.day}/${_date!.month}/${_date!.year}',
                      hint: 'Select date',
                      icon: Icons.calendar_today_outlined,
                      onTap: _pickDate,
                    ),
                  ),
                  hGap(10),
                  Expanded(
                    child: _TapField(
                      label: 'Start',
                      value: _startTime?.format(context),
                      hint: 'Start time',
                      icon: Icons.access_time_outlined,
                      onTap: () => _pickTime(true),
                    ),
                  ),
                  hGap(10),
                  Expanded(
                    child: _TapField(
                      label: 'End',
                      value: _endTime?.format(context),
                      hint: 'End time',
                      icon: Icons.timer_outlined,
                      onTap: () => _pickTime(false),
                    ),
                  ),
                ],
              ),
              vGap(12),

              // Location (optional)
              TextField(
                style: AppTextStyles.font14WhiteRegular.copyWith(fontSize: 13.sp),
                onChanged: (v) => _location = v,
                decoration: _inputDec().copyWith(
                  hintText: 'Location (optional)',
                  hintStyle: AppTextStyles.font14GreyRegular,
                ),
              ),
              vGap(12),

              // Notes (optional)
              TextField(
                style: AppTextStyles.font14WhiteRegular.copyWith(fontSize: 13.sp),
                maxLines: 2,
                onChanged: (v) => _notes = v,
                decoration: _inputDec().copyWith(
                  hintText: 'Notes (optional)',
                  hintStyle: AppTextStyles.font14GreyRegular,
                ),
              ),

              if (_error != null) ...[
                vGap(8),
                Text(_error!,
                    style: TextStyle(color: AppColors.red, fontSize: 12.sp)),
              ],

              vGap(16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _sending ? null : _save,
                  icon: _sending
                      ? SizedBox(
                          width: 16.r,
                          height: 16.r,
                          child: const CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Icon(Icons.check_circle_outline, size: 18.r),
                  label: Text(_sending ? 'Scheduling…' : 'Schedule Session'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                    padding: EdgeInsets.symmetric(vertical: 13.h),
                    textStyle: AppTextStyles.font14WhiteRegular
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              vGap(8),
            ],
          );
        },
      ),
    );
  }

  InputDecoration _inputDec() => InputDecoration(
        filled: true,
        fillColor: AppColors.primary,
        contentPadding:
            EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide.none),
        isDense: true,
      );
}

class _TapField extends StatelessWidget {
  final String label;
  final String? value;
  final String hint;
  final IconData icon;
  final VoidCallback onTap;

  const _TapField({
    required this.label,
    required this.value,
    required this.hint,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTextStyles.font14GreyRegular
                  .copyWith(fontSize: 10.sp, color: AppColors.teal)),
          vGap(4),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.grey, size: 14.r),
                hGap(4),
                Expanded(
                  child: Text(
                    value ?? hint,
                    style: AppTextStyles.font14GreyRegular.copyWith(
                        color: value != null ? Colors.white : AppColors.grey,
                        fontSize: 11.sp),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
