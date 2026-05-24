import 'package:flutter/material.dart';
import 'package:gym_app/core/helpers/app_decoration.dart';
import 'package:gym_app/features/admin/data/admin_repository.dart';
import '../../../member/data/models/member_model.dart';

class MembersBody extends StatefulWidget {
  const MembersBody({super.key});

  @override
  State<MembersBody> createState() => _MembersBodyState();
}

class _MembersBodyState extends State<MembersBody> {
  MemberStatus? selectedFilter;
  String search = '';
  List<dynamic> _raw = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await AdminRepository.getMembers();
      if (mounted) setState(() { _raw = data; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<_MemberRow> get _members {
    return _raw.map((e) {
      final m = e as Map<String, dynamic>;
      final user = m['user'] as Map<String, dynamic>? ?? {};
      final sub = (m['active_subscription'] ?? m['latest_subscription']) as Map<String, dynamic>?;
      final plan = (sub?['plan'] as Map<String, dynamic>?)?['name'] as String?;
      final status = _parseStatus(m['status'] as String?);
      final lastCheckIn = m['last_check_in'] as String? ?? '-';
      return _MemberRow(
        name: user['name'] as String? ?? m['name'] as String? ?? '-',
        plan: plan ?? '-',
        status: status,
        lastCheckIn: lastCheckIn,
      );
    }).toList();
  }

  MemberStatus _parseStatus(String? s) {
    switch (s) {
      case 'inactive': return MemberStatus.inactive;
      case 'frozen': return MemberStatus.frozen;
      case 'expiring': return MemberStatus.expiring;
      default: return MemberStatus.active;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final filteredMembers = _members.where((m) {
      final matchesSearch =
          m.name.toLowerCase().contains(search.toLowerCase());
      final matchesFilter =
          selectedFilter == null || m.status == selectedFilter;
      return matchesSearch && matchesFilter;
    }).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.containerDecoration,
      child: Column(
        children: [
          _searchAndFilters(),
          const SizedBox(height: 16),
          _headerRow(),
          const Divider(color: Colors.white12),
          Expanded(
            child: filteredMembers.isEmpty
                ? const Center(
                    child: Text(
                      'No members found',
                      style: TextStyle(color: Colors.white38),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredMembers.length,
                    itemBuilder: (context, index) {
                      return _memberRow(filteredMembers[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ---------------- SEARCH + FILTER ----------------

  Widget _searchAndFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          onChanged: (v) => setState(() => search = v),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: ' ',
            hintStyle: const TextStyle(color: Colors.white38),
            prefixIcon: const Icon(Icons.search, color: Colors.white38),
            filled: true,
            fillColor: const Color(0xFF111827),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),

        /// filters
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _filterChip('All', null),
              const SizedBox(width: 6),
              _filterChip('Active', MemberStatus.active),
              const SizedBox(width: 6),
              _filterChip('Inactive', MemberStatus.inactive),
              const SizedBox(width: 6),
              _filterChip('Frozen', MemberStatus.frozen),
              const SizedBox(width: 6),
              _filterChip('Expiring', MemberStatus.expiring),
            ],
          ),
        ),
      ],
    );
  }

  Widget _filterChip(String label, MemberStatus? status) {
    final selected = selectedFilter == status;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => selectedFilter = status),
      selectedColor: Colors.blueAccent,
      backgroundColor: const Color(0xFF111827),
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.white54,
      ),
    );
  }

  // ---------------- HEADER ----------------

  static const _headerStyle =
  TextStyle(color: Colors.white54, fontSize: 12);

  Widget _headerRow() {
    return const Row(
      children: [
        Expanded(child: Text('Member', style: _headerStyle)),
        Expanded(child: Text('Plan', style: _headerStyle)),
        Expanded(child: Text('Status', style: _headerStyle)),
        Expanded(child: Text('Last Check-in', style: _headerStyle)),
        SizedBox(width: 90),
      ],
    );
  }

  // ---------------- MEMBER ROW ----------------

  Widget _memberRow(_MemberRow m) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(m.name, style: const TextStyle(color: Colors.white)),
          ),
          Expanded(
            child: Text(m.plan, style: const TextStyle(color: Colors.white70)),
          ),
          Expanded(child: _statusBadge(m.status)),
          Expanded(
            child: Text(
              m.lastCheckIn,
              style: const TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text(
              'View Profile',
              style: TextStyle(color: Colors.blueAccent),
            ),
          ),
        ],
      ),
    );
  }


  Widget _statusBadge(MemberStatus status) {
    final (Color color, String text) = switch (status) {
      MemberStatus.active => (Colors.green, 'Active'),
      MemberStatus.inactive => (Colors.red, 'Inactive'),
      MemberStatus.frozen => (Colors.orange, 'Frozen'),
      MemberStatus.expiring => (Colors.purple, 'Expiring'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 12)),
    );
  }
}

class _MemberRow {
  final String name;
  final String plan;
  final MemberStatus status;
  final String lastCheckIn;

  const _MemberRow({
    required this.name,
    required this.plan,
    required this.status,
    required this.lastCheckIn,
  });
}
