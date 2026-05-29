import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/services/api_client.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';
import 'package:gym_app/features/coach/chat/widgets/send_plan_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Message type ──────────────────────────────────────────────────────────────

enum _MsgType {
  text,
  inbodyAttachment,
  analyticsAttachment,
  workoutPlan,
  nutritionPlan,
  deleted;

  static _MsgType fromString(String? s) => switch (s) {
        'inbody_attachment'    => inbodyAttachment,
        'analytics_attachment' => analyticsAttachment,
        'workout_plan'         => workoutPlan,
        'nutrition_plan'       => nutritionPlan,
        'deleted'              => deleted,
        _                      => text,
      };
}

class _Msg {
  final int id;
  final String body;
  final bool isCoach;
  final DateTime time;
  final _MsgType type;
  final Map<String, dynamic>? payload;
  final bool isApplied;

  const _Msg({
    required this.id,
    required this.body,
    required this.isCoach,
    required this.time,
    required this.type,
    this.payload,
    this.isApplied = false,
  });

  factory _Msg.fromJson(Map<String, dynamic> j) => _Msg(
        id: j['id'] as int? ?? 0,
        body: j['body'] as String? ?? '',
        isCoach: (j['sender_role'] as String?) == 'coach',
        time: DateTime.tryParse(j['sent_at'] as String? ?? '') ?? DateTime.now(),
        type: _MsgType.fromString(j['type'] as String?),
        payload: j['payload'] as Map<String, dynamic>?,
        isApplied: j['is_applied'] as bool? ?? false,
      );
}

// ── Screen ────────────────────────────────────────────────────────────────────

class CoachChatThreadScreen extends StatefulWidget {
  final int memberId;
  final String memberName;
  final int? memberUserId;

  const CoachChatThreadScreen({
    super.key,
    required this.memberId,
    required this.memberName,
    this.memberUserId,
  });

  static const routeName = '/coach-chat-thread';

  @override
  State<CoachChatThreadScreen> createState() => _CoachChatThreadScreenState();
}

class _CoachChatThreadScreenState extends State<CoachChatThreadScreen> {
  final _ctrl   = TextEditingController();
  final _scroll = ScrollController();
  List<_Msg> _messages   = [];
  bool _loading       = true;
  bool _sending       = false;
  bool _showTemplates = false;
  bool _safetyAlertShown = true;
  int? _memberUserId;
  Timer? _pollTimer;

  static const _templates = [
    'Great job today! 💪',
    "Don't forget to log your meals",
    'Rest day — stretch and sleep 🙏',
    'How are you feeling after the workout?',
    'Check in with me after your session!',
    'Your new plan is ready — check the Train tab!',
  ];

  @override
  void initState() {
    super.initState();
    _memberUserId = widget.memberUserId;
    _load();
    _pollTimer = Timer.periodic(const Duration(seconds: 4), (_) => _poll());
    _checkSafetyAlert();
  }

  Future<void> _checkSafetyAlert() async {
    final prefs = await SharedPreferences.getInstance();
    final shown = prefs.getBool('coach_chat_safety_alert_shown') ?? false;
    if (!shown && mounted) setState(() => _safetyAlertShown = false);
  }

  Future<void> _dismissSafetyAlert() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('coach_chat_safety_alert_shown', true);
    if (mounted) setState(() => _safetyAlertShown = true);
  }

  Future<void> _deleteMessage(_Msg msg) async {
    try {
      await ApiClient.delete('/coach/messages/${msg.id}');
      if (mounted) {
        setState(() {
          final idx = _messages.indexOf(msg);
          if (idx >= 0) {
            _messages[idx] = _Msg(
              id: msg.id,
              body: '',
              isCoach: msg.isCoach,
              time: msg.time,
              type: _MsgType.deleted,
            );
          }
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final res  = await ApiClient.get('/coach/messages/${widget.memberId}');
      final data = res['data'] as Map<String, dynamic>? ?? {};
      final list = (data['messages'] as List?) ?? [];
      final contact = data['contact'] as Map<String, dynamic>?;
      if (!mounted) return;
      setState(() {
        _messages = list
            .map((m) => _Msg.fromJson(m as Map<String, dynamic>))
            .toList();
        _memberUserId ??= contact?['id'] as int?;
        _loading = false;
      });
      _scrollToBottom();
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _poll() async {
    if (!mounted || _sending) return;
    try {
      final res  = await ApiClient.get('/coach/messages/${widget.memberId}');
      final data = res['data'] as Map<String, dynamic>? ?? {};
      final list = (data['messages'] as List?) ?? [];
      final fetched = list
          .map((m) => _Msg.fromJson(m as Map<String, dynamic>))
          .toList();
      if (!mounted) return;
      final latestId = fetched.isNotEmpty ? fetched.last.id : -1;
      final currentId = _messages.isNotEmpty ? _messages.last.id : -1;
      if (fetched.length != _messages.length || latestId != currentId) {
        final wasAtBottom = _scroll.hasClients &&
            _scroll.position.pixels >=
                _scroll.position.maxScrollExtent - 80;
        setState(() => _messages = fetched);
        if (wasAtBottom) _scrollToBottom();
      }
    } catch (_) {}
  }

  void _startReply(String prefix) {
    _ctrl.text = prefix;
    _scrollToBottom();
  }

  Future<void> _send([String? text]) async {
    final body = (text ?? _ctrl.text).trim();
    if (body.isEmpty) return;
    _ctrl.clear();
    setState(() {
      _sending = true;
      _showTemplates = false;
      _messages.add(_Msg(
        id: DateTime.now().millisecondsSinceEpoch,
        body: body,
        isCoach: true,
        time: DateTime.now(),
        type: _MsgType.text,
      ));
    });
    _scrollToBottom();
    try {
      await ApiClient.post('/coach/messages', {
        'receiver_id': _memberUserId,
        'body': body,
      });
    } catch (_) {}
    if (mounted) setState(() => _sending = false);
  }

  void _showSendPlan() {
    if (_memberUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Cannot resolve member account. Please reload.'),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SendPlanSheet(
          memberUserId: _memberUserId!,
          memberName: widget.memberName,
          onSent: () {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Plan sent to ${widget.memberName}! ✅'),
              backgroundColor: AppColors.emerald,
              behavior: SnackBarBehavior.floating,
            ));
            _load(); // reload thread to show the plan message
          },
        ),
      ),
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

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
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
              backgroundColor: AppColors.blue.withValues(alpha: 0.2),
              child: Text(_initials(widget.memberName),
                  style: AppTextStyles.font14WhiteRegular
                      .copyWith(color: AppColors.blue, fontSize: 12.sp)),
            ),
            hGap(10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.memberName,
                    style: AppTextStyles.font14WhiteRegular
                        .copyWith(fontWeight: FontWeight.w600)),
                Text('Member',
                    style: AppTextStyles.font14GreyRegular
                        .copyWith(fontSize: 10.sp, color: AppColors.teal)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.note_add_outlined,
                color: AppColors.emerald, size: 22.r),
            tooltip: 'Send Plan',
            onPressed: _showSendPlan,
          ),
          IconButton(
            icon: Icon(Icons.flash_on_outlined,
                color: AppColors.teal, size: 22.r),
            tooltip: 'Quick templates',
            onPressed: () => setState(() => _showTemplates = !_showTemplates),
          ),
        ],
      ),
      body: Column(
        children: [
          if (!_safetyAlertShown)
            _SafetyBanner(onDismiss: _dismissSafetyAlert),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.teal))
                : _messages.isEmpty
                    ? _EmptyThread(memberName: widget.memberName)
                    : ListView.builder(
                        controller: _scroll,
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 12.h),
                        itemCount: _messages.length,
                        itemBuilder: (_, i) => _CoachMsgRow(
                          msg: _messages[i],
                          onDelete: _deleteMessage,
                          onMakePlan: _showSendPlan,
                          onQuickReply: _startReply,
                        ),
                      ),
          ),
          if (_showTemplates)
            _TemplatesBar(templates: _templates, onTap: _send),
          _InputBar(
            ctrl: _ctrl,
            sending: _sending,
            onSend: () => _send(),
            onTemplates: () =>
                setState(() => _showTemplates = !_showTemplates),
            onPlan: _showSendPlan,
          ),
        ],
      ),
    );
  }
}

// ── Message row dispatcher ────────────────────────────────────────────────────

class _CoachMsgRow extends StatelessWidget {
  final _Msg msg;
  final void Function(_Msg) onDelete;
  final VoidCallback onMakePlan;
  final void Function(String) onQuickReply;

  const _CoachMsgRow({
    required this.msg,
    required this.onDelete,
    required this.onMakePlan,
    required this.onQuickReply,
  });

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.secondary,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.copy_outlined, color: AppColors.grey),
              title: Text('Copy', style: AppTextStyles.font14WhiteRegular),
              onTap: () {
                Navigator.pop(context);
                Clipboard.setData(ClipboardData(text: msg.body));
              },
            ),
            if (msg.isCoach)
              ListTile(
                leading: Icon(Icons.delete_outline, color: AppColors.red),
                title: Text('Delete for me',
                    style: AppTextStyles.font14WhiteRegular
                        .copyWith(color: AppColors.red)),
                onTap: () {
                  Navigator.pop(context);
                  onDelete(msg);
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _showOptions(context),
      child: Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: switch (msg.type) {
          _MsgType.deleted             => _DeletedBubble(msg: msg),
          _MsgType.inbodyAttachment    => _InBodyCard(msg: msg, onMakePlan: onMakePlan, onQuickReply: onQuickReply),
          _MsgType.analyticsAttachment => _AnalyticsCard(msg: msg, onMakePlan: onMakePlan, onQuickReply: onQuickReply),
          _MsgType.workoutPlan         => _PlanSentCard(msg: msg),
          _MsgType.nutritionPlan       => _PlanSentCard(msg: msg),
          _                            => _TextBubble(msg: msg),
        },
      ),
    );
  }
}

// ── Deleted bubble ────────────────────────────────────────────────────────────

class _DeletedBubble extends StatelessWidget {
  final _Msg msg;
  const _DeletedBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: msg.isCoach ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.block, color: AppColors.grey, size: 13.r),
            hGap(6),
            Text('Message deleted',
                style: AppTextStyles.font14GreyRegular
                    .copyWith(fontSize: 12.sp, fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }
}

// ── Text bubble ───────────────────────────────────────────────────────────────

class _TextBubble extends StatelessWidget {
  final _Msg msg;
  const _TextBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    final timeStr = _fmt(msg.time);
    return Row(
      mainAxisAlignment:
          msg.isCoach ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!msg.isCoach) ...[
          CircleAvatar(
            radius: 14.r,
            backgroundColor: AppColors.blue.withValues(alpha: 0.2),
            child: Icon(Icons.person, size: 14.r, color: AppColors.blue),
          ),
          hGap(8),
        ],
        Flexible(
          child: Column(
            crossAxisAlignment: msg.isCoach
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: msg.isCoach
                      ? AppColors.teal.withValues(alpha: 0.85)
                      : AppColors.secondary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.r),
                    topRight: Radius.circular(16.r),
                    bottomLeft: msg.isCoach
                        ? Radius.circular(16.r)
                        : Radius.circular(4.r),
                    bottomRight: msg.isCoach
                        ? Radius.circular(4.r)
                        : Radius.circular(16.r),
                  ),
                  border: msg.isCoach ? null : Border.all(color: Colors.white12),
                ),
                child: Text(msg.body,
                    style: AppTextStyles.font14WhiteRegular
                        .copyWith(height: 1.4)),
              ),
              vGap(3),
              Text(timeStr,
                  style: AppTextStyles.font14GreyRegular
                      .copyWith(fontSize: 10.sp)),
            ],
          ),
        ),
        if (msg.isCoach) hGap(8),
      ],
    );
  }
}

// ── InBody card (coach view) ──────────────────────────────────────────────────

class _InBodyCard extends StatelessWidget {
  final _Msg msg;
  final VoidCallback onMakePlan;
  final void Function(String) onQuickReply;
  const _InBodyCard({required this.msg, required this.onMakePlan, required this.onQuickReply});

  @override
  Widget build(BuildContext context) {
    final p = msg.payload ?? {};
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: 0.85.sw),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            AppColors.teal.withValues(alpha: 0.22),
            AppColors.teal.withValues(alpha: 0.08),
          ]),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.teal.withValues(alpha: 0.45)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CardHeader(
              icon: Icons.monitor_weight_outlined,
              label: '${msg.isCoach ? '' : 'Member sent '}In-Body Results',
              color: AppColors.teal,
              time: _fmt(msg.time),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 4.h, 14.w, 12.h),
              child: Wrap(
                spacing: 10.w,
                runSpacing: 8.h,
                children: [
                  if (p['weight'] != null)
                    _StatChip('Weight', '${p['weight']} kg', AppColors.teal),
                  if (p['body_fat_pct'] != null)
                    _StatChip('Body Fat', '${p['body_fat_pct']}%', AppColors.red),
                  if (p['muscle_mass'] != null)
                    _StatChip('Muscle', '${p['muscle_mass']} kg', AppColors.emerald),
                  if (p['bmi'] != null)
                    _StatChip('BMI', '${p['bmi']}', AppColors.blue),
                  if (p['visceral_fat'] != null)
                    _StatChip('Visceral', '${p['visceral_fat']}', AppColors.purple),
                  if (p['inbody_score'] != null)
                    _StatChip('Score', '${p['inbody_score']}', AppColors.teal),
                  if (p['fat_mass'] != null)
                    _StatChip('Fat Mass', '${p['fat_mass']} kg', AppColors.red),
                  if (p['bmr'] != null)
                    _StatChip('BMR', '${p['bmr']} kcal', AppColors.blue),
                  if (p['recorded_at'] != null)
                    _StatChip('Date', '${p['recorded_at']}', AppColors.grey),
                ],
              ),
            ),
            if (!msg.isCoach) ...[
              Padding(
                padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 8.h),
                child: _MakePlanButton(
                  label: '📋 Make a plan from this data',
                  color: AppColors.teal,
                  onTap: onMakePlan,
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 12.h),
                child: _MakePlanButton(
                  label: '💬 Reply to member',
                  color: AppColors.blue,
                  onTap: () => onQuickReply('I reviewed your In-Body results 📊 '),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Analytics card (coach view) ───────────────────────────────────────────────

class _AnalyticsCard extends StatelessWidget {
  final _Msg msg;
  final VoidCallback onMakePlan;
  final void Function(String) onQuickReply;
  const _AnalyticsCard({required this.msg, required this.onMakePlan, required this.onQuickReply});

  @override
  Widget build(BuildContext context) {
    final p = msg.payload ?? {};
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: 0.85.sw),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            AppColors.purple.withValues(alpha: 0.22),
            AppColors.purple.withValues(alpha: 0.08),
          ]),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.purple.withValues(alpha: 0.45)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CardHeader(
              icon: Icons.watch_outlined,
              label: 'Member sent Smart Watch Analytics',
              color: AppColors.purple,
              time: _fmt(msg.time),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 4.h, 14.w, 12.h),
              child: Wrap(
                spacing: 10.w,
                runSpacing: 8.h,
                children: [
                  if (p['steps'] != null)
                    _StatChip('Steps', _n(p['steps']), AppColors.purple),
                  if (p['active_minutes'] != null)
                    _StatChip('Active', '${p['active_minutes']} min', AppColors.blue),
                  if (p['calories_burned'] != null)
                    _StatChip('Calories', '${p['calories_burned']} kcal', AppColors.red),
                  if (p['heart_rate_avg'] != null)
                    _StatChip('Avg HR', '${p['heart_rate_avg']} bpm', AppColors.red),
                  if (p['sleep_hours'] != null)
                    _StatChip('Sleep', '${p['sleep_hours']} hrs', AppColors.blue),
                  if (p['water_liters'] != null)
                    _StatChip('Water', '${p['water_liters']} L', AppColors.teal),
                  if (p['date'] != null)
                    _StatChip('Date', '${p['date']}', AppColors.grey),
                ],
              ),
            ),
            if (!msg.isCoach) ...[
              Padding(
                padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 8.h),
                child: _MakePlanButton(
                  label: '📋 Make a plan from this data',
                  color: AppColors.purple,
                  onTap: onMakePlan,
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 12.h),
                child: _MakePlanButton(
                  label: '💬 Reply to member',
                  color: AppColors.blue,
                  onTap: () => onQuickReply('I checked your Smart Watch Analytics ⌚ '),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Make-plan fast action button ──────────────────────────────────────────────

class _MakePlanButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _MakePlanButton({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(Icons.note_add_outlined, size: 15.r),
        label: Text(label, style: TextStyle(fontSize: 12.sp)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 9.h),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r)),
        ),
      ),
    );
  }
}

// ── Plan sent card (coach sent, shown on coach side) ─────────────────────────

class _PlanSentCard extends StatelessWidget {
  final _Msg msg;
  const _PlanSentCard({required this.msg});

  @override
  Widget build(BuildContext context) {
    final isWorkout = msg.type == _MsgType.workoutPlan;
    final color     = isWorkout ? AppColors.blue : AppColors.emerald;
    final p         = msg.payload ?? {};
    final title     = p['title'] as String? ?? msg.body;
    final days      = (p['days'] as List?)?.cast<Map>() ?? [];
    final meals     = (p['meals'] as List?)?.cast<Map>() ?? [];

    return Align(
      alignment: msg.isCoach ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: 0.82.sw),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            color.withValues(alpha: 0.22),
            color.withValues(alpha: 0.06),
          ]),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CardHeader(
              icon: isWorkout
                  ? Icons.fitness_center_outlined
                  : Icons.restaurant_outlined,
              label: isWorkout ? 'Workout Plan Sent' : 'Nutrition Plan Sent',
              color: color,
              time: _fmt(msg.time),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTextStyles.font14WhiteRegular
                          .copyWith(fontWeight: FontWeight.w600)),
                  vGap(6),
                  if (isWorkout)
                    ...days.take(3).map((d) => _PlanLine(
                        icon: Icons.calendar_today_outlined,
                        text: d['day_name'] as String? ?? '',
                        color: color))
                  else
                    ...meals.take(3).map((m) => _PlanLine(
                        icon: Icons.restaurant_menu_outlined,
                        text: m['name'] as String? ?? '',
                        color: color)),
                  if (msg.isApplied) ...[
                    vGap(8),
                    Row(
                      children: [
                        Icon(Icons.check_circle,
                            color: AppColors.emerald, size: 14.r),
                        hGap(4),
                        Text('Member applied this plan',
                            style: AppTextStyles.font14GreyRegular.copyWith(
                                color: AppColors.emerald,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared card header ────────────────────────────────────────────────────────

class _CardHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String time;

  const _CardHeader({
    required this.icon,
    required this.label,
    required this.color,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 8.h),
      child: Row(
        children: [
          Icon(icon, color: color, size: 15.r),
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

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatChip(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
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
          vGap(1),
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

class _PlanLine extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _PlanLine({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 3.h),
      child: Row(
        children: [
          Icon(icon, color: color, size: 11.r),
          hGap(5),
          Expanded(
            child: Text(text,
                style: AppTextStyles.font14GreyRegular
                    .copyWith(fontSize: 11.sp, color: Colors.white70),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

// ── Templates bar ─────────────────────────────────────────────────────────────

class _TemplatesBar extends StatelessWidget {
  final List<String> templates;
  final void Function(String) onTap;
  const _TemplatesBar({required this.templates, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.secondary,
      height: 48.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        itemCount: templates.length,
        separatorBuilder: (_, __) => hGap(8),
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => onTap(templates[i]),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.teal.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: AppColors.teal.withValues(alpha: 0.4)),
            ),
            child: Text(templates[i],
                style: AppTextStyles.font14GreyRegular
                    .copyWith(color: AppColors.teal, fontSize: 12.sp)),
          ),
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
  final VoidCallback onTemplates;
  final VoidCallback onPlan;

  const _InputBar({
    required this.ctrl,
    required this.sending,
    required this.onSend,
    required this.onTemplates,
    required this.onPlan,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        color: AppColors.secondary,
        child: Row(
          children: [
            IconButton(
              onPressed: onTemplates,
              icon: Icon(Icons.flash_on_outlined,
                  color: AppColors.teal, size: 22.r),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            hGap(6),
            IconButton(
              onPressed: onPlan,
              icon: Icon(Icons.note_add_outlined,
                  color: AppColors.emerald, size: 22.r),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Send Plan',
            ),
            hGap(8),
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
                      borderSide: BorderSide.none),
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

// ── Safety banner ─────────────────────────────────────────────────────────────

class _SafetyBanner extends StatelessWidget {
  final VoidCallback onDismiss;
  const _SafetyBanner({required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 0),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.teal.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.teal.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.verified_user_outlined, color: AppColors.teal, size: 18.r),
          hGap(10),
          Expanded(
            child: Text(
              'Keep all communication inside FitQuad. In-app chat keeps a '
              'safe record and protects both you and your client.',
              style: AppTextStyles.font14GreyRegular
                  .copyWith(fontSize: 11.sp, height: 1.4),
            ),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: Icon(Icons.close, color: AppColors.grey, size: 16.r),
          ),
        ],
      ),
    );
  }
}

// ── Empty thread ──────────────────────────────────────────────────────────────

class _EmptyThread extends StatelessWidget {
  final String memberName;
  const _EmptyThread({required this.memberName});

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
          Text('Start the conversation with $memberName',
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
