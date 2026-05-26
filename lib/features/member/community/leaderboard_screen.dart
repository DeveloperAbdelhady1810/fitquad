import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/helpers/app_decoration.dart';
import '../../../core/helpers/spacing.dart';
import '../../../core/services/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  static const routeName = '/leaderboard';

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _categories = [
    _LeaderCategory('check_ins', '📍', 'Most Check-ins'),
    _LeaderCategory('streak', '🔥', 'Longest Streak'),
    _LeaderCategory('xp', '⭐', 'Most XP'),
  ];

  final Map<String, List<dynamic>> _data = {};
  final Map<String, bool> _loading = {};

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: _categories.length, vsync: this);
    _tab.addListener(() {
      if (!_tab.indexIsChanging) _loadTab(_tab.index);
    });
    _loadTab(0);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _loadTab(int index) async {
    final cat = _categories[index].key;
    if (_data.containsKey(cat)) return;
    setState(() => _loading[cat] = true);
    try {
      final res = await ApiClient.get('/member/leaderboard',
          query: {'category': cat});
      if (mounted) {
        setState(() {
          _data[cat] = (res['data'] as List?) ?? [];
          _loading[cat] = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading[cat] = false);
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
        title: Text('Leaderboard', style: AppTextStyles.font16WhiteBold),
        bottom: TabBar(
          controller: _tab,
          indicatorColor: AppColors.teal,
          labelColor: AppColors.teal,
          unselectedLabelColor: AppColors.grey,
          tabs: _categories
              .map((c) => Tab(text: '${c.emoji} ${c.label}'))
              .toList(),
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: _categories.asMap().entries.map((entry) {
          final cat = entry.value.key;
          final isLoading = _loading[cat] == true;
          final rows = _data[cat] ?? [];

          if (isLoading) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.teal));
          }
          if (rows.isEmpty) {
            return _EmptyLeader(emoji: entry.value.emoji);
          }

          return ListView.separated(
            padding: EdgeInsets.all(16.r),
            itemCount: rows.length,
            separatorBuilder: (_, __) => vGap(10),
            itemBuilder: (context, i) {
              final row = rows[i] as Map<String, dynamic>;
              final isMe = row['is_me'] == true;
              return _LeaderRow(
                rank: i + 1,
                name: row['name'] as String? ?? 'Member',
                value: row['value']?.toString() ?? '0',
                unit: entry.value.unit,
                isMe: isMe,
              );
            },
          );
        }).toList(),
      ),
    );
  }
}

class _LeaderCategory {
  final String key;
  final String emoji;
  final String label;

  const _LeaderCategory(this.key, this.emoji, this.label);

  String get unit {
    switch (key) {
      case 'check_ins': return 'check-ins';
      case 'streak': return 'days';
      case 'xp': return 'XP';
      default: return '';
    }
  }
}

class _LeaderRow extends StatelessWidget {
  final int rank;
  final String name;
  final String value;
  final String unit;
  final bool isMe;

  const _LeaderRow({
    required this.rank,
    required this.name,
    required this.value,
    required this.unit,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final rankColor = rank == 1
        ? Colors.amber
        : rank == 2
            ? Colors.grey.shade300
            : rank == 3
                ? const Color(0xFFCD7F32)
                : AppColors.grey;

    final rankEmoji = rank == 1
        ? '🥇'
        : rank == 2
            ? '🥈'
            : rank == 3
                ? '🥉'
                : '$rank';

    return Container(
      decoration: AppDecorations.containerDecoration.copyWith(
        borderRadius: BorderRadius.circular(14.r),
        border: isMe
            ? Border.all(color: AppColors.teal.withValues(alpha: 0.6))
            : null,
        color: isMe
            ? AppColors.teal.withValues(alpha: 0.08)
            : null,
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          SizedBox(
            width: 36.w,
            child: Text(
              rankEmoji,
              style: TextStyle(
                  fontSize: rank <= 3 ? 22.sp : 14.sp,
                  color: rankColor,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          hGap(12),
          CircleAvatar(
            radius: 18.r,
            backgroundColor: isMe
                ? AppColors.teal.withValues(alpha: 0.2)
                : AppColors.secondary,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: AppTextStyles.font14WhiteRegular
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          hGap(12),
          Expanded(
            child: Text(
              isMe ? '$name (You)' : name,
              style: AppTextStyles.font14WhiteRegular.copyWith(
                fontWeight: isMe ? FontWeight.w700 : FontWeight.normal,
                color: isMe ? AppColors.teal : Colors.white,
              ),
            ),
          ),
          Text(
            '$value $unit',
            style: AppTextStyles.font14GreyRegular.copyWith(
              color: rank <= 3 ? rankColor : AppColors.grey,
              fontWeight: rank <= 3 ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyLeader extends StatelessWidget {
  final String emoji;

  const _EmptyLeader({required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: TextStyle(fontSize: 60.sp)),
          vGap(16),
          Text('No data yet', style: AppTextStyles.font16WhiteBold),
          vGap(8),
          Text('Be the first to top the leaderboard!',
              style: AppTextStyles.font14GreyRegular),
        ],
      ),
    );
  }
}
