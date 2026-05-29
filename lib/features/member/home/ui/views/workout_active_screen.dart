import 'dart:async';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/helpers/spacing.dart';
import '../../../../../core/services/health_service.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

/// Full-screen active workout session.
/// Pass [exercises] (from the workout plan) and [planTitle].
class WorkoutActiveScreen extends StatefulWidget {
  const WorkoutActiveScreen({
    super.key,
    required this.exercises,
    required this.planTitle,
  });

  static const String routeName = '/workout-active';

  final List<Map<String, dynamic>> exercises;
  final String planTitle;

  @override
  State<WorkoutActiveScreen> createState() => _WorkoutActiveScreenState();
}

class _WorkoutActiveScreenState extends State<WorkoutActiveScreen> {
  // ── Exercise state ────────────────────────────────────────────
  int _exerciseIndex = 0;
  int _currentSet    = 1;
  bool _resting      = false;
  int _restSeconds   = 60;
  Timer? _restTimer;

  // ── Elapsed timer ─────────────────────────────────────────────
  int _elapsedSeconds = 0;
  Timer? _elapsedTimer;

  // ── Completion ────────────────────────────────────────────────
  bool _finished = false;
  late ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 4));
    _startElapsed();
  }

  // ── Helpers ───────────────────────────────────────────────────
  bool get _hasExercises => widget.exercises.isNotEmpty;
  Map<String, dynamic> get _ex => widget.exercises[_exerciseIndex];
  // sets/reps may be top-level (manually built plan) or in pivot (DB loaded plan)
  int get _totalSets {
    final ex = _ex;
    final v = ex['sets'] ?? (ex['pivot'] as Map?)?['sets'];
    return ((v as num?)?.toInt() ?? 3).clamp(1, 99);
  }
  int get _reps {
    final ex = _ex;
    final v = ex['reps'] ?? (ex['pivot'] as Map?)?['reps'];
    return ((v as num?)?.toInt() ?? 10).clamp(1, 999);
  }
  String get _exName      => _ex['name'] as String? ?? _ex['exercise']?['name'] as String? ?? 'Exercise';
  String get _muscleGroup => _ex['muscle_group'] as String? ?? _ex['exercise']?['muscle_group'] as String? ?? '';

  IconData get _muscleIcon {
    switch (_muscleGroup.toLowerCase()) {
      case 'chest':    return Icons.fitness_center;
      case 'back':     return Icons.airline_seat_flat;
      case 'legs':     return Icons.directions_run;
      case 'shoulder': return Icons.accessibility_new;
      case 'biceps':
      case 'triceps':  return Icons.sports_gymnastics;
      case 'abs':      return Icons.crop_free;
      case 'cardio':   return Icons.favorite;
      default:         return Icons.sports_gymnastics;
    }
  }

  String get _elapsed {
    final m = _elapsedSeconds ~/ 60;
    final s = _elapsedSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get _restDisplay {
    final m = _restSeconds ~/ 60;
    final s = _restSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  int get _estimatedCalories => ((_elapsedSeconds / 60) * 7).round();

  // ── Timer methods ─────────────────────────────────────────────
  void _startElapsed() {
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && !_resting) setState(() => _elapsedSeconds++);
    });
  }

  void _startRest() {
    setState(() {
      _resting     = true;
      _restSeconds = 60;
    });
    _restTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      if (_restSeconds <= 0) {
        t.cancel();
        setState(() => _resting = false);
      } else {
        setState(() => _restSeconds--);
      }
    });
  }

  void _skipRest() {
    _restTimer?.cancel();
    setState(() => _resting = false);
  }

  // ── Set / exercise progression ────────────────────────────────
  void _setDone() {
    if (_currentSet < _totalSets) {
      _startRest();
      setState(() => _currentSet++);
    } else {
      _nextExercise();
    }
  }

  void _nextExercise() {
    if (_exerciseIndex < widget.exercises.length - 1) {
      setState(() {
        _exerciseIndex++;
        _currentSet = 1;
        _resting    = false;
      });
      _restTimer?.cancel();
    } else {
      _complete();
    }
  }

  void _prevExercise() {
    if (_exerciseIndex > 0) {
      setState(() {
        _exerciseIndex--;
        _currentSet = 1;
        _resting    = false;
      });
      _restTimer?.cancel();
    }
  }

  void _complete() {
    _elapsedTimer?.cancel();
    _restTimer?.cancel();
    setState(() => _finished = true);
    _confetti.play();

    // Log to health
    HealthService.writeWorkout(
      calories: _estimatedCalories,
      duration: Duration(seconds: _elapsedSeconds),
      start: DateTime.now().subtract(Duration(seconds: _elapsedSeconds)),
    );
  }

  @override
  void dispose() {
    _elapsedTimer?.cancel();
    _restTimer?.cancel();
    _confetti.dispose();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (!_hasExercises) {
      return Scaffold(
        backgroundColor: AppColors.primary,
        appBar: AppBar(
          backgroundColor: AppColors.secondary,
          foregroundColor: Colors.white,
          title: Text(widget.planTitle,
              style: AppTextStyles.font14WhiteRegular),
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(32.r),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.fitness_center_outlined,
                    color: AppColors.grey, size: 56.r),
                vGap(16),
                Text('No exercises for today',
                    style: AppTextStyles.font16WhiteBold,
                    textAlign: TextAlign.center),
                vGap(8),
                Text(
                  'Your coach hasn\'t assigned exercises for this day yet, '
                  'or today is a rest day.',
                  style: AppTextStyles.font14GreyRegular,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_finished) return _buildCompletionScreen();

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(20.r),
              child: Column(
                children: [
                  _buildHeader(),
                  vGap(20),
                  Expanded(child: _buildExerciseCard()),
                  vGap(20),
                  _buildControls(),
                ],
              ),
            ),
            // Rest overlay
            if (_resting) _buildRestOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => _confirmExit(),
          child: Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child:
                Icon(Icons.close, color: AppColors.grey, size: 20.r),
          ),
        ),
        Column(
          children: [
            Text(
              _elapsed,
              style: AppTextStyles.font16WhiteBold.copyWith(
                fontSize: 22.sp,
                color: AppColors.teal,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            Text(
              widget.planTitle,
              style: AppTextStyles.font14GreyRegular.copyWith(fontSize: 11.sp),
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: AppColors.teal.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            '${_exerciseIndex + 1}/${widget.exercises.length}',
            style: AppTextStyles.font14GreyRegular
                .copyWith(color: AppColors.teal, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.teal.withValues(alpha: 0.12),
            AppColors.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.teal.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Muscle icon
          Container(
            width: 80.r,
            height: 80.r,
            decoration: BoxDecoration(
              color: AppColors.teal.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child:
                Icon(_muscleIcon, color: AppColors.teal, size: 40.r),
          ),
          vGap(20),

          // Exercise name
          Text(
            _exName,
            style: AppTextStyles.font16WhiteBold.copyWith(fontSize: 24.sp),
            textAlign: TextAlign.center,
          ),
          vGap(4),
          if (_muscleGroup.isNotEmpty)
            Text(
              _muscleGroup.toUpperCase(),
              style: AppTextStyles.font14GreyRegular.copyWith(
                fontSize: 11.sp,
                letterSpacing: 1.5,
                color: AppColors.teal,
              ),
            ),
          vGap(24),

          // Set counter
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _totalSets,
              (i) => Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < _currentSet - 1
                      ? AppColors.teal
                      : i == _currentSet - 1
                          ? AppColors.teal.withValues(alpha: 0.3)
                          : Colors.white10,
                  border: Border.all(
                    color: i == _currentSet - 1
                        ? AppColors.teal
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${i + 1}',
                    style: AppTextStyles.font14WhiteRegular.copyWith(
                      fontWeight: FontWeight.bold,
                      color: i < _currentSet
                          ? Colors.white
                          : AppColors.grey,
                    ),
                  ),
                ),
              ),
            ),
          ),
          vGap(12),
          Text(
            'Set $_currentSet of $_totalSets',
            style: AppTextStyles.font14GreyRegular,
          ),
          vGap(8),
          Text(
            '$_reps reps',
            style: AppTextStyles.font16WhiteBold.copyWith(
              color: AppColors.emerald,
              fontSize: 20.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Column(
      children: [
        // Main "Set Done" button
        SizedBox(
          width: double.infinity,
          height: 56.h,
          child: ElevatedButton(
            onPressed: _setDone,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.teal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            child: Text(
              _currentSet == _totalSets &&
                      _exerciseIndex == widget.exercises.length - 1
                  ? 'FINISH WORKOUT 🏆'
                  : _currentSet == _totalSets
                      ? 'NEXT EXERCISE →'
                      : 'SET DONE ✓',
              style: AppTextStyles.font16WhiteBold
                  .copyWith(letterSpacing: 1.2),
            ),
          ),
        ),
        vGap(12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed:
                    _exerciseIndex > 0 ? _prevExercise : null,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.grey,
                  side: const BorderSide(color: Colors.white24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                ),
                child: Text(
                  '← Prev',
                  style: AppTextStyles.font14GreyRegular,
                ),
              ),
            ),
            hGap(12),
            Expanded(
              child: OutlinedButton(
                onPressed: _nextExercise,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.grey,
                  side: const BorderSide(color: Colors.white24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                ),
                child: Text(
                  'Skip →',
                  style: AppTextStyles.font14GreyRegular,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRestOverlay() {
    final progress = _restSeconds / 60;
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.75),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '💤 Rest',
              style: AppTextStyles.font16WhiteBold.copyWith(fontSize: 20.sp),
            ),
            vGap(20),
            SizedBox(
              width: 160.r,
              height: 160.r,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8,
                    backgroundColor: Colors.white12,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppColors.teal),
                  ),
                  Text(
                    _restDisplay,
                    style: AppTextStyles.font16WhiteBold.copyWith(
                      fontSize: 32.sp,
                      color: AppColors.teal,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
            vGap(30),
            TextButton(
              onPressed: _skipRest,
              child: Text(
                'Skip Rest',
                style: AppTextStyles.font14GreyRegular
                    .copyWith(color: AppColors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionScreen() {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 40,
              colors: const [
                AppColors.teal, AppColors.emerald, Colors.amber, Colors.orange,
              ],
            ),
            Padding(
              padding: EdgeInsets.all(28.r),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🏆', style: TextStyle(fontSize: 72.sp)),
                  vGap(16),
                  Text(
                    'Workout Complete!',
                    style: AppTextStyles.font16WhiteBold.copyWith(
                      fontSize: 26.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  vGap(8),
                  Text(
                    'Amazing work — your body thanks you.',
                    style: AppTextStyles.font14GreyRegular,
                    textAlign: TextAlign.center,
                  ),
                  vGap(32),
                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _CompletionStat(
                          icon: '⏱',
                          value: _elapsed,
                          label: 'Duration'),
                      _CompletionStat(
                          icon: '🏋️',
                          value: '${widget.exercises.length}',
                          label: 'Exercises'),
                      _CompletionStat(
                          icon: '🔥',
                          value: '$_estimatedCalories',
                          label: 'kcal'),
                    ],
                  ),
                  vGap(28),
                  // Post-workout upsell
                  Container(
                    padding: EdgeInsets.all(14.r),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                          color: AppColors.emerald.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Text('💪', style: TextStyle(fontSize: 28.sp)),
                        hGap(12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Fuel Your Recovery',
                                style: AppTextStyles.font14WhiteRegular
                                    .copyWith(fontWeight: FontWeight.w600),
                              ),
                              vGap(2),
                              Text(
                                'Whey Protein 20% off today — shop now',
                                style: AppTextStyles.font14GreyRegular
                                    .copyWith(
                                        fontSize: 11.sp,
                                        color: AppColors.emerald),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios,
                            color: AppColors.emerald, size: 14.r),
                      ],
                    ),
                  ),
                  vGap(20),
                  SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: ElevatedButton(
                      onPressed: () => context.pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: Text(
                        'BACK TO HOME',
                        style: AppTextStyles.font16WhiteBold
                            .copyWith(letterSpacing: 1.2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmExit() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.secondary,
        title: Text('Quit workout?',
            style: AppTextStyles.font16WhiteBold),
        content: Text(
          'Your progress will not be saved.',
          style: AppTextStyles.font14GreyRegular,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Keep Going',
                style: AppTextStyles.font14GreyRegular
                    .copyWith(color: AppColors.teal)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.pop();
            },
            child: Text('Quit',
                style: AppTextStyles.font14GreyRegular
                    .copyWith(color: AppColors.red)),
          ),
        ],
      ),
    );
  }
}

class _CompletionStat extends StatelessWidget {
  final String icon;
  final String value;
  final String label;

  const _CompletionStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: TextStyle(fontSize: 28.sp)),
        vGap(6),
        Text(
          value,
          style: AppTextStyles.font16WhiteBold
              .copyWith(color: AppColors.teal, fontSize: 20.sp),
        ),
        Text(label, style: AppTextStyles.font14GreyRegular),
      ],
    );
  }
}
