
import 'package:flutter/material.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/features/member/data/models/meal_model.dart';

class EatenTodayCard extends StatelessWidget {
  final FoodModel foodModel;
  final VoidCallback? onLogAgain;
  const EatenTodayCard({super.key, required this.foodModel, this.onLogAgain});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.grey,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          /// ✓ Circle
          Container(
            height: 28,
            width: 28,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              size: 16,
              color: Colors.black,
            ),
          ),

          const SizedBox(width: 12),

          /// Name + kcal
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  foodModel.nameEn,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${foodModel.calories} kcal",
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          /// Logged badge
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: .15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "Logged",
              style: TextStyle(
                color: Colors.green,
                fontSize: 12,
              ),
            ),
          ),

          if (onLogAgain != null) ...[
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Log again',
              onPressed: onLogAgain,
              icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 22),
            ),
          ],
        ],
      ),
    );
  }
}




