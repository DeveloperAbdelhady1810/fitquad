import 'package:flutter/material.dart';
import 'package:gym_app/features/admin/data/admin_repository.dart';

class ProductsTable extends StatefulWidget {
  const ProductsTable({super.key});

  @override
  State<ProductsTable> createState() => _ProductsTableState();
}

class _ProductsTableState extends State<ProductsTable> {
  List<dynamic> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await AdminRepository.getProducts();
      if (mounted) setState(() { _products = data; _isLoading = false; });
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Inventory',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Product'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_products.isEmpty)
            const Expanded(
              child: Center(
                child: Text('No products', style: TextStyle(color: Colors.white54)),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _products.length,
                itemBuilder: (_, i) {
                  final p = _products[i] as Map<String, dynamic>;
                  final name = p['name'] as String? ?? '-';
                  final stock = '${p['stock_qty'] ?? 0} units';
                  final price = '\$${(p['price'] as num?)?.toStringAsFixed(2) ?? '0.00'}';
                  return ProductRow(name: name, stock: stock, price: price);
                },
              ),
            ),
        ],
      ),
    );
  }
}

class ProductRow extends StatelessWidget {
  final String name;
  final String stock;
  final String price;

  const ProductRow({
    super.key,
    required this.name,
    required this.stock,
    required this.price,
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
          Expanded(child: Chip(label: Text(stock))),
          Expanded(
            child: Text(price, style: const TextStyle(color: Colors.white)),
          ),
          const Icon(Icons.edit, color: Colors.grey),
        ],
      ),
    );
  }
}
