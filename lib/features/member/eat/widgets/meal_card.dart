import 'package:flutter/material.dart';
import 'package:gym_app/core/helpers/app_decoration.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';
import 'package:gym_app/core/widgets/custom_text_feild.dart';

class MealModel {
  String time;
  String title;
  String food;

  MealModel({
    required this.time,
    required this.title,
    required this.food,
  });
}

class MealCard extends StatefulWidget {
  final MealModel meal;
  final VoidCallback onDelete;

  const MealCard({
    super.key,
    required this.meal,
    required this.onDelete,
  });

  @override
  State<MealCard> createState() => _MealCardState();
}

class _MealCardState extends State<MealCard> {
late TextEditingController nameController;
late TextEditingController foodController;


@override
  void initState() {
    // TODO: implement initState
    super.initState();
    nameController=TextEditingController(text: widget.meal.title);
    foodController=TextEditingController(text: widget.meal.food);
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.containerDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: AppDecorations.containerDecoration.copyWith(color: AppColors.primary),
                child: Text(
                  widget.meal.time,
                  style:AppTextStyles.font16WhiteRegular.copyWith(color: AppColors.emerald),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: widget.onDelete,
                icon: const Icon(Icons.delete, color: Colors.white),
              ),
            ],
          ),
          vGap(10),
          CustomTextFormField(textInputType: TextInputType.text, controller: nameController,),
          vGap(10),
          CustomTextFormField(textInputType: TextInputType.text, controller: foodController,),

        ],
      ),
    );
  }
}

