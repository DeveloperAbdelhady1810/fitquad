import 'package:flutter/material.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/features/admin/data/admin_repository.dart';
import 'package:gym_app/features/admin/ui/widgets/coach_container.dart';

class CoachesBody extends StatefulWidget {
  const CoachesBody({super.key});

  @override
  State<CoachesBody> createState() => _CoachesBodyState();
}

class _CoachesBodyState extends State<CoachesBody> {
  List<dynamic> _coaches = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await AdminRepository.getCoaches();
      if (mounted) setState(() { _coaches = data; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_coaches.isEmpty) {
      return const Center(
        child: Text('No coaches found', style: TextStyle(color: Colors.white54)),
      );
    }
    return ListView.separated(
      itemCount: _coaches.length,
      separatorBuilder: (_, __) => vGap(10),
      itemBuilder: (context, index) {
        final c = _coaches[index] as Map<String, dynamic>;
        final user = c['user'] as Map<String, dynamic>? ?? {};
        return CoachContainer(
          name: user['name'] as String? ?? 'Coach',
          specialization: c['specialization'] as String? ?? 'Personal Trainer',
          rating: (c['rating'] as num?)?.toDouble() ?? 0,
          membersCount: (c['members_count'] as num?)?.toInt() ?? 0,
          sessionsCount: (c['sessions_count'] as num?)?.toInt() ?? 0,
          isActive: c['is_active'] as bool? ?? true,
        );
      },
    );
  }
}
