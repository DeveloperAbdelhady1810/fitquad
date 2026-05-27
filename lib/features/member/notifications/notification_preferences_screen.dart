import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/services/reminder_service.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  static const routeName = '/notification-preferences';

  @override
  State<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends State<NotificationPreferencesScreen> {
  bool _water = true;
  bool _sleep = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _water = prefs.getBool('notif_water') ?? true;
      _sleep = prefs.getBool('notif_sleep') ?? true;
      _loading = false;
    });
  }

  Future<void> _toggleWater(bool val) async {
    setState(() => _water = val);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_water', val);
    if (val) {
      await ReminderService.requestPermission();
      await ReminderService.scheduleWaterReminders();
    } else {
      await ReminderService.cancelWaterReminders();
    }
  }

  Future<void> _toggleSleep(bool val) async {
    setState(() => _sleep = val);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_sleep', val);
    if (val) {
      await ReminderService.requestPermission();
      await ReminderService.scheduleSleepReminder();
    } else {
      await ReminderService.cancelSleepReminder();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text('Notification Settings', style: AppTextStyles.font16WhiteBold),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.teal))
          : ListView(
              padding: EdgeInsets.all(20.r),
              children: [
                Text('Smart Reminders',
                    style: AppTextStyles.font14GreyRegular
                        .copyWith(color: AppColors.teal, fontSize: 12.sp)),
                vGap(12),
                _PrefTile(
                  icon: '💧',
                  title: 'Water Reminders',
                  subtitle: 'Every 2 hours from 9am to 9pm',
                  value: _water,
                  onChanged: _toggleWater,
                ),
                vGap(10),
                _PrefTile(
                  icon: '😴',
                  title: 'Sleep Reminder',
                  subtitle: 'Nightly at 10:30pm',
                  value: _sleep,
                  onChanged: _toggleSleep,
                ),
                vGap(24),
                Text('App Notifications',
                    style: AppTextStyles.font14GreyRegular
                        .copyWith(color: AppColors.teal, fontSize: 12.sp)),
                vGap(12),
                _StaticTile(
                  icon: '🏆',
                  title: 'Streak & Achievement alerts',
                  subtitle: 'When you earn badges or hit milestones',
                ),
                vGap(10),
                _StaticTile(
                  icon: '📋',
                  title: 'Coach plan updates',
                  subtitle: 'When your coach sends a new plan',
                ),
                vGap(10),
                _StaticTile(
                  icon: '📦',
                  title: 'Order updates',
                  subtitle: 'When your order ships or is delivered',
                ),
                vGap(24),
                Container(
                  padding: EdgeInsets.all(14.r),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: AppColors.grey, size: 18.r),
                      hGap(10),
                      Expanded(
                        child: Text(
                          'App notifications are managed by your device settings. Tap "Allow" when prompted to enable them.',
                          style: AppTextStyles.font14GreyRegular
                              .copyWith(fontSize: 11.sp, height: 1.5),
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

class _PrefTile extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PrefTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: value
              ? AppColors.teal.withValues(alpha: 0.35)
              : Colors.white12,
        ),
      ),
      child: Row(
        children: [
          Text(icon, style: TextStyle(fontSize: 24.sp)),
          hGap(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.font14WhiteRegular
                        .copyWith(fontWeight: FontWeight.w600)),
                vGap(2),
                Text(subtitle,
                    style: AppTextStyles.font14GreyRegular
                        .copyWith(fontSize: 11.sp)),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.teal,
          ),
        ],
      ),
    );
  }
}

class _StaticTile extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;

  const _StaticTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Text(icon, style: TextStyle(fontSize: 24.sp)),
          hGap(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.font14WhiteRegular
                        .copyWith(fontWeight: FontWeight.w600)),
                vGap(2),
                Text(subtitle,
                    style: AppTextStyles.font14GreyRegular
                        .copyWith(fontSize: 11.sp)),
              ],
            ),
          ),
          Icon(Icons.check_circle_outline,
              color: AppColors.teal, size: 20.r),
        ],
      ),
    );
  }
}
