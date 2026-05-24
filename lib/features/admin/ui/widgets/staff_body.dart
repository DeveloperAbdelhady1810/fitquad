import 'package:flutter/material.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';
import 'package:gym_app/features/admin/data/admin_repository.dart';

class StaffBody extends StatefulWidget {
  const StaffBody({super.key});

  @override
  State<StaffBody> createState() => _StaffBodyState();
}

class _StaffBodyState extends State<StaffBody> {
  List<dynamic> _staff = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await AdminRepository.getStaff();
      if (mounted) setState(() { _staff = data; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF111A2E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Staff Management',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.person_add, size: 16),
                  label: Text('Add Staff', style: AppTextStyles.font14WhiteRegular),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const StaffHeaderRow(),
            const Divider(color: Colors.white12),
            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_staff.isEmpty)
              const Expanded(
                child: Center(
                  child: Text('No staff members', style: TextStyle(color: Colors.white54)),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _staff.length,
                  itemBuilder: (_, i) {
                    final s = _staff[i] as Map<String, dynamic>;
                    final user = s['user'] as Map<String, dynamic>? ?? {};
                    final name = user['name'] as String? ?? 'Staff';
                    final position = s['position'] as String? ?? '-';
                    final branch = (s['branch'] as Map<String, dynamic>?)?['name'] as String? ?? 'Main';
                    return StaffRow(name: name, role: position, access: branch);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class StaffHeaderRow extends StatelessWidget {
  const StaffHeaderRow({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(flex: 3, child: Text('Name', style: TextStyle(color: Colors.grey, fontSize: 12))),
        Expanded(flex: 2, child: Text('Role', style: TextStyle(color: Colors.grey, fontSize: 12))),
        Expanded(flex: 3, child: Text('Branch', style: TextStyle(color: Colors.grey, fontSize: 12))),
        Expanded(child: Text('Actions', style: TextStyle(color: Colors.grey, fontSize: 12))),
      ],
    );
  }
}

class StaffRow extends StatelessWidget {
  final String name;
  final String role;
  final String access;

  const StaffRow({
    super.key,
    required this.name,
    required this.role,
    required this.access,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(name, style: const TextStyle(color: Colors.white)),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .05),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(role, style: const TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(access, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            child: TextButton(
              onPressed: () {},
              child: const Text('Edit', style: TextStyle(color: Colors.blue)),
            ),
          ),
        ],
      ),
    );
  }
}
