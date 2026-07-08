import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gym_app/core/cubit/health/health_cubit.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/services/ai_consent.dart';
import 'package:gym_app/core/theme/neo_theme.dart';
import 'package:gym_app/features/member/ai/manager/ai_cubit.dart';
import 'package:gym_app/features/member/ai/models/ai_member_context.dart';
import 'package:gym_app/features/member/data/models/message_model.dart';
import 'package:gym_app/features/member/data/repositories/member_repository.dart';
import 'package:gym_app/features/member/home/manager/member_cubit.dart';
import 'package:gym_app/features/member/home/manager/member_state.dart';
import 'package:gym_app/features/member/inbody/models/inbody_model.dart';
import 'package:gym_app/core/services/health_service.dart';

class AiTabNeo extends StatefulWidget {
  const AiTabNeo({super.key});

  @override
  State<AiTabNeo> createState() => _AiTabNeoState();
}

class _AiTabNeoState extends State<AiTabNeo> with TickerProviderStateMixin {
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  late final AiAssistantCubit _cubit;
  InBodyModel? _latestInBody;

  late final AnimationController _orbPulse;
  late final AnimationController _scanAnim;

  @override
  void initState() {
    super.initState();
    _cubit = AiAssistantCubit();
    _orbPulse = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _scanAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500))..repeat();
    _loadInBody();
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    _orbPulse.dispose();
    _scanAnim.dispose();
    super.dispose();
  }

  Future<void> _loadInBody() async {
    try {
      final records = await MemberRepository.getInBodyRecords();
      if (records.isNotEmpty && mounted) {
        setState(() => _latestInBody = InBodyModel.fromJson(records.first as Map<String, dynamic>));
      }
    } catch (_) {}
  }

  AiMemberContext _buildContext() {
    final ms = context.read<MemberCubit>().state;
    final hs = context.read<HealthCubit>().state;
    HealthSnapshot? snapshot;
    if (hs is HealthLoaded) snapshot = hs.snapshot;
    final memberCubit = context.read<MemberCubit>();
    return AiMemberContext(
      member:         ms is MemberLoaded ? ms.member : null,
      latestInBody:   _latestInBody,
      workoutPlan:    memberCubit.workoutPlan,
      nutritionPlan:  memberCubit.nutritionPlan,
      weekCheckIns:   memberCubit.weekCheckIns,
      healthSnapshot: snapshot,
    );
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty) return;
    if (!await AiConsent.ensure(context)) return;
    if (!mounted) return;
    _inputCtrl.clear();
    _cubit.sendMessage(text);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  static const _quickActions = [
    (label: 'Analyze Lift',  icon: Icons.videocam_outlined),
    (label: 'Fix Macros',    icon: Icons.restaurant_outlined),
    (label: 'Recovery Tip',  icon: Icons.self_improvement),
  ];

  @override
  Widget build(BuildContext context) {
    _cubit.updateContext(_buildContext());

    return BlocProvider.value(
      value: _cubit,
      child: Column(
        children: [
          // Neural orb header
          _NeuralOrbHeader(orbPulse: _orbPulse, scanAnim: _scanAnim),
          // Chat messages
          Expanded(
            child: BlocConsumer<AiAssistantCubit, AiChatState>(
              listener: (_, __) => _scrollToBottom(),
              builder: (context, chatState) {
                return ListView.builder(
                  controller: _scrollCtrl,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  itemCount: chatState.messages.length,
                  itemBuilder: (_, i) => _NeoMessageBubble(
                    message: chatState.messages[i],
                  ),
                );
              },
            ),
          ),
          // Quick action chips
          SizedBox(
            height: 40.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              children: _quickActions.map((a) => Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: GestureDetector(
                  onTap: () => _send(a.label),
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        decoration: BoxDecoration(
                          color: const Color(0x1A00DCE6),
                          border: Border.all(color: const Color(0x3300DCE6)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(a.icon, color: NeoColors.cyan, size: 14.r),
                            SizedBox(width: 6.w),
                            Text(a.label, style: NeoTextStyles.labelCaps),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )).toList(),
            ),
          ),
          vGap(8),
          // Input bar
          BlocBuilder<AiAssistantCubit, AiChatState>(
            builder: (context, chatState) {
              return _NeoInputBar(
                controller: _inputCtrl,
                onSend: () => _send(_inputCtrl.text),
                inBodyAttached: chatState.inBodyAttached,
                hasInBody: _latestInBody != null,
                onToggleInBody: () {
                  if (_latestInBody != null) {
                    _cubit.toggleInBody();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text('No InBody scan yet — add one in the InBody tab first'),
                      backgroundColor: NeoColors.surface,
                      behavior: SnackBarBehavior.floating,
                    ));
                  }
                },
                onClear: _cubit.clearChat,
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Neural Orb Header ────────────────────────────────────────────────────────

class _NeuralOrbHeader extends StatelessWidget {
  final AnimationController orbPulse;
  final AnimationController scanAnim;
  const _NeuralOrbHeader({required this.orbPulse, required this.scanAnim});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: orbPulse,
            builder: (_, __) {
              final scale = 1.0 + orbPulse.value * 0.08;
              final glow = orbPulse.value;
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 80.r,
                  height: 80.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: NeoColors.cyan.withValues(alpha: 0.15),
                    border: Border.all(color: NeoColors.cyan.withValues(alpha: 0.4)),
                    boxShadow: [BoxShadow(
                      color: NeoColors.cyan.withValues(alpha: 0.3 + glow * 0.3),
                      blurRadius: 20 + glow * 20,
                    )],
                  ),
                  child: Stack(
                    clipBehavior: Clip.hardEdge,
                    children: [
                      AnimatedBuilder(
                        animation: scanAnim,
                        builder: (_, __) => Positioned(
                          top: scanAnim.value * 80.r - 1,
                          left: 0, right: 0,
                          child: Container(
                            height: 1.5,
                            decoration: BoxDecoration(
                              color: NeoColors.cyan,
                              boxShadow: [BoxShadow(color: NeoColors.cyan, blurRadius: 6)],
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Icon(Icons.graphic_eq, color: Colors.white, size: 32.r),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          vGap(8),
          Text('NEURAL CONNECTION ACTIVE',
              style: NeoTextStyles.labelCaps.copyWith(color: NeoColors.cyan, letterSpacing: 2)),
          vGap(2),
          Text('System: QUAD-01',
              style: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w800, color: Colors.white)),
        ],
      ),
    );
  }
}

// ── Message Bubble ───────────────────────────────────────────────────────────

class _NeoMessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _NeoMessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.isTyping) return _TypingIndicator();

    final isUser = message.isUser;
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 28.r, height: 28.r,
              decoration: BoxDecoration(
                color: NeoColors.cyan.withValues(alpha: 0.12),
                border: Border.all(color: NeoColors.cyan.withValues(alpha: 0.3)),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.psychology, color: NeoColors.cyan, size: 14.r),
            ),
            SizedBox(width: 8.w),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: isUser
                            ? const Color(0x66353437)
                            : const Color(0x1A00DCE6),
                        border: Border.all(
                          color: isUser
                              ? const Color(0x22FFFFFF)
                              : NeoColors.cyan.withValues(alpha: 0.3),
                        ),
                        boxShadow: isUser
                            ? null
                            : [BoxShadow(color: NeoColors.cyan.withValues(alpha: 0.08), blurRadius: 12)],
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(12),
                          topRight: const Radius.circular(12),
                          bottomLeft: isUser ? const Radius.circular(12) : Radius.zero,
                          bottomRight: isUser ? Radius.zero : const Radius.circular(12),
                        ),
                      ),
                      child: isUser
                          ? Text(message.text, style: NeoTextStyles.bodySm.copyWith(color: NeoColors.onSurface))
                          : MarkdownBody(
                              data: message.text,
                              styleSheet: MarkdownStyleSheet(
                                p: NeoTextStyles.bodySm.copyWith(color: NeoColors.onSurface),
                                strong: NeoTextStyles.bodySm.copyWith(
                                    color: NeoColors.cyan, fontWeight: FontWeight.w700),
                                listBullet: NeoTextStyles.bodySm.copyWith(color: NeoColors.cyan),
                                code: GoogleFonts.jetBrainsMono(fontSize: 12.sp, color: NeoColors.lime),
                                blockquotePadding: EdgeInsets.only(left: 8.w),
                                blockquoteDecoration: BoxDecoration(
                                  border: Border(left: BorderSide(color: NeoColors.cyan, width: 2)),
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
                if (message.inBodyAttached) ...[
                  vGap(3),
                  Text('InBody attached', style: NeoTextStyles.labelCaps.copyWith(
                      color: NeoColors.cyan, fontSize: 9.sp)),
                ],
                vGap(2),
                Text(
                  isUser ? 'YOU' : 'SYSTEM',
                  style: NeoTextStyles.labelCaps.copyWith(color: NeoColors.outline, fontSize: 9.sp),
                ),
              ],
            ),
          ),
          if (isUser) SizedBox(width: 8.w),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator> with TickerProviderStateMixin {
  final List<AnimationController> _dots = [];

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < 3; i++) {
      final c = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))
        ..repeat(reverse: true);
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) c.forward();
      });
      _dots.add(c);
    }
  }

  @override
  void dispose() {
    for (final c in _dots) { c.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Container(
            width: 28.r, height: 28.r,
            decoration: BoxDecoration(
              color: NeoColors.cyan.withValues(alpha: 0.12),
              border: Border.all(color: NeoColors.cyan.withValues(alpha: 0.3)),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.psychology, color: NeoColors.cyan, size: 14.r),
          ),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: const Color(0x1A00DCE6),
              border: Border.all(color: NeoColors.cyan.withValues(alpha: 0.3)),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12), topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) => AnimatedBuilder(
                animation: _dots[i],
                builder: (_, __) => Container(
                  width: 6.r, height: 6.r,
                  margin: EdgeInsets.symmetric(horizontal: 2.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: NeoColors.cyan.withValues(alpha: 0.4 + _dots[i].value * 0.6),
                  ),
                ),
              )),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Input Bar ────────────────────────────────────────────────────────────────

class _NeoInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool inBodyAttached;
  final bool hasInBody;
  final VoidCallback onToggleInBody;
  final VoidCallback onClear;

  const _NeoInputBar({
    required this.controller,
    required this.onSend,
    required this.inBodyAttached,
    required this.hasInBody,
    required this.onToggleInBody,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
          decoration: const BoxDecoration(
            color: Color(0xCC0E0E10),
            border: Border(top: BorderSide(color: Color(0x2600DCE6))),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // InBody + clear row
              Row(
                children: [
                  GestureDetector(
                    onTap: onToggleInBody,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: inBodyAttached
                            ? NeoColors.cyan.withValues(alpha: 0.15)
                            : const Color(0x0A00DCE6),
                        border: Border.all(
                          color: inBodyAttached
                              ? NeoColors.cyan
                              : const Color(0x3300DCE6),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            inBodyAttached ? Icons.analytics : Icons.analytics_outlined,
                            color: inBodyAttached ? NeoColors.cyan : NeoColors.outline,
                            size: 12.r,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            inBodyAttached ? 'INBODY ✓' : 'ATTACH INBODY',
                            style: NeoTextStyles.labelCaps.copyWith(
                              color: inBodyAttached ? NeoColors.cyan : NeoColors.outline,
                              fontSize: 9.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: onClear,
                    child: Icon(Icons.refresh, color: NeoColors.outline, size: 18.r),
                  ),
                ],
              ),
              vGap(8),
              // Text field row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: NeoColors.surfaceHigh,
                        border: Border.all(color: const Color(0x2200DCE6)),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: TextField(
                        controller: controller,
                        style: NeoTextStyles.bodySm.copyWith(color: NeoColors.onSurface),
                        decoration: InputDecoration(
                          hintText: 'Ask QUAD-01...',
                          hintStyle: NeoTextStyles.bodySm.copyWith(color: NeoColors.outline),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                        ),
                        onSubmitted: (_) => onSend(),
                        minLines: 1,
                        maxLines: 4,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: onSend,
                    child: Container(
                      width: 40.r, height: 40.r,
                      color: NeoColors.cyan,
                      child: Icon(Icons.send_rounded, color: Colors.black, size: 18.r),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
