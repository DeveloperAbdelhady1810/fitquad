import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/theme/neo_theme.dart';
import '../data/partner_gym_repository.dart';
import '../models/partner_gym_model.dart';
import 'gym_detail_screen_neo.dart';

class PartnerGymsScreenNeo extends StatefulWidget {
  static const routeName = '/partner-gyms-neo';

  const PartnerGymsScreenNeo({super.key});

  @override
  State<PartnerGymsScreenNeo> createState() => _PartnerGymsScreenNeoState();
}

class _PartnerGymsScreenNeoState extends State<PartnerGymsScreenNeo> {
  List<PartnerGymModel> _gyms = [];
  List<PartnerGymModel> _filtered = [];
  bool _loading = true;
  String? _error;
  String _search = '';
  String _filter = 'All';
  final _filters = ['All', 'Quiet', 'Moderate', 'Busy'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final gyms = await PartnerGymRepository.getGyms();
      if (mounted) setState(() { _gyms = gyms; _applyFilter(); _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  void _applyFilter() {
    _filtered = _gyms.where((g) {
      final matchSearch = _search.isEmpty || g.name.toLowerCase().contains(_search.toLowerCase());
      final matchFilter = _filter == 'All' || g.crowdLevel.toLowerCase() == _filter.toLowerCase();
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
        title: Text('PARTNER GYMS', style: NeoTextStyles.headlineSm.copyWith(color: NeoColors.cyan)),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: TextField(
              onChanged: (v) => setState(() { _search = v; _applyFilter(); }),
              style: GoogleFonts.jetBrainsMono(color: NeoColors.onSurface, fontSize: 14.sp),
              decoration: InputDecoration(
                hintText: 'SEARCH GYMS...',
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
                    ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Text('CONNECTION LOST', style: NeoTextStyles.headlineSm.copyWith(color: NeoColors.outline)),
                        vGap(12),
                        GestureDetector(
                          onTap: () { setState(() { _loading = true; _error = null; }); _load(); },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                            decoration: BoxDecoration(border: Border.all(color: NeoColors.cyan)),
                            child: Text('RETRY', style: NeoTextStyles.labelCaps.copyWith(color: NeoColors.cyan)),
                          ),
                        ),
                      ]))
                    : _filtered.isEmpty
                        ? Center(child: Text('NO GYMS FOUND', style: NeoTextStyles.headlineSm.copyWith(color: NeoColors.outline)))
                        : RefreshIndicator(
                            color: NeoColors.cyan,
                            backgroundColor: NeoColors.surface,
                            onRefresh: _load,
                            child: ListView.builder(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              itemCount: _filtered.length,
                              itemBuilder: (_, i) => _NeoGymCard(
                                gym: _filtered[i],
                                onTap: () async {
                                  await Navigator.push(context,
                                      MaterialPageRoute(builder: (_) => GymDetailScreenNeo(gymId: _filtered[i].id)));
                                  _load();
                                },
                              ),
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class _NeoGymCard extends StatelessWidget {
  final PartnerGymModel gym;
  final VoidCallback onTap;
  const _NeoGymCard({required this.gym, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final imgUrl = gym.profilePhotoUrl;
    final (badgeColor, badgeText) = switch (gym.crowdLevel.toLowerCase()) {
      'quiet' => (NeoColors.lime, 'QUIET'),
      'busy' || 'crowded' => (NeoColors.magenta, 'BUSY'),
      _ => (NeoColors.cyan, 'MODERATE'),
    };
    final cheapestPlan = gym.plans.isNotEmpty
        ? gym.plans.reduce((a, b) => a.price < b.price ? a : b)
        : null;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: GestureDetector(
        onTap: onTap,
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0x66201F21),
                border: Border.all(color: NeoColors.cyan.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      if (imgUrl != null)
                        SizedBox(
                          height: 160.h,
                          width: double.infinity,
                          child: Image.network(imgUrl, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(height: 160.h, color: NeoColors.surfaceHigh)),
                        )
                      else
                        Container(height: 160.h, color: NeoColors.surfaceHigh,
                          child: Center(child: Icon(Icons.fitness_center, color: NeoColors.outline, size: 40.r))),
                      Positioned(
                        top: 0, left: 0, right: 0, bottom: 0,
                        child: DecoratedBox(decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter, end: Alignment.bottomCenter,
                            colors: [Colors.transparent, NeoColors.bg.withValues(alpha: 0.8)],
                          ),
                        )),
                      ),
                      Positioned(
                        top: 8.h, right: 8.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.2),
                            border: Border.all(color: badgeColor),
                            boxShadow: [BoxShadow(color: badgeColor.withValues(alpha: 0.3), blurRadius: 6)],
                          ),
                          child: Text(badgeText, style: NeoTextStyles.labelCaps.copyWith(color: badgeColor)),
                        ),
                      ),
                      Positioned(
                        bottom: 8.h, left: 8.w,
                        child: Text(
                          '~${gym.attendanceToday} people',
                          style: GoogleFonts.jetBrainsMono(fontSize: 11.sp, color: NeoColors.onSurface),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(12.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(gym.name.toUpperCase(),
                                  style: NeoTextStyles.headlineSm.copyWith(color: NeoColors.cyan)),
                            ),
                            if (cheapestPlan != null)
                              Text('from ${cheapestPlan.price.toStringAsFixed(0)} EGP',
                                  style: NeoTextStyles.dataSm.copyWith(color: NeoColors.cyan)),
                          ],
                        ),
                        vGap(4),
                        Row(children: [
                          Icon(Icons.location_on, color: NeoColors.outline, size: 12.r),
                          hGap(4),
                          Text(gym.city, style: NeoTextStyles.bodySm),
                        ]),
                        vGap(10),
                        GestureDetector(
                          onTap: onTap,
                          child: Container(
                            width: double.infinity,
                            height: 38.h,
                            decoration: BoxDecoration(
                              color: NeoColors.cyan,
                              boxShadow: [BoxShadow(color: NeoColors.cyan.withValues(alpha: 0.3), blurRadius: 10)],
                            ),
                            child: Center(child: Text(
                              'CHECK IN',
                              style: GoogleFonts.anton(fontSize: 14.sp, color: Colors.black),
                            )),
                          ),
                        ),
                      ],
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
