import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helpers/spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../data/partner_gym_repository.dart';

class GymSupportScreen extends StatefulWidget {
  final int gymId;
  final String gymName;

  const GymSupportScreen({super.key, required this.gymId, required this.gymName});

  @override
  State<GymSupportScreen> createState() => _GymSupportScreenState();
}

class _GymSupportScreenState extends State<GymSupportScreen> {
  List<dynamic> _messages = [];
  bool _loading = true;
  bool _sending = false;
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    _load();
    _poll = Timer.periodic(const Duration(seconds: 5), (_) => _load(silent: true));
  }

  @override
  void dispose() {
    _poll?.cancel();
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _load({bool silent = false}) async {
    try {
      final raw = await PartnerGymRepository.getSupportMessages(widget.gymId);
      final msgs = raw['messages'] as List? ?? [];
      if (mounted) {
        setState(() {
          _messages = msgs;
          if (!silent) _loading = false;
        });
        if (!silent) _scrollToBottom();
      }
    } catch (_) {
      if (mounted && !silent) setState(() => _loading = false);
    }
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    _ctrl.clear();
    setState(() => _sending = true);
    try {
      await PartnerGymRepository.sendSupportMessage(widget.gymId, text);
      await _load(silent: true);
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: AppColors.red));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.gymName, style: AppTextStyles.font16WhiteBold),
            Text('Support & Coaches',
                style: AppTextStyles.font14GreyRegular
                    .copyWith(fontSize: 11.sp, color: AppColors.teal)),
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
                    ? _EmptyState(gymName: widget.gymName)
                    : ListView.builder(
                        controller: _scroll,
                        padding:
                            EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                        itemCount: _messages.length,
                        itemBuilder: (_, i) {
                          final msg = _messages[i] as Map<String, dynamic>;
                          final isMe = msg['sender_type'] == 'member';
                          return _Bubble(
                            body: msg['body'] as String? ?? '',
                            isMe: isMe,
                            time: msg['created_at'] as String? ?? '',
                          );
                        },
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

class _Bubble extends StatelessWidget {
  final String body;
  final bool isMe;
  final String time;

  const _Bubble({required this.body, required this.isMe, required this.time});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 8.h,
          left: isMe ? 48.w : 0,
          right: isMe ? 0 : 48.w,
        ),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isMe ? AppColors.teal.withOpacity(0.85) : AppColors.secondary,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomLeft: Radius.circular(isMe ? 16.r : 4.r),
            bottomRight: Radius.circular(isMe ? 4.r : 16.r),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMe) ...[
              Text(
                'Gym Support',
                style: AppTextStyles.font14GreyRegular
                    .copyWith(color: AppColors.teal, fontSize: 10.sp),
              ),
              vGap(2),
            ],
            Text(body, style: AppTextStyles.font14WhiteRegular),
            vGap(4),
            Text(
              _formatTime(time),
              style: AppTextStyles.font14GreyRegular.copyWith(
                  fontSize: 10.sp,
                  color: isMe ? Colors.white60 : AppColors.grey),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    } catch (_) {
      return '';
    }
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
    return Container(
      color: AppColors.secondary,
      padding: EdgeInsets.fromLTRB(12.w, 8.h, 8.w, 8.h),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: ctrl,
                style: AppTextStyles.font14WhiteRegular,
                maxLines: 4,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Message gym support…',
                  hintStyle: AppTextStyles.font14GreyRegular,
                  filled: true,
                  fillColor: AppColors.primary,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.r),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
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
                            color: Colors.white, strokeWidth: 2),
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

class _EmptyState extends StatelessWidget {
  final String gymName;
  const _EmptyState({required this.gymName});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.support_agent_outlined, color: AppColors.grey, size: 56.r),
            vGap(12),
            Text('Start a conversation', style: AppTextStyles.font16WhiteBold),
            vGap(6),
            Text('Ask $gymName support anything',
                style: AppTextStyles.font14GreyRegular),
          ],
        ),
      );
}
