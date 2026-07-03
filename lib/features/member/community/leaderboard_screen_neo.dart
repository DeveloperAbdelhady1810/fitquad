import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/services/api_client.dart';
import 'package:gym_app/core/theme/neo_theme.dart';

class LeaderboardScreenNeo extends StatefulWidget {
  const LeaderboardScreenNeo({super.key});

  static const routeName = '/leaderboard-neo';

  @override
  State<LeaderboardScreenNeo> createState() => _LeaderboardScreenNeoState();
}

class _LeaderboardScreenNeoState extends State<LeaderboardScreenNeo>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  final _categories = [
    ('check_ins', '📍', 'CHECK-INS'),
    ('streak', '🔥', 'STREAK'),
    ('xp', '⭐', 'XP'),
  ];

  final Map<String, List<dynamic>> _data = {};
  final Map<String, bool> _loading = {};

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: _categories.length, vsync: this);
    _tab.addListener(() { if (!_tab.indexIsChanging) _loadTab(_tab.index); });
    _loadTab(0);
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  Future<void> _loadTab(int index) async {
    final cat = _categories[index].$1;
    if (_data.containsKey(cat)) return;
    setState(() => _loading[cat] = true);
    try {
      final res = await ApiClient.get('/member/leaderboard', query: {'category': cat});
      if (mounted) setState(() { _data[cat] = (res['data'] as List?) ?? []; _loading[cat] = false; });
    } catch (_) {
      if (mounted) setState(() => _loading[cat] = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoColors.bg,
      appBar: AppBar(
        backgroundColor: NeoColors.bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: NeoColors.cyan),
        title: Text('LEADERBOARD', style: NeoTextStyles.headlineSm.copyWith(color: NeoColors.cyan)),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(44.h),
          child: TabBar(
            controller: _tab,
            indicatorColor: NeoColors.cyan,
            indicatorWeight: 2,
            labelColor: NeoColors.cyan,
            unselectedLabelColor: NeoColors.outline,
            labelStyle: NeoTextStyles.labelCaps.copyWith(color: NeoColors.cyan),
            unselectedLabelStyle: NeoTextStyles.labelCaps,
            tabs: _categories.map((c) => Tab(text: '${c.$2} ${c.$3}')).toList(),
          ),
        ),
      ),
      body: Stack(
        children: [
          CustomPaint(painter: _GridPainter(), child: const SizedBox.expand()),
          TabBarView(
            controller: _tab,
            children: _categories.map((c) {
              final cat = c.$1;
              if (_loading[cat] == true) {
                return Center(child: CircularProgressIndicator(color: NeoColors.cyan));
              }
              final entries = (_data[cat] ?? []).cast<Map<String, dynamic>>();
              if (entries.isEmpty) {
                return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.emoji_events_outlined, color: NeoColors.outline, size: 40.r),
                  vGap(12),
                  Text('NO DATA YET', style: NeoTextStyles.headlineSm.copyWith(color: NeoColors.outline)),
                ]));
              }
              return _LeaderList(entries: entries, cat: cat);
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _LeaderList extends StatelessWidget {
  final List<Map<String, dynamic>> entries;
  final String cat;
  const _LeaderList({required this.entries, required this.cat});

  @override
  Widget build(BuildContext context) {
    final top3 = entries.take(3).toList();
    final rest = entries.skip(3).toList();
    return ListView(
      padding: EdgeInsets.all(16.r),
      children: [
        if (top3.length >= 3) _Podium(top3: top3, cat: cat),
        vGap(20),
        Row(children: [
          Container(width: 3.w, height: 16.h, color: NeoColors.cyan),
          hGap(8),
          Text('CHALLENGERS', style: NeoTextStyles.labelCaps.copyWith(color: NeoColors.cyan)),
        ]),
        vGap(12),
        ...rest.asMap().entries.map((e) => _LeaderRow(rank: e.key + 4, data: e.value, cat: cat)),
      ],
    );
  }
}

class _Podium extends StatelessWidget {
  final List<Map<String, dynamic>> top3;
  final String cat;
  const _Podium({required this.top3, required this.cat});

  @override
  Widget build(BuildContext context) {
    final order = [top3[1], top3[0], top3[2]];
    final heights = [64.0, 96.0, 48.0];
    final ranks = [2, 1, 3];
    final borderColors = [NeoColors.outline, NeoColors.cyan, NeoColors.magenta];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(3, (i) {
        final entry = order[i];
        final name = entry['name'] as String? ?? entry['member']?['name'] as String? ?? '?';
        final avatarUrl = entry['avatar'] as String? ?? entry['member']?['avatar'] as String?;
        final val = _val(entry, cat);
        final avatarSize = ranks[i] == 1 ? 80.r : 60.r;
        return Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: avatarSize / 2,
                    backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                    backgroundColor: NeoColors.surfaceHigh,
                    child: avatarUrl == null ? Icon(Icons.person, color: NeoColors.outline, size: avatarSize * 0.4) : null,
                  ),
                  Positioned(
                    bottom: -6,
                    right: -6,
                    child: Container(
                      width: 22.r, height: 22.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: borderColors[i],
                        border: Border.all(color: NeoColors.bg, width: 2),
                      ),
                      child: Center(child: Text(
                        '${ranks[i]}',
                        style: GoogleFonts.jetBrainsMono(fontSize: 10.sp, fontWeight: FontWeight.w800, color: Colors.black),
                      )),
                    ),
                  ),
                ],
              ),
              vGap(8),
              Text(name.toUpperCase(), style: NeoTextStyles.headlineSm.copyWith(
                fontSize: 11.sp,
                color: ranks[i] == 1 ? NeoColors.cyan : NeoColors.onSurface,
              ), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
              Text(val, style: NeoTextStyles.dataSm.copyWith(color: borderColors[i])),
              vGap(6),
              Container(
                height: heights[i].h,
                decoration: BoxDecoration(
                  color: borderColors[i].withValues(alpha: 0.08),
                  border: Border(top: BorderSide(color: borderColors[i], width: 2)),
                  boxShadow: ranks[i] == 1
                      ? [BoxShadow(color: NeoColors.cyan.withValues(alpha: 0.2), blurRadius: 10)]
                      : [],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  String _val(Map<String, dynamic> e, String cat) {
    final v = e['value'] ?? e[cat] ?? e['xp'] ?? e['check_ins'] ?? e['streak'] ?? 0;
    return '$v ${cat == "xp" ? "XP" : cat == "check_ins" ? "visits" : "days"}';
  }
}

class _LeaderRow extends StatelessWidget {
  final int rank;
  final Map<String, dynamic> data;
  final String cat;
  const _LeaderRow({required this.rank, required this.data, required this.cat});

  @override
  Widget build(BuildContext context) {
    final name = data['name'] as String? ?? data['member']?['name'] as String? ?? '?';
    final avatarUrl = data['avatar'] as String? ?? data['member']?['avatar'] as String?;
    final val = data['value'] ?? data[cat] ?? data['xp'] ?? 0;
    final isMe = data['is_current_user'] == true;

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: isMe ? const Color(0x1A00F3FF) : const Color(0x66201F21),
              border: isMe
                  ? const Border(left: BorderSide(color: NeoColors.cyan, width: 4))
                  : Border.all(color: const Color(0x1500DCE6)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 28.w,
                  child: Text(
                    '$rank',
                    style: GoogleFonts.jetBrainsMono(fontSize: 13.sp, color: NeoColors.outline),
                  ),
                ),
                CircleAvatar(
                  radius: 18.r,
                  backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                  backgroundColor: NeoColors.surfaceHigh,
                  child: avatarUrl == null ? Icon(Icons.person, size: 14.r, color: NeoColors.outline) : null,
                ),
                hGap(10),
                Expanded(child: Text(
                  name,
                  style: NeoTextStyles.bodyLg.copyWith(color: isMe ? NeoColors.cyan : NeoColors.onSurface, fontSize: 14.sp),
                )),
                Text(
                  '$val ${cat == "xp" ? "XP" : cat == "check_ins" ? "visits" : "days"}',
                  style: GoogleFonts.jetBrainsMono(fontSize: 12.sp, color: NeoColors.cyan),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0x0500DCE6)..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 20) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += 20) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => false;
}
