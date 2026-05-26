import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/services/api_client.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';

class CoachChatThreadScreen extends StatefulWidget {
  final int memberId;
  final String memberName;

  const CoachChatThreadScreen({
    super.key,
    required this.memberId,
    required this.memberName,
  });

  static const routeName = '/coach-chat-thread';

  @override
  State<CoachChatThreadScreen> createState() => _CoachChatThreadScreenState();
}

class _CoachChatThreadScreenState extends State<CoachChatThreadScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  List<_Msg> _messages = [];
  bool _loading = true;
  bool _sending = false;
  bool _showTemplates = false;

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
      final res = await ApiClient.get('/coach/messages/${widget.memberId}');
      final list = (res['data'] as List?) ?? [];
      setState(() {
        _messages = list
            .map((m) => _Msg.fromJson(m as Map<String, dynamic>))
            .toList();
        _loading = false;
      });
      _scrollToBottom();
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _send([String? text]) async {
    final body = (text ?? _ctrl.text).trim();
    if (body.isEmpty) return;
    _ctrl.clear();
    setState(() {
      _sending = true;
      _showTemplates = false;
      _messages.add(_Msg(body: body, isCoach: true, time: DateTime.now()));
    });
    _scrollToBottom();
    try {
      await ApiClient.post('/coach/messages', {
        'member_id': widget.memberId,
        'body': body,
      });
    } catch (_) {
      // message still shown locally
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
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
              backgroundColor: AppColors.teal.withValues(alpha: 0.2),
              child: Text(
                _initials(widget.memberName),
                style: AppTextStyles.font14WhiteRegular
                    .copyWith(color: AppColors.teal, fontSize: 12.sp),
              ),
            ),
            hGap(10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.memberName, style: AppTextStyles.font14WhiteRegular
                    .copyWith(fontWeight: FontWeight.w600)),
                Text('Member', style: AppTextStyles.font14GreyRegular
                    .copyWith(fontSize: 10.sp, color: AppColors.teal)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.flash_on_outlined, color: AppColors.teal, size: 22.r),
            tooltip: 'Quick templates',
            onPressed: () => setState(() => _showTemplates = !_showTemplates),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.teal))
                : _messages.isEmpty
                    ? _EmptyThread(memberName: widget.memberName)
                    : ListView.builder(
                        controller: _scroll,
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 12.h),
                        itemCount: _messages.length,
                        itemBuilder: (_, i) => _BubbleRow(msg: _messages[i]),
                      ),
          ),
          if (_showTemplates) _TemplatesBar(templates: _templates, onTap: _send),
          _InputBar(
            ctrl: _ctrl,
            sending: _sending,
            onSend: () => _send(),
            onTemplates: () => setState(() => _showTemplates = !_showTemplates),
          ),
        ],
      ),
    );
  }
}

// ── Message model ─────────────────────────────────────────────────────────────

class _Msg {
  final String body;
  final bool isCoach;
  final DateTime time;

  const _Msg({required this.body, required this.isCoach, required this.time});

  factory _Msg.fromJson(Map<String, dynamic> j) {
    final senderRole = j['sender_role'] as String? ?? 'member';
    return _Msg(
      body: j['body'] as String? ?? '',
      isCoach: senderRole == 'coach',
      time: DateTime.tryParse(j['sent_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

// ── Bubble ────────────────────────────────────────────────────────────────────

class _BubbleRow extends StatelessWidget {
  final _Msg msg;
  const _BubbleRow({required this.msg});

  @override
  Widget build(BuildContext context) {
    final isCoach = msg.isCoach;
    final timeStr =
        '${msg.time.hour.toString().padLeft(2, '0')}:${msg.time.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        mainAxisAlignment:
            isCoach ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isCoach) ...[
            CircleAvatar(
              radius: 14.r,
              backgroundColor: AppColors.blue.withValues(alpha: 0.2),
              child: Icon(Icons.person, size: 14.r, color: AppColors.blue),
            ),
            hGap(8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isCoach ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: isCoach
                        ? AppColors.teal.withValues(alpha: 0.85)
                        : AppColors.secondary,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.r),
                      topRight: Radius.circular(16.r),
                      bottomLeft: isCoach
                          ? Radius.circular(16.r)
                          : Radius.circular(4.r),
                      bottomRight: isCoach
                          ? Radius.circular(4.r)
                          : Radius.circular(16.r),
                    ),
                    border: isCoach
                        ? null
                        : Border.all(color: Colors.white12),
                  ),
                  child: Text(
                    msg.body,
                    style: AppTextStyles.font14WhiteRegular.copyWith(
                        height: 1.4,
                        color: isCoach ? Colors.white : Colors.white70),
                  ),
                ),
                vGap(3),
                Text(
                  timeStr,
                  style: AppTextStyles.font14GreyRegular
                      .copyWith(fontSize: 10.sp),
                ),
              ],
            ),
          ),
          if (isCoach) hGap(8),
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
            child: Text(
              templates[i],
              style: AppTextStyles.font14GreyRegular
                  .copyWith(color: AppColors.teal, fontSize: 12.sp),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Input bar ────────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  final TextEditingController ctrl;
  final bool sending;
  final VoidCallback onSend;
  final VoidCallback onTemplates;

  const _InputBar({
    required this.ctrl,
    required this.sending,
    required this.onSend,
    required this.onTemplates,
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
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 14.w, vertical: 10.h),
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
                  color: AppColors.teal,
                  shape: BoxShape.circle,
                ),
                child: sending
                    ? Padding(
                        padding: EdgeInsets.all(12.r),
                        child: const CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Icon(Icons.send_rounded,
                        color: Colors.white, size: 20.r),
              ),
            ),
          ],
        ),
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
          Text(
            'Start the conversation with $memberName',
            style: AppTextStyles.font14GreyRegular,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
