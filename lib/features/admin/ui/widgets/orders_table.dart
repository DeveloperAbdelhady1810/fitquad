import 'package:flutter/material.dart';
import 'package:gym_app/features/admin/data/admin_repository.dart';

class OrdersTable extends StatefulWidget {
  const OrdersTable({super.key});

  @override
  State<OrdersTable> createState() => _OrdersTableState();
}

class _OrdersTableState extends State<OrdersTable> {
  List<dynamic> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await AdminRepository.getOrders();
      if (mounted) setState(() { _orders = data; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111A2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Orders',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_orders.isEmpty)
            const Expanded(
              child: Center(
                child: Text('No orders', style: TextStyle(color: Colors.white54)),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _orders.length,
                itemBuilder: (_, i) {
                  final o = _orders[i] as Map<String, dynamic>;
                  final member = o['member'] as Map<String, dynamic>? ?? {};
                  final user = member['user'] as Map<String, dynamic>? ?? {};
                  final customer = user['name'] as String? ?? 'Member';
                  final status = o['status'] as String? ?? 'pending';
                  final total = (o['total'] as num?)?.toStringAsFixed(2) ?? '0.00';
                  final id = '#${o['id']}';
                  return OrderRow(
                    orderId: id,
                    status: _capitalize(status),
                    customer: customer,
                    total: '\$$total',
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}

class OrderRow extends StatelessWidget {
  final String orderId;
  final String status;
  final String customer;
  final String total;

  const OrderRow({
    super.key,
    required this.orderId,
    required this.status,
    required this.customer,
    required this.total,
  });

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'completed': return Colors.green;
      case 'pending': return Colors.orange;
      default: return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(orderId, style: const TextStyle(color: Colors.white)),
          ),
          Expanded(
            child: Chip(
              label: Text(status),
              backgroundColor: statusColor.withValues(alpha: .2),
              labelStyle: TextStyle(color: statusColor),
            ),
          ),
          Expanded(
            child: Text(customer, style: const TextStyle(color: Colors.white)),
          ),
          Expanded(
            child: Text(total, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
