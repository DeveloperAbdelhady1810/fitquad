import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/theme/neo_theme.dart';
import 'package:gym_app/features/member/data/models/coach_model.dart';
import 'package:gym_app/features/member/data/repositories/member_repository.dart';
import 'coach_profile_screen_neo.dart';

class ChooseCoachScreenNeo extends StatefulWidget {
  final String? source;
  const ChooseCoachScreenNeo({super.key, this.source});

  @override
  State<ChooseCoachScreenNeo> createState() => _ChooseCoachScreenNeoState();
}

class _ChooseCoachScreenNeoState extends State<ChooseCoachScreenNeo> {
  List<CoachModel> _coaches = [];
  List<CoachModel> _filtered = [];
  bool _loading = true;
  String? _error;
  String _search = '';
  String _filter = 'All';
  final _filters = ['All', 'Train', 'Nutrition', 'Both'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final raw = await MemberRepository.getCoaches(source: widget.source);
      final coaches = raw.map((e) => CoachModel.fromJson(e as Map<String, dynamic>)).toList();
      if (mounted) setState(() { _coaches = coaches; _applyFilter(); _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  void _applyFilter() {
    _filtered = _coaches.where((c) {
      final matchSearch = _search.isEmpty ||
          c.name.toLowerCase().contains(_search.toLowerCase()) ||
          c.jobTitle.toLowerCase().contains(_search.toLowerCase());
      final matchFilter = _filter == 'All' ||
          (c.coachType?.toLowerCase() ?? '').contains(_filter.toLowerCase());
      return matchSearch && matchFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoColors.bg,
      appBar: AppBar(
        backgroundColor: NeoColors.bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: NeoColors.cyan),
        title: Text('FIND A COACH', style: NeoTextStyles.headlineSm.copyWith(color: NeoColors.cyan)),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: TextField(
              onChanged: (v) => setState(() { _search = v; _applyFilter(); }),
              style: GoogleFonts.jetBrainsMono(color: NeoColors.onSurface, fontSize: 14.sp),
              decoration: InputDecoration(
                hintText: 'SEARCH COACHES...',
                hintStyle: GoogleFonts.jetBrainsMono(color: NeoColors.outline, fontSize: 14.sp),
                prefixIcon: Icon(Icons.search, color: NeoColors.cyan, size: 18.r),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: NeoColors.cyan.withValues(alpha: 0.4))),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: NeoColors.cyan)),
              ),
            ),
          ),
          vGap(12),
          SizedBox(
            height: 32.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => hGap(8),
              itemBuilder: (_, i) {
                final active = _filter == _filters[i];
                return GestureDetector(
                  onTap: () => setState(() { _filter = _filters[i]; _applyFilter(); }),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: active ? NeoColors.cyan.withValues(alpha: 0.1) : Colors.transparent,
                      border: Border.all(color: active ? NeoColors.cyan : NeoColors.outline),
                    ),
                    child: Text(
                      _filters[i].toUpperCase(),
                      style: NeoTextStyles.labelCaps.copyWith(color: active ? NeoColors.cyan : NeoColors.outline),
                    ),
                  ),
                );
              },
            ),
          ),
          vGap(12),
          Expanded(
            child: _loading
                ? Center(child: CircularProgressIndicator(color: NeoColors.cyan))
                : _error != null
                    ? _ErrorView(onRetry: _load)
                    : _filtered.isEmpty
                        ? Center(child: Text('NO COACHES FOUND', style: NeoTextStyles.headlineSm.copyWith(color: NeoColors.outline)))
                        : RefreshIndicator(
                            color: NeoColors.cyan,
                            backgroundColor: NeoColors.surface,
                            onRefresh: _load,
                            child: ListView.builder(
                              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
                              itemCount: _filtered.length,
                              itemBuilder: (_, i) => _NeoCoachCard(
                                coach: _filtered[i],
                                onTap: () => Navigator.push(context, MaterialPageRoute(
                                  builder: (_) => CoachProfileScreenNeo(coach: _filtered[i]),
                                )),
                              ),
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off, color: NeoColors.outline, size: 40.r),
          vGap(12),
          Text('CONNECTION LOST', style: NeoTextStyles.headlineSm.copyWith(color: NeoColors.outline)),
          vGap(12),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              decoration: BoxDecoration(border: Border.all(color: NeoColors.cyan)),
              child: Text('RETRY', style: NeoTextStyles.labelCaps.copyWith(color: NeoColors.cyan)),
            ),
          ),
        ],
      ),
    );
  }
}

class _NeoCoachCard extends StatelessWidget {
  final CoachModel coach;
  final VoidCallback onTap;
  const _NeoCoachCard({required this.coach, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final stars = coach.rating.clamp(0, 5).toDouble();

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: GestureDetector(
        onTap: onTap,
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: const Color(0x66201F21),
                border: Border.all(color: NeoColors.cyan.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _AvatarCircle(name: coach.name, url: coach.avatarUrl),
                      hGap(12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(coach.name.toUpperCase(),
                                style: NeoTextStyles.headlineSm.copyWith(color: NeoColors.cyan)),
                            vGap(2),
                            Text(coach.jobTitle,
                                style: NeoTextStyles.bodySm.copyWith(color: NeoColors.onSurfaceVariant)),
                            vGap(4),
                            Row(
                              children: [
                                ...List.generate(5, (i) => Icon(
                                  i < stars.round() ? Icons.star_rounded : Icons.star_outline_rounded,
                                  color: NeoColors.lime,
                                  size: 13.r,
                                )),
                                hGap(4),
                                Text('(${coach.reviewsCount})',
                                    style: NeoTextStyles.dataSm.copyWith(fontSize: 11.sp)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${coach.price.toStringAsFixed(0)} EGP',
                              style: GoogleFonts.jetBrainsMono(
                                  fontSize: 16.sp, fontWeight: FontWeight.w700, color: NeoColors.lime)),
                          Text('/plan', style: NeoTextStyles.dataSm.copyWith(fontSize: 10.sp)),
                        ],
                      ),
                    ],
                  ),
                  if (coach.bio.isNotEmpty) ...[
                    vGap(10),
                    Text(coach.bio,
                        style: NeoTextStyles.bodySm,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ],
                  vGap(10),
                  Row(
                    children: [
                      if (coach.service.isNotEmpty)
                        _Tag(label: coach.service, color: NeoColors.cyan),
                      if (coach.service.isNotEmpty) hGap(6),
                      _Tag(label: coach.turnaround, color: NeoColors.magenta),
                      if (coach.coachType != null) ...[
                        hGap(6),
                        _Tag(label: coach.coachType!.toUpperCase(), color: NeoColors.lime),
                      ],
                    ],
                  ),
                  vGap(10),
                  SizedBox(
                    width: double.infinity,
                    height: 36.h,
                    child: coach.isSubscribed
                        ? Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: NeoColors.lime),
                              color: NeoColors.lime.withValues(alpha: 0.08),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle_outline, color: NeoColors.lime, size: 14.r),
                                  hGap(6),
                                  Text('SUBSCRIBED', style: NeoTextStyles.labelCaps.copyWith(color: NeoColors.lime)),
                                ],
                              ),
                            ),
                          )
                        : GestureDetector(
                            onTap: onTap,
                            child: Container(
                              decoration: BoxDecoration(
                                color: NeoColors.cyan,
                                boxShadow: [BoxShadow(color: NeoColors.cyan.withValues(alpha: 0.3), blurRadius: 10)],
                              ),
                              child: Center(
                                child: Text('VIEW PROFILE',
                                    style: GoogleFonts.anton(fontSize: 13.sp, color: Colors.black)),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  final String name;
  final String? url;
  const _AvatarCircle({required this.name, this.url});

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().split(' ').take(2).map((w) => w.isEmpty ? '' : w[0].toUpperCase()).join();
    return Container(
      width: 52.r,
      height: 52.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: NeoColors.cyan.withValues(alpha: 0.12),
        border: Border.all(color: NeoColors.cyan.withValues(alpha: 0.4), width: 1.5),
        image: url != null && url!.isNotEmpty
            ? DecorationImage(image: NetworkImage(url!), fit: BoxFit.cover,
                onError: (_, __) {})
            : null,
      ),
      child: (url == null || url!.isEmpty)
          ? Center(child: Text(initials,
              style: GoogleFonts.jetBrainsMono(
                  fontSize: 18.sp, fontWeight: FontWeight.w700, color: NeoColors.cyan)))
          : null,
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label.toUpperCase(),
          style: NeoTextStyles.labelCaps.copyWith(color: color, fontSize: 9.sp)),
    );
  }
}
