import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/helpers/spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../auth/data/auth_repository.dart';
import '../home/ui/views/coach_bottom_nav_bar_view.dart';

class CoachSetupScreen extends StatefulWidget {
  static const String routeName = '/coach_setup';
  const CoachSetupScreen({super.key});

  @override
  State<CoachSetupScreen> createState() => _CoachSetupScreenState();
}

class _CoachSetupScreenState extends State<CoachSetupScreen> {
  // 0 = choosing, 1 = gym picker (gym_staff path)
  int _step = 0;

  List<Map<String, dynamic>> _gyms = [];
  bool _loadingGyms = false;
  int? _selectedGymId;
  String? _selectedGymName;
  bool _submitting = false;
  String? _error;

  Future<void> _loadGyms() async {
    setState(() { _loadingGyms = true; _error = null; });
    try {
      final gyms = await AuthRepository.getAvailableGyms();
      setState(() { _gyms = gyms; _loadingGyms = false; _step = 1; });
    } catch (e) {
      setState(() {
        _loadingGyms = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _submitGymRequest() async {
    if (_selectedGymId == null) return;
    setState(() { _submitting = true; _error = null; });
    try {
      await AuthRepository.submitGymRequest(_selectedGymId!);
      if (!mounted) return;
      context.go(CoachGymPendingScreen.routeName);
    } catch (e) {
      setState(() {
        _submitting = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: _step == 0 ? _buildChooseStep() : _buildGymPickerStep(),
        ),
      ),
    );
  }

  Widget _buildChooseStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        vGap(20),
        Text('Welcome, Coach!', style: AppTextStyles.font24GreyBold),
        vGap(8),
        Text(
          'Tell us about your coaching setup so we can configure your account.',
          style: AppTextStyles.font14GreyRegular,
        ),
        vGap(32),
        _TypeCard(
          icon: Icons.person_outline,
          color: const Color(0xFFf97316),
          title: 'Freelance Coach',
          subtitle: 'I work independently and take personal training clients. Platform takes 10% of each subscription.',
          feeLabel: '10% platform fee',
          onTap: () => context.go(CoachBottomNavBarView.routeName),
        ),
        vGap(16),
        _TypeCard(
          icon: Icons.fitness_center,
          color: AppColors.blue,
          title: 'Gym Staff Coach',
          subtitle: 'I am employed by a partner gym. My profile will be listed under the gym\'s coaching staff.',
          feeLabel: 'No extra platform fee',
          onTap: _loadingGyms ? null : _loadGyms,
          loading: _loadingGyms,
        ),
        if (_error != null) ...[
          vGap(12),
          Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
        ],
      ],
    );
  }

  Widget _buildGymPickerStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => setState(() { _step = 0; _selectedGymId = null; }),
            ),
            Text('Select Your Gym', style: AppTextStyles.font24GreyBold),
          ],
        ),
        vGap(8),
        Text(
          'Choose the partner gym you work at. The gym manager will review and approve your request.',
          style: AppTextStyles.font14GreyRegular,
        ),
        vGap(16),
        Expanded(
          child: _gyms.isEmpty
              ? const Center(child: Text('No gyms available.', style: TextStyle(color: Colors.grey)))
              : ListView.separated(
                  itemCount: _gyms.length,
                  separatorBuilder: (_, __) => vGap(10),
                  itemBuilder: (context, i) {
                    final gym = _gyms[i];
                    final id   = gym['id'] as int;
                    final name = gym['name'] as String? ?? '';
                    final city = gym['city'] as String? ?? '';
                    final selected = _selectedGymId == id;
                    return GestureDetector(
                      onTap: () => setState(() { _selectedGymId = id; _selectedGymName = name; }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.blue.withValues(alpha:0.15) : AppColors.secondary,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: selected ? AppColors.blue : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40.r, height: 40.r,
                              decoration: BoxDecoration(
                                color: AppColors.blue.withValues(alpha:0.15),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Icon(Icons.fitness_center, color: AppColors.blue, size: 20.r),
                            ),
                            hGap(12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(name, style: AppTextStyles.font16WhiteRegular.copyWith(fontWeight: FontWeight.w600)),
                                  Text(city, style: AppTextStyles.font14GreyRegular),
                                ],
                              ),
                            ),
                            if (selected)
                              Icon(Icons.check_circle, color: AppColors.blue, size: 20.r),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        if (_error != null) ...[
          vGap(8),
          Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
        ],
        vGap(12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _selectedGymId == null || _submitting ? null : _submitGymRequest,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue,
              disabledBackgroundColor: AppColors.blue.withValues(alpha:0.4),
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            child: _submitting
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(
                    _selectedGymName != null ? 'Request to Join $_selectedGymName' : 'Select a Gym',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
        vGap(8),
        Center(
          child: TextButton(
            onPressed: () => context.go(CoachBottomNavBarView.routeName),
            child: Text('Skip — I\'ll decide later',
                style: AppTextStyles.font14GreyRegular.copyWith(color: AppColors.teal)),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pending approval screen — shown after a gym-staff request is submitted
// ─────────────────────────────────────────────────────────────────────────────

class CoachGymPendingScreen extends StatefulWidget {
  static const String routeName = '/coach_gym_pending';
  const CoachGymPendingScreen({super.key});

  @override
  State<CoachGymPendingScreen> createState() => _CoachGymPendingScreenState();
}

class _CoachGymPendingScreenState extends State<CoachGymPendingScreen> {
  Map<String, dynamic>? _requestData;
  bool _loading = true;
  bool _withdrawing = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await AuthRepository.getCoachGymRequest();
      if (mounted) setState(() { _requestData = data; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _withdraw() async {
    setState(() => _withdrawing = true);
    try {
      await AuthRepository.withdrawGymRequest();
      if (!mounted) return;
      context.go(CoachSetupScreen.routeName);
    } catch (e) {
      setState(() => _withdrawing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final req     = _requestData?['gym_request'] as Map<String, dynamic>?;
    final gymName = (req?['partner_gym'] as Map<String, dynamic>?)?['name'] as String? ?? 'the gym';
    final status  = req?['status'] as String? ?? 'pending';

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _StatusIcon(status: status),
                    vGap(24),
                    Text(
                      status == 'accepted'
                          ? 'You\'re In!'
                          : status == 'rejected'
                              ? 'Request Rejected'
                              : 'Awaiting Gym Approval',
                      style: AppTextStyles.font24GreyBold,
                      textAlign: TextAlign.center,
                    ),
                    vGap(12),
                    Text(
                      status == 'accepted'
                          ? 'Your request to join $gymName was accepted. You are now listed as gym staff.'
                          : status == 'rejected'
                              ? 'Your request to join $gymName was rejected. You can apply to a different gym or continue as a freelancer.'
                              : 'Your request to join $gymName has been sent. You\'ll be able to take clients once the gym approves your application.',
                      style: AppTextStyles.font14GreyRegular,
                      textAlign: TextAlign.center,
                    ),
                    if (req?['notes'] != null && (req!['notes'] as String).isNotEmpty) ...[
                      vGap(16),
                      Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text('"${req['notes']}"',
                            style: AppTextStyles.font14GreyRegular.copyWith(fontStyle: FontStyle.italic)),
                      ),
                    ],
                    vGap(32),
                    if (status == 'accepted') ...[
                      _PrimaryButton(
                        label: 'Go to Dashboard',
                        color: AppColors.teal,
                        onTap: () => context.go('/coach_nav'),
                      ),
                    ] else if (status == 'rejected') ...[
                      _PrimaryButton(
                        label: 'Apply to Another Gym',
                        color: AppColors.blue,
                        onTap: () => context.go(CoachSetupScreen.routeName),
                      ),
                      vGap(12),
                      _PrimaryButton(
                        label: 'Continue as Freelancer',
                        color: const Color(0xFFf97316),
                        onTap: () => context.go('/coach_nav'),
                      ),
                    ] else ...[
                      _PrimaryButton(
                        label: 'Continue as Freelancer for Now',
                        color: const Color(0xFFf97316),
                        onTap: () => context.go('/coach_nav'),
                      ),
                      vGap(12),
                      TextButton(
                        onPressed: _withdrawing ? null : _withdraw,
                        child: _withdrawing
                            ? const SizedBox(width: 16, height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red))
                            : const Text('Withdraw Request',
                                style: TextStyle(color: Colors.red, fontSize: 13)),
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final String status;
  const _StatusIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = status == 'accepted'
        ? AppColors.teal
        : status == 'rejected'
            ? Colors.red
            : AppColors.blue;
    final icon = status == 'accepted'
        ? Icons.check_circle_outline
        : status == 'rejected'
            ? Icons.cancel_outlined
            : Icons.hourglass_empty;

    return Container(
      width: 80.r, height: 80.r,
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 40.r),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _PrimaryButton({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        ),
        child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _TypeCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String feeLabel;
  final VoidCallback? onTap;
  final bool loading;

  const _TypeCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.feeLabel,
    required this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(18.r),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: color.withValues(alpha:0.3), width: 1.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44.r, height: 44.r,
              decoration: BoxDecoration(
                color: color.withValues(alpha:0.15),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: loading
                  ? Padding(
                      padding: EdgeInsets.all(10.r),
                      child: CircularProgressIndicator(strokeWidth: 2, color: color),
                    )
                  : Icon(icon, color: color, size: 22.r),
            ),
            hGap(14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTextStyles.font16WhiteRegular
                          .copyWith(fontWeight: FontWeight.w700)),
                  vGap(4),
                  Text(subtitle, style: AppTextStyles.font14GreyRegular),
                  vGap(8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha:0.15),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(feeLabel,
                        style: TextStyle(color: color, fontSize: 11.sp, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14.r),
          ],
        ),
      ),
    );
  }
}
