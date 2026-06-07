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

class _CommunityFeedScreenState extends State<CommunityFeedScreen>
    with SingleTickerProviderStateMixin {
  List<dynamic> _posts = [];
  bool _loading = true;
  bool _posting = false;
  late AnimationController _fabAnim;

  @override
  void initState() {
    super.initState();
    _fabAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _load();
  }

  @override
  void dispose() {
    _fabAnim.dispose();
    super.dispose();
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
        _fabAnim.forward();
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _react(int postId, String emoji) async {
    try {
      await ApiClient.post('/member/community/posts/$postId/react', {'type': emoji});
      _load();
    } catch (_) {}
  }

  Future<void> _showComposeSheet() async {
    final ctrl = TextEditingController();
    String? selectedType = 'post';

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            border: Border(top: BorderSide(color: AppColors.teal.withValues(alpha: 0.3), width: 1.5)),
          ),
          padding: EdgeInsets.only(
            left: 20.w, right: 20.w, top: 20.h,
            bottom: MediaQuery.viewInsetsOf(ctx).bottom + 20.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w, height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              vGap(16),
              Row(
                children: [
                  Container(
                    width: 36.r, height: 36.r,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [AppColors.teal, AppColors.blue]),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.edit_outlined, color: Colors.white, size: 16.r),
                  ),
                  hGap(12),
                  Text('Share with the community', style: AppTextStyles.font16WhiteBold),
                ],
              ),
              vGap(16),
              // Post type chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _TypeChip(
                      label: '💪 Workout Win',
                      selected: selectedType == 'workout_share',
                      onTap: () => setLocal(() => selectedType = 'workout_share'),
                    ),
                    hGap(8),
                    _TypeChip(
                      label: '🏆 Milestone',
                      selected: selectedType == 'milestone',
                      onTap: () => setLocal(() => selectedType = 'milestone'),
                    ),
                    hGap(8),
                    _TypeChip(
                      label: '💬 General',
                      selected: selectedType == 'post',
                      onTap: () => setLocal(() => selectedType = 'post'),
                    ),
                  ],
                ),
              ),
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
                  counterStyle: AppTextStyles.font14GreyRegular.copyWith(fontSize: 10.sp),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppColors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppColors.grey.withValues(alpha: 0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppColors.teal, width: 1.5),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  onPressed: () async {
                    final body = ctrl.text.trim();
                    if (body.isEmpty) return;
                    Navigator.pop(ctx);
                    setState(() => _posting = true);
                    try {
                      await ApiClient.post('/member/community/posts', {
                        'body': body,
                        'type': selectedType ?? 'post',
                      });
                      await _load();
                    } catch (_) {}
                    if (mounted) setState(() => _posting = false);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.send_rounded, size: 16.r),
                      hGap(8),
                      Text('Post to Community', style: AppTextStyles.font16WhiteBold),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            expandedHeight: 140.h,
            floating: true,
            snap: true,
            pinned: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0a1628), Color(0xFF020618)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Text('👥', style: TextStyle(fontSize: 28.sp)),
                            hGap(12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Community',
                                    style: AppTextStyles.font16WhiteBold
                                        .copyWith(fontSize: 20.sp)),
                                Text('${_posts.length} posts · Share your wins',
                                    style: AppTextStyles.font14GreyRegular
                                        .copyWith(fontSize: 11.sp)),
                              ],
                            ),
                          ],
                        ),
                        vGap(12),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          if (_loading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: AppColors.teal)),
            )
          else if (_posts.isEmpty)
            SliverFillRemaining(child: _EmptyFeed(onCompose: _showComposeSheet))
          else
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => Padding(
                    padding: EdgeInsets.only(bottom: 14.h),
                    child: _PostCard(
                      post: _posts[i] as Map<String, dynamic>,
                      onReact: (emoji) => _react((_posts[i] as Map)['id'] as int, emoji),
                    ),
                  ),
                  childCount: _posts.length,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: CurvedAnimation(parent: _fabAnim, curve: Curves.elasticOut),
        child: FloatingActionButton.extended(
          backgroundColor: AppColors.teal,
          onPressed: _showComposeSheet,
          icon: _posting
              ? const SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Icon(Icons.edit_outlined, color: Colors.white),
          label: Text('Share', style: AppTextStyles.font14WhiteRegular),
        ),
      ),
    );
  }
}

// ── Type chip ────────────────────────────────────────────────────────────────

class _TypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TypeChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.teal : AppColors.primary,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: selected ? AppColors.teal : AppColors.grey.withValues(alpha: 0.3),
          ),
        ),
        child: Text(label,
            style: AppTextStyles.font14GreyRegular.copyWith(
              color: selected ? Colors.white : AppColors.grey,
              fontSize: 12.sp,
            )),
      ),
    );
  }
}

// ── Empty state ──────────────────────────────────────────────────────────────

class _EmptyFeed extends StatelessWidget {
  final VoidCallback onCompose;

  const _EmptyFeed({required this.onCompose});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100.r, height: 100.r,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [AppColors.teal.withValues(alpha: 0.2), Colors.transparent],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.people_outline, size: 52.r, color: AppColors.teal),
          ),
          vGap(20),
          Text('The gym is quiet...', style: AppTextStyles.font16WhiteBold, textAlign: TextAlign.center),
          vGap(8),
          Text('Be the first to fire up the community!',
              style: AppTextStyles.font14GreyRegular, textAlign: TextAlign.center),
          vGap(28),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.teal,
              padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 14.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
            ),
            onPressed: onCompose,
            icon: const Icon(Icons.bolt_rounded, color: Colors.white),
            label: Text('Start the Conversation', style: AppTextStyles.font14WhiteRegular),
          ),
        ],
      ),
    );
  }
}

// ── Post card ────────────────────────────────────────────────────────────────

class _PostCard extends StatefulWidget {
  final Map<String, dynamic> post;
  final void Function(String emoji) onReact;

  const _PostCard({required this.post, required this.onReact});

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> with SingleTickerProviderStateMixin {
  late AnimationController _reactAnim;
  String? _lastReacted;

  @override
  void initState() {
    super.initState();
    _reactAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    _reactAnim.dispose();
    super.dispose();
  }

  void _handleReact(String emoji) {
    setState(() => _lastReacted = emoji);
    _reactAnim.forward(from: 0);
    widget.onReact(emoji);
  }

  static const _reactions = ['💪', '🔥', '🎉'];

  @override
  Widget build(BuildContext context) {
    final author = (widget.post['user'] as Map<String, dynamic>?)?['name'] as String? ?? 'Member';
    final body = widget.post['body'] as String? ?? '';
    final createdAt = widget.post['created_at'] as String?;
    final date = createdAt != null ? DateTime.tryParse(createdAt) : null;
    final timeAgo = date != null ? _timeAgo(date) : '';
    final rawReactions = widget.post['reactions'];
    final reactions = rawReactions is Map<String, dynamic> ? rawReactions : <String, dynamic>{};
    final type = widget.post['type'] as String? ?? 'post';
    final totalReactions = _reactions.fold<int>(
        0, (sum, e) => sum + ((reactions[e] as num?)?.toInt() ?? 0));

    final accentColor = _typeAccent(type);
    final initials = author.trim().split(' ').take(2)
        .map((p) => p.isNotEmpty ? p[0].toUpperCase() : '').join();

    return Container(
      decoration: AppDecorations.containerDecoration.copyWith(
        borderRadius: BorderRadius.circular(16.r),
        border: Border(
          left: BorderSide(color: accentColor, width: 3),
          right: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
          top: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 14.w, 0),
            child: Row(
              children: [
                // Avatar with gradient
                Container(
                  width: 40.r, height: 40.r,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accentColor.withValues(alpha: 0.8), accentColor.withValues(alpha: 0.4)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      initials.isEmpty ? '?' : initials,
                      style: AppTextStyles.font14WhiteRegular.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.sp,
                      ),
                    ),
                  ),
                ),
                hGap(12),
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
                // Type badge
                if (type != 'post')
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: accentColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      _typeLabel(type),
                      style: TextStyle(fontSize: 10.sp, color: accentColor),
                    ),
                  ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
            child: Text(
              body,
              style: AppTextStyles.font14GreyRegular.copyWith(height: 1.6, fontSize: 13.5.sp),
            ),
          ),

          // Separator
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
            child: Divider(color: Colors.white.withValues(alpha: 0.07), height: 1),
          ),

          // Reactions row
          Padding(
            padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
            child: Row(
              children: [
                ..._reactions.map((emoji) {
                  final count = (reactions[emoji] as num?)?.toInt() ?? 0;
                  final isMine = _lastReacted == emoji;
                  return Padding(
                    padding: EdgeInsets.only(right: 6.w),
                    child: GestureDetector(
                      onTap: () => _handleReact(emoji),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: (count > 0 || isMine)
                              ? accentColor.withValues(alpha: 0.18)
                              : Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: (count > 0 || isMine)
                                ? accentColor.withValues(alpha: 0.45)
                                : Colors.white12,
                            width: isMine ? 1.5 : 1,
                          ),
                        ),
                        child: Text(
                          '$emoji${count > 0 ? '  $count' : ''}',
                          style: TextStyle(fontSize: 13.sp),
                        ),
                      ),
                    ),
                  );
                }),
                const Spacer(),
                if (totalReactions > 0)
                  Text(
                    '$totalReactions reaction${totalReactions != 1 ? 's' : ''}',
                    style: AppTextStyles.font14GreyRegular.copyWith(fontSize: 10.sp),
                  ),
              ],
            ),
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
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(date);
  }

  Color _typeAccent(String type) {
    switch (type) {
      case 'workout_share': return AppColors.teal;
      case 'milestone': return const Color(0xFFFFD700);
      case 'coach_tip': return AppColors.purple;
      default: return AppColors.blue;
    }
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'workout_share': return '💪 Workout';
      case 'milestone': return '🏆 Milestone';
      case 'coach_tip': return '👨‍🏫 Coach Tip';
      default: return '';
    }
  }
}
