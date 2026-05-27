import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/services/api_client.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';

class MemberChatScreen extends StatefulWidget {
  final String coachName;

  const MemberChatScreen({super.key, required this.coachName});

  static const routeName = '/member-chat';

  @override
  State<MemberChatScreen> createState() => _MemberChatScreenState();
}

class _MemberChatScreenState extends State<MemberChatScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  List<_Msg> _messages = [];
  bool _loading = true;
  bool _sending = false;

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
      final res = await ApiClient.get('/member/messages');
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

  Future<void> _send() async {
    final body = _ctrl.text.trim();
    if (body.isEmpty) return;
    _ctrl.clear();
    setState(() {
      _sending = true;
      _messages.add(_Msg(body: body, isMe: true, time: DateTime.now()));
    });
    _scrollToBottom();
    try {
      await ApiClient.post('/member/messages', {'body': body});
    } catch (_) {
      // message shown locally regardless
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
                    style: AppTextStyles.font14GreyRegular.copyWith(
                        fontSize: 10.sp, color: AppColors.teal)),
              ],
            ),
          ],
        ),
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
                        itemBuilder: (_, i) =>
                            _BubbleRow(msg: _messages[i]),
                      ),
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

class _Msg {
  final String body;
  final bool isMe;
  final DateTime time;

  const _Msg({required this.body, required this.isMe, required this.time});

  factory _Msg.fromJson(Map<String, dynamic> j) {
    final senderRole = j['sender_role'] as String? ?? 'coach';
    return _Msg(
      body: j['body'] as String? ?? '',
      isMe: senderRole == 'member',
      time: DateTime.tryParse(j['sent_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class _BubbleRow extends StatelessWidget {
  final _Msg msg;
  const _BubbleRow({required this.msg});

  @override
  Widget build(BuildContext context) {
    final isMe = msg.isMe;
    final timeStr =
        '${msg.time.hour.toString().padLeft(2, '0')}:${msg.time.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
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
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: isMe
                        ? AppColors.teal.withValues(alpha: 0.85)
                        : AppColors.secondary,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.r),
                      topRight: Radius.circular(16.r),
                      bottomLeft: isMe
                          ? Radius.circular(16.r)
                          : Radius.circular(4.r),
                      bottomRight: isMe
                          ? Radius.circular(4.r)
                          : Radius.circular(16.r),
                    ),
                    border: isMe ? null : Border.all(color: Colors.white12),
                  ),
                  child: Text(
                    msg.body,
                    style: AppTextStyles.font14WhiteRegular.copyWith(
                        height: 1.4,
                        color: isMe ? Colors.white : Colors.white70),
                  ),
                ),
                vGap(3),
                Text(timeStr,
                    style: AppTextStyles.font14GreyRegular
                        .copyWith(fontSize: 10.sp)),
              ],
            ),
          ),
          if (isMe) hGap(8),
        ],
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController ctrl;
  final bool sending;
  final VoidCallback onSend;

  const _InputBar(
      {required this.ctrl, required this.sending, required this.onSend});

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
                  hintText: 'Message your coach…',
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
          Text(
            'Say hi to $coachName!',
            style: AppTextStyles.font14GreyRegular,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
