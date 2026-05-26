import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../core/helpers/app_decoration.dart';
import '../../../core/helpers/spacing.dart';
import '../../../core/services/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class CommunityFeedScreen extends StatefulWidget {
  const CommunityFeedScreen({super.key});

  static const routeName = '/community';

  @override
  State<CommunityFeedScreen> createState() => _CommunityFeedScreenState();
}

class _CommunityFeedScreenState extends State<CommunityFeedScreen> {
  List<dynamic> _posts = [];
  bool _loading = true;
  bool _posting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await ApiClient.get('/member/community/posts');
      final data = res['data'];
      if (mounted) {
        setState(() {
          _posts = (data is List ? data : (data['data'] as List? ?? []));
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _react(int postId, String emoji) async {
    try {
      await ApiClient.post('/member/community/posts/$postId/react',
          {'type': emoji});
      _load();
    } catch (_) {}
  }

  Future<void> _showComposeSheet() async {
    final ctrl = TextEditingController();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.secondary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20.w, right: 20.w, top: 20.h,
          bottom: MediaQuery.viewInsetsOf(ctx).bottom + 20.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Share with the community',
                style: AppTextStyles.font16WhiteBold),
            vGap(14),
            TextField(
              controller: ctrl,
              maxLines: 4,
              maxLength: 300,
              style: AppTextStyles.font14WhiteRegular,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Share a workout win, tip, or milestone...',
                hintStyle: AppTextStyles.font14GreyRegular,
                filled: true,
                fillColor: AppColors.primary,
                counterStyle:
                    AppTextStyles.font14GreyRegular.copyWith(fontSize: 10.sp),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: AppColors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: AppColors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: AppColors.teal),
                ),
              ),
            ),
            vGap(14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                ),
                onPressed: () async {
                  final body = ctrl.text.trim();
                  if (body.isEmpty) return;
                  Navigator.pop(ctx);
                  setState(() => _posting = true);
                  try {
                    await ApiClient.post('/member/community/posts',
                        {'body': body});
                    await _load();
                  } catch (_) {}
                  if (mounted) setState(() => _posting = false);
                },
                child:
                    Text('Post', style: AppTextStyles.font16WhiteBold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text('Community', style: AppTextStyles.font16WhiteBold),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.teal,
        onPressed: _showComposeSheet,
        child: _posting
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : const Icon(Icons.edit_outlined, color: Colors.white),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.teal))
          : _posts.isEmpty
              ? _EmptyFeed(onCompose: _showComposeSheet)
              : RefreshIndicator(
                  color: AppColors.teal,
                  onRefresh: _load,
                  child: ListView.separated(
                    padding:
                        EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 80.h),
                    itemCount: _posts.length,
                    separatorBuilder: (_, __) => vGap(14),
                    itemBuilder: (context, i) {
                      final post =
                          _posts[i] as Map<String, dynamic>;
                      return _PostCard(
                        post: post,
                        onReact: (emoji) =>
                            _react(post['id'] as int, emoji),
                      );
                    },
                  ),
                ),
    );
  }
}

class _EmptyFeed extends StatelessWidget {
  final VoidCallback onCompose;

  const _EmptyFeed({required this.onCompose});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80.r, color: AppColors.grey),
          vGap(16),
          Text('The community is quiet...', style: AppTextStyles.font16WhiteBold,
              textAlign: TextAlign.center),
          vGap(8),
          Text('Be the first to share a win!',
              style: AppTextStyles.font14GreyRegular,
              textAlign: TextAlign.center),
          vGap(24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.teal,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r)),
            ),
            onPressed: onCompose,
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            label: Text('Share Something',
                style: AppTextStyles.font14WhiteRegular),
          ),
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final Map<String, dynamic> post;
  final void Function(String emoji) onReact;

  const _PostCard({required this.post, required this.onReact});

  static const _reactions = ['💪', '🔥', '🎉'];

  @override
  Widget build(BuildContext context) {
    final author = (post['user'] as Map<String, dynamic>?)?['name'] as String? ?? 'Member';
    final body = post['body'] as String? ?? '';
    final createdAt = post['created_at'] as String?;
    final date = createdAt != null ? DateTime.tryParse(createdAt) : null;
    final timeAgo = date != null ? _timeAgo(date) : '';
    final reactions = (post['reactions'] as Map<String, dynamic>?) ?? {};
    final type = post['type'] as String? ?? 'post';
    final typeIcon = _typeIcon(type);

    return Container(
      decoration: AppDecorations.containerDecoration.copyWith(
        borderRadius: BorderRadius.circular(16.r),
      ),
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CircleAvatar(
                radius: 18.r,
                backgroundColor: AppColors.teal.withValues(alpha: 0.2),
                child: Text(
                  author.isNotEmpty ? author[0].toUpperCase() : '?',
                  style: AppTextStyles.font14WhiteRegular
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              hGap(10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(author,
                        style: AppTextStyles.font14WhiteRegular
                            .copyWith(fontWeight: FontWeight.w600)),
                    Text(timeAgo,
                        style: AppTextStyles.font14GreyRegular
                            .copyWith(fontSize: 10.sp)),
                  ],
                ),
              ),
              if (typeIcon != null)
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: AppColors.emerald.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(typeIcon,
                      style: TextStyle(fontSize: 11.sp)),
                ),
            ],
          ),
          vGap(10),

          // Body
          Text(body,
              style: AppTextStyles.font14GreyRegular.copyWith(height: 1.5)),
          vGap(12),

          // Reactions
          Row(
            children: _reactions.map((emoji) {
              final count =
                  (reactions[emoji] as num?)?.toInt() ?? 0;
              return Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: GestureDetector(
                  onTap: () => onReact(emoji),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 10.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: count > 0
                          ? AppColors.teal.withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: count > 0
                            ? AppColors.teal.withValues(alpha: 0.4)
                            : Colors.white12,
                      ),
                    ),
                    child: Text(
                      '$emoji${count > 0 ? ' $count' : ''}',
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateFormat('MMM d').format(date);
  }

  String? _typeIcon(String type) {
    switch (type) {
      case 'workout_share': return '💪 Workout';
      case 'milestone': return '🏆 Milestone';
      case 'coach_tip': return '👨‍🏫 Coach Tip';
      default: return null;
    }
  }
}
