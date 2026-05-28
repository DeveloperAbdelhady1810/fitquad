import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/services/api_client.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';

// ── Message type ──────────────────────────────────────────────────────────────

enum ChatMsgType {
  text,
  inbodyAttachment,
  analyticsAttachment,
  workoutPlan,
  nutritionPlan;

  static ChatMsgType fromString(String? s) => switch (s) {
        'inbody_attachment'    => inbodyAttachment,
        'analytics_attachment' => analyticsAttachment,
        'workout_plan'         => workoutPlan,
        'nutrition_plan'       => nutritionPlan,
        _                      => text,
      };

  bool get isPlan => this == workoutPlan || this == nutritionPlan;
  bool get isAttachment =>
      this == inbodyAttachment || this == analyticsAttachment;
}

// ── Message model ─────────────────────────────────────────────────────────────

class _ChatMsg {
  final int id;
  final String body;
  final bool isMe;
  final DateTime time;
  final ChatMsgType type;
  final Map<String, dynamic>? payload;
  bool isApplied;

  _ChatMsg({
    required this.id,
    required this.body,
    required this.isMe,
    required this.time,
    required this.type,
    this.payload,
    this.isApplied = false,
  });

  factory _ChatMsg.fromJson(Map<String, dynamic> j) => _ChatMsg(
        id: j['id'] as int? ?? 0,
        body: j['body'] as String? ?? '',
        isMe: (j['sender_role'] as String?) == 'member',
        time: DateTime.tryParse(j['sent_at'] as String? ?? '') ?? DateTime.now(),
        type: ChatMsgType.fromString(j['type'] as String?),
        payload: j['payload'] as Map<String, dynamic>?,
        isApplied: j['is_applied'] as bool? ?? false,
      );
}

// ── Screen ────────────────────────────────────────────────────────────────────

class MemberChatScreen extends StatefulWidget {
  final String coachName;

  const MemberChatScreen({super.key, required this.coachName});

  static const routeName = '/member-chat';

  @override
  State<MemberChatScreen> createState() => _MemberChatScreenState();
}

class _MemberChatScreenState extends State<MemberChatScreen> {
  final _ctrl   = TextEditingController();
  final _scroll = ScrollController();
  List<_ChatMsg> _messages   = [];
  bool _loading  = true;
  bool _sending  = false;
  bool _sendingInBody   = false;
  bool _sendingAnalytics = false;

  List<_ChatMsg> get _plans =>
      _messages.where((m) => m.type.isPlan && !m.isMe).toList();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final res  = await ApiClient.get('/member/messages');
      final data = res['data'] as Map<String, dynamic>? ?? {};
      final list = (data['messages'] as List?) ?? [];
      setState(() {
        _messages = list
            .map((m) => _ChatMsg.fromJson(m as Map<String, dynamic>))
            .toList();
        _loading = false;
      });
      _scrollToBottom();
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _send() async {
    final body = _ctrl.text.trim();
    if (body.isEmpty || _sending) return;
    _ctrl.clear();
    setState(() {
      _sending = true;
      _messages.add(_ChatMsg(
        id: DateTime.now().millisecondsSinceEpoch,
        body: body,
        isMe: true,
        time: DateTime.now(),
        type: ChatMsgType.text,
      ));
    });
    _scrollToBottom();
    try {
      await ApiClient.post('/member/messages', {'body': body});
    } catch (_) {}
    if (mounted) setState(() => _sending = false);
  }

  Future<void> _sendInBody() async {
    if (_sendingInBody) return;
    setState(() => _sendingInBody = true);
    try {
      final res = await ApiClient.post('/member/messages/send-inbody', {});
      final msg = _ChatMsg.fromJson(res['data'] as Map<String, dynamic>);
      setState(() => _messages.add(msg));
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _sendingInBody = false);
    }
  }

  Future<void> _sendAnalytics() async {
    if (_sendingAnalytics) return;
    setState(() => _sendingAnalytics = true);
    try {
      final res = await ApiClient.post('/member/messages/send-analytics', {});
      final msg = _ChatMsg.fromJson(res['data'] as Map<String, dynamic>);
      setState(() => _messages.add(msg));
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _sendingAnalytics = false);
    }
  }

  Future<void> _applyPlan(_ChatMsg msg) async {
    try {
      await ApiClient.post('/member/messages/apply-plan/${msg.id}', {});
      setState(() => msg.isApplied = true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          msg.type == ChatMsgType.workoutPlan
              ? '✅ Workout plan applied! Check the Train tab.'
              : '✅ Nutrition plan applied! Check the Eat tab.',
        ),
        backgroundColor: AppColors.emerald,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to apply: $e'),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  void _showPlansSheet() {
    if (_plans.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No plans received from your coach yet.'),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.secondary,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (_) => _PlansSheet(plans: _plans, onApply: _applyPlan),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final pendingPlans = _plans.where((p) => !p.isApplied).length;

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18.r,
              backgroundColor: AppColors.teal.withValues(alpha: 0.2),
              child: Icon(Icons.sports_gymnastics,
                  size: 16.r, color: AppColors.teal),
            ),
            hGap(10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.coachName,
                    style: AppTextStyles.font14WhiteRegular
                        .copyWith(fontWeight: FontWeight.w600)),
                Text('Your Coach',
                    style: AppTextStyles.font14GreyRegular
                        .copyWith(fontSize: 10.sp, color: AppColors.teal)),
              ],
            ),
          ],
        ),
        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: Icon(Icons.assignment_outlined,
                    color: AppColors.grey, size: 22.r),
                tooltip: 'Plans',
                onPressed: _showPlansSheet,
              ),
              if (pendingPlans > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    width: 16.r,
                    height: 16.r,
                    decoration: BoxDecoration(
                      color: AppColors.teal,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text('$pendingPlans',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
          hGap(4),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.teal))
                : _messages.isEmpty
                    ? _EmptyState(coachName: widget.coachName)
                    : ListView.builder(
                        controller: _scroll,
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 12.h),
                        itemCount: _messages.length,
                        itemBuilder: (_, i) => _MessageRow(
                          msg: _messages[i],
                          onApply: _applyPlan,
                        ),
                      ),
          ),
          _FastReplyBar(
            sendingInBody: _sendingInBody,
            sendingAnalytics: _sendingAnalytics,
            onInBody: _sendInBody,
            onAnalytics: _sendAnalytics,
          ),
          _InputBar(
            ctrl: _ctrl,
            sending: _sending,
            onSend: _send,
          ),
        ],
      ),
    );
  }
}

// ── Message row (dispatcher) ──────────────────────────────────────────────────

class _MessageRow extends StatelessWidget {
  final _ChatMsg msg;
  final void Function(_ChatMsg) onApply;

  const _MessageRow({required this.msg, required this.onApply});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: switch (msg.type) {
        ChatMsgType.inbodyAttachment    => _InBodyBubble(msg: msg),
        ChatMsgType.analyticsAttachment => _AnalyticsBubble(msg: msg),
        ChatMsgType.workoutPlan         => _PlanBubble(msg: msg, onApply: onApply),
        ChatMsgType.nutritionPlan       => _PlanBubble(msg: msg, onApply: onApply),
        _                               => _TextBubble(msg: msg),
      },
    );
  }
}

// ── Text bubble ───────────────────────────────────────────────────────────────

class _TextBubble extends StatelessWidget {
  final _ChatMsg msg;
  const _TextBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    final timeStr = _fmt(msg.time);
    return Row(
      mainAxisAlignment:
          msg.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!msg.isMe) ...[
          CircleAvatar(
            radius: 14.r,
            backgroundColor: AppColors.teal.withValues(alpha: 0.2),
            child: Icon(Icons.sports_gymnastics,
                size: 14.r, color: AppColors.teal),
          ),
          hGap(8),
        ],
        Flexible(
          child: Column(
            crossAxisAlignment:
                msg.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: msg.isMe
                      ? AppColors.teal.withValues(alpha: 0.85)
                      : AppColors.secondary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.r),
                    topRight: Radius.circular(16.r),
                    bottomLeft:
                        msg.isMe ? Radius.circular(16.r) : Radius.circular(4.r),
                    bottomRight:
                        msg.isMe ? Radius.circular(4.r) : Radius.circular(16.r),
                  ),
                  border: msg.isMe ? null : Border.all(color: Colors.white12),
                ),
                child: Text(msg.body,
                    style: AppTextStyles.font14WhiteRegular
                        .copyWith(height: 1.4, color: Colors.white)),
              ),
              vGap(3),
              Text(timeStr,
                  style: AppTextStyles.font14GreyRegular
                      .copyWith(fontSize: 10.sp)),
            ],
          ),
        ),
        if (msg.isMe) hGap(8),
      ],
    );
  }
}

// ── InBody premium bubble ─────────────────────────────────────────────────────

class _InBodyBubble extends StatelessWidget {
  final _ChatMsg msg;
  const _InBodyBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    final p = msg.payload ?? {};
    return Align(
      alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: 0.78.sw),
        margin: EdgeInsets.only(
            left: msg.isMe ? 40.w : 0, right: msg.isMe ? 0 : 40.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.teal.withValues(alpha: 0.25),
              AppColors.teal.withValues(alpha: 0.10),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.teal.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PremiumHeader(
              icon: Icons.monitor_weight_outlined,
              label: 'In-Body Results',
              color: AppColors.teal,
              time: _fmt(msg.time),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 4.h, 14.w, 14.h),
              child: Wrap(
                spacing: 12.w,
                runSpacing: 8.h,
                children: [
                  if (p['weight'] != null)
                    _Stat('Weight', '${p['weight']} kg', AppColors.teal),
                  if (p['body_fat_pct'] != null)
                    _Stat('Body Fat', '${p['body_fat_pct']}%', AppColors.red),
                  if (p['muscle_mass'] != null)
                    _Stat('Muscle', '${p['muscle_mass']} kg', AppColors.emerald),
                  if (p['bmi'] != null)
                    _Stat('BMI', '${p['bmi']}', AppColors.blue),
                  if (p['visceral_fat'] != null)
                    _Stat('Visceral Fat', '${p['visceral_fat']}', AppColors.purple),
                  if (p['inbody_score'] != null)
                    _Stat('Score', '${p['inbody_score']}', AppColors.teal),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Analytics premium bubble ──────────────────────────────────────────────────

class _AnalyticsBubble extends StatelessWidget {
  final _ChatMsg msg;
  const _AnalyticsBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    final p = msg.payload ?? {};
    return Align(
      alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: 0.78.sw),
        margin: EdgeInsets.only(
            left: msg.isMe ? 40.w : 0, right: msg.isMe ? 0 : 40.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.purple.withValues(alpha: 0.25),
              AppColors.purple.withValues(alpha: 0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.purple.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PremiumHeader(
              icon: Icons.watch_outlined,
              label: 'Smart Watch Analytics',
              color: AppColors.purple,
              time: _fmt(msg.time),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 4.h, 14.w, 14.h),
              child: Wrap(
                spacing: 12.w,
                runSpacing: 8.h,
                children: [
                  if (p['steps'] != null)
                    _Stat('Steps', _n(p['steps']), AppColors.purple),
                  if (p['active_minutes'] != null)
                    _Stat('Active', '${p['active_minutes']} min', AppColors.blue),
                  if (p['calories_burned'] != null)
                    _Stat('Calories', '${p['calories_burned']} kcal', AppColors.red),
                  if (p['heart_rate_avg'] != null)
                    _Stat('Avg HR', '${p['heart_rate_avg']} bpm', AppColors.red),
                  if (p['sleep_hours'] != null)
                    _Stat('Sleep', '${p['sleep_hours']} hrs', AppColors.blue),
                  if (p['water_liters'] != null)
                    _Stat('Water', '${p['water_liters']} L', AppColors.teal),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Plan premium bubble ───────────────────────────────────────────────────────

class _PlanBubble extends StatelessWidget {
  final _ChatMsg msg;
  final void Function(_ChatMsg) onApply;

  const _PlanBubble({required this.msg, required this.onApply});

  @override
  Widget build(BuildContext context) {
    final isWorkout = msg.type == ChatMsgType.workoutPlan;
    final color     = isWorkout ? AppColors.blue : AppColors.emerald;
    final p         = msg.payload ?? {};
    final title     = p['title'] as String? ?? msg.body;
    final desc      = p['description'] as String? ?? '';
    final days      = (p['days'] as List?)?.cast<Map>() ?? [];
    final meals     = (p['meals'] as List?)?.cast<Map>() ?? [];

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: 0.82.sw),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.22),
              color.withValues(alpha: 0.06),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PremiumHeader(
              icon: isWorkout
                  ? Icons.fitness_center_outlined
                  : Icons.restaurant_outlined,
              label: isWorkout ? 'Workout Plan from Coach' : 'Nutrition Plan from Coach',
              color: color,
              time: _fmt(msg.time),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTextStyles.font16WhiteBold
                          .copyWith(fontSize: 14.sp)),
                  if (desc.isNotEmpty) ...[
                    vGap(4),
                    Text(desc,
                        style: AppTextStyles.font14GreyRegular
                            .copyWith(fontSize: 12.sp),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ],
                  vGap(8),
                  // Preview items
                  if (isWorkout && days.isNotEmpty)
                    ...days.take(3).map((d) => _PlanItem(
                        icon: Icons.calendar_today_outlined,
                        text: d['day_name'] as String? ?? '',
                        color: color))
                  else if (!isWorkout && meals.isNotEmpty)
                    ...meals.take(3).map((m) => _PlanItem(
                        icon: Icons.restaurant_menu_outlined,
                        text: m['name'] as String? ?? '',
                        color: color)),
                  if ((isWorkout ? days : meals).length > 3)
                    Padding(
                      padding: EdgeInsets.only(top: 4.h),
                      child: Text(
                        '+ ${(isWorkout ? days : meals).length - 3} more…',
                        style: AppTextStyles.font14GreyRegular
                            .copyWith(fontSize: 11.sp),
                      ),
                    ),
                  vGap(12),
                ],
              ),
            ),
            // Apply button
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
              child: msg.isApplied
                  ? Row(
                      children: [
                        Icon(Icons.check_circle,
                            color: AppColors.emerald, size: 16.r),
                        hGap(6),
                        Text('Plan Applied',
                            style: AppTextStyles.font14GreyRegular.copyWith(
                                color: AppColors.emerald,
                                fontWeight: FontWeight.w600)),
                      ],
                    )
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => onApply(msg),
                        icon: Icon(Icons.check_circle_outline, size: 16.r),
                        label: Text('Apply ${isWorkout ? 'Workout' : 'Nutrition'} Plan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r)),
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          textStyle: AppTextStyles.font14WhiteRegular
                              .copyWith(fontWeight: FontWeight.w600, fontSize: 13.sp),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Plans bottom sheet ────────────────────────────────────────────────────────

class _PlansSheet extends StatelessWidget {
  final List<_ChatMsg> plans;
  final void Function(_ChatMsg) onApply;

  const _PlansSheet({required this.plans, required this.onApply});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.92,
      minChildSize: 0.4,
      expand: false,
      builder: (_, ctrl) => Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 0),
            child: Row(
              children: [
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                const Spacer(),
                Text('Plans from Coach',
                    style: AppTextStyles.font16WhiteBold),
                const Spacer(),
                SizedBox(width: 40.w),
              ],
            ),
          ),
          vGap(12),
          Expanded(
            child: ListView.separated(
              controller: ctrl,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              itemCount: plans.length,
              separatorBuilder: (_, __) => vGap(10),
              itemBuilder: (_, i) => _PlanBubble(
                msg: plans[i],
                onApply: onApply,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Fast reply bar ────────────────────────────────────────────────────────────

class _FastReplyBar extends StatelessWidget {
  final bool sendingInBody;
  final bool sendingAnalytics;
  final VoidCallback onInBody;
  final VoidCallback onAnalytics;

  const _FastReplyBar({
    required this.sendingInBody,
    required this.sendingAnalytics,
    required this.onInBody,
    required this.onAnalytics,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.secondary,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Row(
        children: [
          _FastChip(
            icon: Icons.monitor_weight_outlined,
            label: 'Attach In-Body',
            color: AppColors.teal,
            loading: sendingInBody,
            onTap: onInBody,
          ),
          hGap(8),
          _FastChip(
            icon: Icons.watch_outlined,
            label: 'Send Analytics',
            color: AppColors.purple,
            loading: sendingAnalytics,
            onTap: onAnalytics,
          ),
        ],
      ),
    );
  }
}

class _FastChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool loading;
  final VoidCallback onTap;

  const _FastChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: loading ? 0.06 : 0.12),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            loading
                ? SizedBox(
                    width: 12.r,
                    height: 12.r,
                    child: CircularProgressIndicator(
                        strokeWidth: 1.5, color: color),
                  )
                : Icon(icon, color: color, size: 14.r),
            hGap(6),
            Text(label,
                style: AppTextStyles.font14GreyRegular.copyWith(
                    color: loading
                        ? color.withValues(alpha: 0.5)
                        : color,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// ── Input bar ─────────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  final TextEditingController ctrl;
  final bool sending;
  final VoidCallback onSend;

  const _InputBar({
      required this.ctrl, required this.sending, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        color: AppColors.secondary,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: ctrl,
                style: const TextStyle(color: Colors.white),
                maxLines: null,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: 'Type a message…',
                  hintStyle: AppTextStyles.font14GreyRegular,
                  filled: true,
                  fillColor: AppColors.primary,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.r),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            hGap(8),
            GestureDetector(
              onTap: sending ? null : onSend,
              child: Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                    color: AppColors.teal, shape: BoxShape.circle),
                child: sending
                    ? Padding(
                        padding: EdgeInsets.all(12.r),
                        child: const CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Icon(Icons.send_rounded, color: Colors.white, size: 20.r),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared sub-widgets ────────────────────────────────────────────────────────

class _PremiumHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String time;

  const _PremiumHeader({
    required this.icon,
    required this.label,
    required this.color,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 10.h),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16.r),
          hGap(6),
          Expanded(
            child: Text(label,
                style: AppTextStyles.font14WhiteRegular.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.sp)),
          ),
          Text(time,
              style: AppTextStyles.font14GreyRegular.copyWith(fontSize: 10.sp)),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _Stat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTextStyles.font14GreyRegular
                  .copyWith(fontSize: 9.sp, color: Colors.white38)),
          vGap(2),
          Text(value,
              style: AppTextStyles.font14WhiteRegular.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp)),
        ],
      ),
    );
  }
}

class _PlanItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _PlanItem({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        children: [
          Icon(icon, color: color, size: 12.r),
          hGap(6),
          Expanded(
            child: Text(text,
                style: AppTextStyles.font14GreyRegular
                    .copyWith(fontSize: 12.sp, color: Colors.white70),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String coachName;
  const _EmptyState({required this.coachName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, color: AppColors.grey, size: 56.r),
          vGap(16),
          Text('No messages yet', style: AppTextStyles.font16WhiteBold),
          vGap(8),
          Text('Say hi to $coachName!',
              style: AppTextStyles.font14GreyRegular,
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

String _fmt(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

String _n(dynamic v) {
  final n = (v as num?)?.toInt() ?? 0;
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
  return '$n';
}
