import 'package:flutter/material.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/features/admin/data/admin_repository.dart';
import 'package:gym_app/features/admin/data/plan_model.dart';
import 'package:gym_app/features/admin/ui/widgets/plan_card.dart';

class PlansBody extends StatefulWidget {
  const PlansBody({super.key});

  @override
  State<PlansBody> createState() => _PlansBodyState();
}

class _PlansBodyState extends State<PlansBody> {
  List<PlanModel> _plans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await AdminRepository.getSubscriptionPlans();
      final plans = data.map((e) => PlanModel.fromJson(e as Map<String, dynamic>)).toList();
      if (mounted) setState(() { _plans = plans; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_plans.isEmpty) {
      return const Center(
        child: Text('No plans found', style: TextStyle(color: Colors.white54)),
      );
    }
    return ListView.separated(
      itemCount: _plans.length,
      separatorBuilder: (_, __) => vGap(10),
      itemBuilder: (context, index) => PlanCard(planModel: _plans[index]),
    );
  }
}
