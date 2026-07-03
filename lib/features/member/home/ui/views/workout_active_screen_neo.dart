import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/services/api_client.dart';
import 'package:gym_app/core/services/health_service.dart';
import 'package:gym_app/core/theme/neo_theme.dart';
import 'package:gym_app/features/member/home/manager/member_cubit.dart';

class WorkoutActiveScreenNeo extends StatefulWidget {
  static const routeName = '/workout-active-neo';

  final List<Map<String, dynamic>> exercises;
  final String planTitle;

  const WorkoutActiveScreenNeo({
    super.key,
    required this.exercises,
    required this.planTitle,
  });

  @override
  State<WorkoutActiveScreenNeo> createState() => _WorkoutActiveScreenNeoState();
}

class _WorkoutActiveScreenNeoState extends State<WorkoutActiveScreenNeo>
    with TickerProviderStateMixin {
  int _exerciseIndex = 0;
  int _currentSet = 1;
  bool _resting = false;
  int _restSeconds = 60;
  Timer? _restTimer;
  int _elapsedSeconds = 0;
  Timer? _elapsedTimer;
  late AnimationController _pulse;
  late Animation<double> _pulseAnim;
  late AnimationController _blink;
  late Animation<double> _blinkAnim;
  late AnimationController _spin;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.6, end: 1.0).animate(_pulse);
    _blink = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))..repeat(reverse: true);
    _blinkAnim = Tween<double>(begin: 0, end: 1).animate(_blink);
    _spin = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
    _startElapsed();
  }

  bool get _hasExercises => widget.exercises.isNotEmpty;
  Map<String, dynamic> get _ex => widget.exercises[_exerciseIndex];

  int get _sets => ((_ex['sets'] ?? _ex['pivot']?['sets']) as num?)?.toInt() ?? 3;
  int get _reps => ((_ex['reps'] ?? _ex['pivot']?['reps']) as num?)?.toInt() ?? 10;
  int get _restSec => ((_ex['rest_seconds'] ?? _ex['pivot']?['rest_seconds']) as num?)?.toInt() ?? 60;
  String get _exName => _ex['name'] as String? ?? (_ex['exercise'] as Map?)?['name'] as String? ?? 'EXERCISE';

  void _startElapsed() {
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsedSeconds++);
    });
  }

  void _completeSet() {
    if (_currentSet < _sets) {
      setState(() { _currentSet++; _resting = true; _restSeconds = _restSec; });
      _restTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) { t.cancel(); return; }
        setState(() { _restSeconds--; });
        if (_restSeconds <= 0) { t.cancel(); setState(() => _resting = false); }
      });
    } else {
      _nextExercise();
    }
  }

  void _nextExercise() {
    _restTimer?.cancel();
    if (_exerciseIndex < widget.exercises.length - 1) {
      setState(() { _exerciseIndex++; _currentSet = 1; _resting = false; });
    } else {
      _finish();
    }
  }

  void _prevExercise() {
    _restTimer?.cancel();
    if (_exerciseIndex > 0) {
      setState(() { _exerciseIndex--; _currentSet = 1; _resting = false; });
    }
  }

  Future<void> _finish() async {
    _elapsedTimer?.cancel();
    _restTimer?.cancel();
    try {
      await context.read<MemberCubit>().markWorkoutDone('done');
      await ApiClient.post('/member/check-in', {});
      await HealthService.writeWorkout(
        calories: 0,
        duration: Duration(seconds: _elapsedSeconds),
        start: DateTime.now().subtract(Duration(seconds: _elapsedSeconds)),
      );
    } catch (_) {}
    if (mounted) Navigator.pop(context);
  }

  String _fmt(int s) => '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  void dispose() {
    _elapsedTimer?.cancel(); _restTimer?.cancel();
    _pulse.dispose(); _blink.dispose(); _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasExercises) {
      return Scaffold(
        backgroundColor: NeoColors.bg,
        body: Center(child: Text('NO EXERCISES', style: NeoTextStyles.headlineSm.copyWith(color: NeoColors.cyan))),
      );
    }

    return Scaffold(
      backgroundColor: NeoColors.bg,
      appBar: AppBar(
        backgroundColor: NeoColors.bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: NeoColors.cyan),
        title: Text(widget.planTitle.toUpperCase(), style: NeoTextStyles.headlineSm.copyWith(color: NeoColors.cyan)),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: Center(child: Text(_fmt(_elapsedSeconds),
                style: GoogleFonts.jetBrainsMono(fontSize: 14.sp, color: NeoColors.cyan))),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            children: [
              _resting ? _RestView() : _ExerciseView(),
              vGap(20),
              _Controls(),
              vGap(16),
              _FinishButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ExerciseView() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(children: [
            Container(width: 3.w, height: 20.h, color: NeoColors.cyan),
            hGap(8),
            Text('EXERCISE ${_exerciseIndex + 1}/${widget.exercises.length}', style: NeoTextStyles.labelCaps),
          ]),
          vGap(12),
          Row(children: [
            Expanded(child: Text(_exName.toUpperCase(), style: NeoTextStyles.headlineLg.copyWith(color: NeoColors.cyan))),
            AnimatedBuilder(
              animation: _blinkAnim,
              builder: (_, __) => Opacity(
                opacity: _blinkAnim.value,
                child: Text('|', style: NeoTextStyles.headlineLg.copyWith(color: NeoColors.cyan)),
              ),
            ),
          ]),
          vGap(20),
          Text('$_sets SETS / $_reps REPS', style: GoogleFonts.jetBrainsMono(
            fontSize: 28.sp, fontWeight: FontWeight.w700, color: NeoColors.lime,
            shadows: [Shadow(color: NeoColors.lime.withValues(alpha: 0.6), blurRadius: 10)],
          )),
          vGap(16),
          Row(
            children: List.generate(_sets, (i) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < _sets - 1 ? 6.w : 0),
                child: Container(
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: i < _currentSet ? NeoColors.lime : NeoColors.surfaceTop,
                    boxShadow: i < _currentSet
                        ? [BoxShadow(color: NeoColors.lime.withValues(alpha: 0.5), blurRadius: 6)]
                        : [],
                  ),
                ),
              ),
            )),
          ),
          vGap(24),
          GestureDetector(
            onTap: _completeSet,
            child: Container(
              width: double.infinity,
              height: 52.h,
              decoration: BoxDecoration(
                color: NeoColors.lime,
                boxShadow: [BoxShadow(color: NeoColors.lime.withValues(alpha: 0.4), blurRadius: 16)],
              ),
              child: Center(child: Text(
                _currentSet <= _sets ? 'COMPLETE SET $_currentSet' : 'NEXT EXERCISE',
                style: GoogleFonts.anton(fontSize: 16.sp, color: Colors.black),
              )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _RestView() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _spin,
                builder: (_, child) => Transform.rotate(
                  angle: _spin.value * 6.28318,
                  child: child,
                ),
                child: Container(
                  width: 180.r, height: 180.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: NeoColors.lime.withValues(alpha: 0.3),
                      width: 1,
                      strokeAlign: BorderSide.strokeAlignCenter,
                    ),
                  ),
                ),
              ),
              Column(children: [
                FadeTransition(
                  opacity: _pulseAnim,
                  child: Text('REST PERIOD', style: NeoTextStyles.labelCaps.copyWith(color: NeoColors.lime)),
                ),
                vGap(8),
                FadeTransition(
                  opacity: _pulseAnim,
                  child: Text(_fmt(_restSeconds), style: GoogleFonts.jetBrainsMono(
                    fontSize: 52.sp, fontWeight: FontWeight.w700, color: NeoColors.lime,
                    shadows: [Shadow(color: NeoColors.lime.withValues(alpha: 0.6), blurRadius: 20)],
                  )),
                ),
              ]),
            ],
          ),
          vGap(20),
          GestureDetector(
            onTap: () { _restTimer?.cancel(); setState(() => _resting = false); },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
              decoration: BoxDecoration(border: Border.all(color: NeoColors.lime)),
              child: Text('SKIP REST', style: NeoTextStyles.labelCaps.copyWith(color: NeoColors.lime)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _Controls() {
    return Row(
      children: [
        Expanded(child: _GlassButton(icon: Icons.skip_previous, onTap: _prevExercise, enabled: _exerciseIndex > 0)),
        hGap(12),
        Expanded(flex: 2, child: GestureDetector(
          onTap: _completeSet,
          child: Container(
            height: 52.h,
            decoration: BoxDecoration(
              color: NeoColors.cyan,
              boxShadow: [BoxShadow(color: NeoColors.cyan.withValues(alpha: 0.4), blurRadius: 16)],
            ),
            child: Center(child: Icon(Icons.play_arrow, color: Colors.black, size: 28.r)),
          ),
        )),
        hGap(12),
        Expanded(child: _GlassButton(icon: Icons.skip_next, onTap: _nextExercise, enabled: _exerciseIndex < widget.exercises.length - 1)),
      ],
    );
  }

  Widget _FinishButton() {
    return GestureDetector(
      onTap: _finish,
      child: Container(
        width: double.infinity,
        height: 48.h,
        decoration: BoxDecoration(
          color: const Color(0x3393000A),
          border: Border.all(color: const Color(0xFFFF5449)),
        ),
        child: Center(child: Text(
          'FINISH WORKOUT',
          style: GoogleFonts.anton(fontSize: 16.sp, color: const Color(0xFFFF5449)),
        )),
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;
  const _GlassButton({required this.icon, required this.onTap, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 52.h,
            decoration: BoxDecoration(
              color: const Color(0x66201F21),
              border: Border.all(color: enabled ? NeoColors.cyan.withValues(alpha: 0.4) : NeoColors.outlineVariant),
            ),
            child: Center(child: Icon(icon, color: enabled ? NeoColors.cyan : NeoColors.outline, size: 22.r)),
          ),
        ),
      ),
    );
  }
}
