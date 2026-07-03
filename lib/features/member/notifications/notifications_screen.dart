import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_app/core/helpers/app_decoration.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/services/api_client.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';

class NotificationsScreen extends StatefulWidget {
  static const routeName = '/notifications';
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await ApiClient.get('/member/notifications');
      final list = (res['data'] as List?) ?? (res['notifications'] as List?) ?? [];
      if (mounted) {
        setState(() {
          _notifications = list.cast<Map<String, dynamic>>();
          _loading = false;
        });
      }
      _markRead();
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _markRead() async {
    try {
      await ApiClient.post('/member/notifications/read', {});
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        iconTheme: IconThemeData(color: AppColors.grey),
        title: Text('Notifications', style: AppTextStyles.font16WhiteBold),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return Center(child: CircularProgressIndicator(color: AppColors.teal));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, color: AppColors.grey, size: 40.r),
            vGap(12),
            Text('Could not load notifications',
                style: AppTextStyles.font14GreyRegular),
            vGap(12),
            TextButton(
              onPressed: () { setState(() { _loading = true; _error = null; }); _load(); },
              child: Text('Retry', style: AppTextStyles.font14WhiteRegular.copyWith(color: AppColors.teal)),
            ),
          ],
        ),
      );
    }
    if (_notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_none_rounded, color: AppColors.grey, size: 48.r),
            vGap(12),
            Text("You're all caught up!", style: AppTextStyles.font16WhiteBold),
            vGap(6),
            Text('No notifications yet', style: AppTextStyles.font14GreyRegular),
          ],
        ),
      );
    }
    return RefreshIndicator(
      color: AppColors.teal,
      backgroundColor: AppColors.secondary,
      onRefresh: () async { setState(() => _loading = true); await _load(); },
      child: ListView.builder(
        padding: EdgeInsets.all(16.r),
        itemCount: _notifications.length,
        itemBuilder: (_, i) => _NotifTile.fromJson(_notifications[i]),
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
  final bool isRead;

  const _NotifTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
    required this.time,
    required this.isRead,
  });

  static _NotifTile fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String? ?? 'general';
    final (icon, color) = _typeStyle(type);
    return _NotifTile(
      icon: icon,
      color: color,
      title: json['title'] as String? ?? json['subject'] as String? ?? 'Notification',
      message: json['body'] as String? ?? json['message'] as String? ?? '',
      time: _timeAgo(json['created_at'] as String?),
      isRead: json['read_at'] != null,
    );
  }

  static (IconData, Color) _typeStyle(String type) {
    switch (type.toLowerCase()) {
      case 'workout':
      case 'training':
        return (Icons.fitness_center, AppColors.teal);
      case 'coach':
      case 'message':
        return (Icons.person_outline, const Color(0xFF4A90D9));
      case 'nutrition':
      case 'meal':
      case 'food':
        return (Icons.restaurant_menu, const Color(0xFFFF8C00));
      case 'achievement':
      case 'badge':
      case 'milestone':
        return (Icons.star_rounded, AppColors.emerald);
      case 'payment':
      case 'subscription':
        return (Icons.receipt_long, const Color(0xFF9B59B6));
      case 'gym':
      case 'membership':
        return (Icons.location_on_rounded, const Color(0xFFE74C3C));
      default:
        return (Icons.notifications_rounded, AppColors.grey);
    }
  }

  static String _timeAgo(String? raw) {
    if (raw == null) return '';
    final dt = DateTime.tryParse(raw);
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    return '${(diff.inDays / 30).floor()}mo ago';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.r),
      decoration: AppDecorations.containerDecoration.copyWith(
        border: isRead
            ? null
            : Border.all(color: color.withValues(alpha: 0.3)),
      ),
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
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!isRead)
                            Container(
                              width: 6.r,
                              height: 6.r,
                              margin: EdgeInsets.only(right: 6.w),
                              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                            ),
                          Flexible(
                            child: Text(title,
                                style: AppTextStyles.font14WhiteRegular
                                    .copyWith(fontWeight: isRead ? FontWeight.w500 : FontWeight.w700),
                                overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                    ),
                    Text(time,
                        style: AppTextStyles.font14GreyRegular.copyWith(fontSize: 11.sp)),
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
