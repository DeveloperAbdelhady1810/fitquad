import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/services/api_client.dart';
import 'package:gym_app/core/widgets/app_avatar.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';
import 'package:gym_app/features/member/home/manager/member_cubit.dart';
import 'package:gym_app/features/member/home/manager/member_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../generated/l10n.dart';

// ── Message type ──────────────────────────────────────────────────────────────

enum ChatMsgType {
  text,
  inbodyAttachment,
  analyticsAttachment,
  workoutPlan,
  nutritionPlan,
  deleted;

  static ChatMsgType fromString(String? s) => switch (s) {
        'inbody_attachment'    => inbodyAttachment,
        'analytics_attachment' => analyticsAttachment,
        'workout_plan'         => workoutPlan,
        'nutrition_plan'       => nutritionPlan,
        'deleted'              => deleted,
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
  final String? coachAvatarUrl;

  const MemberChatScreen({
    super.key,
    required this.coachName,
    this.coachAvatarUrl,
  });

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
  bool _sendingInBody    = false;
  bool _sendingAnalytics = false;
  bool _safetyAlertShown = true; // true = already shown / dismissed
  Timer? _pollTimer;

  List<_ChatMsg> get _plans =>
      _messages.where((m) => m.type.isPlan && !m.isMe).toList();

  @override
  void initState() {
    super.initState();
    _load();
    _pollTimer = Timer.periodic(const Duration(seconds: 4), (_) => _poll());
    _checkSafetyAlert();
  }

  Future<void> _checkSafetyAlert() async {
    final prefs = await SharedPreferences.getInstance();
    final shown = prefs.getBool('chat_safety_alert_shown') ?? false;
    if (!shown && mounted) setState(() => _safetyAlertShown = false);
  }

  Future<void> _dismissSafetyAlert() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('chat_safety_alert_shown', true);
    if (mounted) setState(() => _safetyAlertShown = true);
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
      final res  = await ApiClient.get('/member/messages');
      final data = res['data'] as Map<String, dynamic>? ?? {};
      final list = (data['messages'] as List?) ?? [];
      if (!mounted) return;
      setState(() {
        _messages = list
            .map((m) => _ChatMsg.fromJson(m as Map<String, dynamic>))
            .toList();
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
      final res  = await ApiClient.get('/member/messages');
      final data = res['data'] as Map<String, dynamic>? ?? {};
      final list = (data['messages'] as List?) ?? [];
      final fetched = list
          .map((m) => _ChatMsg.fromJson(m as Map<String, dynamic>))
          .toList();
      if (!mounted) return;
      // Never replace the list with a shorter one — prevents the optimistic
      // message from briefly disappearing if the poll fires before the server
      // has finished processing the POST.
      if (fetched.length < _messages.length) return;
      final latestId = fetched.isNotEmpty ? fetched.last.id : -1;
      final currentId = _messages.isNotEmpty ? _messages.last.id : -1;
      if (fetched.length != _messages.length || latestId != currentId) {
        final hasNew = fetched.length > _messages.length;
        final wasAtBottom = _scroll.hasClients &&
            _scroll.position.pixels >=
                _scroll.position.maxScrollExtent - 120;
        setState(() => _messages = fetched);
        if (wasAtBottom || hasNew) _scrollToBottom();
      }
    } catch (_) {}
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
      // Immediately sync so the optimistic message is replaced with the real
      // server record (real ID). Set _sending = false first so _poll can run.
      if (mounted) setState(() => _sending = false);
      _poll();
      return;
    } catch (e) {
      // Remove the optimistic message and show error
      if (mounted) {
        setState(() => _messages.removeWhere(
            (m) => m.body == body && m.isMe));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Failed to send: ${e.toString().replaceFirst('Exception: ', '')}'),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
    if (mounted) setState(() => _sending = false);
  }

  Future<void> _sendInBody() async {
    if (_sendingInBody) return;
    setState(() => _sendingInBody = true);
    try {
      final res = await ApiClient.post('/member/messages/send-inbody', {});
      final msg = _ChatMsg.fromJson(res['data'] as Map<String, dynamic>);
      if (mounted) {
        setState(() => _messages.add(msg));
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) _showFriendlyError('Could not attach InBody', e);
    } finally {
      if (mounted) setState(() => _sendingInBody = false);
    }
  }

  void _showFriendlyError(String prefix, Object e) {
    final raw = e.toString().replaceFirst('Exception: ', '');
    final friendly = raw.toLowerCase().contains('no inbody')
        ? 'No InBody scan found. Add one in the InBody tab first.'
        : raw.toLowerCase().contains('coach')
            ? 'You don\'t have an assigned coach yet.'
            : '$prefix. Please try again.';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(friendly),
      backgroundColor: AppColors.red,
      behavior: SnackBarBehavior.floating,
    ));
  }

  Future<void> _deleteMessage(_ChatMsg msg) async {
    try {
      await ApiClient.delete('/member/messages/${msg.id}');
      if (mounted) {
        setState(() {
          final idx = _messages.indexOf(msg);
          if (idx >= 0) {
            _messages[idx] = _ChatMsg(
              id: msg.id,
              body: '',
              isMe: msg.isMe,
              time: msg.time,
              type: ChatMsgType.deleted,
            );
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _sendQuickReply(String text) async {
    _ctrl.text = text;
    await _send();
  }

  Future<void> _sendAnalytics() async {
    if (_sendingAnalytics) return;
    setState(() => _sendingAnalytics = true);
    try {
      // Read available health data from MemberCubit state
      final memberState = context.read<MemberCubit>().state;
      final body = <String, dynamic>{};
      if (memberState is MemberLoaded) {
        final m = memberState.member;
        if (m.sleepHrs != null && m.sleepHrs! > 0) body['sleep_hours'] = m.sleepHrs;
        if (m.waterL != null && m.waterL! > 0) body['water_liters'] = m.waterL;
      }
      final res = await ApiClient.post('/member/messages/send-analytics', body);
      final msg = _ChatMsg.fromJson(res['data'] as Map<String, dynamic>);
      if (mounted) {
        setState(() => _messages.add(msg));
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        _showFriendlyError('Could not send analytics', e);
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
      // Reload member data so Train / Eat tabs reflect the new plan immediately
      context.read<MemberCubit>().loadAll();
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
      builder: (_) => _PlansSheet(
          plans: _plans, onApply: _applyPlan, onQuickReply: _sendQuickReply),
    );
  }

  void _scrollToBottom() {
    // Double post-frame ensures ListView has finished layout before reading
    // maxScrollExtent; jumpTo is instant so there are no animation timing races.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.jumpTo(_scroll.position.maxScrollExtent);
        }
      });
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
            AppAvatar(
              name:   widget.coachName,
              url:    widget.coachAvatarUrl,
              radius: 18,
            ),
            hGap(10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.coachName,
                    style: AppTextStyles.font14WhiteRegular
                        .copyWith(fontWeight: FontWeight.w600)),
                Text(S.of(context).your_coach,
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
          // Safety alert banner (one-time)
          if (!_safetyAlertShown)
            _SafetyBanner(onDismiss: _dismissSafetyAlert),

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
                          onDelete: _deleteMessage,
                          onQuickReply: _sendQuickReply,
                          coachName: widget.coachName,
                          coachAvatarUrl: widget.coachAvatarUrl,
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
  final void Function(_ChatMsg) onDelete;
  final void Function(String) onQuickReply;
  final String coachName;
  final String? coachAvatarUrl;

  const _MessageRow({
    required this.msg,
    required this.onApply,
    required this.onDelete,
    required this.onQuickReply,
    required this.coachName,
    this.coachAvatarUrl,
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
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Copied to clipboard'),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 1),
                ));
              },
            ),
            if (msg.isMe)
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
          ChatMsgType.deleted             => _DeletedBubble(msg: msg),
          ChatMsgType.inbodyAttachment    => _InBodyBubble(msg: msg, onQuickReply: onQuickReply),
          ChatMsgType.analyticsAttachment => _AnalyticsBubble(msg: msg, onQuickReply: onQuickReply),
          ChatMsgType.workoutPlan         => _PlanBubble(msg: msg, onApply: onApply, onQuickReply: onQuickReply),
          ChatMsgType.nutritionPlan       => _PlanBubble(msg: msg, onApply: onApply, onQuickReply: onQuickReply),
          _                               => _TextBubble(msg: msg, coachName: coachName, coachAvatarUrl: coachAvatarUrl),
        },
      ),
    );
  }
}

// ── Text bubble ───────────────────────────────────────────────────────────────

class _TextBubble extends StatelessWidget {
  final _ChatMsg msg;
  final String coachName;
  final String? coachAvatarUrl;
  const _TextBubble({required this.msg, required this.coachName, this.coachAvatarUrl});

  // Optimistic messages use DateTime.millisecondsSinceEpoch as ID (~1.7 trillion)
  // Real server IDs are small sequential integers, never this large.
  bool get _isPending => msg.id > 1000000000000;

  @override
  Widget build(BuildContext context) {
    final timeStr = _fmt(msg.time);
    return Row(
      mainAxisAlignment:
          msg.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!msg.isMe) ...[
          AppAvatar(
            name:   coachName,
            url:    coachAvatarUrl,
            radius: 14,
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
                      ? AppColors.teal.withValues(alpha: _isPending ? 0.50 : 0.85)
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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isPending) ...[
                    SizedBox(
                      width: 10.r,
                      height: 10.r,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.2,
                        color: AppColors.grey,
                      ),
                    ),
                    hGap(4),
                    Text(S.of(context).sending,
                        style: AppTextStyles.font14GreyRegular
                            .copyWith(fontSize: 10.sp)),
                  ] else
                    Text(timeStr,
                        style: AppTextStyles.font14GreyRegular
                            .copyWith(fontSize: 10.sp)),
                ],
              ),
            ],
          ),
        ),
        if (msg.isMe) hGap(8),
      ],
    );
  }
}

// ── Deleted bubble ────────────────────────────────────────────────────────────

class _DeletedBubble extends StatelessWidget {
  final _ChatMsg msg;
  const _DeletedBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
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

// ── InBody premium bubble ─────────────────────────────────────────────────────

class _InBodyBubble extends StatefulWidget {
  final _ChatMsg msg;
  final void Function(String) onQuickReply;
  const _InBodyBubble({required this.msg, required this.onQuickReply});

  @override
  State<_InBodyBubble> createState() => _InBodyBubbleState();
}

class _InBodyBubbleState extends State<_InBodyBubble> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final msg = widget.msg;
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
              label: msg.isMe ? 'In-Body Results Shared' : 'Member shared In-Body',
              color: AppColors.teal,
              time: _fmt(msg.time),
              badge: '📊',
            ),
            // When sent by me: compact bar with "View Details" toggle
            if (msg.isMe && !_expanded)
              GestureDetector(
                onTap: () => setState(() => _expanded = true),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(14.w, 8.h, 14.w, 12.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('View Details',
                          style: AppTextStyles.font14WhiteRegular.copyWith(
                              color: AppColors.teal,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600)),
                      hGap(4),
                      Icon(Icons.keyboard_arrow_down,
                          color: AppColors.teal, size: 16.r),
                    ],
                  ),
                ),
              ),
            // Expanded stats (always for coach-sent; toggled for own messages)
            if (!msg.isMe || _expanded) ...[
              Padding(
                padding: EdgeInsets.fromLTRB(14.w, 4.h, 14.w, 8.h),
                child: Wrap(
                  spacing: 10.w,
                  runSpacing: 8.h,
                  children: [
                    if (p['weight'] != null)
                      _Stat('⚖️ Weight', '${p['weight']} kg', AppColors.teal),
                    if (p['body_fat_pct'] != null)
                      _Stat('🔥 Body Fat', '${p['body_fat_pct']}%', AppColors.red),
                    if (p['muscle_mass'] != null)
                      _Stat('💪 Muscle', '${p['muscle_mass']} kg', AppColors.emerald),
                    if (p['bmi'] != null)
                      _Stat('📐 BMI', '${p['bmi']}', AppColors.blue),
                    if (p['visceral_fat'] != null)
                      _Stat('🫀 Visceral', '${p['visceral_fat']}', AppColors.purple),
                    if (p['inbody_score'] != null)
                      _Stat('🏆 Score', '${p['inbody_score']}', AppColors.teal),
                  ],
                ),
              ),
              if (msg.isMe) ...[
                GestureDetector(
                  onTap: () => setState(() => _expanded = false),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 4.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Hide Details',
                            style: AppTextStyles.font14WhiteRegular.copyWith(
                                color: AppColors.teal, fontSize: 12.sp)),
                        hGap(4),
                        Icon(Icons.keyboard_arrow_up,
                            color: AppColors.teal, size: 16.r),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 12.h),
                  child: _FastActions([
                    _FastAction('📋 Make a plan for me', widget.onQuickReply),
                    _FastAction('🔍 Analyse my results', widget.onQuickReply),
                  ]),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

// ── Analytics premium bubble ──────────────────────────────────────────────────

class _AnalyticsBubble extends StatefulWidget {
  final _ChatMsg msg;
  final void Function(String) onQuickReply;
  const _AnalyticsBubble({required this.msg, required this.onQuickReply});

  @override
  State<_AnalyticsBubble> createState() => _AnalyticsBubbleState();
}

class _AnalyticsBubbleState extends State<_AnalyticsBubble> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final msg = widget.msg;
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
              label: msg.isMe ? 'Smart Watch Analytics Shared' : 'Member shared Analytics',
              color: AppColors.purple,
              time: _fmt(msg.time),
              badge: '⌚',
            ),
            // When sent by me: compact bar with "View Details" toggle
            if (msg.isMe && !_expanded)
              GestureDetector(
                onTap: () => setState(() => _expanded = true),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(14.w, 8.h, 14.w, 12.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('View Details',
                          style: AppTextStyles.font14WhiteRegular.copyWith(
                              color: AppColors.purple,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600)),
                      hGap(4),
                      Icon(Icons.keyboard_arrow_down,
                          color: AppColors.purple, size: 16.r),
                    ],
                  ),
                ),
              ),
            // Expanded stats (always for coach-sent; toggled for own messages)
            if (!msg.isMe || _expanded) ...[
              Padding(
                padding: EdgeInsets.fromLTRB(14.w, 4.h, 14.w, 8.h),
                child: Wrap(
                  spacing: 10.w,
                  runSpacing: 8.h,
                  children: [
                    if (p['steps'] != null)
                      _Stat('👟 Steps', _n(p['steps']), AppColors.purple),
                    if (p['active_minutes'] != null)
                      _Stat('⚡ Active', '${p['active_minutes']} min', AppColors.blue),
                    if (p['calories_burned'] != null)
                      _Stat('🔥 Calories', '${p['calories_burned']} kcal', AppColors.red),
                    if (p['heart_rate_avg'] != null)
                      _Stat('❤️ Avg HR', '${p['heart_rate_avg']} bpm', AppColors.red),
                    if (p['sleep_hours'] != null)
                      _Stat('🌙 Sleep', '${p['sleep_hours']} hrs', AppColors.blue),
                    if (p['water_liters'] != null)
                      _Stat('💧 Water', '${p['water_liters']} L', AppColors.teal),
                  ],
                ),
              ),
              if (msg.isMe) ...[
                GestureDetector(
                  onTap: () => setState(() => _expanded = false),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 4.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Hide Details',
                            style: AppTextStyles.font14WhiteRegular.copyWith(
                                color: AppColors.purple, fontSize: 12.sp)),
                        hGap(4),
                        Icon(Icons.keyboard_arrow_up,
                            color: AppColors.purple, size: 16.r),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 12.h),
                  child: _FastActions([
                    _FastAction('💪 Suggest recovery tips', widget.onQuickReply),
                    _FastAction('🏃 Improve my training', widget.onQuickReply),
                  ]),
                ),
              ],
            ],
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
  final void Function(String) onQuickReply;

  const _PlanBubble({required this.msg, required this.onApply, required this.onQuickReply});

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
              label: isWorkout ? '🏋️ Workout Plan from Coach' : '🥗 Nutrition Plan from Coach',
              color: color,
              time: _fmt(msg.time),
              badge: isWorkout ? '💪' : '🥗',
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
            // Apply button + fast actions
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
              child: Column(
                children: [
                  msg.isApplied
                      ? Row(
                          children: [
                            Icon(Icons.check_circle,
                                color: AppColors.emerald, size: 16.r),
                            hGap(6),
                            Text('Plan Applied ✅',
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
                            label: Text('✅ Apply ${isWorkout ? 'Workout' : 'Nutrition'} Plan'),
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
                  vGap(8),
                  _FastActions([
                    _FastAction('✏️ Request modification', onQuickReply),
                    _FastAction('❓ Ask about this plan', onQuickReply),
                  ]),
                ],
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
  final void Function(String) onQuickReply;

  const _PlansSheet({
    required this.plans,
    required this.onApply,
    required this.onQuickReply,
  });

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
                Text(S.of(context).plans_from_coach,
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
                onQuickReply: onQuickReply,
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
  final String? badge;

  const _PremiumHeader({
    required this.icon,
    required this.label,
    required this.color,
    required this.time,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 10.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
        ),
      ),
      child: Row(
        children: [
          if (badge != null) ...[
            Text(badge!, style: TextStyle(fontSize: 14.sp)),
            hGap(6),
          ] else ...[
            Icon(icon, color: color, size: 16.r),
            hGap(6),
          ],
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

// ── Fast actions row ──────────────────────────────────────────────────────────

class _FastAction {
  final String label;
  final void Function(String) onTap;
  _FastAction(this.label, this.onTap);
}

class _FastActions extends StatelessWidget {
  final List<_FastAction> actions;
  const _FastActions(this.actions);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6.w,
      runSpacing: 6.h,
      children: actions
          .map((a) => GestureDetector(
                onTap: () => a.onTap(a.label),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Text(a.label,
                      style: AppTextStyles.font14GreyRegular.copyWith(
                          color: Colors.white, fontSize: 11.sp)),
                ),
              ))
          .toList(),
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
              'For your safety, keep all communication inside FitQuad. '
              'In-app chat protects both you and your coach.',
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
          Text(S.of(context).no_messages_yet, style: AppTextStyles.font16WhiteBold),
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
