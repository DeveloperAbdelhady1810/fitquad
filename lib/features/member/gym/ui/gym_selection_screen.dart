import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/core/helpers/app_decoration.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';
import 'package:gym_app/features/member/data/repositories/member_repository.dart';
import 'package:gym_app/features/member/gym/models/gym_model.dart';
import 'package:gym_app/features/member/home/ui/views/bottom_nav_bar_view.dart';

class GymSelectionScreen extends StatefulWidget {
  static const routeName = '/gym-selection';

  const GymSelectionScreen({super.key});

  @override
  State<GymSelectionScreen> createState() => _GymSelectionScreenState();
}

class _GymSelectionScreenState extends State<GymSelectionScreen> {
  List<GymModel> _gyms = [];
  GymModel? _selectedGym;
  String? _selectedMode;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBranches();
  }

  Future<void> _loadBranches() async {
    try {
      final raw = await MemberRepository.getBranches();
      setState(() {
        _gyms = raw.map((e) => GymModel.fromJson(e as Map<String, dynamic>)).toList();
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _loading = false;
        _error = 'Failed to load gyms. You can still choose below.';
      });
    }
  }

  Future<void> _confirm() async {
    if (_selectedMode == null) return;
    setState(() => _saving = true);
    try {
      await MemberRepository.assignBranch(
        branchId: _selectedMode == 'fitquad_gym' ? _selectedGym?.id : null,
        trainingMode: _selectedMode!,
      );
      if (mounted) context.go(BottomNavBarView.routeName);
    } catch (e) {
      setState(() {
        _saving = false;
        _error = 'Could not save. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              vGap(16),
              Text('Where do you train?', style: AppTextStyles.font16WhiteBold.copyWith(fontSize: 24.sp)),
              vGap(8),
              Text(
                'We\'ll show you coaches and gym updates tailored to your location.',
                style: AppTextStyles.font14GreyRegular,
              ),
              vGap(32),
              if (_loading)
                const Center(child: CircularProgressIndicator(color: AppColors.teal))
              else ...[
                // FitQuad partner gyms
                if (_gyms.isNotEmpty) ...[
                  Text('FitQuad Partner Gyms', style: AppTextStyles.font14GreyRegular.copyWith(color: AppColors.teal)),
                  vGap(12),
                  Expanded(
                    child: ListView.separated(
                      itemCount: _gyms.length + 2,
                      separatorBuilder: (_, __) => vGap(10),
                      itemBuilder: (context, i) {
                        if (i < _gyms.length) {
                          final gym = _gyms[i];
                          final selected = _selectedMode == 'fitquad_gym' && _selectedGym?.id == gym.id;
                          return _OptionTile(
                            icon: Icons.fitness_center,
                            title: gym.name,
                            subtitle: [gym.city, gym.address].where((e) => e != null && e.isNotEmpty).join(' · '),
                            selected: selected,
                            iconColor: AppColors.teal,
                            onTap: () => setState(() {
                              _selectedMode = 'fitquad_gym';
                              _selectedGym = gym;
                            }),
                          );
                        } else if (i == _gyms.length) {
                          return _OptionTile(
                            icon: Icons.location_city_outlined,
                            title: 'Another Gym',
                            subtitle: 'I train at a different gym',
                            selected: _selectedMode == 'other_gym',
                            iconColor: AppColors.blue,
                            onTap: () => setState(() {
                              _selectedMode = 'other_gym';
                              _selectedGym = null;
                            }),
                          );
                        } else {
                          return _OptionTile(
                            icon: Icons.person_outline,
                            title: 'Training Alone',
                            subtitle: 'Home workouts or no specific gym',
                            selected: _selectedMode == 'self',
                            iconColor: AppColors.purple,
                            onTap: () => setState(() {
                              _selectedMode = 'self';
                              _selectedGym = null;
                            }),
                          );
                        }
                      },
                    ),
                  ),
                ] else ...[
                  _OptionTile(
                    icon: Icons.location_city_outlined,
                    title: 'Another Gym',
                    subtitle: 'I train at a gym not listed here',
                    selected: _selectedMode == 'other_gym',
                    iconColor: AppColors.blue,
                    onTap: () => setState(() => _selectedMode = 'other_gym'),
                  ),
                  vGap(10),
                  _OptionTile(
                    icon: Icons.person_outline,
                    title: 'Training Alone',
                    subtitle: 'Home workouts or no specific gym',
                    selected: _selectedMode == 'self',
                    iconColor: AppColors.purple,
                    onTap: () => setState(() => _selectedMode = 'self'),
                  ),
                  const Spacer(),
                ],
              ],
              if (_error != null) ...[
                vGap(8),
                Text(_error!, style: AppTextStyles.font14GreyRegular.copyWith(color: AppColors.red)),
              ],
              vGap(16),
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedMode != null ? AppColors.teal : AppColors.grey,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  onPressed: (_selectedMode == null || _saving) ? null : _confirm,
                  child: _saving
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text('Continue', style: AppTextStyles.font16WhiteBold),
                ),
              ),
              vGap(8),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final Color iconColor;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(16.w),
        decoration: AppDecorations.containerDecoration.copyWith(
          border: Border.all(
            color: selected ? iconColor : Colors.grey.withValues(alpha: 0.4),
            width: selected ? 2 : 1,
          ),
          color: selected ? iconColor.withValues(alpha: 0.08) : AppColors.secondary,
        ),
        child: Row(
          children: [
            Container(
              width: 44.r,
              height: 44.r,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 22.r),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.font16WhiteBold.copyWith(fontSize: 14.sp)),
                  if (subtitle.isNotEmpty)
                    Text(subtitle,
                        style: AppTextStyles.font14GreyRegular.copyWith(fontSize: 12.sp),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle, color: iconColor, size: 20.r),
          ],
        ),
      ),
    );
  }
}
