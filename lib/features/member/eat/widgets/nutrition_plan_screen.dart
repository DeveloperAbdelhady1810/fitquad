import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/core/helpers/app_decoration.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';
import 'package:gym_app/core/widgets/custom_button.dart';

import '../../../../generated/l10n.dart';
import 'meal_card.dart';
import 'nutrition_overview_screen.dart';

class NutritionPlanScreen extends StatefulWidget {
  const NutritionPlanScreen({super.key});
  static const String routeName='/nutrition-plan';

  @override
  State<NutritionPlanScreen> createState() => _NutritionPlanScreenState();
}

class _NutritionPlanScreenState extends State<NutritionPlanScreen> {
  final List<MealModel> meals = [
    MealModel(time: '08:00 AM', title: 'Breakfast', food: 'Oatmeal'),
    MealModel(time: '01:00 PM', title: 'Lunch', food: 'Chicken & Rice'),
    MealModel(time: '07:00 PM', title: 'Dinner', food: 'Fish & Veggies'),
  ];

  void addMeal() {
    DateTime newTime;

    if (meals.isNotEmpty) {
      final lastMealTime = parseTime(meals.last.time);
      newTime = lastMealTime.add(const Duration(hours: 3));
    } else {
      newTime = DateTime.now();
    }

    setState(() {
      meals.add(
        MealModel(
          time: formatTime(newTime),
          title: 'New Meal',
          food: '',
        ),
      );
    });
  }

  void removeMeal(int index) {
    setState(() {
      meals.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final s =S.of(context);
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title:  Text(s.nutrition_plan,style: AppTextStyles.font16WhiteBold,),
         iconTheme: IconThemeData(color: AppColors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: meals.length,
              itemBuilder: (context, index) {
                return MealCard(
                  meal: meals[index],
                  onDelete: () => removeMeal(index),
                );
              },
            ),
          ),

          /// Add Meal
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: addMeal,
              child: Container(
                height: 50,
                decoration: AppDecorations.containerDecoration.copyWith(color: AppColors.primary),
                child:  Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: Colors.white),
                      hGap(5),
                      Text(s.add_meal, style: AppTextStyles.font16WhiteBold),
                    ],
                  ),
                ),
              ),
            ),
          ),
   vGap(10),
          /// Save Button
         Padding(
           padding: const EdgeInsets.symmetric(horizontal: 16),
           child: CustomButton(text: s.save_plan, onPressed: () {
             context.push(
               NutritionOverviewScreen.routeName,
               extra: meals,
             );
           },),
         )
        ],
      ),
    );
  }
}


DateTime parseTime(String time) {
  final now = DateTime.now();
  final format = time.split(' ');
  final hourMin = format[0].split(':');

  int hour = int.parse(hourMin[0]);
  int minute = int.parse(hourMin[1]);
  final isPm = format[1] == 'PM';

  if (isPm && hour != 12) hour += 12;
  if (!isPm && hour == 12) hour = 0;

  return DateTime(now.year, now.month, now.day, hour, minute);
}

String formatTime(DateTime time) {
  final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
  final minute = time.minute.toString().padLeft(2, '0');
  final period = time.hour >= 12 ? 'PM' : 'AM';

  return '$hour:$minute $period';
}