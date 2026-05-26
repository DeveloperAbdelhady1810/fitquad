import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/services/api_client.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnnouncementOverlay extends StatefulWidget {
  final Widget child;
  const AnnouncementOverlay({super.key, required this.child});

  @override
  State<AnnouncementOverlay> createState() => _AnnouncementOverlayState();
}

class _AnnouncementOverlayState extends State<AnnouncementOverlay> {
  List<Map<String, dynamic>> _pending = [];
  int _current = 0;
  bool _shown = false;

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  Future<void> _loadAnnouncements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final seenIds = prefs.getStringList('seen_announcements') ?? [];

      final res = await ApiClient.get('/member/announcements');
      final list = (res['data'] as List?) ?? [];

      final unseen = list
          .cast<Map<String, dynamic>>()
          .where((a) => !seenIds.contains(a['id']?.toString()))
          .toList();

      if (unseen.isNotEmpty && mounted) {
        setState(() {
          _pending = unseen;
          _shown = true;
        });
      }
    } catch (_) {
      // silently skip — announcements are non-critical
    }
  }

  Future<void> _dismiss() async {
    final prefs = await SharedPreferences.getInstance();
    final seenIds = prefs.getStringList('seen_announcements') ?? [];
    seenIds.add(_pending[_current]['id']?.toString() ?? '');
    await prefs.setStringList('seen_announcements', seenIds);

    if (_current + 1 < _pending.length) {
      setState(() => _current++);
    } else {
      setState(() => _shown = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_shown || _pending.isEmpty) return widget.child;

    final a = _pending[_current];
    return Stack(
      children: [
        widget.child,
        _AnnouncementCard(
          title: a['title'] as String? ?? '',
          body: a['body'] as String? ?? '',
          ctaLabel: a['cta_label'] as String?,
          ctaUrl: a['cta_url'] as String?,
          index: _current,
          total: _pending.length,
          onDismiss: _dismiss,
        ),
      ],
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final String title;
  final String body;
  final String? ctaLabel;
  final String? ctaUrl;
  final int index;
  final int total;
  final VoidCallback onDismiss;

  const _AnnouncementCard({
    required this.title,
    required this.body,
    required this.ctaLabel,
    required this.ctaUrl,
    required this.index,
    required this.total,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black87,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Story progress dots
              if (total > 1)
                Row(
                  children: List.generate(total, (i) {
                    return Expanded(
                      child: Container(
                        height: 3.h,
                        margin: EdgeInsets.symmetric(horizontal: 2.w),
                        decoration: BoxDecoration(
                          color: i <= index ? AppColors.teal : Colors.white24,
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                    );
                  }),
                ),
              if (total > 1) vGap(12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('FitQuad',
                      style: AppTextStyles.font14GreyRegular
                          .copyWith(color: AppColors.teal)),
                  IconButton(
                    onPressed: onDismiss,
                    icon: Icon(Icons.close, color: Colors.white54, size: 22.r),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.all(24.r),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.teal.withValues(alpha: 0.25),
                      AppColors.secondary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(
                      color: AppColors.teal.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('📢', style: TextStyle(fontSize: 40.sp)),
                    vGap(16),
                    Text(title,
                        style: AppTextStyles.font16WhiteBold
                            .copyWith(fontSize: 24.sp, height: 1.3)),
                    vGap(12),
                    Text(body,
                        style: AppTextStyles.font14GreyRegular
                            .copyWith(height: 1.6, fontSize: 15.sp)),
                    if (ctaLabel != null) ...[
                      vGap(24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: onDismiss,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.teal,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r)),
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                          ),
                          child: Text(ctaLabel!,
                              style: AppTextStyles.font16WhiteBold
                                  .copyWith(fontSize: 15.sp)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: onDismiss,
                child: Text(
                  'Dismiss',
                  style: AppTextStyles.font14GreyRegular,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
