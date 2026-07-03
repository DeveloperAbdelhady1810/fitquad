import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/services/api_client.dart';
import 'package:gym_app/core/theme/neo_theme.dart';

class NotificationsScreenNeo extends StatefulWidget {
  const NotificationsScreenNeo({super.key});

  @override
  State<NotificationsScreenNeo> createState() => _NotificationsScreenNeoState();
}

class _NotificationsScreenNeoState extends State<NotificationsScreenNeo> {
  List<Map<String, dynamic>> _notifications = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await ApiClient.get('/member/notifications');
      final raw = res['data'];
      final list = raw is List
          ? raw
          : raw is Map
              ? (raw['data'] as List? ?? [])
              : <dynamic>[];
      if (mounted) setState(() { _notifications = list.cast<Map<String, dynamic>>(); _loading = false; });
      _markRead();
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _markRead() async {
    try { await ApiClient.post('/member/notifications/read', {}); } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoColors.bg,
      appBar: AppBar(
        backgroundColor: NeoColors.bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: NeoColors.cyan),
        title: Text('NOTIFICATIONS', style: NeoTextStyles.headlineMd.copyWith(color: NeoColors.cyan)),
        actions: [
          TextButton(
            onPressed: _markRead,
            child: Text('MARK ALL READ', style: NeoTextStyles.labelCaps.copyWith(color: NeoColors.cyan)),
          ),
        ],
      ),
      body: Stack(
        children: [
          IgnorePointer(
            child: Positioned.fill(
              child: Stack(
                children: [
                  Positioned(
                    top: -40,
                    right: -40,
                    child: Container(
                      width: 200.r,
                      height: 200.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: NeoColors.cyan.withValues(alpha: 0.06),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 60,
                    left: -60,
                    child: Container(
                      width: 180.r,
                      height: 180.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: NeoColors.magenta.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildBody(),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return Center(child: CircularProgressIndicator(color: NeoColors.cyan));
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off, color: NeoColors.outline, size: 40.r),
            vGap(12),
            Text('CONNECTION LOST', style: NeoTextStyles.headlineSm.copyWith(color: NeoColors.outline)),
            vGap(12),
            GestureDetector(
              onTap: () { setState(() { _loading = true; _error = null; }); _load(); },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                decoration: BoxDecoration(border: Border.all(color: NeoColors.cyan)),
                child: Text('RETRY', style: NeoTextStyles.labelCaps.copyWith(color: NeoColors.cyan)),
              ),
            ),
          ],
        ),
      );
    }
    if (_notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_none_rounded, color: NeoColors.outline, size: 48.r),
            vGap(12),
            Text('NO SIGNALS DETECTED', style: NeoTextStyles.headlineSm.copyWith(color: NeoColors.outline)),
            vGap(6),
            Text('No notifications yet', style: NeoTextStyles.bodySm),
          ],
        ),
      );
    }
    return RefreshIndicator(
      color: NeoColors.cyan,
      backgroundColor: NeoColors.surface,
      onRefresh: () async { setState(() => _loading = true); await _load(); },
      child: ListView.builder(
        padding: EdgeInsets.all(16.r),
        itemCount: _notifications.length,
        itemBuilder: (_, i) => _NeoNotifTile(data: _notifications[i]),
      ),
    );
  }
}

class _NeoNotifTile extends StatefulWidget {
  final Map<String, dynamic> data;
  const _NeoNotifTile({required this.data});

  @override
  State<_NeoNotifTile> createState() => _NeoNotifTileState();
}

class _NeoNotifTileState extends State<_NeoNotifTile> with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.4, end: 1.0).animate(_pulse);
  }

  @override
  void dispose() { _pulse.dispose(); super.dispose(); }

  static (IconData, Color) _typeStyle(String type) {
    switch (type.toLowerCase()) {
      case 'workout': case 'training': return (Icons.fitness_center, NeoColors.cyan);
      case 'coach': case 'message': return (Icons.person, NeoColors.cyan);
      case 'nutrition': case 'meal': return (Icons.restaurant, NeoColors.magenta);
      case 'achievement': case 'badge': return (Icons.star_rounded, NeoColors.lime);
      case 'payment': return (Icons.receipt_long, NeoColors.magenta);
      default: return (Icons.notifications, NeoColors.onSurfaceVariant);
    }
  }

  static String _timeAgo(String? raw) {
    if (raw == null) return '';
    final dt = DateTime.tryParse(raw); if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'NOW';
    if (diff.inMinutes < 60) return '${diff.inMinutes}M AGO';
    if (diff.inHours < 24) return '${diff.inHours}H AGO';
    if (diff.inDays == 1) return 'YESTERDAY';
    return '${diff.inDays}D AGO';
  }

  @override
  Widget build(BuildContext context) {
    final type = widget.data['type'] as String? ?? 'general';
    final (icon, color) = _typeStyle(type);
    final title = widget.data['title'] as String? ?? 'Notification';
    final body = widget.data['body'] as String? ?? '';
    final time = _timeAgo(widget.data['created_at'] as String?);
    final isRead = widget.data['read_at'] != null;

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Opacity(
        opacity: isRead ? 0.8 : 1.0,
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: const Color(0x66201F21),
                border: Border.all(color: isRead ? const Color(0x1500DCE6) : NeoColors.cyan.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 40.r, height: 40.r,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          border: Border.all(color: color.withValues(alpha: 0.25)),
                        ),
                        child: Icon(icon, color: color, size: 18.r),
                      ),
                      if (!isRead)
                        Positioned(
                          top: -3, right: -3,
                          child: FadeTransition(
                            opacity: _opacity,
                            child: Container(
                              width: 8.r, height: 8.r,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: NeoColors.cyan,
                                boxShadow: [BoxShadow(color: NeoColors.cyan.withValues(alpha: 0.6), blurRadius: 4)],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  hGap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(child: Text(title, style: NeoTextStyles.bodyLg.copyWith(
                            color: isRead ? NeoColors.onSurface : NeoColors.cyan,
                            fontWeight: isRead ? FontWeight.w400 : FontWeight.w700,
                          ))),
                          Text(time, style: NeoTextStyles.dataSm),
                        ]),
                        if (body.isNotEmpty) ...[
                          vGap(4),
                          Text(body, style: NeoTextStyles.bodySm, maxLines: 2, overflow: TextOverflow.ellipsis),
                        ],
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
