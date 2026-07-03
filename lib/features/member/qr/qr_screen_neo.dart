import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/services/api_client.dart';
import 'package:gym_app/core/theme/neo_theme.dart';
import 'package:gym_app/features/member/home/manager/member_cubit.dart';
import 'package:gym_app/features/member/home/manager/member_state.dart';
import 'package:qr_flutter/qr_flutter.dart';

void showQrSheetNeo(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => BlocProvider.value(
      value: context.read<MemberCubit>(),
      child: const _QrSheetNeo(),
    ),
  );
}

class _QrSheetNeo extends StatefulWidget {
  const _QrSheetNeo();

  @override
  State<_QrSheetNeo> createState() => _QrSheetNeoState();
}

class _QrSheetNeoState extends State<_QrSheetNeo>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> _memberships = [];
  bool _loading = true;
  Map<String, dynamic>? _selectedGym;

  late AnimationController _scan;
  late Animation<double> _scanAnim;
  late AnimationController _blink;
  late Animation<double> _blinkAnim;

  Timer? _cursorTimer;

  @override
  void initState() {
    super.initState();
    _scan = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
    _scanAnim = Tween<double>(begin: 0, end: 1).animate(_scan);
    _blink = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))..repeat(reverse: true);
    _blinkAnim = Tween<double>(begin: 0, end: 1).animate(_blink);
    _loadMemberships();
  }

  @override
  void dispose() {
    _scan.dispose();
    _blink.dispose();
    _cursorTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadMemberships() async {
    try {
      final res = await ApiClient.get('/member/gym-memberships');
      final list = (res['data'] as List?) ?? [];
      final active = list
          .whereType<Map<String, dynamic>>()
          .where((m) {
            final s = m['status'] as String? ?? '';
            return s == 'active' || s == 'frozen';
          })
          .toList();
      if (mounted) {
        setState(() {
          _memberships = active;
          if (active.length == 1) _selectedGym = active.first['gym'] as Map<String, dynamic>?;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemberCubit, MemberState>(
      builder: (context, state) {
        final memberId = state is MemberLoaded ? (state.member.id?.toString() ?? '—') : '—';
        final name = state is MemberLoaded ? (state.member.name ?? 'MEMBER').toUpperCase() : 'MEMBER';

        String qrData;
        if (_selectedGym != null && memberId != '—') {
          final selectedGymId = _selectedGym!['id'];
          final match = _memberships.firstWhere(
            (m) => (m['gym']?['id']) == selectedGymId,
            orElse: () => <String, dynamic>{},
          );
          final externalId = match['external_id'] as String?;
          if (externalId != null && externalId.isNotEmpty) {
            qrData = externalId;
          } else {
            final slug = _selectedGym!['slug'] as String? ?? '';
            qrData = slug.isNotEmpty ? '$slug-$memberId' : memberId;
          }
        } else if (state is MemberLoaded) {
          qrData = state.member.qrCode ?? state.member.id?.toString() ?? 'MEMBER';
        } else {
          qrData = 'MEMBER';
        }

        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(color: NeoColors.bg),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('FITQUAD', style: GoogleFonts.anton(fontSize: 20.sp, color: NeoColors.cyan,
                        shadows: [Shadow(color: NeoColors.cyan.withValues(alpha: 0.6), blurRadius: 8)],
                      )),
                      Text('SECURE PASS', style: NeoTextStyles.labelCaps),
                    ]),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: ClipRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Container(
                            width: 40.r, height: 40.r,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0x662A2A2C),
                              border: Border.all(color: NeoColors.outlineVariant.withValues(alpha: 0.4)),
                            ),
                            child: Icon(Icons.close, color: NeoColors.onSurface, size: 18.r),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _loading
                    ? Center(child: CircularProgressIndicator(color: NeoColors.cyan))
                    : _selectedGym != null || _memberships.isEmpty
                        ? _buildQrView(qrData, name, memberId)
                        : _buildGymPicker(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQrView(String qrData, String name, String memberId) {
    const qrSize = 220.0;
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 240.r, height: 240.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: NeoColors.cyan.withValues(alpha: 0.05),
                  ),
                ),
                Container(
                  width: qrSize.r + 48,
                  height: qrSize.r + 48,
                  padding: EdgeInsets.all(24.r),
                  decoration: BoxDecoration(
                    color: const Color(0x99141416),
                    border: Border.all(color: NeoColors.cyan.withValues(alpha: 0.4)),
                    boxShadow: [BoxShadow(color: NeoColors.cyan.withValues(alpha: 0.12), blurRadius: 40)],
                  ),
                  child: Stack(
                    children: [
                      Container(color: Colors.white, child: QrImageView(data: qrData, version: QrVersions.auto, size: qrSize.r)),
                      AnimatedBuilder(
                        animation: _scanAnim,
                        builder: (_, __) => Positioned(
                          top: (qrSize.r) * _scanAnim.value,
                          left: 0, right: 0,
                          child: Container(
                            height: 2,
                            decoration: BoxDecoration(
                              color: NeoColors.cyan,
                              boxShadow: [BoxShadow(color: NeoColors.cyan.withValues(alpha: 0.8), blurRadius: 6)],
                            ),
                          ),
                        ),
                      ),
                      _CornerBracket(corner: Alignment.topLeft),
                      _CornerBracket(corner: Alignment.topRight),
                      _CornerBracket(corner: Alignment.bottomLeft),
                      _CornerBracket(corner: Alignment.bottomRight),
                    ],
                  ),
                ),
              ],
            ),
            vGap(24),
            Text(name, style: GoogleFonts.anton(fontSize: 24.sp, color: NeoColors.onSurface)),
            vGap(4),
            Row(mainAxisSize: MainAxisSize.min, children: [
              Text('ACTIVE MEMBER', style: NeoTextStyles.labelCaps.copyWith(color: NeoColors.lime)),
              AnimatedBuilder(
                animation: _blinkAnim,
                builder: (_, __) => Opacity(
                  opacity: _blinkAnim.value,
                  child: Text(' |', style: NeoTextStyles.labelCaps.copyWith(color: NeoColors.cyan)),
                ),
              ),
            ]),
            vGap(8),
            Text('ID: $memberId', style: NeoTextStyles.dataSm),
            if (_selectedGym != null && _memberships.length > 1) ...[
              vGap(12),
              GestureDetector(
                onTap: () => setState(() => _selectedGym = null),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(border: Border.all(color: NeoColors.outline)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.swap_horiz, color: NeoColors.cyan, size: 14.r),
                    hGap(6),
                    Text('CHANGE GYM', style: NeoTextStyles.labelCaps.copyWith(color: NeoColors.cyan)),
                  ]),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGymPicker() {
    return Padding(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SELECT GYM', style: NeoTextStyles.headlineSm.copyWith(color: NeoColors.cyan)),
          vGap(16),
          ..._memberships.map((m) {
            final gym = m['gym'] as Map<String, dynamic>? ?? {};
            return GestureDetector(
              onTap: () => setState(() => _selectedGym = gym),
              child: Container(
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  color: const Color(0x66201F21),
                  border: Border.all(color: NeoColors.cyan.withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.fitness_center, color: NeoColors.cyan, size: 18.r),
                    hGap(12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text((gym['name'] ?? 'Gym').toString().toUpperCase(), style: NeoTextStyles.headlineSm),
                      Text(gym['city'] ?? '', style: NeoTextStyles.bodySm),
                    ])),
                    Icon(Icons.chevron_right, color: NeoColors.outline, size: 18.r),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _CornerBracket extends StatelessWidget {
  final Alignment corner;
  const _CornerBracket({required this.corner});

  @override
  Widget build(BuildContext context) {
    final isTop = corner == Alignment.topLeft || corner == Alignment.topRight;
    final isLeft = corner == Alignment.topLeft || corner == Alignment.bottomLeft;
    return Positioned(
      top: isTop ? 0 : null,
      bottom: isTop ? null : 0,
      left: isLeft ? 0 : null,
      right: isLeft ? null : 0,
      child: SizedBox(
        width: 20.r,
        height: 20.r,
        child: CustomPaint(
          painter: _BracketPainter(isTop: isTop, isLeft: isLeft),
        ),
      ),
    );
  }
}

class _BracketPainter extends CustomPainter {
  final bool isTop, isLeft;
  const _BracketPainter({required this.isTop, required this.isLeft});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = NeoColors.cyan..strokeWidth = 2..style = PaintingStyle.stroke;
    final path = Path();
    if (isTop && isLeft) { path.moveTo(0, size.height); path.lineTo(0, 0); path.lineTo(size.width, 0); }
    else if (isTop && !isLeft) { path.moveTo(0, 0); path.lineTo(size.width, 0); path.lineTo(size.width, size.height); }
    else if (!isTop && isLeft) { path.moveTo(0, 0); path.lineTo(0, size.height); path.lineTo(size.width, size.height); }
    else { path.moveTo(0, size.height); path.lineTo(size.width, size.height); path.lineTo(size.width, 0); }
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(_BracketPainter old) => false;
}
