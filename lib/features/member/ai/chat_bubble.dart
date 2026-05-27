import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';
import '../data/models/message_model.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.isTyping) return _TypingBubble();

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isUser) _Avatar(isAi: true),
          SizedBox(width: 8.w),
          Flexible(
            child: Column(
              crossAxisAlignment: message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                _Bubble(message: message),
                if (message.inBodyAttached)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h, right: 4.w),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.analytics_outlined,
                            size: 11.r, color: AppColors.teal),
                        SizedBox(width: 3.w),
                        Text(
                          'InBody attached',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: AppColors.teal,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          if (message.isUser) _Avatar(isAi: false),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final ChatMessage message;
  const _Bubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.72,
      ),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: isUser
            ? AppColors.teal.withValues(alpha: 0.15)
            : AppColors.secondary,
        border: Border.all(
          color: isUser
              ? AppColors.teal.withValues(alpha: 0.4)
              : Colors.transparent,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(18.r),
          topRight: Radius.circular(18.r),
          bottomLeft: Radius.circular(isUser ? 18.r : 4.r),
          bottomRight: Radius.circular(isUser ? 4.r : 18.r),
        ),
      ),
      child: isUser
          ? Text(
              message.text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                height: 1.45,
              ),
            )
          : MarkdownBody(
              data: message.text,
              styleSheet: _mdStyle(context),
              softLineBreak: true,
            ),
    );
  }

  MarkdownStyleSheet _mdStyle(BuildContext context) {
    final base = TextStyle(
      color: Colors.white70,
      fontSize: 14.sp,
      height: 1.5,
    );
    return MarkdownStyleSheet(
      p: base,
      h1: base.copyWith(
          fontSize: 17.sp,
          fontWeight: FontWeight.w700,
          color: Colors.white),
      h2: base.copyWith(
          fontSize: 15.sp,
          fontWeight: FontWeight.w700,
          color: Colors.white),
      h3: base.copyWith(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white),
      strong: base.copyWith(
          fontWeight: FontWeight.w700, color: Colors.white),
      em: base.copyWith(fontStyle: FontStyle.italic),
      code: base.copyWith(
        fontFamily: 'monospace',
        backgroundColor: AppColors.primary,
        color: AppColors.teal,
      ),
      codeblockDecoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8.r),
      ),
      listBullet: base.copyWith(color: AppColors.teal),
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: AppColors.teal, width: 3),
        ),
      ),
      blockquote: base.copyWith(color: Colors.white54),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white12),
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _Avatar(isAi: true),
          SizedBox(width: 8.w),
          Container(
            padding:
                EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18.r),
                topRight: Radius.circular(18.r),
                bottomRight: Radius.circular(18.r),
                bottomLeft: Radius.circular(4.r),
              ),
            ),
            child: _TypingDots(),
          ),
        ],
      ),
    );
  }
}

class _TypingDots extends StatefulWidget {
  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (i) {
      final c = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );
      Future.delayed(Duration(milliseconds: i * 160), () {
        if (mounted) c.repeat(reverse: true);
      });
      return c;
    });
    _animations = _controllers
        .map((c) =>
            Tween<double>(begin: 0, end: -6).animate(CurvedAnimation(
              parent: c,
              curve: Curves.easeInOut,
            )))
        .toList();
  }

  @override
  void dispose() {
    for (final c in _controllers) { c.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _animations[i],
          builder: (_, __) => Transform.translate(
            offset: Offset(0, _animations[i].value),
            child: Container(
              width: 7.r,
              height: 7.r,
              margin: EdgeInsets.symmetric(horizontal: 3.w),
              decoration: BoxDecoration(
                color: AppColors.teal,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _Avatar extends StatelessWidget {
  final bool isAi;
  const _Avatar({required this.isAi});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32.r,
      height: 32.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isAi
            ? AppColors.teal.withValues(alpha: 0.2)
            : AppColors.secondary,
        border: Border.all(
          color: isAi ? AppColors.teal : Colors.white24,
        ),
      ),
      child: Icon(
        isAi ? Icons.smart_toy_outlined : Icons.person_outline,
        size: 17.r,
        color: isAi ? AppColors.teal : Colors.white54,
      ),
    );
  }
}
