import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/core/helpers/app_decoration.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';
import 'package:gym_app/features/member/data/repositories/member_repository.dart';
import 'package:gym_app/features/member/home/ui/views/bottom_nav_bar_view.dart';
import 'package:gym_app/features/member/partner_gyms/data/partner_gym_repository.dart';
import 'package:gym_app/features/member/partner_gyms/models/partner_gym_model.dart';

class GymSelectionScreen extends StatefulWidget {
  static const routeName = '/gym-selection';

  const GymSelectionScreen({super.key});

  @override
  State<GymSelectionScreen> createState() => _GymSelectionScreenState();
}

class _GymSelectionScreenState extends State<GymSelectionScreen> {
  List<PartnerGymModel> _gyms = [];
  PartnerGymModel? _selectedGym;
  String? _selectedMode;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadGyms();
  }

  Future<void> _loadGyms() async {
    try {
      final gyms = await PartnerGymRepository.getGyms();
      if (mounted) {
        setState(() {
          _gyms = gyms;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Failed to load gyms. You can still choose below.';
        });
      }
    }
  }

  // Called for non-partner-gym modes (other_gym / self) or skip from the gym ID sheet
  Future<void> _saveMode(String mode, {String? partnerGymId}) async {
    setState(() => _saving = true);
    try {
      await MemberRepository.assignBranch(
        partnerGymId: partnerGymId,
        trainingMode: mode,
      );
      if (mounted) context.go(BottomNavBarView.routeName);
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Could not save. Please try again.';
        });
      }
    }
  }

  void _onContinue() {
    if (_selectedMode == null || _saving) return;

    if (_selectedMode == 'partner_gym' && _selectedGym != null) {
      // Show membership-ID sheet before finalising
      _showMembershipIdSheet(_selectedGym!);
    } else {
      _saveMode(_selectedMode!);
    }
  }

  void _showMembershipIdSheet(PartnerGymModel gym) {
    final ctrl = TextEditingController();
    bool sheetSaving = false;
    String? sheetError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (sheetCtx, setSheetState) {
          Future<void> doLink() async {
            final id = ctrl.text.trim();
            if (id.isEmpty) {
              setSheetState(() => sheetError = 'Please enter your membership ID.');
              return;
            }
            setSheetState(() {
              sheetSaving = true;
              sheetError = null;
            });
            try {
              await PartnerGymRepository.syncSubscription(gym.id, id);
              if (mounted) {
                Navigator.pop(sheetCtx);
                context.go(BottomNavBarView.routeName);
              }
            } catch (e) {
              if (mounted) {
                setSheetState(() {
                  sheetSaving = false;
                  sheetError = e.toString().replaceAll('Exception: ', '');
                });
              }
            }
          }

          Future<void> doSkip() async {
            Navigator.pop(sheetCtx);
            await _saveMode('partner_gym', partnerGymId: gym.id.toString());
          }

          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(sheetCtx).viewInsets.bottom),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              padding: EdgeInsets.fromLTRB(24.r, 20.r, 24.r, 32.r),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40.w, height: 4.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  vGap(20),
                  Text(
                    'Link your membership at ${gym.name}',
                    style: AppTextStyles.font16WhiteBold,
                  ),
                  vGap(8),
                  Text(
                    'Enter the membership ID the gym gave you when you subscribed on-site. This links your account to your existing subscription.',
                    style: AppTextStyles.font14GreyRegular.copyWith(fontSize: 13.sp),
                  ),
                  vGap(20),
                  TextField(
                    controller: ctrl,
                    style: AppTextStyles.font14WhiteRegular,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => doLink(),
                    decoration: InputDecoration(
                      hintText: 'e.g. GLD-001234',
                      hintStyle: AppTextStyles.font14GreyRegular,
                      filled: true,
                      fillColor: AppColors.primary,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: AppColors.teal.withValues(alpha: 0.4)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: AppColors.teal, width: 1.5),
                      ),
                    ),
                  ),
                  if (sheetError != null) ...[
                    vGap(10),
                    Text(
                      sheetError!,
                      style: AppTextStyles.font14GreyRegular.copyWith(color: AppColors.red, fontSize: 12.sp),
                    ),
                  ],
                  vGap(20),
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.teal,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      onPressed: sheetSaving ? null : doLink,
                      child: sheetSaving
                          ? const SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text('Link & Continue', style: AppTextStyles.font16WhiteBold),
                    ),
                  ),
                  vGap(10),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: sheetSaving ? null : doSkip,
                      child: Text(
                        "I don't have an ID yet — skip for now",
                        style: AppTextStyles.font14GreyRegular,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
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
              Text('Where do you train?',
                  style: AppTextStyles.font16WhiteBold.copyWith(fontSize: 24.sp)),
              vGap(8),
              Text(
                'Select your gym to get personalised coaches and updates.',
                style: AppTextStyles.font14GreyRegular,
              ),
              vGap(32),
              if (_loading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator(color: AppColors.teal)),
                )
              else
                Expanded(
                  child: ListView(
                    children: [
                      if (_gyms.isNotEmpty) ...[
                        Text('Partner Gyms',
                            style: AppTextStyles.font14GreyRegular
                                .copyWith(color: AppColors.teal)),
                        vGap(12),
                        ..._gyms.map((gym) {
                          final selected =
                              _selectedMode == 'partner_gym' && _selectedGym?.id == gym.id;
                          final crowdColor = gym.crowdLevel == 'crowded'
                              ? Colors.redAccent
                              : gym.crowdLevel == 'moderate'
                                  ? const Color(0xFFFFD700)
                                  : AppColors.emerald;
                          return Padding(
                            padding: EdgeInsets.only(bottom: 10.h),
                            child: _GymTile(
                              gym: gym,
                              selected: selected,
                              crowdColor: crowdColor,
                              onTap: () => setState(() {
                                _selectedMode = 'partner_gym';
                                _selectedGym = gym;
                              }),
                            ),
                          );
                        }),
                        vGap(10),
                      ],
                      _OptionTile(
                        icon: Icons.location_city_outlined,
                        title: 'Another Gym',
                        subtitle: 'I train at a gym not listed here',
                        selected: _selectedMode == 'other_gym',
                        iconColor: AppColors.blue,
                        onTap: () => setState(() {
                          _selectedMode = 'other_gym';
                          _selectedGym = null;
                        }),
                      ),
                      vGap(10),
                      _OptionTile(
                        icon: Icons.person_outline,
                        title: 'Training Alone',
                        subtitle: 'Home workouts or no specific gym',
                        selected: _selectedMode == 'self',
                        iconColor: AppColors.purple,
                        onTap: () => setState(() {
                          _selectedMode = 'self';
                          _selectedGym = null;
                        }),
                      ),
                    ],
                  ),
                ),
              if (_error != null) ...[
                vGap(8),
                Text(_error!,
                    style: AppTextStyles.font14GreyRegular.copyWith(color: AppColors.red)),
              ],
              vGap(16),
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _selectedMode != null ? AppColors.teal : AppColors.grey,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                  ),
                  onPressed: (_selectedMode == null || _saving) ? null : _onContinue,
                  child: _saving
                      ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text(
                          _selectedMode == 'partner_gym'
                              ? 'Continue — Link Membership'
                              : 'Continue',
                          style: AppTextStyles.font16WhiteBold,
                        ),
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

class _GymTile extends StatelessWidget {
  final PartnerGymModel gym;
  final bool selected;
  final Color crowdColor;
  final VoidCallback onTap;

  const _GymTile({
    required this.gym,
    required this.selected,
    required this.crowdColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(14.w),
        decoration: AppDecorations.containerDecoration.copyWith(
          border: Border.all(
            color: selected ? AppColors.teal : Colors.grey.withValues(alpha: 0.3),
            width: selected ? 2 : 1,
          ),
          color: selected ? AppColors.teal.withValues(alpha: 0.08) : AppColors.secondary,
        ),
        child: Row(
          children: [
            Container(
              width: 46.r, height: 46.r,
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.fitness_center, color: AppColors.teal, size: 22.r),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(gym.name,
                      style: AppTextStyles.font16WhiteBold.copyWith(fontSize: 14.sp)),
                  Text(
                    [gym.city, gym.address]
                        .where((e) => e.isNotEmpty)
                        .join(' · '),
                    style: AppTextStyles.font14GreyRegular.copyWith(fontSize: 11.sp),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: crowdColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    gym.crowdLevel,
                    style: TextStyle(color: crowdColor, fontSize: 9.sp),
                  ),
                ),
                if (selected) ...[
                  vGap(4),
                  Icon(Icons.check_circle, color: AppColors.teal, size: 16.r),
                ],
              ],
            ),
          ],
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
              width: 44.r, height: 44.r,
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
                  Text(title,
                      style: AppTextStyles.font16WhiteBold.copyWith(fontSize: 14.sp)),
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
