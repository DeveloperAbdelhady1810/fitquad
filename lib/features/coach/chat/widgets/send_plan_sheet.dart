import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/services/api_client.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';

class SendPlanSheet extends StatefulWidget {
  final int memberUserId;
  final String memberName;
  final VoidCallback onSent;
  final int initialTab;

  const SendPlanSheet({
    super.key,
    required this.memberUserId,
    required this.memberName,
    required this.onSent,
    this.initialTab = 0,
  });

  @override
  State<SendPlanSheet> createState() => _SendPlanSheetState();
}

class _SendPlanSheetState extends State<SendPlanSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this,
        initialIndex: widget.initialTab);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
            child: Row(
              children: [
                Icon(Icons.assignment_outlined,
                    color: AppColors.teal, size: 20.r),
                hGap(10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Send a Plan',
                          style: AppTextStyles.font16WhiteBold),
                      Text('To ${widget.memberName}',
                          style: AppTextStyles.font14GreyRegular
                              .copyWith(fontSize: 11.sp,
                                  color: AppColors.teal)),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: AppColors.grey, size: 20.r),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          TabBar(
            controller: _tab,
            indicatorColor: AppColors.teal,
            labelColor: AppColors.teal,
            unselectedLabelColor: AppColors.grey,
            labelStyle: AppTextStyles.font14WhiteRegular
                .copyWith(fontWeight: FontWeight.w600, fontSize: 13.sp),
            tabs: const [
              Tab(icon: Icon(Icons.fitness_center_outlined), text: 'Workout'),
              Tab(icon: Icon(Icons.restaurant_outlined), text: 'Nutrition'),
            ],
          ),
          SizedBox(
            height: 460.h,
            child: TabBarView(
              controller: _tab,
              children: [
                _WorkoutPlanForm(
                  memberUserId: widget.memberUserId,
                  onSent: () {
                    Navigator.pop(context);
                    widget.onSent();
                  },
                ),
                _NutritionPlanForm(
                  memberUserId: widget.memberUserId,
                  onSent: () {
                    Navigator.pop(context);
                    widget.onSent();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Workout plan form ─────────────────────────────────────────────────────────

class _WorkoutPlanForm extends StatefulWidget {
  final int memberUserId;
  final VoidCallback onSent;

  const _WorkoutPlanForm({required this.memberUserId, required this.onSent});

  @override
  State<_WorkoutPlanForm> createState() => _WorkoutPlanFormState();
}

class _WorkoutPlanFormState extends State<_WorkoutPlanForm> {
  final _title = TextEditingController();
  final _desc  = TextEditingController();
  final List<Map<String, dynamic>> _days = [];
  bool _sending = false;

  void _addDay() {
    setState(() => _days.add({
          'day_name': 'Day ${_days.length + 1}',
          'exercises': <Map<String, dynamic>>[],
        }));
  }

  void _addExercise(int dayIdx) {
    setState(() {
      (_days[dayIdx]['exercises'] as List).add({
        'name': '',
        'sets': 3,
        'reps': 12,
        'rest_seconds': 60,
      });
    });
  }

  Future<void> _send() async {
    if (_title.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter a plan title'),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    if (_days.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Add at least one day'),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    setState(() => _sending = true);
    try {
      await ApiClient.post('/coach/messages/send-plan', {
        'receiver_id': widget.memberUserId,
        'type'       : 'workout_plan',
        'title'      : _title.text.trim(),
        'description': _desc.text.trim(),
        'payload'    : {'days': _days},
      });
      widget.onSent();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed: $e'),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Field(ctrl: _title, hint: 'Plan title (e.g. 4-Week Strength)'),
          vGap(10),
          _Field(ctrl: _desc, hint: 'Description (optional)', maxLines: 2),
          vGap(14),
          Row(
            children: [
              Text('Training Days',
                  style: AppTextStyles.font14WhiteRegular
                      .copyWith(fontWeight: FontWeight.w600)),
              const Spacer(),
              TextButton.icon(
                onPressed: _addDay,
                icon: Icon(Icons.add, color: AppColors.teal, size: 16.r),
                label: Text('Add Day',
                    style: AppTextStyles.font14GreyRegular
                        .copyWith(color: AppColors.teal, fontSize: 12.sp)),
              ),
            ],
          ),
          ..._days.asMap().entries.map((e) => _DayTile(
                day: e.value,
                index: e.key,
                onAddExercise: () => _addExercise(e.key),
                onDayNameChange: (v) =>
                    setState(() => _days[e.key]['day_name'] = v),
                onExerciseChange: (exIdx, field, val) => setState(() {
                  (_days[e.key]['exercises'] as List)[exIdx][field] = val;
                }),
                onRemove: () => setState(() => _days.removeAt(e.key)),
              )),
          vGap(16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _sending ? null : _send,
              icon: _sending
                  ? SizedBox(
                      width: 16.r,
                      height: 16.r,
                      child: const CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Icon(Icons.send_outlined, size: 16.r),
              label: Text(_sending ? 'Sending…' : 'Send Workout Plan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
                padding: EdgeInsets.symmetric(vertical: 13.h),
                textStyle: AppTextStyles.font14WhiteRegular
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayTile extends StatelessWidget {
  final Map<String, dynamic> day;
  final int index;
  final VoidCallback onAddExercise;
  final ValueChanged<String> onDayNameChange;
  final Function(int, String, dynamic) onExerciseChange;
  final VoidCallback onRemove;

  const _DayTile({
    required this.day,
    required this.index,
    required this.onAddExercise,
    required this.onDayNameChange,
    required this.onExerciseChange,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final exercises = (day['exercises'] as List).cast<Map>();
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: day['day_name'])
                      ..selection = TextSelection.collapsed(
                          offset: (day['day_name'] as String).length),
                    style: AppTextStyles.font14WhiteRegular
                        .copyWith(fontWeight: FontWeight.w600, fontSize: 13.sp),
                    decoration: const InputDecoration(
                        border: InputBorder.none, isDense: true),
                    onChanged: onDayNameChange,
                  ),
                ),
                TextButton(
                  onPressed: onAddExercise,
                  child: Text('+ Exercise',
                      style: AppTextStyles.font14GreyRegular.copyWith(
                          color: AppColors.teal, fontSize: 11.sp)),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline,
                      color: AppColors.red, size: 16.r),
                  onPressed: onRemove,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          ...exercises.asMap().entries.map((e) => _ExerciseRow(
                ex: e.value,
                onChange: (field, val) => onExerciseChange(e.key, field, val),
              )),
          if (exercises.isEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Text('No exercises yet',
                  style: AppTextStyles.font14GreyRegular
                      .copyWith(fontSize: 11.sp)),
            ),
        ],
      ),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  final Map ex;
  final Function(String, dynamic) onChange;

  const _ExerciseRow({required this.ex, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 8.h),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              style: AppTextStyles.font14GreyRegular.copyWith(fontSize: 12.sp),
              decoration: InputDecoration(
                hintText: 'Exercise name',
                hintStyle: AppTextStyles.font14GreyRegular
                    .copyWith(fontSize: 11.sp),
                filled: true,
                fillColor: AppColors.secondary,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide.none),
                isDense: true,
              ),
              onChanged: (v) => onChange('name', v),
            ),
          ),
          hGap(6),
          _SmallNum('Sets', ex['sets'], (v) => onChange('sets', v)),
          hGap(6),
          _SmallNum('Reps', ex['reps'], (v) => onChange('reps', v)),
        ],
      ),
    );
  }
}

class _SmallNum extends StatelessWidget {
  final String label;
  final dynamic value;
  final ValueChanged<int> onChange;

  const _SmallNum(this.label, this.value, this.onChange);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44.w,
      child: TextField(
        controller: TextEditingController(text: '$value'),
        style: AppTextStyles.font14GreyRegular.copyWith(fontSize: 12.sp),
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTextStyles.font14GreyRegular.copyWith(fontSize: 9.sp),
          filled: true,
          fillColor: AppColors.secondary,
          contentPadding: EdgeInsets.symmetric(vertical: 6.h),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide.none),
          isDense: true,
        ),
        onChanged: (v) => onChange(int.tryParse(v) ?? 0),
      ),
    );
  }
}

// ── Nutrition plan form ───────────────────────────────────────────────────────

class _NutritionPlanForm extends StatefulWidget {
  final int memberUserId;
  final VoidCallback onSent;

  const _NutritionPlanForm({required this.memberUserId, required this.onSent});

  @override
  State<_NutritionPlanForm> createState() => _NutritionPlanFormState();
}

class _NutritionPlanFormState extends State<_NutritionPlanForm> {
  final _title    = TextEditingController();
  final _calories = TextEditingController();
  final _protein  = TextEditingController();
  final _carbs    = TextEditingController();
  final _fat      = TextEditingController();
  final List<Map<String, dynamic>> _meals = [];
  bool _sending = false;

  final _timeOptions = ['breakfast', 'lunch', 'dinner', 'snacks', 'dessert'];

  void _addMeal() {
    setState(() => _meals.add({
          'name': 'Meal ${_meals.length + 1}',
          'time_of_day': 'breakfast',
          'foods': '',
        }));
  }

  Future<void> _send() async {
    if (_title.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter a plan title'),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    setState(() => _sending = true);
    try {
      await ApiClient.post('/coach/messages/send-plan', {
        'receiver_id': widget.memberUserId,
        'type'       : 'nutrition_plan',
        'title'      : _title.text.trim(),
        'description': '',
        'payload'    : {
          'daily_calories': double.tryParse(_calories.text) ?? 0,
          'protein_g'     : double.tryParse(_protein.text) ?? 0,
          'carbs_g'       : double.tryParse(_carbs.text) ?? 0,
          'fat_g'         : double.tryParse(_fat.text) ?? 0,
          'meals'         : _meals,
        },
      });
      widget.onSent();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed: $e'),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _calories.dispose();
    _protein.dispose();
    _carbs.dispose();
    _fat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Field(ctrl: _title, hint: 'Plan title (e.g. Weight Loss Plan)'),
          vGap(10),
          Row(
            children: [
              Expanded(child: _Field(ctrl: _calories, hint: 'Calories', keyboardType: TextInputType.number)),
              hGap(8),
              Expanded(child: _Field(ctrl: _protein, hint: 'Protein (g)', keyboardType: TextInputType.number)),
            ],
          ),
          vGap(8),
          Row(
            children: [
              Expanded(child: _Field(ctrl: _carbs, hint: 'Carbs (g)', keyboardType: TextInputType.number)),
              hGap(8),
              Expanded(child: _Field(ctrl: _fat, hint: 'Fat (g)', keyboardType: TextInputType.number)),
            ],
          ),
          vGap(14),
          Row(
            children: [
              Text('Meals',
                  style: AppTextStyles.font14WhiteRegular
                      .copyWith(fontWeight: FontWeight.w600)),
              const Spacer(),
              TextButton.icon(
                onPressed: _addMeal,
                icon: Icon(Icons.add, color: AppColors.emerald, size: 16.r),
                label: Text('Add Meal',
                    style: AppTextStyles.font14GreyRegular
                        .copyWith(color: AppColors.emerald, fontSize: 12.sp)),
              ),
            ],
          ),
          ..._meals.asMap().entries.map((e) => _MealTile(
                meal: e.value,
                timeOptions: _timeOptions,
                onNameChange: (v) => setState(() => _meals[e.key]['name'] = v),
                onTimeChange: (v) =>
                    setState(() => _meals[e.key]['time_of_day'] = v),
                onFoodsChange: (v) =>
                    setState(() => _meals[e.key]['foods'] = v),
                onRemove: () => setState(() => _meals.removeAt(e.key)),
              )),
          vGap(16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _sending ? null : _send,
              icon: _sending
                  ? SizedBox(
                      width: 16.r,
                      height: 16.r,
                      child: const CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Icon(Icons.send_outlined, size: 16.r),
              label: Text(_sending ? 'Sending…' : 'Send Nutrition Plan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emerald,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
                padding: EdgeInsets.symmetric(vertical: 13.h),
                textStyle: AppTextStyles.font14WhiteRegular
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MealTile extends StatelessWidget {
  final Map<String, dynamic> meal;
  final List<String> timeOptions;
  final ValueChanged<String> onNameChange;
  final ValueChanged<String> onTimeChange;
  final ValueChanged<String> onFoodsChange;
  final VoidCallback onRemove;

  const _MealTile({
    required this.meal,
    required this.timeOptions,
    required this.onNameChange,
    required this.onTimeChange,
    required this.onFoodsChange,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: meal['name'])
                    ..selection = TextSelection.collapsed(
                        offset: (meal['name'] as String).length),
                  style: AppTextStyles.font14WhiteRegular
                      .copyWith(fontWeight: FontWeight.w600, fontSize: 13.sp),
                  decoration: const InputDecoration(
                      border: InputBorder.none, isDense: true),
                  onChanged: onNameChange,
                ),
              ),
              DropdownButton<String>(
                value: meal['time_of_day'] as String,
                dropdownColor: AppColors.secondary,
                style: AppTextStyles.font14GreyRegular
                    .copyWith(fontSize: 11.sp, color: AppColors.teal),
                underline: const SizedBox(),
                items: timeOptions
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) { if (v != null) onTimeChange(v); },
              ),
              IconButton(
                icon: Icon(Icons.delete_outline,
                    color: AppColors.red, size: 16.r),
                onPressed: onRemove,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          vGap(6),
          TextField(
            style: AppTextStyles.font14GreyRegular.copyWith(fontSize: 12.sp),
            decoration: InputDecoration(
              hintText: 'Foods (e.g. Oats 50g, 2 Eggs, Banana)',
              hintStyle: AppTextStyles.font14GreyRegular
                  .copyWith(fontSize: 11.sp),
              filled: true,
              fillColor: AppColors.secondary,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide.none),
              isDense: true,
            ),
            maxLines: 2,
            onChanged: onFoodsChange,
          ),
        ],
      ),
    );
  }
}

// ── Shared field ──────────────────────────────────────────────────────────────

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final int maxLines;
  final TextInputType keyboardType;

  const _Field({
    required this.ctrl,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      style: AppTextStyles.font14WhiteRegular.copyWith(fontSize: 13.sp),
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.font14GreyRegular.copyWith(fontSize: 12.sp),
        filled: true,
        fillColor: AppColors.primary,
        contentPadding:
            EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide.none),
        isDense: true,
      ),
    );
  }
}
