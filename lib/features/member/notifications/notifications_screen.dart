import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_app/core/helpers/app_decoration.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';

class NotificationsScreen extends StatelessWidget {
  static const routeName = '/notifications';
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        iconTheme: IconThemeData(color: AppColors.grey),
        title: Text('Notifications', style: AppTextStyles.font16WhiteBold),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.r),
        children: const [
          _NotifTile(
            icon: Icons.fitness_center,
            color: AppColors.teal,
            title: 'Workout Reminder',
            message: "Time for your workout! Keep up your streak.",
            time: '1 hour ago',
          ),
          _NotifTile(
            icon: Icons.person_outline,
            color: AppColors.blue,
            title: 'Coach Message',
            message: 'Your coach has reviewed your InBody results.',
            time: '3 hours ago',
          ),
          _NotifTile(
            icon: Icons.local_fire_department,
            color: AppColors.red,
            title: 'Calories Goal',
            message: "You're 400 kcal away from your daily goal. Log your next meal!",
            time: 'Yesterday',
          ),
          _NotifTile(
            icon: Icons.star,
            color: AppColors.emerald,
            title: 'Achievement Unlocked',
            message: 'You completed 7 workouts this month. Keep it up!',
            time: '2 days ago',
          ),
        ],
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String message;
  final String time;

  const _NotifTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.r),
      decoration: AppDecorations.containerDecoration,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42.r,
            height: 42.r,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20.r),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(title,
                          style: AppTextStyles.font14WhiteRegular
                              .copyWith(fontWeight: FontWeight.w600)),
                    ),
                    Text(time,
                        style: AppTextStyles.font14GreyRegular
                            .copyWith(fontSize: 11.sp)),
                  ],
                ),
                vGap(4),
                Text(message,
                    style: AppTextStyles.font14GreyRegular,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
